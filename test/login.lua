package.cpath = "../luaclib/?.so;../skynet/luaclib/?.so;../3rd/pbc/binding/lua53/?.so"
package.path = "../lualib/?.lua;../3rd/pbc/binding/lua53/?.lua"

if _VERSION ~= "Lua 5.3" then
	error "Use lua 5.3"
end
local HEADER_LEN		=	2+2+4+1+4

local socket = require "clientsocket"
local proto  = require "protobuf"

require "preload"

proto.register_file("../proto/cmd.pb")
proto.register_file("../proto/account.pb")
--parser.register("errno.proto", ".")
--parser.register("cmd.proto", ".")

local fd = assert(socket.connect("127.0.0.1", 8888))

local function make_header( mcmd, scmd, len, context)
	local header = string.pack(">HHI4BI4", mcmd, scmd, len, 0, context)
	return header
end

local function send_login()
	local login = {
		sid		=	1,
		api		=	1,
		type	=	1,
		platuid	=	"18098924892",
		token	=	"hehe",
		lang	=	1,
		time	=	os.time()
	}
	local data = proto.encode("network.cmd.PBReqAccountLogin", login)
	socket.send(fd, make_header(1, 1, #data, 123456789)..data)
end

local function parse_header( data )
	local mcmd, scmd, bodylen, encrypt, context = string.unpack(">HHI4BI4", data)
	print(string.format("MCMD:%d, SCMD:%d, bodylen:%d, encrypt:%d, context:%d", mcmd, scmd, bodylen, encrypt, context))
	return mcmd, scmd, bodylen, encrypt, context
end

local function dispatch_package()
	local packet = socket.recv(fd)
	if packet then
		local mcmd, scmd, bodylen, encrypt, context = parse_header(string.sub(packet, 1, HEADER_LEN))
		local pbdata = string.sub(packet, HEADER_LEN+1, #packet)
		if pbdata then
			print(string.format("[%d] Received: %s", fd, bin2hex(pbdata)))
			local ret, err = proto.decode("network.cmd.PBRespAccountLogin", pbdata)
			if ret then
				print(dumpTab(ret))
			else
				print(err)
			end
		end
	end
end
send_login()
dispatch_package()
while true do
	local input = socket.readstdin()
	if input then
		if input=="r" then
			dispatch_package()
		elseif input == "q" then
			break
		else
			socket.send(fd, string.pack(">I4", string.len(input))..input)
		end
	end
	socket.usleep(100)
end
