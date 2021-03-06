local skynet = require "skynet"
local gateserver = require "snax.gateserver"
local crypt = require "skynet.crypt"
local snax = require "skynet.snax"
local socketdriver = require "skynet.socketdriver"

local connection = {}
local handler = {}
local CMD = {}
local onlinecount = 0
local uid_fd = {}

local function sendmsg(fd,msg)
    local c = connection[fd]
    if c.secret then
        msg = crypt.desencode(c.secret,msg)
    end
    msg = crypt.base64encode(msg)
    local package = string.pack(">s2",msg)
    socketdriver.send(fd,package)
end

-- will be called ,after listen socket setup
function handler.open(source,conf)

end

function handler.message(fd,msg,sz)
    local c = assert(connection[fd])
    msg = crypt.base64decode(skynet.tostring(msg,sz))
    
    if c.secret then
        msg = crypt.desdecode(c.secret,msg)
    end

    if c.agent then
        local id = c.uid or fd
        local resp = c.agent.req.message(id,msg,sz)
        if resp then
            sendmsg(fd,resp)
        end
    end
end

function handler.connect(fd,addr)
    local c = {
        fd = fd,
        addr = string.match(addr,'(%d+%.%d+%.%d+%.%d+):%d+' ),
        conntime = skynet.now(),
    }
    print('client connect', addr)
    --forward auth service as agent
    c.agent = snax.queryservice('handshake')

    connection[fd] = c

    onlinecount = onlinecount + 1
    --start receive client socket data
    gateserver.openclient(fd)
end

function handler.disconnect(fd)
    local c = connection[fd]
    if not c then
        return 
    end
    if c.agent then
        local id = c.uid or fd
        local ret = c.agent.req.disconnect(id)
    end
    connection[fd] = nil

    
    onlinecount = onlinecount -1
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
    local f = CMD[cmd]
    if f then
        f(source,...)
    end
end

function CMD.forward(source,fd,handle,servicetype,userid)
    local c = connection[fd]
    if not c then
        c = assert(connection[uid_fd[fd]])
    end

    c.agent = snax.bind(handle,servicetype)

    if userid then
        c.uid = userid
        uid_fd[userid] = fd
    end

    --清除掉註銷時留下的uid
    if servicetype == 'auth' then
        c.uid = nil
    end
end

function CMD.crypted(source,fd,secret)
    local c = assert(connection[fd])
    c.secret = secret
end

gateserver.start(handler)