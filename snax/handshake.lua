local skynet = require "skynet"
local snax = require "skynet.snax"
local sproto = require "sproto"
local crypt = require "skynet.crypt"
local utils = require "utils"
local errs = require "errorcode"

local sp_host
local sp_request
local client = {}
local REQUEST = {}
local authers = {}
local auther_count = 6
local indicator = 0

local function alloc_auth()
    indicator = indicator + 1
    indicator = indicator % auther_count 
    return authers[indicator]
end

function init(...)
    sp_host = sproto.new(utils.loadproto('./proto/handshake_c2s.sp')):host "package"
    sp_request = sp_host:attach(sproto.new( utils.loadproto("./proto/handshake_s2c.sp")))

    for i = 0, auther_count - 1 do
        authers[i] = snax.newservice('auth')
    end
end

function response.message(fd,msg,sz)
    local msgtype, msgname, args, response = sp_host:dispatch(msg,sz)
    if msgtype == 'REQUEST' then
        local f = REQUEST[msgname]
        if f then
            local resp = f(fd,args)
            if response then
                return response(resp)
            end
        else
            --todo:close client connection

        end
    end
end

function response.disconnect(fd)
    skynet.error("[handshake] client disconnect while handshake ....")
    client[fd] = nil
end

function response.getauth()
    local auth = alloc_auth()
    return auth.handle,auth.type
end

function REQUEST.handshake(fd,args)
    challenge = crypt.randomkey()
    client[fd] = {
        challenge = challenge
    }

    return { challenge = challenge }
end

function REQUEST.exkey(fd,args)
    local c = assert(client[fd])
    c.clientkey = args.ckey
    c.serverkey = crypt.randomkey()
    return {skey = crypt.dhexchange(c.serverkey)}
end

function REQUEST.exsec(fd, args)
    local c = assert(client[fd])
    local chmac = args.cse
    local tmpsec = crypt.dhsecret(c.clientkey,c.serverkey)
    local shmac = crypt.hmac64(c.challenge,tmpsec)
    local errcode = errs.code.SUCCESS
    if shmac ~= chmac then
        errcode = errs.code.HANDSHAKE_ERROR
    end

    --send secret to gated
    skynet.timeout(5, function()
        local addr = skynet.queryservice('gated')
        if addr then
            local authobj = alloc_auth()
            skynet.send(addr,'lua','forward',fd,authobj.handle,authobj.type)
            skynet.send(addr,'lua','crypted',fd,tmpsec)

            skynet.error(" auth handle :" .. authobj.handle)

        end
        client[fd] = nil
    end)
    
    return { errcode = errcode}
end

