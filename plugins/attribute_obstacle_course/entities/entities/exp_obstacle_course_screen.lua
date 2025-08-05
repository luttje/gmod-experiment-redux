local PLUGIN = PLUGIN

AddCSLuaFile()

ENT.Base = "anim"
ENT.PrintName = "Obstacle Course Screen"
ENT.Author = "Experiment Redux"
ENT.Spawnable = false

function ENT:SetupDataTables()
	self:NetworkVar("String", "CourseID")
	self:NetworkVar("Int", "ScreenWidth")
	self:NetworkVar("Int", "ScreenHeight")
	self:NetworkVar("Float", "ScreenScale")
end

if (SERVER) then
	function ENT:Initialize()
		self:SetSolid(SOLID_NONE)
		self:SetMoveType(MOVETYPE_NONE)
	end

	function ENT:KeyValue(key, value)
		if (key == "courseID") then
			self:SetCourseID(value)
		elseif (key == "screenWidth") then
			self:SetScreenWidth(tonumber(value) or 200)
		elseif (key == "screenHeight") then
			self:SetScreenHeight(tonumber(value) or 150)
		elseif (key == "screenScale") then
			self:SetScreenScale(tonumber(value) or 0.1)
		end
	end
else
	ENT.CameraRenderTargets = ENT.CameraRenderTargets or {}

	local gradient = Material("vgui/gradient-l")
	local function DrawGradientBox(x, y, w, h, dir, col1, col2)
		surface.SetMaterial(gradient)
		surface.SetDrawColor(col1)

		if dir == 1 then -- Horizontal
			surface.DrawTexturedRectRotated(x + w * .5, y + h * .5, w, h, 0)
		else       -- Vertical
			surface.DrawTexturedRectRotated(x + w * .5, y + h * .5, h, w, 90)
		end
	end

	local function FormatTime(seconds)
		local mins = math.floor(seconds / 60)
		local secs = seconds % 60
		return string.format("%d:%02d", mins, secs)
	end

	function ENT:GetCameras()
		local cameras = {}
		local courseID = self:GetCourseID()

		for _, ent in ipairs(ents.FindByClass("exp_obstacle_course_camera")) do
			if ent:GetCourseID() == courseID then
				table.insert(cameras, ent)
			end
		end

		return cameras
	end

	function ENT:GetCurrentCamera()
		local cameras = self:GetCameras()
		if #cameras == 0 then return nil end

		-- Cycle through cameras every 5 seconds
		local cycleTime = 5
		local currentTime = CurTime()
		local index = math.floor(currentTime / cycleTime) % #cameras + 1

		return cameras[index]
	end

	function ENT:GetCourseData()
		-- Get course data from networked table
		local courseID = self:GetCourseID()
		if not courseID or courseID == "" then return nil end

		return PLUGIN.obstacleCoursesClient and PLUGIN.obstacleCoursesClient[courseID]
	end

	function ENT:DrawPlayerList(courseData, x, y, w, h)
		local headerHeight = 30
		local lineHeight = 25
		local padding = 8

		-- Header
		surface.SetDrawColor(30, 30, 30, 200)
		surface.DrawRect(x, y, w, headerHeight)

		draw.SimpleText("RACERS", "DermaDefaultBold", x + w * .5, y + headerHeight * .5,
			Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		-- Active players
		local yPos = y + headerHeight + padding

		-- Sort finished players by position
		local sortedFinished = {}

		for _, player in ipairs(courseData.finishedPlayers or {}) do
			table.insert(sortedFinished, player)
		end

		table.sort(sortedFinished, function(a, b) return a.position < b.position end)

		-- Draw finished players first
		for _, clientInfo in ipairs(sortedFinished) do
			local timeStr = FormatTime(math.ceil(clientInfo.finishTime))
			local name = clientInfo.name

			-- Background
			surface.SetDrawColor(0, 150, 0, 100)
			surface.DrawRect(x, yPos, w, lineHeight)

			-- Position
			draw.SimpleText("#" .. clientInfo.position, "DermaDefault", x + 5, yPos + lineHeight * .5,
				Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

			-- Name
			draw.SimpleText(name, "DermaDefault", x + 35, yPos + lineHeight * .5,
				Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

			-- Time
			draw.SimpleText(timeStr, "DermaDefault", x + w - 5, yPos + lineHeight * .5,
				Color(255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

			yPos = yPos + lineHeight + 2
		end

		-- Draw active players
		for _, clientInfo in pairs(courseData.activePlayers or {}) do
			local currentTime = CurTime() - clientInfo.startedAt
			local timeStr = FormatTime(math.ceil(currentTime))
			local name = clientInfo.name

			-- Background
			surface.SetDrawColor(255, 165, 0, 100)
			surface.DrawRect(x, yPos, w, lineHeight)

			-- Name
			draw.SimpleText(name, "DermaDefault", x + 5, yPos + lineHeight * .5,
				Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

			-- Time
			draw.SimpleText(timeStr, "DermaDefault", x + w - 5, yPos + lineHeight * .5,
				Color(255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

			yPos = yPos + lineHeight + 2
		end

		return yPos
	end

	function ENT:DrawQueueList(courseData, x, y, w, h)
		local headerHeight = 25
		local lineHeight = 20
		local padding = 5

		-- Header
		surface.SetDrawColor(50, 50, 50, 200)
		surface.DrawRect(x, y, w, headerHeight)

		draw.SimpleText("QUEUE", "DermaDefault", x + w * .5, y + headerHeight * .5,
			Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		-- Waiting players
		local yPos = y + headerHeight + padding
		local position = 1

		for _, clientInfo in pairs(courseData.waitingPlayers or {}) do
			local name = clientInfo.name

			-- Background
			surface.SetDrawColor(100, 100, 100, 80)
			surface.DrawRect(x, yPos, w, lineHeight)

			-- Position
			draw.SimpleText(tostring(position), "DermaDefault", x + 5, yPos + lineHeight * .5,
				Color(200, 200, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

			-- Name
			draw.SimpleText(name, "DermaDefault", x + 20, yPos + lineHeight * .5,
				Color(200, 200, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

			yPos = yPos + lineHeight + 1
			position = position + 1
		end
	end

	-- Camera render targets storage
	ENT.CameraRenderTargets = ENT.CameraRenderTargets or {}

	function ENT:UpdateCameraRenderTarget()
		local camera = self:GetCurrentCamera()
		if not camera then return end

		local rtName = "obstacle_camera_" .. camera:EntIndex()
		local screenWidth = self:GetScreenWidth()
		local screenHeight = self:GetScreenHeight()

		-- Camera view dimensions (right side of screen)
		local leftWidth = screenWidth * 0.4
		local rightWidth = screenWidth - leftWidth - 30
		local rightHeight = screenHeight - 60

		-- Create or get render target
		local rt = GetRenderTarget(rtName, rightWidth, rightHeight)
		if not rt then return end

		-- Store the render target for this camera
		self.CameraRenderTargets[camera:EntIndex()] = {
			renderTarget = rt,
			lastUpdate = CurTime(),
			camera = camera
		}

		-- Update render target (limit to reasonable framerate)
		if not self.lastCameraUpdate or (CurTime() - self.lastCameraUpdate) > (1 / 30) then
			local oldRT = render.GetRenderTarget()
			render.SetRenderTarget(rt)
			render.Clear(0, 0, 0, 255, true, true)

			-- Set up the camera view
			local cameraPos = camera:GetPos()
			local cameraAngles = camera:GetViewAngles()
			local fov = camera:GetFOV()

			-- Render the 3D view from camera perspective
			render.RenderView({
				origin = cameraPos,
				angles = cameraAngles,
				x = 0,
				y = 0,
				w = rightWidth,
				h = rightHeight,
				fov = fov,
				aspectratio = rightWidth / rightHeight,
				znear = 1,
				zfar = 16384,
				drawviewmodel = false
			})

			-- Restore the previous render target
			render.SetRenderTarget(oldRT)
			self.lastCameraUpdate = CurTime()
		end
	end

	function ENT:GetOrCreateCameraMaterial(renderTarget)
		local matName = "exp_obstacle_course_camera_" .. renderTarget:GetName()
		local material = Material(matName)

		if (not material:IsError()) then
			return material
		end

		material = CreateMaterial(matName, "UnlitGeneric", {
			["$basetexture"] = renderTarget:GetName(),
		})

		return material
	end

	function ENT:DrawCameraView(x, y, w, h)
		local camera = self:GetCurrentCamera()
		if not camera then
			-- No cameras available
			surface.SetDrawColor(50, 50, 50, 200)
			surface.DrawRect(x, y, w, h)

			draw.SimpleText("NO CAMERAS", "DermaDefaultBold", x + w * .5, y + h * .5,
				Color(150, 150, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			return
		end

		-- Camera view background
		surface.SetDrawColor(20, 20, 20, 220)
		surface.DrawRect(x, y, w, h)

		-- Get the render target for this camera
		local cameraData = self.CameraRenderTargets[camera:EntIndex()]
		if cameraData and cameraData.renderTarget then
			-- Draw the render target
			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(self:GetOrCreateCameraMaterial(cameraData.renderTarget))
			surface.DrawTexturedRect(x, y, w, h)
		else
			-- Loading state
			draw.SimpleText("LOADING CAMERA...", "DermaDefault", x + w * .5, y + h * .5,
				Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		-- Camera info overlay
		local cameraName = camera:GetCameraName()
		if (cameraName and cameraName ~= "") then
			local textWidth, textHeight = Schema.GetCachedTextSize("DermaDefault", "CAM: " .. cameraName)

			-- Semi-transparent background for text
			surface.SetDrawColor(0, 0, 0, 150)
			surface.DrawRect(x + 5, y + 5, textWidth + 10, textHeight + 10)

			draw.SimpleText("CAM: " .. cameraName, "DermaDefault", x + 10, y + 15,
				Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end

		-- Live indicator
		local liveText = "● LIVE"
		local liveColor = Color(255, 50, 50)
		local textWidth, textHeight = Schema.GetCachedTextSize("DermaDefault", liveText)

		-- Pulsing effect for live indicator
		local pulse = math.sin(CurTime() * 3) * 0.3 + 0.7
		liveColor.a = 255 * pulse

		surface.SetDrawColor(0, 0, 0, 150)
		surface.DrawRect(x + w - textWidth - 15, y + h - textHeight - 5, textWidth + 10, textHeight + 10)

		draw.SimpleText(liveText, "DermaDefault", x + w - 10, y + h - 5,
			liveColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)

		-- Add recording-style border effect
		local borderColor = Color(255, 0, 0, 100 * pulse)
		surface.SetDrawColor(borderColor)
		surface.DrawOutlinedRect(x, y, w, h, 2)
	end

	function ENT:Initialize()
		-- Calculate the actual screen bounds based on dimensions and scale
		local screenWidth = self:GetScreenWidth()
		local screenHeight = self:GetScreenHeight()
		local scale = self:GetScreenScale()

		-- Calculate world space dimensions
		local worldWidth = screenWidth * scale
		local worldHeight = screenHeight * scale

		-- Set rendering bounds that encompass the entire 3D2D screen, so it keeps rendering even if
		-- the true entity is outside the PVS.
		local mins = Vector(-worldWidth / 2, -worldHeight / 2, -10)
		local maxs = Vector(worldWidth / 2, worldHeight / 2, 10)

		self:SetRenderBounds(mins, maxs)
	end

	function ENT:Think()
		-- Update camera render target outside a 3D context
		self:UpdateCameraRenderTarget()
	end

	function ENT:Draw()
		local courseID = self:GetCourseID()
		if not courseID or courseID == "" then return end

		local courseData = self:GetCourseData()
		if not courseData then return end

		local pos = self:GetPos()
		local ang = self:GetAngles()
		local originalForward = ang:Forward()

		-- Rotate the screen to match how it looks in Hammer
		ang:RotateAroundAxis(ang:Up(), 90)
		ang:RotateAroundAxis(ang:Forward(), 90)

		local screenWidth = self:GetScreenWidth()
		local screenHeight = self:GetScreenHeight()
		local scale = self:GetScreenScale()

		-- Subtract half the screen size, to center it where it is in Hammer
		pos = pos - (ang:Forward() * screenWidth * .5 * scale)
		pos = pos - (ang:Right() * screenHeight * .5 * scale)

		-- Move it a tad forward, so it doesn't clip into the world
		pos = pos + (originalForward * 0.5)

		cam.Start3D2D(pos, ang, scale)
		-- Background
		surface.SetDrawColor(15, 15, 15, 240)
		surface.DrawRect(0, 0, screenWidth, screenHeight)

		-- Border
		surface.SetDrawColor(60, 60, 60, 255)
		surface.DrawOutlinedRect(0, 0, screenWidth, screenHeight, 2)

		-- Title
		local titleHeight = 40
		local course = courseID:gsub("_", " "):upper()
		DrawGradientBox(0, 0, screenWidth, titleHeight, 1, Color(40, 40, 40, 200), Color(20, 20, 20, 200))
		draw.SimpleText(course, "DermaLarge", screenWidth * .5, 5 + titleHeight * .5,
			Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		-- Left side - Player lists
		local leftWidth = screenWidth * 0.4
		local leftX = 10
		local listY = titleHeight + 10

		-- Racers list
		local racersHeight = screenHeight * 0.6
		self:DrawPlayerList(courseData, leftX, listY, leftWidth, racersHeight)

		-- Queue list
		local queueY = listY + racersHeight + 10
		local queueHeight = screenHeight - queueY - 10
		self:DrawQueueList(courseData, leftX, queueY, leftWidth, queueHeight)

		-- Right side - Camera view
		local rightX = leftX + leftWidth + 20
		local rightWidth = screenWidth - rightX - 10
		local rightHeight = screenHeight - titleHeight - 20

		self:DrawCameraView(rightX, listY, rightWidth, rightHeight)

		cam.End3D2D()
	end
end
