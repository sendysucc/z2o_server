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

local function getredis()
    if not rediscache then
        rediscache = snax.queryservice('redis')
    end
    return rediscache
end

--注册
playermgr.register = function(params)
    local cellphone = escape(params.cellphone)
    local password = escape(params.password or '')
    local referrer = escape(params.referrer or '')
    local agentcode = escape(params.agentcode or '')

    local sql_str = string.format("call proc_register(%s,%s,%s,%s)",cellphone,password,referrer,agentcode)
    local errcode,res = getdb().req.docall(sql_str)
    
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
    res = getredis().req.getRecordByField("Player:*","cellphone",string.sub(cellphone,2,12))
    if res then
        if res.online == '1' then
            return { errcode = errs.code.ALREADY_LOGIN }
        end

        local userid = res.userid
        -- set online flag
        getredis().post.updateValue("Player:" .. userid, {online = 1})
    else
        local sql_str = string.format("call proc_login(%s,%s)",cellphone,password)
        errcode ,res = getdb().req.docall(sql_str)
        if errcode ~= errs.code.SUCCESS then
            return {errcode = errcode}
        end
        res.online = 1
        getredis().post.addNewRecord("Player:" .. res.userid, res)
    end
    return res
end

--下线
playermgr.offline = function(userid)
    getredis().post.updateValue("Player:" .. userid, {online = 0})
end

--加载机器人到redis
playermgr.loadrobot2redis = function()
    local sql_str = string.format('select * from User where User.isrobot = 1;')
    local errcode, res = getdb().req.doquery(sql_str)

    for _,robot in pairs(res) do
        local robotid = robot.userid
        local alreadyExists = getredis().req.getRecordByKey("Player:" .. robotid)
        if utils.tlength(alreadyExists) == 0 then
            robot.isbuzy = 0
            getredis().post.addNewRecord("Player:" .. robotid, robot)
        end
    end
end

--获取 count 个空闲机器人
playermgr.getidelrobot = function(count)
    count = count or 1

end


--设置玩家游戏状态
playermgr.setplayinggame = function(uid,handle,gametype)
    
end

return playermgr