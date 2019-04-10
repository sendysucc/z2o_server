local parser = require "sprotoparser"
local core = require "sproto.core"
local crypt = require "skynet.crypt"

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

utils.tlength = function(dest)
    assert (type(dest) == 'table')
    local length = 0
    for k,v in pairs(dest) do
        length = length + 1
    end
    return length
end

return utils