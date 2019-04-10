local skynet = require "skynet"
local snax = require "skynet.snax"
local sproto = require "sproto"
local utils = require "utils"
local errs = require "errorcode"
local playermanager = require "playermanager"
local gamemanager = require "gamemanager"

local sp_host
local sp_request
local REQUEST = {}

function init(...)
    sp_host = sproto.new( utils.loadproto("./proto/hall_c2s.sp") ):host "package"
    sp_request = sp_host:attach(sproto.new( utils.loadproto("./proto/hall_s2c.sp") ))
end

function response.message(userid,msg,sz)
    local msgtype, msgname, args, response = sp_host:dispatch(msg,sz)
    if msgtype == 'REQUEST' then
        local f = REQUEST[msgname]
        if f then
            local resp = f(userid,args)
            if response then
                return response(resp)
            end
        end
        return nil
    else

    end
end

function response.disconnect(id)
    skynet.error('[hall] client disconnected ... id:', id)
    playermanager.offline(id)
end

--游戏列表
function REQUEST.gamelist(uid,args)
    local res = {}
    res.games = gamemanager.gamelist()
    if #res.games <= 0 then
        res.errcode = errs.code.PLATFOMR_MAINTENANCE
    else
        res.errcode = errs.code.SUCCESS
    end
    
    return res
end

--房间列表
function REQUEST.roomlist(uid,args)
    local res = {}
    res.rooms = gamemanager.roomlist(args.gameid or 0)
    if #res.rooms <=0 then
        res.errcode = errs.code.GAME_MAINTENANCE
    else
        res.errcode = errs.code.SUCCESS
    end
    return res
end

--邮件列表
function REQUEST.maillist(uid,args)

end

--通知列表
function REQUEST.noticelist(uid,args)

end

--充值
function REQUEST.charge(uid,args)

end

--注销登陆
function REQUEST.logout(uid,args)
    playermanager.offline(uid)
    
    --forward to auth service
    local addr = skynet.queryservice('gated')
    local auth_handle,auth_type = snax.queryservice('handshake').req.getauth()
    print('----------->logout :',uid,'gated addr:',addr)
    skynet.send(addr,'lua','forward',-1,auth_handle,auth_type,uid)

    return { errcode = errs.code.SUCCESS }
end

--加入游戏
function REQUEST.joinroom(uid,args)

end

--test
function REQUEST.loadrobot()
    playermanager.loadrobot2redis()
    return { errcode = errs.code.SUCCESS }
end