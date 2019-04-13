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
            
            local gobj = snax.newservice(roomitem.gametype,rid)
            table.insert(gameservices[gid][rid],gobj)
        end
    end

end



