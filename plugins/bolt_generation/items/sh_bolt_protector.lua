local ITEM = ITEM

ITEM.name = "BCU Protector"
ITEM.price = 200
ITEM.model = "models/props_combine/breenlight.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.noDrop = true
ITEM.category = "Wealth Generation & Protection"
ITEM.description = "When placed near a BCU it will reduce the damage they take by 50%%. This is not permanent and can be destroyed by others."

ITEM.functions.Place = {
	OnRun = function(item)
		local client = item.player
		local character = client:GetCharacter()
		local trace = client:GetEyeTraceNoCursor()

		if (trace.HitPos:Distance(client:GetShootPos()) > 192) then
			client:Notify("You cannot place a bolt protector that far away!")

			return false
		end

		local entity = ents.Create("exp_bolt_protector")
		entity:SetupBoltProtector(client)

		-- TODO: Limit the amount that can be spawned (TODO: This logic is repetitive, move it somewhere common)
		local protectors = character:GetVar("boltProtectors") or {}
		protectors[#protectors + 1] = entity
		character:SetVar("boltProtectors", protectors, true)

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

		return true
	end
}

function ITEM:OnCanOrder(client)
	local character = client:GetCharacter()
	local protectors = character:GetVar("boltProtectors") or {}

	if (#protectors >= 1) then
		client:Notify("You have reached the maximum amount of this item!")

		return false
	end
end
