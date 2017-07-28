local skynet = require "skynet"

skynet.start(function()
  skynet.newservice("DBServer")
  skynet.exit()
end)