local skynet = require "skynet"
local socket = require "skynet.socket"
local httpd = require "http.httpd"
local sockethelper = require "http.sockethelper"
local urllib = require "http.url"

local table = table
local string = string
local httpHandler
local HTTP = {}

local mode = ...

function HTTP.init(handler, runningNum)
  if httpHandler == nil then
    httpHandler = handler
    skynet.error("http server reg handler")
    if mode ~= "agent" then
      local agent = {}
      for i= 1, runningNum do
        agent[i] = skynet.newservice(SERVICE_NAME, "agent")
        skynet.send(agent[i], "lua", "init", handler, 0)
      end
      local balance = 1
      local id = socket.listen("0.0.0.0", 8001)
      skynet.error("Listen web port 8001")
      socket.start(id , function(id, addr)
        skynet.error(string.format("%s connected, pass it to agent :%08x", addr, agent[balance]))
        skynet.send(agent[balance], "lua", "request", id)
        balance = balance + 1
        if balance > #agent then
          balance = 1
        end
      end)
    end
  end
end

function HTTP.response(id, ...)
  local ok, err = httpd.write_response(sockethelper.writefunc(id), ...)
  if not ok then
    skynet.error(string.format("fd = %d, %s", id, err))
  end
end

function HTTP.request(id)
  socket.start(id)
  -- limit request body size to 8192 bytes (you can pass nil to unlimit)
  local code, url, method, header, body = httpd.read_request(sockethelper.readfunc(id), 8192)
  if code then
    if code == 200 then
      local backInfo = skynet.call(httpHandler, "lua", "httpReqHandler", url)
      HTTP.response(id, code, backInfo)
    else
      HTTP.response(id, code)
    end
  else
    if url == sockethelper.socket_error then
      skynet.error("socket closed")
    else
      skynet.error(url)
    end
  end
  socket.close(id)
end

skynet.start(function()
  skynet.dispatch("lua", function(_, _, cmd, ...)
    local f = HTTP[cmd]
    if f then
      skynet.ret(skynet.pack(f(...)))
    else
      skynet.error("not found cmd:"..cmd)
    end
  end)
end)