local skynet = require "skynet"
local max_client = 10240
local msgHandler
local httpHandler
local watchdog
local rpc
local httpServer

local function init()
  httpServer = skynet.uniqueservice("HttpServer")
  httpHandler = skynet.uniqueservice("HttpHandler")
  rpc = skynet.uniqueservice("RpcHandler")
  msgHandler = skynet.uniqueservice("MsgHandler")
  watchdog = skynet.uniqueservice("Watchdog")
  skynet.send(rpc, "lua", "init")
  skynet.send(httpServer, "lua", "init", httpHandler, 10)
  skynet.send(watchdog, "lua", "socket", "regHandler", msgHandler)
  skynet.send(watchdog, "lua", "start", {
      port = 2525,
      maxclient = max_client,
      nodelay = true,
  })
  skynet.error("Watchdog Listen on", 2525)
end

skynet.start(function()
  skynet.error("game server init")
  init()
  skynet.exit()
end)
