local PLUGIN = PLUGIN

include("shared.lua")

function ENT:Initialize()
	self.random = math.random()
end

local sparkSounds = {
	"ambient/energy/spark1.wav",
	"ambient/energy/spark2.wav",
	"ambient/energy/spark3.wav",
	"ambient/energy/spark4.wav",
	"ambient/energy/spark5.wav",
	"ambient/energy/spark6.wav"
}

function ENT:GetSparkChance()
	return math.ceil(math.Rand(8, 15) * self.random)
end

function ENT:Think()
	if (not self.nextSparkChance) then
		self.nextSparkChance = self:GetSparkChance()
	end

	if (math.floor(CurTime()) % self.nextSparkChance == 1) then
		self.nextSparkChance = self:GetSparkChance()
		self.justSparked = true
		self:EmitSound(table.Random(sparkSounds), 30, 100 - (50 * math.random()), 1)
	end
end

local function vectorToString(vector)
	return string.format("Vector(%d, %d, %d)", vector.x, vector.y, vector.z)
end
local function anglesToString(angles)
	return string.format("Angle(%d, %d, %d)", angles.p, angles.y, angles.r)
end

local highlightedEntity

net.Receive("expMonitorConfig", function()
	local entity = net.ReadEntity()
	local frame = vgui.Create("DFrame")
	frame:SetTitle("Monitor screen configuration")
	frame:SetSize(ScrW() * .25, ScrH() * .5)
	frame:Center()
	frame:MakePopup()

	local panelList = vgui.Create("DPanelList", frame)
	panelList:SetSpacing(10)
	panelList:SetPadding(10)
	panelList:Dock(FILL)

	local widthForm = vgui.Create("DPanelList", frame)
	widthForm:SetAutoSize(true)
	widthForm:SetPadding(0)
	local widthLabel = vgui.Create("DLabel", frame)
	widthLabel:SetText("Width:")
	widthLabel:SizeToContents()
	widthForm:AddItem(widthLabel)

	local widthScratch = vgui.Create("DNumberScratch", frame)
	widthScratch:SetValue(entity:GetMonitorWidth())
	widthScratch:SetMin(0)
	widthScratch:SetMax(7680)
	widthForm:AddItem(widthScratch)
	panelList:AddItem(widthForm)

	local heightForm = vgui.Create("DPanelList", frame)
	heightForm:SetAutoSize(true)
	heightForm:SetPadding(0)
	local heightLabel = vgui.Create("DLabel", frame)
	heightLabel:SetText("Height:")
	heightLabel:SizeToContents()
	heightForm:AddItem(heightLabel)

	local heightScratch = vgui.Create("DNumberScratch", frame)
	heightScratch:SetValue(entity:GetMonitorHeight())
	heightScratch:SetMin(0)
	heightScratch:SetMax(4320)
	heightForm:AddItem(heightScratch)
	panelList:AddItem(heightForm)

	local scaleForm = vgui.Create("DPanelList", frame)
	scaleForm:SetAutoSize(true)
	scaleForm:SetPadding(0)
	local scaleLabel = vgui.Create("DLabel", frame)
	scaleLabel:SetText("Scale:")
	scaleLabel:SizeToContents()
	scaleForm:AddItem(scaleLabel)

	local scaleScratch = vgui.Create("DNumberScratch", frame)
	scaleScratch:SetValue(entity:GetMonitorScale())
	scaleScratch:SetMin(0)
	scaleScratch:SetMax(5)
	scaleScratch:SetDecimals(4)
	scaleForm:AddItem(scaleScratch)
	panelList:AddItem(scaleForm)

	local parent = entity:GetParent()
	local function sendChanges()
		local width = widthScratch:GetFloatValue()
		local height = heightScratch:GetFloatValue()
		local scale = scaleScratch:GetFloatValue()

		net.Start("expMonitorConfigResponse")
		net.WriteFloat(width)
		net.WriteFloat(height)
		net.WriteFloat(scale)
		net.WriteEntity(parent)
		net.SendToServer()
	end
	widthScratch.OnValueChanged = sendChanges
	heightScratch.OnValueChanged = sendChanges
	scaleScratch.OnValueChanged = sendChanges

	local propParentForm = vgui.Create("DPanelList", frame)
	propParentForm:SetAutoSize(true)
	propParentForm:SetPadding(0)
	local scroll = vgui.Create("DScrollPanel", frame)
	scroll:SetTall(256)

	local list = vgui.Create("DIconLayout", scroll)
	list:Dock(FILL)
	list:SetSpaceY(5)
	list:SetSpaceX(5)

	local entities = ents.FindInSphere(entity:GetPos(), 256)
	for _, nearbyEntity in ipairs(entities) do
		local model = nearbyEntity:GetModel()

		if (model == nil or not util.IsValidModel(model)) then
			continue
		end

		local spawnIcon = list:Add("SpawnIcon")
		spawnIcon:SetModel(model)
		spawnIcon:SetSize(80, 80)
		spawnIcon.nearbyEntity = nearbyEntity
		spawnIcon.DoClick = function()
			parent = nearbyEntity
			sendChanges()
		end

		local function onCursorEntered(self)
			highlightedEntity = self.nearbyEntity
		end

		local function OnCursorExited(self)
			highlightedEntity = nil
		end

		spawnIcon.OnCursorEntered = onCursorEntered
		spawnIcon.OnCursorExited = onCursorExited
	end
	propParentForm:AddItem(scroll)
	panelList:AddItem(propParentForm)

	local parentModelButton = vgui.Create("DButton", frame)
	parentModelButton:SetText("Set parent model to this model")
	parentModelButton:SizeToContents()
	parentModelButton:SetWide(panelList:GetWide())
	parentModelButton.DoClick = function()
		if (not IsValid(parent)) then
			ix.util.Notify("You must select a parent entity first.")
			return
		end

		-- Find the positions relative to the ent
		local relativePosition = parent:WorldToLocal(entity:GetPos())
		local relativeAngles = parent:WorldToLocalAngles(entity:GetAngles())

		local stub = [[
			keyForPreset = {
				spawn = function(client, trace)
					local parent = ents.Create("prop_physics")
					parent:SetModel("]].. parent:GetModel() ..[[")
					parent:SetPos(trace.HitPos)
					parent:Spawn()
					local monitor = ents.Create("exp_monitor")
					monitor:SetMonitorWidth(]].. entity:GetMonitorWidth() ..[[)
					monitor:SetMonitorHeight(]].. entity:GetMonitorHeight() ..[[)
					monitor:SetMonitorScale(]].. entity:GetMonitorScale() ..[[)
					monitor:ConfigureParent(parent, ]]..vectorToString(relativePosition)..[[, ]]..anglesToString(relativeAngles)..[[)
					monitor:Spawn()
					PLUGIN:RelatePropToMonitor(parent, monitor)
				end
			end
		]]

		print(stub)
	end
	panelList:AddItem(parentModelButton)
end)

hook.Add("PreDrawHalos", "expAddPropHalosOnHighlight", function()
	if (highlightedEntity) then
		halo.Add({ highlightedEntity }, Color(255, 0, 0), 5, 5, 2)
	end
end)

-- Called when the entity should draw.
function ENT:Draw()
	if (self:GetIsHelper()) then
		self:DrawModel()
	end
end

-- From: https://wiki.facepunch.com/gmod/surface.DrawPoly
local function drawCircle(x, y, radius, seg)
	local cir = {}

	table.insert(cir, { x = x, y = y, u = 0.5, v = 0.5 })
	for i = 0, seg do
		local a = math.rad((i / seg) * -360)
		table.insert(cir,
			{ x = x + math.sin(a) * radius, y = y + math.cos(a) * radius, u = math.sin(a) / 2 + 0.5, v = math.cos(a) / 2 +
			0.5 })
	end

	local a = math.rad(0) -- This is needed for non absolute segment counts
	table.insert(cir,
		{ x = x + math.sin(a) * radius, y = y + math.cos(a) * radius, u = math.sin(a) / 2 + 0.5, v = math.cos(a) / 2 +
		0.5 })

	surface.DrawPoly(cir)
end
