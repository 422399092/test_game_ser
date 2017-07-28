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

local function init()
	local function on_connect(db)
		db:query("set charset utf8")
		skynet.error("mysql connected ok.")
	end
	db_ser = mysql.connect({
		host="127.0.0.1",
		port=3306,
		database="yyworld",
		user="root",
		password="123456",
		max_packet_size = 1024 * 1024,
		on_connect = on_connect
	})
	if not db_ser then
		print("failed to connect")
	end
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