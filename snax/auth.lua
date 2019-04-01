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

local function genverifycode()
    return math.random(0,9) .. math.random(0,9) .. math.random(0,9) .. math.random(0,9)
end

local function checkrepeat(cellphone)
    local isrepeat = false

    for fd, infos in pairs(client) do
        if infos.cellphone == cellphone and (skynet.now() - infos.issuetime) < 100 * 180  then
            isrepeat = true
            break
        end
    end

    return isrepeat
end

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
    skynet.error('[auth] client disconnect while auth...')
    -- client[fd] = nil
end

function REQUEST.verifycode(fd, args)
    client[fd] = {}
    local phonenum = args.cellphone
    local errcode = errs.code.SUCCESS
    local verifycode = 0

    if not phonenum or #phonenum ~= 11 or string.sub(phonenum,1,1) ~= '1' then
        errcode = errs.code.INVALID_PHONE_NUMBER
    end

    --check repeat operation
    if checkrepeat(phonenum) then
        errcode = errs.code.OPERATOR_TOO_FAST
    else
        --generate verifycode
        verifycode = genverifycode()

        --todo: request third part message service to send verifycode

        --save client's phone number and verifycode
        client[fd].verifycode = verifycode
        client[fd].cellphone = phonenum
        client[fd].issuetime = skynet.now()
        skynet.error(' verifycode :' .. verifycode)
    end

    return { errcode = errcode }
end

function REQUEST.register(fd,args)
    local c = assert(client[fd])
    local errcode = errs.code.SUCCESS

    if not c.verifycode then
        errcode = errs.code.NO_VERIFYCODE_ISSUES
    end

    if args.verifycode ～= c.verifycode then
        errcode = errs.code.INVALID_VERIFYCODE
    end



end

function REQUEST.login(fd,args)
    local c = client[fd] or {}

end

