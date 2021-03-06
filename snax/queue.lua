local skynet = require "skynet"
local snax = require "skynet.snax"
local errs = require "errorcode"
local playermanager = require "playermanager"
local gamedata = require "gamedata"
local roomdata = require "roomdata"

local applylist = {}
local gservicemgr = nil

local function reply(userid,result)
    snax.queryservice('hall').post.replyjoinroom(userid,result)
end

local function addPlayer2Service(serviceobj,userinfo)
    snax.bind(serviceobj.handle,serviceobj.type).post.addPlayer(userinfo)
end

local function matching()
    local st_t = skynet.now()

    for rid, roomqueue in pairs(applylist) do
        while #roomqueue > 0 do
            local gameid = roomdata[rid].gameid
            local gameinfo = gamedata[gameid]
            
            local ecode, srvinfo = gservicemgr.req.getservice(gameid,rid)

            if ecode ~= errs.code.SUCCESS then  --clear queue list
                while #roomqueue > 0 do
                    local uid = table.remove(roomqueue)
                    if uid then
                        reply(uid,{errcode = ecode})
                    end
                end
                return 
            end

            if gameinfo.maxplayer == 100 then --百人游戏
                local remain = gameinfo.maxplayer - srvinfo.onlines

                while remain > 0 do
                    local uid = table.remove(roomqueue)

                    if uid then
                        skynet.error('-----> remain left position: ' .. remain .. ' ; alloc player :' .. uid)
                        reply(uid,{ errcode = errs.code.SUCCESS, handle = srvinfo.obj.handle, gametype = srvinfo.obj.type })
                        gservicemgr.post.increaseonline(gameid,rid,srvinfo.obj.handle)
                        remain = remain - 1

                        --add user to game service
                        local userinfo = playermanager.getPlayerById(uid)
                        addPlayer2Service(srvinfo.obj,userinfo)
                    else
                        break
                    end 
                end
            elseif gameinfo.maxplayer == 1 then -- 单人游戏
                local uid = table.remove(roomqueue)
                if uid then
                    reply(uid, { errcode = errs.code.SUCCESS, handle = srvinfo.obj.handle, gametype = srvinfo.obj.type })
                    gameservicemgr.post.increaseonline(gameid,rid,srvinfo.obj.handle)

                    --add user to game service
                    local userinfo = playermanager.getPlayerById(uid)
                    addPlayer2Service(srvinfo.obj,userinfo)
                end
            else --对战游戏
                local playernum = math.random(gameinfo.minplayer, gameinfo.maxplayer)
                local userlist = {}

                while playernum > 0 do
                    local uid = table.remove(roomqueue)
                    if uid then --real player
                        local player = playermanager.getPlayerById(uid)
                        if player then
                            table.insert(userlist,player)
                            playernum = playernum - 1
                        end
                    else    --add robot
                        local robots = playermanager.getidelrobot(playernum)
                        for _,rob in pairs(robots) do
                            table.insert(userlist,rob)
                        end
                        
                        playernum = 0
                    end
                end

                for _, user in pairs(userlist) do
                    reply(user.userid,{ errcode = errs.code.SUCCESS, handle = srvinfo.obj.handle, gametype = srvinfo.obj.type , uidlist = userlist })

                    -- add user to game service
                    addPlayer2Service(srvinfo.obj,user)
                end

                gameservicemgr.post.increaseonline(gameid,rid,srvinfo.obj.handle,#userlist)
            end
        end
    end
    skynet.error(' round mathcing spend time : ' .. (skynet.now() - st_t)  ) 
end

function init(...)
    skynet.fork(function()
        while true do
            --rest 3 seconds
            skynet.sleep(300)

            matching()
        end
    end)
    gservicemgr = snax.queryservice('gameservicemgr')
end

function accept.applyjoinroom(userid,gameid,roomid)
    local playerlist = applylist[roomid] or {}
    for _,uid in pairs(playerlist) do
        if uid == userid then
            --inform to hall service, return failed to match game
            snax.queryservice('hall').post.replyjoinroom(userid,{ errcode = errs.code.CANT_JOIN_MULTITY_ROOM })
            return
        end
    end
    applylist[roomid] = applylist[roomid] or {}
    table.insert(applylist[roomid],userid)
end