local PLUGIN = PLUGIN

PLUGIN.name = "Moon"
PLUGIN.author = "Experiment Redux"
PLUGIN.description = "Draws an infinitely far away moon in the skybox."

if (SERVER) then
	resource.AddFile("materials/experiment-redux/moon.vmt")

	function PLUGIN:InitPostEntity()
		local sun = ents.FindByClass("env_sun")[1]

		if (IsValid(sun)) then
			SetGlobal2Angle("sun_angles", sun:GetAngles())
			return
		end

		local light = ents.FindByClass("light_environment")[1]

		if (IsValid(light)) then
			SetGlobal2Angle("sun_angles", light:GetAngles())
			return
		end
	end
end

ix.config.Add("moonSize", 4000, "The size of the moon.", nil, {
	data = {min = 0, max = 10000},
	category = "moon"
})

ix.config.Add("moonDistance", 27000, "The distance of the moon from the player.", nil, {
	data = {min = 1, max = 27000},
	category = "moon"
})

if (not CLIENT) then
	return
end

local moonMaterial = Material("experiment-redux/moon")

function PLUGIN:PostDrawOpaqueRenderables(isDrawingDepth, isDrawingSkybox, isDrawing3dSkybox)
	if (not isDrawing3dSkybox) then
		return
	end

	local client = LocalPlayer()

	if (not IsValid(client)) then
		return
	end

	if (not IsValid(self.sunAngles)) then
		self.sunAngles = GetGlobal2Angle("sun_angles") or Angle(-60, 0, 0)
	end

	local moonSize = ix.config.Get("moonSize")
	local moonDistance = ix.config.Get("moonDistance")
	local moonDirection = self.sunAngles:Forward()

	-- X is flipped because the moon is on the other side of the skybox
	moonDirection.x = -moonDirection.x

	local moonPos = client:GetPos() + moonDirection * moonDistance

	cam.Start3D()
	render.SetMaterial(moonMaterial)
	render.DrawSprite(moonPos, moonSize, moonSize, Color(255, 255, 255))
	cam.End3D()
end
