local Types: nil = require(script.Parent.Types)
local BridgeNet2: Types.TableType = require(script.Parent.Parent.BridgeNet2)
local ServerSignal: Types.TableType = require(script.Parent.ServerSignal)

local Server: Types.TableType = {}
Server.__index = Server

function Server.new(ServiceName: string)
	local self: Types.TableType = setmetatable({}, Server)

	self.ServiceName = ServiceName
	self.ReplicationData = {}
	self.Calls = {}

	return self :: Types.TableType
end

function Server:WrapMethod(Table: Types.TableType, Name: string, InboundMiddleware: any, OutboundMiddleware: any)
	local Bridge: Types.TableType = BridgeNet2.ServerBridge(`{self.ServiceName}_{Name}`)

	if InboundMiddleware then
		Bridge:InboundMiddleware(InboundMiddleware)
	end

	if OutboundMiddleware then
		Bridge:OutboundMiddleware(OutboundMiddleware)
	end

	self.ReplicationData[Name] = "Method"
	self.Calls[Name] = 0

	Bridge.OnServerInvoke = function(Player: Player, Content: Types.TableType)
		--print(`[DarkoKnit] [OnServerInvoke] [{self.ServiceName}] [{Name}]:`)
		--print(Content)
		self.Calls[Name] += 1
		return table.pack(Table[Name](Table, Player, table.unpack(Content)))
	end

	return Bridge
end

function Server:ConstructSignal(Name: string, InboundMiddleware: any, OutboundMiddleware: any)
	local Bridge: Types.TableType = BridgeNet2.ServerBridge(`{self.ServiceName}_{Name}`)

	if InboundMiddleware then
		Bridge:InboundMiddleware(InboundMiddleware)
	end

	if OutboundMiddleware then
		Bridge:OutboundMiddleware(OutboundMiddleware)
	end

	self.ReplicationData[Name] = "Signal"
	self.Calls[Name] = 0

	return ServerSignal.new(Bridge, self.Calls[Name])
end

return Server
