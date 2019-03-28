local skynet = require "skynet"
local snax = require "skynet.snax"
local sproto = require "sproto"
local crypt = require "skynet.crypt"
local utils = require "utils"

local sp_host
local sp_request

function init(...)
    sp_host = sproto.new( utils.loadproto("./proto/auth_c2s.spro") ):host "package"
    sp_request = sp_host:attach(sproto.new( utils.loadproto("./proto/auth_s2c.spro") ))
end

function response.message(fd,msg,sz)

end

function response.disconnect(fd)

end

