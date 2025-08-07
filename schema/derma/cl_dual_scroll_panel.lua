local PANEL = {}

AccessorFunc(PANEL, "m_bCanScrollX", "CanScrollX", FORCE_BOOL)
AccessorFunc(PANEL, "m_bCanScrollY", "CanScrollY", FORCE_BOOL)

function PANEL:Init()
	-- Enable both scrolling directions by default
	self.m_bCanScrollX = true
	self.m_bCanScrollY = true

	-- Create the canvas (content area)
	self.Canvas = vgui.Create("Panel", self)
	self.Canvas:SetPos(0, 0)

	-- Create vertical scrollbar
	self.VBar = vgui.Create("DVScrollBar", self)
	self.VBar:SetWide(15)
	self.VBar:Dock(RIGHT)

	-- Create horizontal scrollbar
	self.HBar = vgui.Create("DHScrollBar", self)
	self.HBar:SetTall(15)
	self.HBar:Dock(BOTTOM)

	-- Canvas content size tracking
	self.ContentWidth = 0
	self.ContentHeight = 0

	-- Track if we're currently updating to prevent recursion
	self.UpdatingPosition = false
	self.EventsSetup = false

	-- Setup scrollbar events after a delay to ensure scrollbars are ready
	timer.Simple(0.1, function()
		if IsValid(self) then
			self:SetupScrollbarEvents()
		end
	end)
end

function PANEL:SetupScrollbarEvents()
	if self.EventsSetup then return end
	self.EventsSetup = true

	-- Store original functions to avoid recursion
	local vbarOriginalOnMouseWheeled = self.VBar.OnMouseWheeled
	local hbarOriginalOnMouseWheeled = self.HBar.OnMouseWheeled

	-- Vertical scrollbar events
	self.VBar.OnMouseWheeled = function(s, delta)
		-- Call original function directly, don't go through our OnMouseWheeled
		if vbarOriginalOnMouseWheeled then
			local result = vbarOriginalOnMouseWheeled(s, delta)
			self:UpdateCanvasPosition()
			return result
		end
		return false
	end

	-- Horizontal scrollbar events
	self.HBar.OnMouseWheeled = function(s, delta)
		-- Call original function directly, don't go through our OnMouseWheeled
		if hbarOriginalOnMouseWheeled then
			local result = hbarOriginalOnMouseWheeled(s, delta)
			self:UpdateCanvasPosition()
			return result
		end
		return false
	end

	-- Override grip dragging for both scrollbars
	if IsValid(self.VBar.btnGrip) then
		local oldThink = self.VBar.btnGrip.Think
		self.VBar.btnGrip.Think = function(s)
			if oldThink then oldThink(s) end
			if s.Dragging then
				self:UpdateCanvasPosition()
			end
		end
	end

	if IsValid(self.HBar.btnGrip) then
		local oldThink = self.HBar.btnGrip.Think
		self.HBar.btnGrip.Think = function(s)
			if oldThink then oldThink(s) end
			if s.Dragging then
				self:UpdateCanvasPosition()
			end
		end
	end
end

function PANEL:AddItem(item)
	item:SetParent(self.Canvas)
	return item
end

function PANEL:Clear()
	self.Canvas:Clear()
	self:InvalidateLayout()
end

function PANEL:PerformLayout(w, h)
	local wide, tall = self:GetSize()

	-- Calculate content size
	local contentW, contentH = 0, 0

	for k, v in pairs(self.Canvas:GetChildren()) do
		if not IsValid(v) then continue end
		local x, y = v:GetPos()
		local vw, vh = v:GetSize()
		contentW = math.max(contentW, x + vw)
		contentH = math.max(contentH, y + vh)
	end

	self.ContentWidth = contentW
	self.ContentHeight = contentH

	-- Determine scrollbar visibility
	local vbarVisible = self.m_bCanScrollY and contentH > tall - 15
	local hbarVisible = self.m_bCanScrollX and contentW > wide - 15

	-- Account for scrollbars taking up space
	local availableW = wide - (vbarVisible and 15 or 0)
	local availableH = tall - (hbarVisible and 15 or 0)

	-- Re-check after accounting for scrollbar space
	vbarVisible = self.m_bCanScrollY and contentH > availableH
	hbarVisible = self.m_bCanScrollX and contentW > availableW

	-- Final available space
	availableW = wide - (vbarVisible and 15 or 0)
	availableH = tall - (hbarVisible and 15 or 0)

	-- Setup vertical scrollbar
	if vbarVisible then
		self.VBar:SetVisible(true)
		self.VBar:SetPos(wide - 15, 0)
		self.VBar:SetSize(15, availableH)
		self.VBar:SetUp(availableH, contentH)
	else
		self.VBar:SetVisible(false)
		if IsValid(self.VBar) then
			self.VBar:SetScroll(0)
		end
	end

	-- Setup horizontal scrollbar
	if hbarVisible then
		self.HBar:SetVisible(true)
		self.HBar:SetPos(0, tall - 15)
		self.HBar:SetSize(availableW, 15)
		self.HBar:SetUp(availableW, contentW)
	else
		self.HBar:SetVisible(false)
		if IsValid(self.HBar) then
			self.HBar:SetScroll(0)
		end
	end

	-- Size and position canvas
	self.Canvas:SetSize(math.max(availableW, contentW), math.max(availableH, contentH))

	-- Update canvas position
	self:UpdateCanvasPosition()
end

function PANEL:UpdateCanvasPosition()
	if not IsValid(self.Canvas) or self.UpdatingPosition then return end
	self.UpdatingPosition = true

	local x = IsValid(self.HBar) and -self.HBar:GetScroll() or 0
	local y = IsValid(self.VBar) and -self.VBar:GetScroll() or 0

	self.Canvas:SetPos(x, y)

	self.UpdatingPosition = false
end

function PANEL:OnMouseWheeled(delta)
	if not self:IsVisible() then return false end

	local ctrl = input.IsKeyDown(KEY_LCONTROL) or input.IsKeyDown(KEY_RCONTROL)
	local shift = input.IsKeyDown(KEY_LSHIFT) or input.IsKeyDown(KEY_RSHIFT)

	-- Horizontal scrolling with Shift+scroll or Ctrl+scroll
	if (shift or ctrl) and self.HBar:IsVisible() then
		-- Don't call the overridden function, call the original scrollbar method
		local oldScroll = self.HBar:GetScroll()
		self.HBar:AddScroll(delta * -20) -- Adjust scroll amount as needed
		if oldScroll ~= self.HBar:GetScroll() then
			self:UpdateCanvasPosition()
			return true
		end
		-- Vertical scrolling (default)
	elseif self.VBar:IsVisible() then
		-- Don't call the overridden function, call the original scrollbar method
		local oldScroll = self.VBar:GetScroll()
		self.VBar:AddScroll(delta * -20) -- Adjust scroll amount as needed
		if oldScroll ~= self.VBar:GetScroll() then
			self:UpdateCanvasPosition()
			return true
		end
	end

	return false
end

function PANEL:Paint(w, h)
	return true
end

-- Scrolling methods for external control
function PANEL:ScrollToTop()
	if IsValid(self.VBar) then
		self.VBar:SetScroll(0)
		self:UpdateCanvasPosition()
	end
end

function PANEL:ScrollToBottom()
	if IsValid(self.VBar) then
		self.VBar:SetScroll(self.VBar.CanvasSize or 0)
		self:UpdateCanvasPosition()
	end
end

function PANEL:ScrollToLeft()
	if IsValid(self.HBar) then
		self.HBar:SetScroll(0)
		self:UpdateCanvasPosition()
	end
end

function PANEL:ScrollToRight()
	if IsValid(self.HBar) then
		self.HBar:SetScroll(self.HBar.CanvasSize or 0)
		self:UpdateCanvasPosition()
	end
end

function PANEL:GetCanvas()
	return self.Canvas
end

function PANEL:GetVBar()
	return self.VBar
end

function PANEL:GetHBar()
	return self.HBar
end

-- Register the panel
vgui.Register("expDualScrollPanel", PANEL, "Panel")
