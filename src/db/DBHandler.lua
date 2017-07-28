local skynet = require "skynet"
local mysql = require "skynet.db.mysql"

--[[
local json = require "json"
-- Object to JSON encode
test = {
  one='first',two='second',three={2,3,5}
}

jsonTest = json.encode(test)

print('JSON encoded test is: ' .. jsonTest)

-- Now JSON decode the json string
result = json.decode(jsonTest)
print ("The decoded table result one:"..result.one)
print ("The decoded table result two:"..result.two)
print ("The decoded table result three:"..result.three)
--]]

local DBHandler = {}
local db_ser

local function dump(obj)
    local getIndent, quoteStr, wrapKey, wrapVal, dumpObj
    getIndent = function(level)
        return string.rep("\t", level)
    end
    quoteStr = function(str)
        return '"' .. string.gsub(str, '"', '\\"') .. '"'
    end
    wrapKey = function(val)
        if type(val) == "number" then
            return "[" .. val .. "]"
        elseif type(val) == "string" then
            return "[" .. quoteStr(val) .. "]"
        else
            return "[" .. tostring(val) .. "]"
        end
    end
    wrapVal = function(val, level)
        if type(val) == "table" then
            return dumpObj(val, level)
        elseif type(val) == "number" then
            return val
        elseif type(val) == "string" then
            return quoteStr(val)
        else
            return tostring(val)
        end
    end
    dumpObj = function(obj, level)
        if type(obj) ~= "table" then
            return wrapVal(obj)
        end
        level = level + 1
        local tokens = {}
        tokens[#tokens + 1] = "{"
        for k, v in pairs(obj) do
            tokens[#tokens + 1] = getIndent(level) .. wrapKey(k) .. " = " .. wrapVal(v, level) .. ","
        end
        tokens[#tokens + 1] = getIndent(level - 1) .. "}"
        return table.concat(tokens, "\n")
    end
    return dumpObj(obj, 0)
end

local function init()
	local function on_connect(db)
		skynet.error("mysql connected ok.")
		local ret = db:query("insert into player (uid, imid, avatar, name) ".."values(100, 99000111, 1, \'test1\')")
		print(dump(ret))
	end
	db_ser = mysql.connect({
		host="127.0.0.1",
		port=3306,
		database="test",
		user="root",
		password="123456",
		max_packet_size = 1024 * 1024,
		on_connect = on_connect
	})
end

skynet.start(function()
	init()
  skynet.dispatch("lua", function(_, _, cmd, ...)
    f = DBHandler[cmd]
    if f then
      skynet.ret(skynet.pack(f(...)))
    else
      skynet.error("not found db hander:"..cmd)
    end
  end)
end)