local skynet = require "skynet"
local socket = require "socket"

local function login( source, fd )
	socket.start(fd)
	local str = socket.read(fd, 4)
	if str then
		-- local r = str
		-- local b, p, t = string.char(r:byte(1)),string.char(r:byte(2)),string.char(r:byte(3))
		-- local header_len = r:byte(4)
		-- local body_len = r:byte(5)*256 + r:byte(6)
		-- print(b..p..t.."h"..header_len.."b"..body_len)
		-- local mcmd = r:byte(7)*256 + r:byte(8)
		-- local subcmd = r:byte(9)*256 + r:byte(10)
		-- print("mcmd"..mcmd.."scmd"..subcmd)
		-- if b == 'B' and p == 'P' and t == 'T' then
		-- 	if mcmd == 1 and subcmd == 5 then
		-- 		local param = skynet.call("")
		-- 	end
		-- end 
		local len = string.unpack(">I4", str)
		if len > 0 then
			local data = socket.read(fd, len)
			print(string.format("[%d] Received: %s", fd, data))
			if data == "zhulin" then
				local hello = "hello " .. data
				data = string.len(hello)
				data = string.pack(">I4", data)
				print("Will write " .. hello)
				socket.abandon(fd)
				socket.write(fd, data..hello)
				skynet.call(source, "lua", "forward", fd)
				return
			end
		end
	end
	socket.abandon(fd)
	skynet.call(source, "lua", "close", fd)
end

skynet.start(function()
	skynet.dispatch("lua", function(session, source, id, addr, ...)
		login(source, id)
	end)
end)