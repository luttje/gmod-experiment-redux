DEFINE_BASECLASS("ixMenu")
local PANEL = {}

function PANEL:Init()
    self:ParentToHUD()

    hook.Run("OnMainMenuCreated", self)
end

vgui.Register("expMenu", PANEL, "ixMenu")
