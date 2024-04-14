-- Overriden lua/tacrp/client/cl_bind.lua to remove complaints
function TacRP.GetBind(binding)
    local bind = input.LookupBinding(binding)

    if !bind then
        return "!"
    end

    return string.upper(bind)
end

-- This removes autoreloading and melee attacks with weapons (which would require binding +tacrp_melee)
hook.Remove("CreateMove", "TacRP_CreateMove")

function PLUGIN:ShowCompatibleItems(attachmentId)
	local window = vgui.Create("expAttachmentList")
	window:Populate(attachmentId)
end
