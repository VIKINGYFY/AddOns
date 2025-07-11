local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:RegisterModule("Maps")

local currentMapID, playerCoords, cursorCoords

function module:GetPlayerMapCoords(mapID)
	if not mapID then return end

	local position = C_Map.GetPlayerMapPosition(mapID, "player")
	if position then
		return position.x, position.y
	end
end

function module:GetCursorMapCoords()
	if not WorldMapFrame.ScrollContainer:IsMouseOver() then return end

	local cursorX, cursorY = WorldMapFrame.ScrollContainer:GetNormalizedCursorPosition()
	if cursorX and cursorY then
		return cursorX, cursorY
	end
end

function module:UpdateCoords(elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed > .1 then
		local cursorX, cursorY = module:GetCursorMapCoords()
		if cursorX and cursorY then
			cursorCoords:SetFormattedText("<%.1f , %.1f> %s", 100 * cursorX, 100 * cursorY, DB.MyColor..MOUSE_LABEL.."|r")
			cursorCoords:Show()
		else
			cursorCoords:Hide()
		end

		local playerX, playerY = module:GetPlayerMapCoords(currentMapID)
		if playerX and playerY then
			playerCoords:SetFormattedText("<%.1f , %.1f> %s", 100 * playerX, 100 * playerY, DB.MyColor..PLAYER.."|r")
		else
			playerCoords:SetFormattedText("<%s> %s", "-- , --", DB.MyColor..PLAYER.."|r")
		end

		self.elapsed = 0
	end
end

function module:UpdateMapID()
	currentMapID = self:GetMapID()
end

function module:SetupCoords()
	local parentFrame = CreateFrame("Frame", nil, WorldMapFrame)
	parentFrame:SetPoint("BOTTOMRIGHT", WorldMapFrame.ScrollContainer, "BOTTOMRIGHT", -30, 8)
	parentFrame:SetFrameStrata("HIGH")
	parentFrame:SetSize(1, 18)
	B.SetGradient(parentFrame, "H", 0, 0, 0, 0, DB.alpha, 350, 18):SetPoint("RIGHT")

	playerCoords = B.CreateFS(parentFrame, 14, "", false, "RIGHT", -10, 0)
	cursorCoords = B.CreateFS(parentFrame, 14, "", false, "RIGHT", -185, 0)

	hooksecurefunc(WorldMapFrame, "OnFrameSizeChanged", module.UpdateMapID)
	hooksecurefunc(WorldMapFrame, "OnMapChanged", module.UpdateMapID)

	parentFrame:SetScript("OnUpdate", module.UpdateCoords)
end

function module:UpdateMapScale()
	if self.isMaximized and self:GetScale() ~= C.db["Map"]["MaxMapScale"] then
		self:SetScale(C.db["Map"]["MaxMapScale"])
	elseif not self.isMaximized and self:GetScale() ~= C.db["Map"]["MapScale"] then
		self:SetScale(C.db["Map"]["MapScale"])
	end
end

function module:UpdateMapAnchor()
	module.UpdateMapScale(self)
	B.RestoreMF(self)
end

function module:WorldMapScale()
	B.CreateMF(WorldMapFrame, nil, true)
	WorldMapFrame:HookScript("OnShow", self.UpdateMapAnchor)
	hooksecurefunc(WorldMapFrame, "SynchronizeDisplayState", self.UpdateMapAnchor)
end

local shownMapCache, exploredCache, fileDataIDs, storedTex = {}, {}, {}, {}

local function GetStringFromInfo(info)
	return format("W%dH%dX%dY%d", info.textureWidth, info.textureHeight, info.offsetX, info.offsetY)
end

local function GetShapesFromString(str)
	local w, h, x, y = string.match(str, "W(%d*)H(%d*)X(%d*)Y(%d*)")
	return tonumber(w), tonumber(h), tonumber(x), tonumber(y)
end

local function RefreshFileIDsByString(str)
	table.wipe(fileDataIDs)

	for fileID in string.gmatch(str, "%d+") do
		table.insert(fileDataIDs, fileID)
	end
end

function module:MapData_RefreshOverlays(fullUpdate)
	table.wipe(shownMapCache)
	table.wipe(exploredCache)
	for _, tex in pairs(storedTex) do
		tex:SetVertexColor(1, 1, 1)
	end
	table.wipe(storedTex)

	local mapID = WorldMapFrame.mapID
	if not mapID then return end

	local mapArtID = C_Map.GetMapArtID(mapID)
	local mapData = mapArtID and module.RawMapData[mapArtID]
	if not mapData then return end

	local exploredMapTextures = C_MapExplorationInfo.GetExploredMapTextures(mapID)
	if exploredMapTextures then
		for _, exploredTextureInfo in pairs(exploredMapTextures) do
			exploredCache[GetStringFromInfo(exploredTextureInfo)] = true
		end
	end

	if not self.layerIndex then
		self.layerIndex = WorldMapFrame.ScrollContainer:GetCurrentLayerIndex()
	end
	local layers = C_Map.GetMapArtLayers(mapID)
	local layerInfo = layers and layers[self.layerIndex]
	if not layerInfo then return end

	local TILE_SIZE_WIDTH = layerInfo.tileWidth
	local TILE_SIZE_HEIGHT = layerInfo.tileHeight

	-- Blizzard_SharedMapDataProviders\MapExplorationDataProvider: MapExplorationPinMixin:RefreshOverlays
	for i, exploredInfoString in pairs(mapData) do
		if not exploredCache[i] then
			local width, height, offsetX, offsetY = GetShapesFromString(i)
			RefreshFileIDsByString(exploredInfoString)
			local numTexturesWide = math.ceil(width/TILE_SIZE_WIDTH)
			local numTexturesTall = math.ceil(height/TILE_SIZE_HEIGHT)
			local texturePixelWidth, textureFileWidth, texturePixelHeight, textureFileHeight

			for j = 1, numTexturesTall do
				if j < numTexturesTall then
					texturePixelHeight = TILE_SIZE_HEIGHT
					textureFileHeight = TILE_SIZE_HEIGHT
				else
					texturePixelHeight = mod(height, TILE_SIZE_HEIGHT)
					if texturePixelHeight == 0 then
						texturePixelHeight = TILE_SIZE_HEIGHT
					end
					textureFileHeight = 16
					while textureFileHeight < texturePixelHeight do
						textureFileHeight = textureFileHeight * 2
					end
				end
				for k = 1, numTexturesWide do
					local texture = self.overlayTexturePool:Acquire()
					table.insert(storedTex, texture)
					if k < numTexturesWide then
						texturePixelWidth = TILE_SIZE_WIDTH
						textureFileWidth = TILE_SIZE_WIDTH
					else
						texturePixelWidth = width %TILE_SIZE_WIDTH
						if texturePixelWidth == 0 then
							texturePixelWidth = TILE_SIZE_WIDTH
						end
						textureFileWidth = 16
						while textureFileWidth < texturePixelWidth do
							textureFileWidth = textureFileWidth * 2
						end
					end
					texture:SetWidth(texturePixelWidth)
					texture:SetHeight(texturePixelHeight)
					texture:SetTexCoord(0, texturePixelWidth/textureFileWidth, 0, texturePixelHeight/textureFileHeight)
					texture:SetPoint("TOPLEFT", offsetX + (TILE_SIZE_WIDTH * (k-1)), -(offsetY + (TILE_SIZE_HEIGHT * (j - 1))))
					texture:SetTexture(fileDataIDs[((j - 1) * numTexturesWide) + k], nil, nil, "TRILINEAR")

					if C.db["Map"]["MapReveal"] then
						if C.db["Map"]["MapRevealGlow"] then
							texture:SetVertexColor(.7, .7, .7)
						else
							texture:SetVertexColor(1, 1, 1)
						end
						texture:SetDrawLayer("ARTWORK")
						texture:Show()
						if fullUpdate then self.textureLoadGroup:AddTexture(texture) end
					else
						texture:Hide()
					end
					table.insert(shownMapCache, texture)
				end
			end
		end
	end
end

function module:MapData_ResetTexturePool(texture)
	texture:SetVertexColor(1, 1, 1)
	texture:SetAlpha(1)
	return TexturePool_HideAndClearAnchors(self, texture)
end

function module:RemoveMapFog()
	local bu = B.CreateCheckBox(WorldMapFrame.BorderFrame.TitleContainer, true)
	bu:SetPoint("BOTTOMLEFT", WorldMapFrameHomeButton, "TOPLEFT", -3, 0)
	bu:SetSize(26, 26)
	bu:SetChecked(C.db["Map"]["MapReveal"])
	bu.text = B.CreateFS(bu, 14, L["Map Reveal"], "system", "LEFT", 25, 0)

	for pin in WorldMapFrame:EnumeratePinsByTemplate("MapExplorationPinTemplate") do
		hooksecurefunc(pin, "RefreshOverlays", module.MapData_RefreshOverlays)
		pin.overlayTexturePool.resetterFunc = module.MapData_ResetTexturePool
	end

	bu:SetScript("OnClick", function(self)
		C.db["Map"]["MapReveal"] = self:GetChecked()

		for i = 1, #shownMapCache do
			shownMapCache[i]:SetShown(C.db["Map"]["MapReveal"])
		end
	end)
end

function module:SetupWorldMap()
	if C.db["Map"]["DisableMap"] then return end
	if C_AddOns.IsAddOnLoaded("Mapster") then return end

	-- Remove from frame manager
	WorldMapFrame:ClearAllPoints()
	WorldMapFrame:SetPoint("CENTER") -- init anchor

	-- Hide stuff
	WorldMapFrame.BlackoutFrame:SetAlpha(0)
	WorldMapFrame.BlackoutFrame:EnableMouse(false)
	--QuestMapFrame:SetScript("OnHide", nil) -- fix map toggle taint -- fix by LibShowUIPanel

	WorldMapFrame.BorderFrame.Tutorial:ClearAllPoints()
	WorldMapFrame.BorderFrame.Tutorial:SetPoint("TOPLEFT", WorldMapFrame, "TOPLEFT", -12, -12)

	self:WorldMapScale()
	self:SetupCoords()
	self:RemoveMapFog()
end

function module:MapFunc()
	WorldMapFrame:SetAttribute("UIPanelLayout-area", nil)
	WorldMapFrame:SetAttribute("UIPanelLayout-enabled", false)
	WorldMapFrame:SetAttribute("UIPanelLayout-allowOtherPanels", true)
	table.insert(UISpecialFrames, "WorldMapFrame")
	B:UnregisterEvent("PLAYER_ENTERING_WORLD", self.MapFunc)
end

function module:OnLogin()
	self:SetupWorldMap()
	self:SetupMinimap()
	B:RegisterEvent("PLAYER_ENTERING_WORLD", self.MapFunc)
end
