local parser = require "sprotoparser"
local core = require "sproto.core"

local utils = {}

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

return utils