
local PANEL = {}

local function StructureSetPermission(door, target, permission)
	net.Start("ixStructurePermission")
		net.WriteEntity(door)
		net.WriteEntity(target)
		net.WriteUInt(permission, 4)
	net.SendToServer()
end

function PANEL:Init()
	self:SetSize(280, 240)
	self:SetTitle(L"structureSettings")
	self:Center()
	self:MakePopup()

	self.access = self:Add("DListView")
	self.access:Dock(FILL)
	self.access:AddColumn(L"name").Header:SetTextColor(Color(25, 25, 25))
	self.access:AddColumn(L"access").Header:SetTextColor(Color(25, 25, 25))
	self.access.OnClickLine = function(this, line, selected)
		if (IsValid(line.player)) then
			local menu = DermaMenu()
				menu:AddOption(L"tenant", function()
					if (self.accessData and self.accessData[line.player] ~= DOOR_TENANT) then
						StructureSetPermission(self.door, line.player, DOOR_TENANT)
					end
				end):SetImage("icon16/user_add.png")
				menu:AddOption(L"guest", function()
					if (self.accessData and self.accessData[line.player] ~= DOOR_GUEST) then
						StructureSetPermission(self.door, line.player, DOOR_GUEST)
					end
				end):SetImage("icon16/user_green.png")
				menu:AddOption(L"none", function()
					if (self.accessData and self.accessData[line.player] ~= DOOR_NONE) then
						StructureSetPermission(self.door, line.player, DOOR_NONE)
					end
				end):SetImage("icon16/user_red.png")
			menu:Open()
		end
	end
end

function PANEL:SetStructure(door, access, door2)
	door.ixPanel = self

	self.accessData = access
	self.door = door

	for _, v in ipairs(player.GetAll()) do
		if (v ~= LocalPlayer() and v:GetCharacter()) then
			self.access:AddLine(v:Name(), L(ACCESS_LABELS[access[v] or 0])).player = v
		end
	end
end

function PANEL:CheckAccess(access)
	access = access or DOOR_GUEST

	if ((self.accessData[LocalPlayer()] or 0) >= access) then
		return true
	end

	return false
end

function PANEL:Think()
	if (self.accessData and !IsValid(self.door) and self:CheckAccess()) then
		self:Remove()
	end
end

vgui.Register("expStructureAccessMenu", PANEL, "DFrame")
