local skynet = require "skynet"
local protobuf = require "protobuf"

local pb

local pb_files = {
	"./proto/cmd.pb",
	"./proto/account.pb",
}

local cmd = {}

function cmd.init()
	for _,v in ipairs(pb_files) do
		protobuf.register_file(v)
	end
end

function cmd.encode(msg_name, msg)
	skynet.error("encode ".. msg_name)
	skynet.error("msg " .. dumpTableToString(msg))
	return protobuf.encode("network.cmd." .. msg_name, msg)
end

function cmd.decode(msg_name, data)
	skynet.error("decode ".. msg_name.. " " .. type(data) .." " .. #data)
	local ok, err = protobuf.decode("network.cmd."..msg_name, data)
	if not ok then
		skynet.error("deoce Error " .. err)
	end
	skynet.error("msg " .. dumpTableToString(msg))
	return ok
end



function cmd.test()
	skynet.error("pbc test...")
	print(protobuf.enum_id("network.cmd.PBMainCmdAccountSubCmd", "Account_RespInfoExt"))
end

skynet.start(function ()
	cmd.init()
	skynet.dispatch("lua", function (session, address, command, ...)
		local f = cmd[command]
		if not f then
			skynet.ret(skynet.pack(nil, "Invalid command" .. command))
		end

		if command == "decode" then
			local name
			local buf
			name,buf = ...
			skynet.ret(skynet.pack(cmd.decode(name,buf)))
			return
		end
		local ret = f(...)
			skynet.ret(skynet.pack(ret))
	end)
end)
