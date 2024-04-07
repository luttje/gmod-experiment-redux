-- Overriden lua/tacrp/client/cl_bind.lua to remove complaints
function TacRP.GetBind(binding)
    local bind = input.LookupBinding(binding)

    if !bind then
        return "!"
    end

    return string.upper(bind)
end
