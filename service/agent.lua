local skynet = require "skynet"
local socket = require "socket"

local CMD = {}
local client_fd

local HEADER_LEN		=	2+2+4+1+4


local function bin2hex(s)
    s=string.gsub(s,"(.)",function (x) return string.format("%02X ",string.byte(x)) end)
    return s
end

-- 包头约定
-- Mcmd, Scmd, BodyLen, encrypt, Context, PBData
-- uint16,uint16,uint32,uint8,	uint32,	 bytes

local function send_package(pack)
	print(string.format("Will Send to [%d] %d bytes", client_fd, #pack))
	socket.write(client_fd, pack)
end

local function make_header( mcmd, scmd, len )
	local header = string.pack(">HHI4BI4", mcmd, scmd, len, 0, 0)
	return header
end

local function parse_header( data )
	local mcmd, scmd, bodylen, encrypt, context = string.unpack(">HHI4BI4", data)
	print(string.format("MCMD:%d, SCMD:%d, bodylen:%d, encrypt:%d, context:%d", mcmd, scmd, bodylen, encrypt, context))
	return mcmd, scmd, bodylen, encrypt, context
end

local function dispatch( mcmd, scmd, context, data )
	local dest = nil
	if mcmd == 1 then
		dest = "PHPPROXY"
	end
	if dest then
		skynet.send(dest, "lua", "cmd", scmd, context, data)
	end
end

function CMD.runloop( fd )
	while(socket.block(fd)) do
		local header = socket.read(fd, HEADER_LEN)
		if not header then		--连接断开导致读到false
			break
		end
		local mcmd, scmd, bodylen, encrypt, context = parse_header(header)
		local pbdata = socket.read(fd, bodylen)
		print(string.format("[%d] Received: %s", fd, bin2hex(pbdata)))
		dispatch(mcmd, scmd, context, pbdata)
	end
	print("end while")
	skynet.call("GATE", "lua", "close", fd)
end

function CMD.start(fd)
	client_fd = fd
	socket.start(fd)
	print("agent for fd " .. fd)
	skynet.send(skynet.self(), "lua", "runloop", fd)
end

function CMD.response( data )
	send_package(data)
end

function CMD.disconnect()
	-- todo: do something before exit
 	skynet.exit()
end

skynet.start(function()
 	skynet.dispatch("lua", function(_, source, command, ...)
		local f = CMD[command]
		f(...)
	end)
end)
