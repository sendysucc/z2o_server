local skynet = require "skynet"
local mysql = require "skynet.db.mysql"
local errs = require "errorcode"

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
    local cellphone = escap(params.cellphone)
    local password = escap(params.password or '')
    local referrer = escap(params.referrer or '')
    local agentcode = escap(params.agentcode or '')

    local sql_str = string.format("call proc_register(%s,%s,%s,%s)",cellphone,password,referrer,agentcode)
    local errcode,res = getdb().req.dosomething(sql_str)
    if errcode ~= errs.code.SUCCESS then
        reutrn { errcode = errcode }
    end

    if res.errcode ~= errs.code.SUCCESS then
        return { errcode = res.errcode }
    end

    
    

end


return playermgr