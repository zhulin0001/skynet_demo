local skynet = require "skynet"
local snax = require "snax"
local protobuf = require "protobuf"


local pb_files = {
	"./proto/cmd.pb",
	"./proto/account.pb",
}

function init( ... )
	snax.enablecluster()	-- enable cluster call
	for _,v in ipairs(pb_files) do
		protobuf.register_file(v)
	end
end

function exit(...)
	skynet.error("pbc service exit")
end


function response.encode( msg_name, msg )
	skynet.error("encode "..msg_name)
	skynet.error("msg " .. dumpTableToString(msg))
	return protobuf.encode("network.cmd."..msg_name, msg)
end

function response.decode( msg_name, data )
	skynet.error("decode ".. msg_name.. " " .. type(data) .." " .. #data)
	local ok, err = protobuf.decode("network.cmd."..msg_name, data)
	if not ok then
		skynet.error("deoce Error " .. err)
	end
	return ok
end

function response.getObj()
	return protobuf
end

function accept.test( ... )
	print( ... )
end