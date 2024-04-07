local ITEM = ITEM

ITEM.name = "BCU Informer"
ITEM.price = 200
ITEM.model = "models/props_combine/breenlight.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.noDrop = true
ITEM.category = "Wealth Generation & Protection"
ITEM.description = "Place it near your bold creators, and be informed when they take damage."

ITEM.functions.Place = {
	OnRun = function(item)
		local client = item.player
		local character = client:GetCharacter()
		local trace = client:GetEyeTraceNoCursor()

		if (trace.HitPos:Distance(client:GetShootPos()) > 192) then
			client:Notify("You cannot place a bolt informer that far away!")

			return false
		end

		local entity = ents.Create("exp_bolt_informer")
		entity:SetupBoltInformer(client)

		-- TODO: Limit the amount that can be spawned (TODO: This logic is repetitive, move it somewhere common)
		local informers = character:GetVar("boltInformers") or {}
		informers[#informers + 1] = entity
		character:SetVar("boltInformers", informers, true)

		entity:SetPos(trace.HitPos)
		entity:Spawn()
		Schema.MakeFlushToGround(entity, trace.HitPos, trace.HitNormal)
	end,

	OnCanRun = function(item)
		local client = item.player
		local trace = client:GetEyeTraceNoCursor()

		if (trace.HitPos:Distance(client:GetShootPos()) > 192) then
			return false
		end

		local character = client:GetCharacter()
		local protectors = character:GetVar("boltInformers") or {}

		if (#protectors >= 1) then
			client:Notify("You have reached the maximum amount of this item!")

			return false
		end

		return true
	end
}

function ITEM:OnCanOrder(client)
	local character = client:GetCharacter()
	local protectors = character:GetVar("boltInformers") or {}

	if (#protectors >= 1) then
		client:Notify("You have reached the maximum amount of this item!")

		return false
	end
end
