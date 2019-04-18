local skynet = require "skynet"
local redis = require "skynet.db.redis"
local snax = require "skynet.snax"
local errs = require "errorcode"

local db


local function convert2tuple(origintable)
    local newT = {}
    for k,v in pairs(origintable) do
        table.insert(newT,k)
        table.insert(newT,v)
    end
    return newT
end

local function convert2table(origintuple)
    local newT = {}
    for i = 1, #origintuple/2 do

        local _key = origintuple[i*2 -1]
        local _value = origintuple[i*2]

        if _key ~= 'cellphone' and _key ~= 'username' and tonumber(_value) then
            newT[_key] = tonumber(_value)
        else
            newT[_key] = _value
        end
    end
    return newT
end

function init(...)
    local conf = {
        host = '127.0.0.1',
        port = 6379,
        db = 0,
    }

    db = redis.connect(conf)

    if db then
        skynet.error('connect to redis success !')
    else
        skynet.error('failed to connect to redis, please check it out...')
        snax.exit()
    end
end

function accept.addNewRecord(key,record)
    db:hmset(key,table.unpack(convert2tuple(record)))
end

function response.getRecordByKey(key)
    local record = convert2table( db:hgetall(key) )
    return record
end

function response.getRecordByField(classfy,field ,fieldvalue)
    local keys = db:keys(classfy)
    for _,key in pairs(keys) do
        local record = convert2table (db:hgetall(key))
        if record[field] == fieldvalue then
            return record
        end
    end
    return nil
end

function response.getIdleRobot(count)
    count = count or 1
    local set = {}
    local keys = db:keys("Player:*")

    local idx = 0

    for _,key in pairs(keys) do
        local record = convert2table(db:hgetall(key))
        if record[field] == value and record.isrobot == 1 then
            table.insert(set,record)
            idx = idx + 1
        end
        if idx >= count then
            break
        end
    end
    return set
end

function accept.updateValue(key,keyvalues)
    print('----------->updateValue')
    for k,v in pairs(keyvalues) do
        print('--->',k,v)
        db:hset(key,k,v)
    end
end

function accept.delValue(key,fields)
    for _, field in pairs(fields) do
        db:hdel(key,field)
    end
end

function accept.replaceRecord(key,record)

end

function accept.removeRecord(key)
    db:del(key)
end

function response.getValue(key,field)
    return db:hget(key,field)
end