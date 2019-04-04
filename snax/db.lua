local skynet = require "skynet"
local snax = require "skynet.snax"
local mysql = require "skynet.db.mysql"
local errs = require "errorcode"

local db


local function dberror(errno,sqlstate)
    skynet.error('[db] procedure error! errno: ' .. errno .. ' errorcode:' .. sqlstate)
end

function init(...)
    local function on_connect(db)
        db:query('set charset utf8')
        skynet.error('[db] connect to database success!')
    end

    db = mysql.connect({
        host = '127.0.0.1',
        port = 3306,
        database = 'z2oserver',
        user = 'sendy',
        password = 'sendy',
        max_package_size = 1024*1024,
        on_connect = on_connect,
    })
    if not db then
        skynet.error('[db] connect database failed !')
        snax.exit()
    end
end

function response.dosomething(sql_str)
    local ret = db:query(sql_str)
    if ret.badresult then
        dberror(ret.errno,ret.sqlstate)
        return errs.code.DB_EXECUTE_ERROR
    else
        return errs.code.SUCCESS,ret
    end
end
