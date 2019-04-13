local skynet = require "skynet"
local snax = require "skynet.snax"
local gamedata = require "gamedata"
local roomdata = require "roomdata"


function init(...)
    local roomid = ...

    skynet.error('---------->start:' .. roomid .. ' type:' .. type(roomid))
end