local PLUGIN = PLUGIN

PLUGIN.name = "Bug Reporter"
PLUGIN.author = "Experiment Redux"
PLUGIN.description = "Adds a bug reporter UI for players to report issues directly to GitHub issues."

ix.util.Include("sv_plugin.lua")

if (CLIENT) then
	PLUGIN.luaErrors = PLUGIN.luaErrors or {}

	function PLUGIN:OnLuaError(error, realm, stack, name, id)
		local errorData = {
			error = error,
			realm = realm,
			stack = stack,
			name = name,
			id = id,
			timestamp = os.date("%Y-%m-%d %H:%M:%S"),
		}

		table.insert(self.luaErrors, errorData)

		if (#self.luaErrors > 100) then
			table.remove(self.luaErrors, 1) -- Keep the last 100 errors
		end
	end

	function PLUGIN:GetLuaErrors()
		return self.luaErrors
	end

	net.Receive("expBugReporterOpen", function()
		local frame = vgui.Create("expBugReporter")
		frame:MakePopup()

		Schema.bugReporter = frame
	end)
end

do
	local COMMAND = {}

	COMMAND.description = "Open the Bug Reporter UI."

	function COMMAND:OnRun(client)
		net.Start("expBugReporterOpen")
		net.Send(client)
	end

	ix.command.Add("ReportBug", COMMAND)
end
