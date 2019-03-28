skynet = require "skynet"
snax = require "skynet.snax"

skynet.start(function()
    skynet.error("start main......")

    snax.uniqueservice('auth')
    
end)