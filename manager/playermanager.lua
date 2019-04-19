local skynet = require "skynet"
local mysql = require "skynet.db.mysql"
local errs = require "errorcode"
local snax = require "skynet.snax"
local utils = require "utils"

local playermgr = {}
local db = nil
local rediscache = nil

local function escape(param)
    return mysql.quote_sql_str(param)
end

local function getdb()
    if not db then
        db = snax.queryservice('db')
    end
    return db
end


--注册
playermgr.register = function(params)
    local cellphone = escape(params.cellphone)
    local password = escape(params.password or '')
    local referrer = escape(params.referrer or '')
    local agentcode = escape(params.agentcode or '')

    local sql_str = string.format("call proc_register(%s,%s,%s,%s)",cellphone,password,referrer,agentcode)
    local errcode,res = utils.getDb().req.docall(sql_str)
    
    if errcode ~= errs.code.SUCCESS then
        return { errcode = errcode }
    end
    return { errcode = res.errcode }
end

--登陆
playermgr.login = function(params)
    local cellphone = escape(params.cellphone)
    local password = escape(params.password)
    local errcode = errs.code.SUCCESS
    local res = nil
    --login from redis first
    res = utils.getRedis().req.getRecordByField("Player:*","cellphone",string.sub(cellphone,2,12))
    if res then
        if res.online == '1' then
            return { errcode = errs.code.ALREADY_LOGIN }
        end

        local userid = res.userid
        -- set online flag
        utils.getRedis().post.updateValue("Player:" .. userid, {online = 1})
    else
        local sql_str = string.format("call proc_login(%s,%s)",cellphone,password)
        errcode ,res = utils.getDb().req.docall(sql_str)
        if errcode ~= errs.code.SUCCESS then
            return {errcode = errcode}
        end
        res.online = 1
        utils.getRedis().post.addNewRecord("Player:" .. res.userid, res)
    end
    return res
end

--下线
playermgr.offline = function(userid)
    utils.getRedis().post.updateValue("Player:" .. userid, {online = 0})
end

--加载机器人到redis
playermgr.loadrobot2redis = function()
    local sql_str = string.format('select * from User where User.isrobot = 1;')
    local errcode, res = utils.getDb().req.doquery(sql_str)

    for _,robot in pairs(res) do
        local robotid = robot.userid
        local alreadyExists = utils.getRedis().req.getRecordByKey("Player:" .. robotid)
        if utils.tlength(alreadyExists) == 0 then
            robot.isbuzy = 0
            utils.getRedis().post.addNewRecord("Player:" .. robotid, robot)
        end
    end
end

--[[获取 count 个空闲机器人, 
    这个函数只能以同步的方式在 queue 服务中调用， 否则会出现同步问题，导致一个机器人在同时在多个游戏中.
]]
playermgr.getidelrobot = function(count)
    count = count or 1
    local robset = utils.getRedis().req.getIdleRobot(count)
    return robset
end

--设置玩家游戏状态
playermgr.setplayinggame = function(uid,gameid,roomid,handle,gametype)
    utils.getRedis().post.updateValue( "Player:" .. uid, { gameid = gameid, roomid = roomid, handle = handle, gametype = gametype } )
end

playermgr.getPlayerById = function(uid)
    local player = utils.getRedis().req.getRecordByKey("Player:" .. uid)
    return player
end

playermgr.breaklineFlag = function(uid, isBreak)
    if isBreak then
        utils.getRedis().post.updateValue("Player:" .. uid, {breakline = 1})
    else
        utils.getRedis().post.delValue("Player:" .. uid, { "breakline" })
    end
end

return playermgr