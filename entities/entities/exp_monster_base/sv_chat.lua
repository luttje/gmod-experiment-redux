DEFINE_BASECLASS("base_ai")

function ENT:PrintChat(message, chatClass)
	local isYelling = chatClass == true or chatClass == MONSTER_CHAT_YELL
	local range = ix.config.Get("chatRange", 280) * (isYelling and 2 or 1)

	if (chatClass == MONSTER_CHAT_WHISPER) then
		range = range * 0.5
	end

	local receivers = {}

	for _, entity in ipairs(ents.FindInSphere(self:GetPos(), range)) do
		if (entity:IsPlayer()) then
			receivers[#receivers + 1] = entity
		end
	end

	ix.chat.Send(nil, "monster", message, false, receivers, {
		name = self:GetDisplayName(),
		yelling = isYelling == true
	})
end

function ENT:AddChat(message, listeners, chatClass)
	local isYelling = chatClass == true or chatClass == MONSTER_CHAT_YELL
	local range = ix.config.Get("chatRange", 280) * (isYelling and 2 or 1)

	if (chatClass == MONSTER_CHAT_WHISPER) then
		range = range * 0.5
	end

	ix.chat.Send(nil, "monster", message, false, listeners, {
		name = self:GetDisplayName(),
		yelling = isYelling == true,
		whispering = chatClass == MONSTER_CHAT_WHISPER
	})
end
