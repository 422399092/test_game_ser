StringBuffer = {}

StringBuffer.append = function(t, str)
	if t and str then
	    table.insert(t, str)
	end
end

StringBuffer.tostr =  function(t)
	if t then
	    return table.concat(t)
	end
end

StringBuffer.new = function() return {} end