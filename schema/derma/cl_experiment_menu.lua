DEFINE_BASECLASS("ixMenu")

local PANEL = {}

function PANEL:Init()
    self:ParentToHUD()

    hook.Run("OnMainMenuCreated", self)
end

function PANEL:FullRefresh()
    local newMenuInstance = vgui.Create("expMenu")
    newMenuInstance:StopAnimations() -- Stop the fade-in animation

	self:TransferScrollPositions(self:GetActiveSubpanel(), newMenuInstance:GetActiveSubpanel())
end

-- When refreshing the menu, we want to bring our users back to the correct scroll position.
function PANEL:TransferScrollPositions(oldPanel, newPanel, delayRestore)
    local scrollPositions = {}
	delayRestore = delayRestore or 0.01

	local function forEachScrollableChild(panel, callback)
		local children = panel:GetChildren()
		local count = 0

		for k, child in ipairs(children) do
			if (IsValid(child) and child:IsVisible() and child.GetVBar and child:GetVBar()) then
				callback(child, count)
				count = count + 1
			end
		end
	end

	forEachScrollableChild(oldPanel, function(child, count)
		scrollPositions[count] = child:GetVBar():GetScroll()
    end)

	-- TODO: Find better way to time this.
	timer.Simple(delayRestore, function()
		if (not IsValid(newPanel)) then
			return
		end

		forEachScrollableChild(newPanel, function(child, count)
			local scroll = scrollPositions[count]

			child:GetVBar():SetScroll(scroll)
		end)
	end)
end

vgui.Register("expMenu", PANEL, "ixMenu")
