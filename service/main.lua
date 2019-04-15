local skynet = require "skynet"
local snax = require "skynet.snax"

skynet.start(function()
    skynet.error("start main......")

    snax.uniqueservice('redis')
    snax.uniqueservice('db')

    snax.uniqueservice('handshake')
    snax.uniqueservice('hall')

    snax.uniqueservice('gameservicemgr')

    --queue need create after gameservicemgr
    snax.uniqueservice('queue')

    local gate = skynet.uniqueservice("gated")

    local config = {
        port = 12288,
        maxclient = 5120,
        nodelay = true,
    }

    skynet.send(gate,"lua","open", config )
    
    skynet.exit()
end)