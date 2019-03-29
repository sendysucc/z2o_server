package.cpath = './3rd/skynet/luaclib/?.so'
package.path = './3rd/skynet/lualib/?.lua;' .. './utils/?.lua;'

local socket = require "client.socket"
local sproto = require "sproto"
local crypt = require "client.crypt"
local utils = require "utils"

local host = sproto.new( utils.loadproto("./proto/auth_c2s.spro") ):host "package"
local request = host:attach( utils.loadproto("./proto/auth_s2c.spro") )

local fd = assert(socket.connect('127.0.0.1',12288))

