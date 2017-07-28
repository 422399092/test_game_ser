local skynet = require "skynet"

local max_client = 10240
local handler
local watchdog

local function init()
    handler = skynet.uniqueservice("MsgHandler")
    watchdog = skynet.uniqueservice("Watchdog")
    skynet.send(watchdog, "lua", "socket", "regHandler", handler)
    skynet.send(watchdog, "lua", "start", {
        port = 2524,
        maxclient = max_client,
        nodelay = true,
    })
    skynet.error("Watchdog Listen on", 2524)
end

skynet.start(function()
    skynet.error("server init")
    init()
    skynet.exit()
end)