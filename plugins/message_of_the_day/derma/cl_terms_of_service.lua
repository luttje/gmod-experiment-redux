local PLUGIN = PLUGIN
local PANEL = {}

function PANEL:Init()
    self.html = self:Add("DHTML")
    self.html:Dock(FILL)

    local html = file.Read(PLUGIN.folder .. "/html/terms-of-service.html", "LUA")

    html = html:Replace("{{privacy_email}}", ix.config.Get("privacyEmail"))
    html = html:Replace("{{github_url}}", ix.config.Get("githubUrl"))

    self.html:SetHTML(html)

    self.html.ConsoleMessage = function(html, message, file, line)
        if (not isstring(message)) then
            message = "*js variable*"
        end

        if (message == "TERMS_AGREED") then
            self:Close()

            net.Start("expAcceptTermsOfService")
            net.SendToServer()
		elseif (message == "TERMS_DISAGREED") then
            net.Start("expDisagreeTermsOfService")
            net.SendToServer()
        end
    end
end

vgui.Register("expTermsOfService", PANEL, "EditablePanel")
