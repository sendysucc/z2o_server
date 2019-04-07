local skynet = require "skynet"
local mysql = require "skynet.db.mysql"
local errs = require "errorcode"
local snax = require "skynet.snax"

local playermgr = {}
local db = nil

local function escape(param)
    return mysql.quote_sql_str(param)
end

local function getdb()
    if not db then
        db = snax.queryservice('db')
    end
    return db
end

playermgr.register = function(params)
    local cellphone = escape(params.cellphone)
    local password = escape(params.password or '')
    local referrer = escape(params.referrer or '')
    local agentcode = escape(params.agentcode or '')

    local sql_str = string.format("call proc_register(%s,%s,%s,%s)",cellphone,password,referrer,agentcode)
    local errcode,res = getdb().req.dosomething(sql_str)
    if errcode ~= errs.code.SUCCESS then
        reutrn { errcode = errcode }
    end
    return { errcode = res.errcode }
end

playermgr.login = function(params)
    local cellphone = escape(params.cellphone)
    local password = escape(params.password)

    local sql_str = string.format("call proc_login(%s,%s)",cellphone,password)
    local errcode ,res = getdb().req.dosomething(sql_str)
    if errcode ~= errs.code.SUCCESS then
        return {errcode = errcode}
    end

    return res
end


return playermgr