local skynet = require "skynet"
local snax = require "skynet.snax"
local utils = require "utils"
local gamedata = require "gamedata"
local roomdata = require "roomdata"
local json = require "cjson"
local errs = require "errorcode"

local gamemgr = {}

gamemgr.reloaddata = function()
    gamedata = dofile('gamedata')
    roomdata = dofile('roomdata')
end

gamemgr.gamelist = function()
    glist = {}
    for id ,game in pairs(gamedata) do
        if game.status == 1 then
            table.insert(glist,game)
        end
    end
    return glist
end

gamemgr.roomlist = function(gameid)
    local rlist = {}
    for id, room in pairs(roomdata) do
        if room.gameid == gameid then
            room.limitBet = json.encode(room.limitBet)
            table.insert(rlist,room)
        end
    end
    return rlist
end

--匹配游戏
gamemgr.applyjoinroom = function(userid, gameid,roomid)
    --check game or room whether in maintenance
    if gamedata[gameid] == nil or gamedata[gameid].status ~= 1 then
        return errs.code.GAME_MAINTENANCE
    end

    if roomdata[roomid] == nil or roomdata[roomid].status ~= 1 then
        return errs.code.ROOM_MAINTENANCE
    end

    --check gold whether enought
    local player = "Player:" .. userid
    local gold = utils.getRedis().req.getValue(player , "gold") or 0
    gold = tonumber(gold)
    if gold < roomdata[roomid].entry then
        return errs.code.DONT_HAVE_ENOUGH_GOLD
    end

    local queue = snax.queryservice('queue')
    if queue then
        queue.post.applyjoinroom(userid,gameid,roomid)
        return errs.code.SUCCESS
    else
        return errs.code.FAILED
    end
end

return gamemgr