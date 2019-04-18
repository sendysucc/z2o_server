local skynet = require "skynet"
local snax = require "skynet.snax"
local gamedata = require "gamedata"
local roomdata = require "roomdata"
local errs = require "errorcode"
local sproto = require "sproto"
local utils = require "utils"
local playermanager = require "playermanager"

local seats = {}
local sp_host
local sp_request
local gameid
local roomid 
local REQUEST = {}


function init(...)
    gameid,roomid = ...

    skynet.error('---------->start:' .. roomid .. ' type:' .. type(roomid))

    for i = 1, gamedata[gameid].maxplayer do
        seats[i] = nil
    end

    sp_host = sproto.new( utils.loadproto("./proto/brnn_c2s.sp") ):host "package"
    sp_request = sp_host:attach(sproto.new( utils.loadproto("./proto/brnn_s2c.sp") ))

end

function response.message(userid,msg,sz)
    local msgtype,msgname,args,response = sp_host:dispatch(msg,sz)
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

function response.disconnect(userid)
    skynet.error('[brnn] client disconnected .. id:', userid)
    playermanager.offline(userid)
end


function accept.addPlayer(userinfo)
    local available_pos = {}
    for i =1, gamedata[gameid].maxplayer do
        if not seats[i] then
            table.insert(available_pos,i)
        end
    end

    local pos = available_pos[math.random(#available_pos)]

    seats[pos] = userinfo

    --forward message to this game service
    local addr = skynet.queryservice('gated')
    local selfobj = snax.self()
    print('---------------->userid:', userinfo.userid)
    skynet.send(addr,'lua','forward',userinfo.userid, selfobj.handle, selfobj.type)

    playermanager.setplayinggame(userinfo.userid, selfobj.handle, selfobj.type )


end

--获取游戏信息
function REQUEST.gamestatus(userid,args)
    print('------------->[brnn] get game status')
    return {errcode = errs.code.SUCCESS}
end

--退出游戏
function REQUEST.quit(userid)

end