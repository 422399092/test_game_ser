local skynet = require "skynet"
local pb = require "protobuf"

local watchdog
local handler = {}
local handler_arr = {
  [1]   = function(fd, msg) handler.closed(fd) end,
}

function handler.closed(fd)
  skynet.error("client be closed %s", fd)
end

function handler.enterRoom(fd, msg)

end

function handler.leaveRoom(fd, msg)

end

local function working(co) 
	while true do
		-- print("working..")
		skynet.sleep(50)
		skynet.wakeup(co)
	end
end

skynet.start(function()
  skynet.fork(working, coroutine.running())
  watchdog = skynet.uniqueservice("Watchdog")
  pb.register_file "proto/game_c2s.pb"
  pb.register_file "proto/game_s2c.pb"
  skynet.dispatch("lua", function(_, _, fd, pid, msg)
    f = handler_arr[pid]
    if f then
        f(fd, msg)
    else
        skynet.error("not found msg hander:"..pid)
    end
  end)
end)