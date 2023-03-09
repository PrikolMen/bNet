local CLIENT = CLIENT
local SERVER = SERVER
local ipairs = ipairs
local unpack = unpack
local net = net

if SERVER then
	util.AddNetworkString("_bNet")
end

module( "bnet" )

local events = {}
function Receive(name , cb)
	events[name] = cb
end

net.Receive("_bNet" , function(len , ply)
	local messageName = net.ReadString()
	local cb = events[messageName]
	if not cb then return end

	local data = {}
	for i = 1 , net.ReadInt(8) do
		data[i] = net.ReadType()
	end

	if SERVER then
		cb(ply , unpack(data))
	else
		cb(unpack(data))
	end
end)

local function writeData(data)
	for _, value in ipairs(data) do
		net.WriteType(value)
	end
end

if SERVER then
	function Send(ply , name , ...)
		local data = {...}
		net.Start("_bNet")
			net.WriteString(name)
			net.WriteInt(#data , 8)
			writeData(data)
		net.Send(ply)
	end

	function Broadcast(name , ...)
		local data = {...}
		net.Start("_bNet")
			net.WriteString(name)
			net.WriteInt(#data , 8)
			writeData(data)
		net.Broadcast()
	end
end

if CLIENT then
	function SendToServer(name , ...)
		local data = {...}
		net.Start("_bNet")
			net.WriteString(name)
			net.WriteInt(#data , 8)
			writeData(data)
		net.SendToServer()
	end
end
