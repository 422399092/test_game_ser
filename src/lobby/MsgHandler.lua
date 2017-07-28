local skynet = require "skynet"
local cluster = require "skynet.cluster"
local pb = require "protobuf"

local watchdog
local handler = {}
local handler_arr = {
    [1]   = function(fd, msg) handler.closed(fd) end,
    [100] = function(fd, msg) handler.loginReq(fd, msg) end,
    [110] = function(fd, msg) handler.joinRoomReq(fd, msg) end,
}

function handler.closed(fd)
    skynet.error("client be closed %s", fd)
end

function handler.loginReq(fd, msg)
    local c2sLogin = pb.decode("lobby.C2SLogin", msg)
    skynet.error("loginReq():"..c2sLogin.uid)
    local s2cLogin = pb.encode("lobby.S2CLogin", {ret=1;})
    skynet.send(watchdog, "lua", "socket", "send", fd, 100, s2cLogin)
end

function handler.joinRoomReq(fd, msg)
    local c2sJoinRoom = pb.decode("lobby.C2SJoinRoom", msg)
    skynet.error("joinRoomReq():"..c2sJoinRoom.area_id)
    local s2cJoinRoom = pb.encode("lobby.S2CJoinRoom", {ret=0;room_id=1})
    skynet.send(watchdog, "lua", "socket", "send", fd, 110, s2cJoinRoom)
end

local function test()
    local gs1RPC = cluster.query("gs1", "gs1")
    local proxy = cluster.proxy("gs1", gs1RPC)
    print(skynet.call(proxy, "lua", "getRoomNum", 1))
    skynet.send(proxy, "lua", "getRoomNum", 1)
end

skynet.start(function()
    watchdog = skynet.uniqueservice("Watchdog")
    pb.register_file "proto/lobby_c2s.pb"
    pb.register_file "proto/lobby_s2c.pb"
    skynet.dispatch("lua", function(_, _, fd, pid, msg)
        f = handler_arr[pid]
        if f then
            f(fd, msg)
        else
            skynet.error("not found msg hander:"..pid)
        end
    end)
    -- test()
end)