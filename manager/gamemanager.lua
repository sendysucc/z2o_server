local skynet = require "skynet"
local snax = require "skynet.snax"
local utils = require "utils"
local gamedata = require "gamedata"
local roomdata = require "roomdata"
local json = require "cjson"

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


return gamemgr