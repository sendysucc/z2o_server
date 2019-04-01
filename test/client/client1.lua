package.cpath = './3rd/skynet/luaclib/?.so'
package.path = './3rd/skynet/lualib/?.lua;' .. './utils/?.lua;'

local socket = require "client.socket"
local sproto = require "sproto"
local crypt = require "client.crypt"
local utils = require "utils"

local session = 0
local secret = nil
local last = ""

local host = sproto.new( utils.loadproto("./proto/handshake_s2c.sp") ):host "package"
local request = host:attach( sproto.new(utils.loadproto("./proto/handshake_c2s.sp") ))
local fd = assert(socket.connect('127.0.0.1',12288))

local function send_package(fd,pack)
    local package = string.pack('>s2',pack)
    socket.send(fd,package)
end

local function send_request(name,args)
    session = session + 1
    print('--->proto: ',name)
    local str = request(name,args,session)
    if secret then
        str = crypt.desencode(secret,str)
    end
    str = crypt.base64encode(str)
    send_package(fd,str)
end

local function unpack_package(text)
    local size = #text
    if size < 2 then
        return nil, text
    end
    local s = text:byte(1)*256 + text:byte(2)
    if size < s + 2 then
        return nil,text
    end
    return text:sub(3,2+s),text:sub(3+s)
end

local function recv_package(last)
    local result
    result,last = unpack_package(last)
    if result then
        return result,last
    end
    local r = socket.recv(fd)
    if not r then
       return nil,last 
    end
    if r == '' then
        error "server closed"
    end
    return unpack_package(last .. r)
end

local function dispatch_package()
    while true do
        local v 
        v,last = recv_package(last)
        if not v then
            break
        end
        v = crypt.base64decode(v)

        if secret then
            v = crypt.desdecode(secret,v)
        end
        local resType,name,args = host:dispatch(v)
        return args
    end
end

local function receive_data()
    local rets = nil
    while true do
        rets = dispatch_package()
        if rets then
            break
        end
    end
    return rets
end

send_request('handshake')
local res = receive_data()
local challenge = res.challenge
print('[handshake] challenge:',challenge)


local clientkey = crypt.randomkey()
send_request('exkey', {ckey = crypt.dhexchange(clientkey)})
res = receive_data()
local serverkey = res.skey
print('[exkey] skey:',serverkey)


local tempsecret = crypt.dhsecret(serverkey,clientkey)
send_request('exsec',{ cse = crypt.hmac64(challenge,tempsecret) })
res = receive_data()
local errcode = res.errcode
print('[exsec] errcode:',errcode)

secret = tempsecret

os.execute('sleep 1')

host = sproto.new( utils.loadproto("./proto/auth_s2c.sp") ):host "package"
request = host:attach( sproto.new(utils.loadproto("./proto/auth_c2s.sp") ))

send_request('verifycode', { cellphone = '18565671320'})
res = receive_data()
local verifycode = res.vcode
print('[verifycode] vcode:',verifycode)
