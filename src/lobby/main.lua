local skynet = require "skynet"

skynet.start(function()
    skynet.newservice("console")
    -- skynet.newservice("debug_console", 8000)
    skynet.newservice("LobbyServer")
    skynet.exit()
end)