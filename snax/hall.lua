local skynet = require "skynet"
local snax = require "skynet.snax"
local sproto = require "sproto"
local utils = require "utils"
local errs = require "errorcode"
local playermanager = require "playermanager"

local sp_host
local sp_request

function init(...)
    sp_host = sproto.new( utils.loadproto("./proto/hall_c2s.sp") ):host "package"
    sp_request = sp_host:attach(sproto.new( utils.loadproto("./proto/hall_s2c.sp") ))
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
    skynet.error('[hall] client disconnected ...')
    
end