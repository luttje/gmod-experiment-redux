local ITEM = ITEM

ITEM.name = "An Introduction"
ITEM.model = Model("models/props_lab/binderblue.mdl")
ITEM.description = "A comic book with a worn cover. It's filled with warnings."
ITEM.hideFrameTitleBar = true
ITEM.hideFrameCloseButton = true

function ITEM:GetText()
    local html = file.Read(Schema.folder .. "/schema/html/tutorial.html", "LUA")

	return html, true
end

function ITEM:GetFrameSize()
    return ScrW(), ScrH()
end
