local skynet = require "skynet"
local httpd = require "http.httpd"
local sockethelper = require "http.sockethelper"
local urllib = require "http.url"
local Hotfix = require "Hotfix"
local HttpHandler = {}

function HttpHandler.httpReqHandler(url)
  local tmp = {}
  local path, query = urllib.parse(url)
  path = string.sub(path, 2)
  table.insert(tmp, string.format("path: %s", path))

  local f = HttpHandler[path]
  if f == nil then
    table.insert(tmp, "is error.\n")
    return table.concat(tmp,"\n")
  end

  if query then
    local q = urllib.parse_query(query)
    for k, v in pairs(q) do
      table.insert(tmp, string.format("query: %s=%s", k,v))
    end
    table.insert(tmp, string.format(f(q)))
  end

  return table.concat(tmp,"\n")
end

function HttpHandler.hotfix(q)
  local name = q["lua"]
  local ok,err = pcall(require, name)
  if ok then
    skynet.error("hotfix-->"..name..".lua start.")
    Hotfix.hotfix_module(name)
    httpHandler = skynet.uniqueservice("HttpHandler")
    skynet.send(httpHandler, "lua", "str")
    return "hotfix-->"..name..".lua is ok."
  else
    return "hotfix-->"..name..".lua is error."
  end
end

function HttpHandler.str()
  print("HttpHandler.str()new")
end

skynet.start(function()
  skynet.dispatch("lua", function(_, _, cmd, ...)
    f = HttpHandler[cmd]
    if f then
      skynet.ret(skynet.pack(f(...)))
    else
      skynet.error("not found http hander:"..cmd)
    end
  end)
end)

return HttpHandler