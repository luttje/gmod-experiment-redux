-- Experiment Entity Menu with no list, but a custom panel to the right of the entity and optionally a panel over the entity.
local PANEL = {}
local padding = 8

local MAIN_PANEL_FRACTION = 0.5
local ENTITY_PANEL_FRACTION = 1 - MAIN_PANEL_FRACTION

DEFINE_BASECLASS("ixEntityMenu")

function PANEL:Init()
    self.list:Remove()
	self.list = self:Add("EditablePanel")
	self.list:Dock(FILL)
    self.list:SetPaintedManually(true)
    self.list.OnMousePressed = function(code)
        self:Remove()
    end

    -- Draw a button to close the menu.
    self.closeButton = self:Add("DImageButton")
    self.closeButton:SetSize(48, 48)
	self.closeButton:SetIcon("experiment-redux/close.png")
	self.closeButton:SetPos(ScrW() - self.closeButton:GetWide() - padding, padding)
	self.closeButton.DoClick = function()
		self:Remove()
	end
end

function PANEL:SetOptions(options)
	ix.util.SchemaErrorNoHalt("expEntityMenu: SetOptions is not supported for this panel.")
end

function PANEL:SetMainPanel(panel)
    self.mainPanel = panel

    panel:SetParent(self.list)
    panel:SetSize(ScrW() * MAIN_PANEL_FRACTION, ScrH())
	panel:SetPos(ScrW() * ENTITY_PANEL_FRACTION, 0)
end

function PANEL:SetEntityPanel(panel)
    self.entityPanel = panel

    panel:SetParent(self.list)
	panel:SetSize(ScrW() * ENTITY_PANEL_FRACTION, ScrH())
	panel:SetPos(0, 0)
end

function PANEL:GetOverviewInfo(origin, angles)
	local entity = self.entity

	if (IsValid(entity)) then
		local radius = entity:BoundingRadius() * 0.5
        local center = entity:LocalToWorld(entity:OBBCenter()) + LocalPlayer():GetRight() * radius

        center = center + entity:GetUp() * (radius * 0.5)

		return LerpAngle(self.bClosing and self.alpha or self.blur, angles, (center - origin):Angle())
	end

	return angles
end

-- Mostly copied from ixEntityMenu, bar the bottom where we don't use the list, but the panels instead.
function PANEL:Think()
	local entity = self.entity
	local distance = 0

	if (IsValid(entity)) then
		local position = entity:GetPos()
		distance = LocalPlayer():GetShootPos():DistToSqr(position)

		if (distance > 65536) then
			self:Remove()
			return
		end

		self.lastPosition = position
	end

	self.desiredHeight = ScrH()
end

function PANEL:Paint(width, height) -- luacheck: ignore 312
	local selfHalf = self:GetTall() * 0.5
	local entity = self.entity

	height = self.desiredHeight + padding * 2
	width = self.blur * width

	local y = selfHalf - height * 0.5

	DisableClipping(true) -- for cheap blur
	render.SetScissorRect(0, y, width, y + height, true)
		if (IsValid(entity)) then
			cam.Start3D()
				ix.util.ResetStencilValues()
				render.SetStencilEnable(true)
				-- cam.IgnoreZ(true)
					render.SetStencilWriteMask(29)
					render.SetStencilTestMask(29)
					render.SetStencilReferenceValue(29)

					render.SetStencilCompareFunction(STENCIL_ALWAYS)
					render.SetStencilPassOperation(STENCIL_REPLACE)
					render.SetStencilFailOperation(STENCIL_KEEP)
					render.SetStencilZFailOperation(STENCIL_KEEP)

					entity:DrawModel()

					render.SetStencilCompareFunction(STENCIL_NOTEQUAL)
					render.SetStencilPassOperation(STENCIL_KEEP)

					cam.Start2D()
						ix.util.DrawBlur(self, 10)
					cam.End2D()
				-- cam.IgnoreZ(false)
				render.SetStencilEnable(false)
			cam.End3D()
		else
			ix.util.DrawBlur(self, 10)
		end
	render.SetScissorRect(0, 0, 0, 0, false)
	DisableClipping(false)

	-- scissor again because 3d rendering messes with the clipping apparently?
	render.SetScissorRect(0, y, width, y + height, true)
		surface.SetDrawColor(ix.config.Get("color"))
		surface.DrawRect(ScrW() * 0.5, y + padding, 1, height - padding * 2)

		self.list:PaintManual()
	render.SetScissorRect(0, 0, 0, 0, false)
end

vgui.Register("expEntityMenu", PANEL, "ixEntityMenu")
