local skynet = require "skynet"
local snax = require "skynet.snax"
local sproto = require "sproto"
local crypt = require "skynet.crypt"
local utils = require "utils"

local sp_host
local sp_request
local client = {}
local REQUEST = {}

function init(...)
    sp_host = sproto.new( utils.loadproto("./proto/auth_c2s.sp") ):host "package"
    sp_request = sp_host:attach(sproto.new( utils.loadproto("./proto/auth_s2c.sp") ))
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
        end
        return nil
    else

    end
end

function response.disconnect(fd)

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
    return {skey = c.serverkey}
end

function REQUEST.exsec(fd, args)
    local c = assert(client[fd])
    local chmac = args.cse
    local tmpsec = crypt.dhsecret(c.clientkey,c.serverkey)
    local shmac = crypt.hmac64(c.challenge,tmpsec)
    local errcode = errs.code.SUCCESS
    if shmac ~= chmac then
        errcode = errs.code.HANDSHAKEERROR
    end
    return { errcode = errcode}
end

function REQUEST.verifycode(fd, args)

end


