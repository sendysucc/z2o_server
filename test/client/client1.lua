package.cpath = './3rd/skynet/luaclib/?.so'
package.path = './3rd/skynet/lualib/?.lua;' .. './utils/?.lua;'

local socket = require "client.socket"
local sproto = require "sproto"
local crypt = require "client.crypt"
local parser = require "sprotoparser"
-- local utils = require "utils"
local cjson = require "cjson"

local session = 0
local secret = nil
local last = ""

local utils = {}
utils.loadproto = function(protofile)
    local f = assert(io.open(protofile))
    local data = f:read 'a'
    f:close()
    return parser.parse(data)
end


print('=-------------------cjson')
ta = {}
ta.name ='hansen'
ta.age = 28
print(cjson.encode(ta))


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


send_request("register",{ cellphone='18565671320', password='hansen', verifycode = '7812', referrer='' ,agentcode='' })
res = receive_data()
print('[register] errcode:', res.errcode)


send_request("login", { cellphone = '18565671320', password = 'hansen' })
res = receive_data()
print('[login] :')
for k,v in pairs(res) do
    print(k,v)
end

os.execute('sleep 3')

host = sproto.new( utils.loadproto("./proto/hall_s2c.sp") ):host "package"
request = host:attach( sproto.new(utils.loadproto("./proto/hall_c2s.sp") ))

send_request('gamelist')
res = receive_data()
print('[gamelist]:')
for k,v in pairs(res.games) do
    if type(v) == 'table' then
        for _k, _v in pairs(v) do
            print(_k,_v)
        end

    end
end

send_request('roomlist',{gameid=200})
res = receive_data()
local rooms = res.rooms
print('[roomlist]:')
for k,v in pairs(res.rooms) do
    print('===?room:',v)
    if type(v) == 'table' then
        for _k,_v in pairs(v) do
            print(_k,_v)
        end
    end
end

os.execute('sleep 2')

send_request('logout')
res = receive_data()
print('[logout]: errcode:',res.errcode)

os.execute('sleep 1')

host = sproto.new( utils.loadproto("./proto/auth_s2c.sp") ):host "package"
request = host:attach( sproto.new(utils.loadproto("./proto/auth_c2s.sp") ))

--register again
send_request('verifycode', { cellphone = '18565671320'})
res = receive_data()
local verifycode = res.vcode
print('[verifycode] vcode:',verifycode)

os.execute("sleep 1")

send_request("register", { cellphone='18565672920', password='hansen', verifycode = '7812', referrer='' ,agentcode=''  })
res = receive_data()
print('[register] errcode:', res.errcode)

os.execute("sleep 2")

send_request("login", { cellphone = '18565672920', password = 'hansen' })
res = receive_data()
print('[login] :')
for k,v in pairs(res) do
    print(k,v)
end

if res.gameid and res.roomid then
    host = sproto.new( utils.loadproto("./proto/brnn_s2c.sp") ):host "package"
    request = host:attach( sproto.new(utils.loadproto("./proto/brnn_c2s.sp") ))

    send_request("gamestatus")
    res = receive_data()
    print('[gamestatus] errcode: ',res.errcode)

    os.execute('sleep 3')
else
    host = sproto.new( utils.loadproto("./proto/hall_s2c.sp") ):host "package"
    request = host:attach( sproto.new(utils.loadproto("./proto/hall_c2s.sp") ))

    send_request("loadrobot")
    res = receive_data()
    print('[loadrobot] errcode:', res.errcode)

    t = { gameid = rooms[1].gameid, roomid = rooms[1].id}
    print('---------->:', cjson.encode(t))
    send_request('joinroom', t)
    res = receive_data()
    print('[joinroom] errcode:', res.errcode)

    os.execute('sleep 3')

    host = sproto.new( utils.loadproto("./proto/brnn_s2c.sp") ):host "package"
    request = host:attach( sproto.new(utils.loadproto("./proto/brnn_c2s.sp") ))

    send_request("gamestatus")
    res = receive_data()
    print('[gamestatus] errcode: ',res.errcode)

    os.execute('sleep 3')
end
