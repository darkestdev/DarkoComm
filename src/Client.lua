local Types: nil = require(script.Parent.Types)
local BridgeNet2: Types.TableType = require(script.Parent.Parent.BridgeNet2)
local ServerSignal: Types.TableType = require(script.Parent.ClientSignal)

local Client: Types.TableType = {}
Client.__index = Client

function Client.new(ServiceName: string, ReplicationData: { [string]: string })
	local self: Types.TableType = setmetatable({}, Client)

	self.ServiceName = ServiceName
	self.ReplicationData = ReplicationData

	return self :: Types.TableType
end

function Client:GetServiceMethods(Middleware: table | nil)
	local Methods: { [string]: Types.TableType | () -> Types.TableType } = {}

	for MethodKey, MethodType in pairs(self.ReplicationData) do
		local Bridge: Types.TableType = BridgeNet2.ClientBridge(`{self.ServiceName}_{MethodKey}`)

		if Middleware and Middleware.Inbound then
			Bridge:InboundMiddleware(Middleware.Inbound)
		end

		if Middleware and Middleware.Outbound then
			Bridge:OutboundMiddleware(Middleware.Outbound)
		end

		if MethodType == "Method" then
			Methods[MethodKey] = function(_self: any, ...: any)
				local PackedArgs: Types.TableType = table.pack(...)
				PackedArgs.n = nil
				--print(`[DarkoKnit] [InvokeServerAsync] [{self.ServiceName}] [{MethodKey}]:`)
				--print(PackedArgs)
				return table.unpack(Bridge:InvokeServerAsync(PackedArgs))
			end
		elseif MethodType == "Signal" then
			Methods[MethodKey] = ServerSignal.new(Bridge)
		end
	end

	return Methods
end

return Client
