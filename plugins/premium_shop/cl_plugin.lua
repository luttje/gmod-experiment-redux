local PLUGIN = PLUGIN

--- Supporters get a heart icon in OOC chat, except if they're also moderator/operator, admin or superadmin
function PLUGIN:GetPlayerIcon(speaker)
  if (speaker:IsSuperAdmin() or speaker:IsAdmin() or speaker:IsUserGroup("moderator") or speaker:IsUserGroup("operator")) then
    return
  end

  if (speaker:HasPremiumPackage("supporter-role-lifetime")) then
    return "icon16/heart.png"
  end
end
