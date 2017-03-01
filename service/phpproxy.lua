local skynet = require "skynet"
local httpc = require "http.httpc"
local dns = require "dns"

local CMD = {}

local function request( ... )
	httpc.dns()	-- set dns server
	print("GET baidu.com")
	local respheader = {}
	local status, body = httpc.get("baidu.com", "/", respheader)
	print("[header] =====>")
	for k,v in pairs(respheader) do
		print(k,v)
	end
	print("[body] =====>", status)
	print(body)

	local respheader = {}
	dns.server()
	local ip = dns.resolve "baidu.com"
	print(string.format("GET %s (baidu.com)", ip))
	local status, body = httpc.get("baidu.com", "/", respheader, { host = "baidu.com" })
	print(status)
end

function CMD.test()
	print("test")
	skynet.fork(request)
end

function CMD.echo( text )
	print(text)
end

skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, ...)
		local f = CMD[cmd]
		skynet.ret(skynet.pack(f(...)))
	end)
end)