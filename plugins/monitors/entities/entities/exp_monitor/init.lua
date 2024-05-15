local PLUGIN = PLUGIN

AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

util.AddNetworkString("expMonitorConfig")
util.AddNetworkString("expMonitorConfigResponse")

function ENT:Initialize()
	self:SetModel("models/props_lab/huladoll.mdl")
	-- self:SetSolid(SOLID_NONE) -- Bad for traces
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self:SetMoveType(MOVETYPE_NOCLIP)

	local state = self:GetPoweredOn()
	self:SetPoweredOn(state ~= nil and state or true)

	self:SetMonitorScale(self:GetMonitorScale() or 1)
	self:SetMonitorWidth(self:GetMonitorWidth() or 800)
	self:SetMonitorHeight(self:GetMonitorHeight() or 600)

	--[[
    FOR CRT MONITORS/TV's:  ambient/machines/electrical_hum_2.wav
                            ambient/machines/combine_shield_touch_loop1.wav
                            ambient/energy/force_field_loop1.wav
                            ambient/energy/electric_loop.wav
                            ambient/machines/power_transformer_loop_1.wav
                            ambient/machines/power_transformer_loop_2.wav
    FOR THINGS WITH FANS:   ambient/machines/refrigerator.wav
  --]]
	local soundEmitter = self

	if (IsValid(self:GetParent())) then
		soundEmitter = self:GetParent()
	end

	soundEmitter:EmitSound("ambient/machines/electrical_hum_2.wav", 40, 100 - (50 * math.random()), 1)
end

function ENT:SetHelper(isHelper)
	self:SetIsHelper(isHelper)

	if (isHelper) then
		self:SetUseType(SIMPLE_USE)
	end
end

function ENT:ConfigureParent(parent, vector, angles)
	self._parentOffset = vector
	self:SetParent(parent)

	-- !!! Because we set Solid to SOLID_NONE, we will always be relative to the world when positioning
	self:SetPos(parent:LocalToWorld(vector))
    self:SetAngles(parent:LocalToWorldAngles(angles))

	if (IsValid(parent) and parent:GetClass() ~= "exp_monitor_static") then
		PLUGIN:RelateMonitorToParent(self, parent)
	end
end

function ENT:Think()
	local parent = self:GetParent()

	if (IsValid(parent)) then
		if (not self._lastModelScale or self._lastModelScale ~= parent:GetModelScale()) then
			self._lastModelScale = parent:GetModelScale()

			self:SetPos(parent:LocalToWorld(self._parentOffset * self._lastModelScale))
		end
	end
end

function ENT:OnTakeDamage(dmgInfo)
	dmgInfo:ScaleDamage(0)
end

function ENT:Use(activator, caller)
	if (not activator:IsPlayer()) then
		return
	end

	if (activator._targetMonitorNextConfig and activator._targetMonitorNextConfig > CurTime()) then
		return
	end

	if (not activator:IsSuperAdmin()) then
		activator:Notify("You must be a super admin to configure monitors.")
		return
	end

	activator._targetMonitor = self
	activator._targetMonitorNextConfig = CurTime() + 1
	self:SetPoweredOn(true)
	net.Start("expMonitorConfig")
	net.WriteEntity(self)
	net.Send(activator)
end

net.Receive("expMonitorConfigResponse", function(length, client)
	local width = net.ReadFloat()
	local height = net.ReadFloat()
	local scale = net.ReadFloat()

	local parent = net.ReadEntity()

	if (not client:IsSuperAdmin()) then
		client:Notify("You must be a super admin to configure monitors.")
		return
	end

	local monitor = client._targetMonitor

	if (not IsValid(monitor)) then
		client:Notify("You are not configuring a monitor!")
		return
	end

	monitor:SetMonitorWidth(width)
	monitor:SetMonitorHeight(height)
	monitor:SetMonitorScale(scale)

	if (not IsValid(parent)) then
		client:Notify("You must select a parent entity first!")
		return
	end

	PLUGIN:RelateMonitorToParent(monitor, parent)
end)

-- For now it can't take damage
function ENT:OnTakeDamage(damageInfo)
	damageInfo:ScaleDamage(0)
end

function ENT:OnRemove()
	local parent = self:GetParent()

	if (IsValid(parent)) then
		-- Remove the related monitors and the parent
		for _, monitor in ipairs(parent._relatedMonitors or {}) do
			if (IsValid(monitor)) then
				monitor:Remove()
			end
		end

		parent:Remove()
	end
end
