ATTRIBUTE.name = "Acrobatics"
ATTRIBUTE.description = "Affects the overall height at which you can jump."

function ATTRIBUTE:OnSetup(client, value)
	client:SetJumpPower(200 + value)
end
