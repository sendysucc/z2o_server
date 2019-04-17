local parser = require "sprotoparser"
local core = require "sproto.core"
local crypt = require "skynet.crypt"
local skynet = require "skynet"
local snax = require "skynet.snax"

local utils = {}

utils.redis = nil
utils.db = nil

utils.loadproto = function(protofile)
    local f = assert(io.open(protofile))
    local data = f:read 'a'
    f:close()
    return parser.parse(data)
end

utils.sha1 = function(text)
    local c = crypt.sha1(text)
    return crypt.hexencode(c)
end

utils.tlength = function(dest)
    assert (type(dest) == 'table')
    local length = 0
    for k,v in pairs(dest) do
        length = length + 1
    end
    return length
end

utils.getRedis = function()
    if not utils.redis then
        utils.redis = snax.queryservice('redis')
    end
    return utils.redis
end

utils.getDb = function()
    if not utils.db then
        utils.db = snax.queryservice('db')
    end
    return utils.db
end

return utils