local skynet = require "skynet"

local dbHandler

skynet.start(function()
  dbHandler = skynet.uniqueservice("DBHandler")
  skynet.exit()
end)