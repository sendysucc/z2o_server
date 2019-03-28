local skynet = require "skynet"
local gateserver = require "snax.gateserver"
local crypt = require "skynet.crypt"
local snax = require "skynet.snax"
local socketdriver = require "skynet.socketdriver"

local connection = {}
local handler = {}
local CMD = {}

-- will be called ,after listen socket setup
function handler.open(source,conf)

end

function handler.message(fd,msg,sz)

end

function handler.connect(fd,addr)
    local c = {
        fd = fd,
        addr = string.match(addr,'(%d+%.%d+%.%d+%.%d+):%d+' ),
        
    }
    connection[fd] = c
    --start receive client socket data
    gateserver.openclient(fd)
end

function handler.disconnect(fd)
    local c = assert(connection[fd])
    if c.agent then
        local obj = snax.bind(c.agent.handle,c.agent.type)
        local id = c.uid or fd
        local ret = obj.req.disconnect(id)
        
    end
    connection[fd] = nil
end

function handler.error(fd,msg)
    skynet.error('socket error:', fd, msg)
    gateserver.closeclient(fd)
end

function handler.warning(fd,size)
    skynet.error('client send big size data:',fd,size)
    gateserver.closeclient(fd)
end

function handler.command(cmd,source,...)

end

gateserver.start(handler)