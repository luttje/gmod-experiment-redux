local PLUGIN = PLUGIN

-- Canvas designer class
PLUGIN.CanvasDesigner = {}
PLUGIN.CanvasDesigner.__index = PLUGIN.CanvasDesigner

function PLUGIN.CanvasDesigner:New(item)
	local obj = setmetatable({}, self)
	obj.item = item
	obj.elements = {}
	obj.selectedElement = nil
	obj.isDragging = false
	obj.dragStartX = 0
	obj.dragStartY = 0
	obj.elementStartX = 0
	obj.elementStartY = 0
	obj.canvasOffsetX = 0
	obj.canvasOffsetY = 0

	-- Load existing design
	local designData = item:GetData("design", {})

	obj.canvasWidth = designData.width or PLUGIN.CANVAS_DEFAULT_WIDTH
	obj.canvasHeight = designData.height or PLUGIN.CANVAS_DEFAULT_HEIGHT
	obj.name = designData.name or "Unnamed Canvas"

	if (designData) then
		obj:LoadDesign(designData.data)
	end

	return obj
end

function PLUGIN.CanvasDesigner:GetSize()
	return self.canvasWidth, self.canvasHeight
end

function PLUGIN.CanvasDesigner:LoadDesign(jsonData)
	local success, data = pcall(util.JSONToTable, jsonData)
	if success and data then
		self.elements = data
	else
		self.elements = {}
	end
end

function PLUGIN.CanvasDesigner:SaveDesign()
	return util.TableToJSON(self.elements)
end

function PLUGIN.CanvasDesigner:OnElementsChanged()
	-- This can be overridden to handle element changes
end

function PLUGIN.CanvasDesigner:AddElement(spriteType, x, y)
	if (#self.elements >= PLUGIN.MAX_ELEMENTS) then
		return false
	end

	local element = {
		id = os.time() .. math.random(1000, 9999),
		type = spriteType.type,
		x = x or 100,
		y = y or 100,
		scaleX = 1.0,
		scaleY = 1.0,
		rotation = 0,
		color = spriteType.defaultColor or { r = 0, g = 0, b = 0, a = 255 }
	}

	table.insert(self.elements, element)
	self:SelectElement(#self.elements)

	self:OnElementsChanged()

	return true
end

function PLUGIN.CanvasDesigner:SelectElement(index)
	if (not index or index < 1 or index > #self.elements) then
		self.selectedElement = nil
	else
		self.selectedElement = index
	end

	self:OnElementsChanged()
end

function PLUGIN.CanvasDesigner:GetSelectedElementIndex()
	return self.selectedElement
end

function PLUGIN.CanvasDesigner:DeleteSelected()
	if (self.selectedElement and self.elements[self.selectedElement]) then
		table.remove(self.elements, self.selectedElement)
		self:SelectElement(nil)
	end
end

function PLUGIN.CanvasDesigner:GetElementAt(x, y)
	for i = #self.elements, 1, -1 do
		local element = self.elements[i]
		local spriteType = PLUGIN.SPRITES_BY_TYPE[element.type]
		local sizeX = spriteType.icon.size * element.scaleX
		local sizeY = spriteType.icon.size * element.scaleY
		local halfSizeX = sizeX * .5
		local halfSizeY = sizeY * .5

		if (x >= element.x - halfSizeX and x <= element.x + halfSizeX and
				y >= element.y - halfSizeY and y <= element.y + halfSizeY) then
			return i
		end
	end

	return nil
end

function PLUGIN.CanvasDesigner:DrawGrid(x, y, w, h)
	surface.SetDrawColor(PLUGIN.THEME.border.r, PLUGIN.THEME.border.g, PLUGIN.THEME.border.b, 50)

	for i = 0, w, PLUGIN.GRID_SIZE do
		surface.DrawLine(x + i, y, x + i, y + h)
	end

	for i = 0, h, PLUGIN.GRID_SIZE do
		surface.DrawLine(x, y + i, x + w, y + i)
	end
end

function PLUGIN.CanvasDesigner:DrawCanvas(x, y, w, h, withoutGrid, withoutBackground, compositeAlpha)
	-- If we need composite alpha, use a render target
	if (compositeAlpha and compositeAlpha < 1) then
		local rtName = "CanvasComposite_" .. (self.item and self.item:GetID() or "temp")
		local rtSize = math.max(w, h, 512) -- Ensure minimum size
		rtSize = math.min(rtSize, 2048) -- Cap at reasonable max

		local rt = GetRenderTarget(rtName, rtSize, rtSize)

		-- Render to our RT first
		render.PushRenderTarget(rt)
		render.Clear(0, 0, 0, 0, true, true) -- Clear with transparent

		cam.Start2D()

		-- Draw everything to the RT at 0,0 with full opacity
		self:DrawCanvasInternal(0, 0, w, h, withoutGrid, withoutBackground)

		cam.End2D()

		render.PopRenderTarget()

		-- Now draw the RT with alpha
		-- Create material if needed
		if not self.rtMaterial then
			self.rtMaterial = CreateMaterial(rtName .. "_mat", "UnlitGeneric", {
				["$basetexture"] = rtName,
				["$translucent"] = 1,
				["$vertexalpha"] = 1,
				["$vertexcolor"] = 1,
			})
		end

		-- Draw the composite with alpha
		surface.SetMaterial(self.rtMaterial)
		surface.SetDrawColor(255, 255, 255, compositeAlpha * 255)
		surface.DrawTexturedRect(x, y, w, h)
	else
		-- Create a stencil mask for clipping
		render.ClearStencil()
		render.SetStencilEnable(true)

		-- Write to stencil buffer
		render.SetStencilWriteMask(1)
		render.SetStencilTestMask(1)
		render.SetStencilReferenceValue(1)
		render.SetStencilCompareFunction(STENCIL_ALWAYS)
		render.SetStencilPassOperation(STENCIL_REPLACE)
		render.SetStencilFailOperation(STENCIL_KEEP)
		render.SetStencilZFailOperation(STENCIL_KEEP)

		-- Draw the clipping rectangle to stencil
		render.OverrideDepthEnable(true, false)
		render.OverrideColorWriteEnable(true, false) -- Don't write to color buffer
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawRect(x, y, w, h)
		render.OverrideColorWriteEnable(false, true) -- Re-enable color writing
		render.OverrideDepthEnable(false, true)

		-- Now only draw where stencil = 1
		render.SetStencilCompareFunction(STENCIL_EQUAL)
		render.SetStencilPassOperation(STENCIL_KEEP)

		-- Normal drawing without composite alpha
		self:DrawCanvasInternal(x, y, w, h, withoutGrid, withoutBackground)

		render.SetStencilEnable(false)
	end
end

-- Separated internal drawing logic
function PLUGIN.CanvasDesigner:DrawCanvasInternal(x, y, w, h, withoutGrid, withoutBackground)
	if (not withoutBackground) then
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawRect(x, y, w, h)
	end

	if (not withoutGrid) then
		self:DrawGrid(x, y, w, h)
	end

	for i, element in ipairs(self.elements) do
		local spriteType = PLUGIN.SPRITES_BY_TYPE[element.type]

		if (not spriteType) then
			ix.util.SchemaErrorNoHalt("Unknown sprite type: " .. tostring(element.type))
			continue
		end

		local drawX = x + element.x - (spriteType.icon.size * element.scaleX) * .5
		local drawY = y + element.y - (spriteType.icon.size * element.scaleY) * .5
		local sizeX = spriteType.icon.size * element.scaleX
		local sizeY = spriteType.icon.size * element.scaleY

		surface.SetDrawColor(element.color.r, element.color.g, element.color.b, element.color.a)
		Schema.draw.DrawSpritesheetMaterial(
			spriteType.icon.material,
			drawX, drawY,
			sizeX, sizeY,
			spriteType.icon.x, spriteType.icon.y,
			spriteType.icon.size, spriteType.icon.size,
			false,
			element.rotation
		)

		-- Draw selection outline
		if (not withoutGrid and self:GetSelectedElementIndex() == i) then
			surface.SetDrawColor(
				PLUGIN.THEME.primary.r,
				PLUGIN.THEME.primary.g,
				PLUGIN.THEME.primary.b,
				255
			)
			surface.DrawOutlinedRect(drawX - 3, drawY - 3, sizeX + 6, sizeY + 6, 2)
		end
	end
end
