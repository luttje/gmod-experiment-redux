local PLUGIN = PLUGIN

PLUGIN.name = "The Business"
PLUGIN.author = "Experiment Redux"
PLUGIN.description = "Adds physical business locations to the server, that appear at random locations."

if (not CLIENT) then
    return
end

PLUGIN.businessOutlets = PLUGIN.businessOutlets or {}
PLUGIN.businessOutletWindowAnimations = PLUGIN.businessOutletWindowAnimations or {}

local DISTANCE_FROM_WALL = 1
local TEXTURE_SIZE = 1024

local ANIMATE_WALL_OPEN = {
    move = function(model, start, finish, duration, startTime)
        startTime = startTime or CurTime()
        local endTime = startTime + duration

        PLUGIN.businessOutletWindowAnimations[#PLUGIN.businessOutletWindowAnimations + 1] = {
            model = model,
            startTime = startTime,
            endTime = endTime,
            start = start,
            finish = finish
        }

        return endTime
    end
}

function PLUGIN:DoDrawModel(model)
    cam.PushModelMatrix(model:GetWorldTransformMatrix())
    model:DrawModel()
    cam.PopModelMatrix()
end

--- Takes a given position for a point on a surface, creates a render target and renders the surface to it (render.RenderView)
--- @param position Vector
--- @param angles Angle # The angle of the surface
--- @return ITexture
function PLUGIN:RenderWall(position, angles)
    -- TODO: Reuse render targets from a pool (e.g: if we need 10, only create 10, then reuse them)
    -- TODO: So don't give em these unique names, just give them a number 1-10
    local name = util.CRC(
		"surface_" .. position.x .. "_" .. position.y .. "_" .. position.z ..
        "#" .. angles.p .. "_" .. angles.y .. "_" .. angles.r
	)
    local renderTarget = GetRenderTarget(
        name,
        TEXTURE_SIZE,
        TEXTURE_SIZE
    )
    render.PushRenderTarget(renderTarget)
    render.Clear(0, 0, 0, 255, true, true)

    -- To brighten the model without setting up lighting
    render.SuppressEngineLighting(true)

    -- By default, 3D rendering to a Render Target will put the Depth Buffer into the alpha channel of the image.
    -- I do not know why this is the case, but we can disable that behavior with this function.
    render.SetWriteDepthToDestAlpha(false)

    local scaledTextureSize = (TEXTURE_SIZE * 0.025) -- dunno where this number comes from, but it works for most surfaces (maybe lightmapscale?)

    render.RenderView({
        origin = position,
        angles = angles,
        x = 0,
        y = 0,
        w = TEXTURE_SIZE,
        h = TEXTURE_SIZE,
        drawviewmodel = false,
        viewid = VIEW_MONITOR,

        znear = 1,
        zfar = 32768,
        ortho = {
            left   = -scaledTextureSize,
            right  = scaledTextureSize,
            top    = -scaledTextureSize,
            bottom = scaledTextureSize
        }
    })

    render.SetWriteDepthToDestAlpha(true)
    render.SuppressEngineLighting(false)

    render.PopRenderTarget()

    return renderTarget
end

--- Sets a render target as the material of an entity
--- @param entity Entity
--- @param renderTarget ITexture
function PLUGIN:SetRenderTargetMaterial(entity, renderTarget)
    local name = renderTarget:GetName()
    local material = CreateMaterial(name, "VertexLitGeneric", {
        ["$basetexture"] = renderTarget:GetName(),
        ["$model"] = 1,
        ["$translucent"] = 0,
        ["$vertexalpha"] = 0,
        ["$vertexcolor"] = 0,
    })

    entity:SetMaterial("!" .. name)
end

--- lua_run_cl tr = LocalPlayer():GetEyeTraceNoCursor() ix.plugin.Get("the_business"):CreateWallReplacement(tr.HitPos, tr.HitNormal:Angle(), "models/hunter/plates/plate1x1.mdl")
--- Creates a prop with a render target material
--- @param position Vector
--- @param angles Angle
--- @param plane string
function PLUGIN:CreateWallReplacement(position, angles, plane)
    -- Rotate so the we render the surface from the way the player is looking
    angles:RotateAroundAxis(angles:Up(), -180)

    local surfacePosition = Vector(position)
    local surfaceAngles = Angle(angles)

    -- Move the position a bit away from the surface, so we render the surface (not from inside the surface)
    position = position + (angles:Forward() * -DISTANCE_FROM_WALL)

    local renderTarget = self:RenderWall(position, angles)

    -- Flip the model to face the right way
    surfaceAngles:RotateAroundAxis(surfaceAngles:Right(), -90)

    -- Move the model into the surface so it can appear coming out of the surface
    local INTO_SURFACE_BY = 5
    surfacePosition = surfacePosition + (surfaceAngles:Up() * INTO_SURFACE_BY)

    local entity = ClientsideModel(plane)
    entity:SetPos(surfacePosition)
    entity:SetAngles(surfaceAngles)
    entity:Spawn()
    entity:SetNoDraw(true)

    self:SetRenderTargetMaterial(entity, renderTarget)

    local outletAngles = Angle(surfaceAngles)
    outletAngles:RotateAroundAxis(outletAngles:Right(), 180)
    outletAngles:RotateAroundAxis(outletAngles:Up(), -90)

    local forward = surfaceAngles:Up() * -INTO_SURFACE_BY

	local element = vgui.Create("expBusinessTerminal")
	element:SetSize(512, 512)
	element:SetPaintedManually(true)

	local businessOutlet = {
		entity = entity,
		position = surfacePosition + forward + (surfaceAngles:Right() * -23.5) + (surfaceAngles:Forward() * -23.5),
		angles = outletAngles,
		vgui = element,
		vguiShowAt = CurTime() + 2 -- When the wall is done moving forward
	}
	PLUGIN.businessOutlets[#PLUGIN.businessOutlets + 1] = businessOutlet

	---
	businessOutlet.shopkeeperRenderTarget = businessOutlet.shopkeeperRenderTarget or GetRenderTarget("ShopKeeperView", TEXTURE_SIZE, TEXTURE_SIZE) -- TODO: Reuse render targets, allow multiple
	businessOutlet.shopkeeperRenderTargetMaterial = businessOutlet.shopkeeperRenderTargetMaterial or CreateMaterial("ShopKeeperViewMaterial", "UnlitGeneric", {
		["$basetexture"] = businessOutlet.shopkeeperRenderTarget:GetName(),
		["$translucent"] = 0,
		["$vertexcolor"] = 1
    })
	---

    local targets = {
        { transform = forward, time = 2 },
        { transform = surfaceAngles:Right() * 48, time = 4 }
    }
    local endTime = nil
    local previousPosition = surfacePosition

    for i, target in ipairs(targets) do
        local targetPosition = previousPosition + target.transform
        endTime = ANIMATE_WALL_OPEN.move(entity, previousPosition, targetPosition, target.time, endTime)
        previousPosition = targetPosition
    end
end

function PLUGIN:Think()
    for i, anim in ipairs(PLUGIN.businessOutletWindowAnimations) do
        local model = anim.model
        local startTime = anim.startTime
        local endTime = anim.endTime
        local start = anim.start
        local finish = anim.finish

        local time = CurTime()
        local progress = (time - startTime) / (endTime - startTime)

        if (progress >= 1) then
            table.remove(PLUGIN.businessOutletWindowAnimations, i)
            continue
        end

        -- Check if its started already
        if (time < startTime) then
            continue
        end

        local position = Lerp(progress, start, finish)
        model:SetPos(position)
    end

	self:RenderScene()
end

function PLUGIN:PostDrawOpaqueRenderables(drawingDepth, drawingSkybox, drawingSkybox3d)
    if (drawingSkybox) then
        return
    end

    for _, businessOutlet in ipairs(PLUGIN.businessOutlets) do
        if (not businessOutlet.vgui or (businessOutlet.vguiShowAt and businessOutlet.vguiShowAt > CurTime())) then
            continue
        end

		local scale = 0.093
        cam.Start3D2D(businessOutlet.position, businessOutlet.angles, scale)

		-- Source for Mouse X, Y logic: https://github.com/wyozi-gmod/imgui/blob/master/imgui.lua
        if (not vgui.CursorVisible() or vgui.IsHoveringWorld()) then
            local trace = LocalPlayer():GetEyeTrace()
            local eyePosition = trace.StartPos
            local eyeNormal

            if (vgui.CursorVisible() and vgui.IsHoveringWorld()) then
                eyeNormal = gui.ScreenToVector(input.GetCursorPos())
            else
                eyeNormal = trace.Normal
            end

            local planeNormal = businessOutlet.angles:Up()

            local hitPos = util.IntersectRayWithPlane(eyePosition, eyeNormal, businessOutlet.position, planeNormal)

            if (not hitPos) then
				PLUGIN.worldMousePosition = nil
            else
				local diff = businessOutlet.position - hitPos

				-- This cool code is from Willox's keypad CalculateCursorPos
				local x = diff:Dot(-businessOutlet.angles:Forward()) / scale
				local y = diff:Dot(-businessOutlet.angles:Right()) / scale

				PLUGIN.worldMousePosition = {x = x, y = y}
            end
        else
            PLUGIN.worldMousePosition = nil
        end

		surface.SetDrawColor(255, 255, 255, 255)
		businessOutlet.vgui:PaintManual()
		cam.End3D2D()
	end

	-- -- Draw the shopkeepers as 3D2D on the wall
	-- for _, businessOutlet in ipairs(PLUGIN.businessOutlets) do
	-- 	if (not businessOutlet.shopkeeperRenderTargetMaterial) then
	-- 		continue
	-- 	end

	-- 	local scale = 0.093
	-- 	cam.Start3D2D(businessOutlet.position, businessOutlet.angles, scale)
	-- 	surface.SetDrawColor(255, 255, 255, 255)
	-- 	surface.SetMaterial(businessOutlet.shopkeeperRenderTargetMaterial)
	-- 	surface.DrawTexturedRect(0, 0, 512, 512)
	-- 	cam.End3D2D()
	-- end

	-- Draw the wall models
    render.SuppressEngineLighting(true)
    render.ResetModelLighting(.5, .5, .5) -- Why does this make the models exactly the right brightness?
    for _, businessOutlet in ipairs(PLUGIN.businessOutlets) do
        self:DoDrawModel(businessOutlet.entity)
    end
    render.SuppressEngineLighting(false)

    for _, businessOutlet in ipairs(PLUGIN.businessOutlets) do
        render.RenderFlashlights(function()
            self:DoDrawModel(businessOutlet.entity)
        end)
    end
end

--[=====[
Nope, the math for this is beyond me. Can't get it to look like looking through a hole in the wall... :(
--- lua_run_cl ix.plugin.Get("the_business"):SetShopKeeperCameraPositionFromEyeTrace()
function PLUGIN:SetShopKeeperCameraPositionFromEyeTrace()
    local trace = LocalPlayer():GetEyeTraceNoCursor()

    self.shopKeeperCamera = {
		origin = LocalPlayer():EyePos(),
		subjectPosition = trace.HitPos,
    }

    PrintTable(self.shopKeeperCamera)

	print([[
		Don't forget to add this to the server:

		hook.Add("SetupPlayerVisibility", "ShopKeeperCamera", function(client)
			AddOriginToPVS(Vector(]] .. self.shopKeeperCamera.origin.x .. ", " .. self.shopKeeperCamera.origin.y .. ", " .. self.shopKeeperCamera.origin.z .. [[))
		end)
	]]])
end

--- Update the render target for the shopkeeper
function PLUGIN:RenderScene()
	if (not self.shopKeeperCamera) then
		return
	end

	local fps = 1 / 30

	if (RealTime() - (PLUGIN.lastShopkeeperUpdate or 0) < fps) then
		return
	end

	PLUGIN.lastShopkeeperUpdate = RealTime()

	local client = LocalPlayer()
    local playerPosition = client:GetPos()
    local playerAngles = client:EyeAngles()
	local fovRadians = math.rad(client:GetFOV())

	for _, businessOutlet in ipairs(PLUGIN.businessOutlets) do
		if (not businessOutlet.shopkeeperRenderTarget) then
			continue
		end

        -- Slightly towards the camera from the subject
		local subjectPosition = self.shopKeeperCamera.subjectPosition + Vector(0, 0, 25)
		local cameraOrigin = subjectPosition + (self.shopKeeperCamera.origin + Vector(0, 0, 25) - subjectPosition):GetNormalized() * 109
        local subjectDirection = (subjectPosition - cameraOrigin):GetNormalized()
		local cameraToSubjectAngle = subjectDirection:Angle()
        local cameraAngles = Angle(playerAngles) -- subjectDirection:Angle()

        cameraAngles.yaw = cameraToSubjectAngle.yaw
		cameraAngles.pitch = cameraToSubjectAngle.pitch + (playerAngles.pitch * 0.1)

        -- cameraAngles.pitch = cameraAngles.pitch + differenceWithPlayerAnglesPitch

        -- Only add the difference, so the direction is correct, but the camera moves as if the player is looking through a window
        -- cameraAngles.yaw = cameraAngles.yaw + (playerAngles.yaw - differenceWithPlayerAnglesYaw)
        -- cameraAngles.yaw = cameraAngles.yaw + differenceWithPlayerAnglesYaw

        -- Distance
		local distanceToHole = (businessOutlet.position - playerPosition):Length()
		local distanceFromCameraToSubject = (subjectPosition - cameraOrigin):Length()
        local totalDistance = distanceFromCameraToSubject --+ (distanceToHole * 0.02)
		local parallaxDepth = totalDistance * math.tan(fovRadians / 2)
        local cameraPosition = subjectPosition - subjectDirection * parallaxDepth

		render.PushRenderTarget(businessOutlet.shopkeeperRenderTarget)
		render.Clear(0, 0, 0, 255, true, true)

		cam.Start2D()
        render.RenderView({
			origin = cameraPosition,
			angles = cameraAngles,
			x = 0,
			y = 0,
			w = TEXTURE_SIZE,
			h = TEXTURE_SIZE,
			drawviewmodel = false,
			viewid = VIEW_MONITOR,

			znear = 1,
			zfar = 32768,
		})
		cam.End2D()

		render.PopRenderTarget()
	end
end
]=====]
