local skynet = require "skynet"
local snax = require "skynet.snax"
local errs = require "errorcode"
local playermanager = require "playermanager"
local gamedata = require "gamedata"
local roomdata = require "roomdata"


local applylist = {}

local function matching()

    skynet.error(' mathcing ....')

    for rid, roomqueue in pairs(applylist) do
        if #roomqueue > 0 then
        
            local gameid = roomdata[rid].gameid
            local gameinfo = gamedata[gameid]
            


        end
    end
end

function init(...)
    skynet.fork(function()
        while true do
            --rest 3 seconds
            skynet.sleep(300)

            matching()
        end
    end)
end


function accept.applyjoinroom(userid,gameid,roomid)
    local playerlist = applylist[roomid] or {}
    for _,uid in pairs(playerlist) do
        if uid == userid then
            --inform to hall service, return failed to match game
            snax.queryservice('hall').post.replayjoinroom(userid,{ errcode = errs.code.CANT_JOIN_MULTITY_ROOM })
            return
        end
    end
    applylist[roomid] = applylist[roomid] or {}
    table.insert(applylist[roomid],userid)

end

