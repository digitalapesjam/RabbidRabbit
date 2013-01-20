table.copy = function( t, ... )
	local copyShallow = function( src, dst, dstStart )
		local result = dst or {}
		local resultStart = 0
		if dst and dstStart then
			resultStart = dstStart
		end
		local resultLen = 0
		if "table" == type( src ) then
			resultLen = #src
			for i=1,resultLen do
				local value = src[i]
				if nil ~= value then
					result[i + resultStart] = value
				else
					resultLen = i - 1
					break;
				end
			end
		end
		return result,resultLen
	end
 
	local result, resultStart = copyShallow( t )
 
	local srcs = { ... }
	for i=1,#srcs do
		local _,len = copyShallow( srcs[i], result, resultStart )
		resultStart = resultStart + len
	end
 
	return result
end