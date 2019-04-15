local skynet = require "skynet"
local snax = require "skynet.snax"
local utils = require "utils"
local playermanager = require "playermanager"
local gamedata = require "gamedata"
local roomdata = require "roomdata"

local gameservices = {}

function init(...)
    --创建所有百人类房间
    for rid, roomitem in pairs(roomdata) do
        if roomitem.gamemode == 1 and (roomitem.sNum or 0) > 1  then    --创建百人类游戏
            local gid = roomitem.gameid

            gameservices[gid] = gameservices[gid] or {}
            gameservices[gid][rid] = gameservices[gid][rid] or {}
            
            local serviceNum = roomitem.sNum
            while serviceNum > 0 do
                local gobj = snax.newservice(roomitem.gametype,rid)
                local t = {}
                t.obj = gobj
                t.onlines = 0
                table.insert(gameservices[gid][rid],t)

                serviceNum = serviceNum - 1
            end
            
        end
    end

end

local function createnewservice(gameid,roomid)
    local roomitem = roomdata[roomid]
    if not roomitem then
        return errs.code.FAILED,nil
    end

    if roomitem.status ~= 1 then
        return errs.code.ROOM_MAINTENANCE,nil
    end

    gameservices[gameid] = gameservices[gameid] or {}
    gameservices[gameid][roomid] = gameservices[gameid][roomid] or {}
    local gameobj = snax.newservice(roomitem.gametype, roomid)
    local t = {}
    t.obj = gameobj
    t.onlines = 0
    table.insert(gameservices[gameid][roomid],t)
    return errs.code.SUCCESS, t
end

--创建新的游戏服务
function response.newgameservice(gameid,roomid)
    return createnewservice(gameid,roomid)
end

--关闭游戏服务
function accept.shutdowngameservice(handle,gametype)
    local gobj = snax.bind(handle,gametype)
    if gobj then
        gobj.exit()
    end
end

function accept.increaseonline(gameid,roomid,handle,count)
    count = count or 1
    if gameservices[gameid] and gameservices[gameid][roomid] then
        services = gameservices[gameid][roomid]

        for _, service in pairs(services) do
            if service.obj.handle == handle then
                service.onlines = service.onlines + count
                skynet.error('gameservice : ' .. service.obj.handle .. ", online increase: " .. count .. ", onlines is ：" .. service.onlines)
                break
            end

        end
    end
end

function response.getservice(gameid,roomid)
    local gameinfo = gamedata[gameid]
    local roominfo = roomdata[roomid]
    local maxplayer = gameinfo.maxplayer

    if (not gameinfo) or (gameinfo.status ~= 1 ) then
        return errs.code.GAME_MAINTENANCE, nil
    end

    if (not roominfo) or (roominfo.status ~= 1) then
        return errs.code.ROOM_MAINTENANCE,nil
    end

    if gameservices[gameid] and gameservices[gameid][roomid] then   --game service already exists
        for _,srv in pairs(gameservices[gameid][roomid]) do
            if srv.onlines < maxplayer then
                return errs.code.SUCCESS, srv
            end
        end
    end

    -- need to create new game servcie
    return  createnewservice(gameid,roomid)
end