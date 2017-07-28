local skynet = require "skynet"
local cluster = require "skynet.cluster"

local rpc = {}
local size
local ms_num

function rpc.init()
	cluster.reload 
	{
		gs0 = "127.0.0.1:2500",
		gs1 = "127.0.0.1:2510",
		gs2 = "127.0.0.1:2520",
		gs3 = "127.0.0.1:2530",
		gs4 = "127.0.0.1:2540",
		gs5 = "127.0.0.1:2550",
	}
	local gs1 = skynet.uniqueservice("RpcHandler")
	cluster.register("gs1", gs1)
	cluster.open("gs1")
	skynet.error("rpc init.")
	size = 0
	ms_num = 0
end

function rpc.getRoomNum(s)
	if (size > 0) then
		if size + 1 ~= s then
			skynet.error("if size + 1 ~= s then")
		end
	end
	size = s 
	return 2524
end

local function working(co) 
	while true do
		skynet.sleep(100)
		ms_num = ms_num + 1
		-- print(ms_num.."s rpc handler:"..size)
		size = 0
	end
end

skynet.start(function()
	skynet.fork(working, coroutine.running())
  skynet.dispatch("lua", function(_, _, rpc_handler, ...)
    f = rpc[rpc_handler]
    if f then
      skynet.ret(skynet.pack(f(...)))
    else
      skynet.error("not found rpc handler:"..rpc_handler)
    end
  end)
end)