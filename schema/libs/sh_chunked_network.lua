--[[
	Library to send possibly large amounts of data over the network in smaller chunks.
	This helps prevent reaching the Network Library limit.
	It sends chunks with some delay to avoid causing 'reliable buffer overflow' for clients.
--]]

Schema.chunkedNetwork = Schema.chunkedNetwork or {}

--- Delay between sending data chunks over network (to prevent reliable buffer overflow)
Schema.chunkedNetwork.DefaultChunkSize = 50
Schema.chunkedNetwork.DefaultDelay = 0.05

-- Registry of message handlers
Schema.chunkedNetwork.handlers = Schema.chunkedNetwork.handlers or {}
Schema.chunkedNetwork.activeOperations = Schema.chunkedNetwork.activeOperations or {}

---	Register a chunked network message and the associated network strings:
--- - {messageName}Header is a metadata packet with information about the chunked data
--- - {messageName}Data are the actual data packets being sent
--- - {messageName}Request is a request packet to initiate the chunked transfer and calls back when the transfer is complete
--- You'll need to call this in a shared file so that both the client and server are aware of the message.
--- The network message names will be prefixed with exp to reduce the chance of collisions with addons.
---	@param messageName string - The base name for the message
---	@param chunkSize number - Optional chunk size override
---	@param delay number - Optional delay override
function Schema.chunkedNetwork.Register(messageName, chunkSize, delay)
	local config = {
		messageName = messageName,
		chunkSize = chunkSize or Schema.chunkedNetwork.DefaultChunkSize,
		delay = delay or Schema.chunkedNetwork.DefaultDelay,
		headerName = "exp" .. messageName .. "Header",
		dataName = "exp" .. messageName .. "Data",
		requestName = "exp" .. messageName .. "Request"
	}

	Schema.chunkedNetwork.handlers[messageName] = config

	if (SERVER) then
		-- Register network strings
		util.AddNetworkString(config.requestName)
		util.AddNetworkString(config.headerName)
		util.AddNetworkString(config.dataName)
	else
		-- Setup net.Receive
		Schema.chunkedNetwork.SetupClientReceiver(messageName)
	end

	return config
end

if (SERVER) then
	---	Send chunked data to a client
	---	@param messageName string The registered message name
	---	@param client Player The client to send to
	---	@param data table The data to send (will be chunked automatically)
	---	@param extraData? table Optional extra data to send with header (e.g., steamID)
	---	@return number # Delay in seconds for complete transmission
	function Schema.chunkedNetwork.Send(messageName, client, data, extraData)
		local config = Schema.chunkedNetwork.handlers[messageName]

		if (not config) then
			error("Schema.chunkedNetwork: Message '" .. messageName .. "' not registered!")
		end

		extraData = extraData or {}
		local messageAmount = #data

		-- Send header
		net.Start(config.headerName)
		net.WriteUInt(messageAmount, 16)

		-- Write extra data
		for key, value in pairs(extraData) do
			if (type(value) == "string") then
				net.WriteString(value)
			elseif (type(value) == "number") then
				net.WriteDouble(value)
			elseif (type(value) == "boolean") then
				net.WriteBool(value)
			elseif (type(value) == "table") then
				net.WriteTable(value)
			end
		end

		net.Send(client)

		if (messageAmount == 0) then
			return 0
		end

		-- Use Schema.ScopedChunkData to send the data
		local delayInSeconds = Schema.ScopedChunkData(
			client,
			messageName,
			data,
			config.chunkSize,
			config.delay,
			function(chunk, chunkIndex, chunkAmount)
				for _, entry in ipairs(chunk) do
					net.Start(config.dataName)
					net.WriteTable(entry)
					net.Send(client)
				end
			end
		)

		return delayInSeconds
	end

	---	Handle incoming requests for chunked data
	---	@param messageName string The registered message name
	---	@param callback fun(client: Player, requestData: table) Callback to call when request received
	function Schema.chunkedNetwork.HandleRequest(messageName, callback)
		local config = Schema.chunkedNetwork.handlers[messageName]

		if (not config) then
			error("Schema.chunkedNetwork: Message '" .. messageName .. "' not registered!")
		end

		net.Receive(config.requestName, function(len, client)
			local requestData = {}

			-- Read until we run out of data
			while (len > net.BytesLeft()) do
				local key = net.ReadString()
				local value = net.ReadType()

				requestData[key] = value
			end

			callback(client, requestData)
		end)
	end
elseif (CLIENT) then
	---	Send a request for chunked data
	---
	---	@param messageName string The registered message name
	---	@param requestData table The data to send with the request
	---	@param callback fun(receivedData: table, extraData: table) Callback to call when data is received
	function Schema.chunkedNetwork.Request(messageName, requestData, callback)
		local config = Schema.chunkedNetwork.handlers[messageName]
		if (not config) then
			error("Schema.chunkedNetwork: Message '" .. messageName .. "' not registered!")
		end

		-- Store the callback for when we receive the response
		Schema.chunkedNetwork.activeOperations[messageName] = {
			callback = callback,
			receivedData = {},
			extraData = {},
			remainingMessages = 0
		}

		-- Send the request
		net.Start(config.requestName)

		requestData = requestData or {}

		for key, value in pairs(requestData) do
			net.WriteString(key)
			net.WriteType(value)
		end

		net.SendToServer()
	end

	---	Set up the client-side receivers for a registered message
	---	This is called automatically when registering on client
	---	@param messageName string The registered message name
	function Schema.chunkedNetwork.SetupClientReceiver(messageName)
		local config = Schema.chunkedNetwork.handlers[messageName]

		-- Header receiver
		net.Receive(config.headerName, function(length)
			local messageAmount = net.ReadUInt(16)
			local operation = Schema.chunkedNetwork.activeOperations[messageName]

			if (not operation) then
				print("Schema.chunkedNetwork: Received header for '" .. messageName .. "' but no active operation!")
				return
			end

			-- Read extra data that was sent with header
			-- This is message-specific, so we store it for the callback
			operation.extraData = {}

			if (messageAmount == 0) then
				-- No data, call callback immediately
				operation.callback(operation.receivedData, operation.extraData)
				Schema.chunkedNetwork.activeOperations[messageName] = nil
				return
			end

			operation.remainingMessages = messageAmount
			operation.receivedData = {}
		end)

		-- Data receiver
		net.Receive(config.dataName, function(length)
			local entry = net.ReadTable()
			local operation = Schema.chunkedNetwork.activeOperations[messageName]

			if (not operation) then
				print("Schema.chunkedNetwork: Received data for '" .. messageName .. "' but no active operation!")
				return
			end

			table.insert(operation.receivedData, entry)
			operation.remainingMessages = operation.remainingMessages - 1

			-- Check if we've received all data
			if (operation.remainingMessages <= 0) then
				local receivedData = operation.receivedData
				local extraData = operation.extraData
				local callback = operation.callback

				Schema.chunkedNetwork.activeOperations[messageName] = nil
				callback(receivedData, extraData)
			end
		end)
	end
end

--- Cleanup function for when operations need to be cancelled
--- @param messageName? string The registered message name
function Schema.chunkedNetwork.Cleanup(messageName)
	if (messageName) then
		Schema.chunkedNetwork.activeOperations[messageName] = nil
	else
		Schema.chunkedNetwork.activeOperations = {}
	end
end
