local skynet = require "skynet"
local socket = require "socket"

local Handler = {}
local Socket = {
	handler = nil,
}
local Client = {fd=0, ip=""}
local Clients = {}
local gate
local handler

local function closeAgent(fd)
	local client = Clients[fd]
	Clients[fd] = nil
	if client then
		skynet.send(gate, "lua", "kick", fd)
		skynet.send(handler, "lua", fd, 1, "")
	end
end

function Socket.regHandler(h)
	handler = h
	skynet.error("regHandler()")
end

function Socket.open(fd, addr)
	skynet.error("new client from : " .. addr)
	local client = Client 
	client.fd = fd
	client.ip = addr
	Clients[fd] = client
	skynet.call(gate, "lua", "accept", fd)
end

function Socket.close(fd)
	skynet.error("socket close",fd)
	closeAgent(fd)
end

function Socket.error(fd, msg)
	skynet.error("socket error",fd, msg)
	closeAgent(fd)
end

function Socket.warning(fd, size)
	skynet.error("socket warning", fd, size)
end

function Socket.data(fd, msg)
	local pid = string.byte(msg, 1) << 1 | (string.byte(msg, 2))
	local pb_body = string.sub(msg, 3)
	skynet.error("recv data:"..string.len(pb_body).."bytes pid:"..pid)
	skynet.send(handler, "lua", fd, pid, pb_body)
end

function Socket.send(fd, pid, msg)
	local len = string.len(msg) + 4
	local data = string.pack("<HHs", len, pid, msg)
	socket.write(fd, data)
end

function Handler.start(conf)
	skynet.call(gate, "lua", "open" , conf)
end

function Handler.close(fd)
	closeAgent(fd)
end

skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, subcmd, ...)
		if cmd == "socket" then
			local f = Socket[subcmd]
			if f then
				f(...)
			else
				skynet.error("not found subcmd:"..subcmd)
			end
		else
			local f = Handler[cmd]
			if f then
				skynet.ret(skynet.pack(f(subcmd, ...)))
			else
				skynet.error("not found cmd:"..cmd)
			end
		end
	end)
	gate = skynet.newservice("gate")
end)
