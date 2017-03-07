local skynet = require "skynet"
local httpc = require "http.httpc"
local dns = require "dns"

local CMD = {}

local function make_header( mcmd, scmd, len, context)
	local header = string.pack(">HHI4BI4", mcmd, scmd, len, 0, context)
	return header
end

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

function CMD.cmd( source, scmd, context, data )
	if scmd == 1 then
		local param = skynet.call("PBC", "lua", "decode", "PBReqAccountLogin", data)
		if param then
			print(dumpTab(param))
		end
		local ret = {
			code	=	1,
			time	=	os.time(),
			user	=	{
					uid		=	"1",
					name	=	"zhulin",
					icon	=	nil,
					mmoney	=	9999999,
					status	=	1
			}
		}
		local respData = skynet.call("PBC", "lua", "encode", "PBRespAccountLogin", ret)
		skynet.send(source, "lua", "response", make_header(1, 2, #respData, context)..respData)
	end
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
		f(source, ...)
	end)
end)