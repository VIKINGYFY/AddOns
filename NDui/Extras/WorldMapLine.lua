local _, ns = ...
local B, C, L, DB = unpack(ns)

local lineLength = 1000
local mapID, mapWidth, mapHeight

local MapCanvas = WorldMapFrame:GetCanvas()

local StartPoint = CreateFrame("Frame", nil, MapCanvas)
StartPoint:SetSize(1, 1)
StartPoint:Hide()

local EndPoint = CreateFrame("Frame", nil, MapCanvas)
EndPoint:SetSize(1, 1)
EndPoint:Hide()

local LineFrame = CreateFrame("Frame", nil, MapCanvas)
LineFrame:SetFrameStrata("HIGH")

local Line = LineFrame:CreateLine(nil, "OVERLAY")
Line:SetColorTexture(0, 1, 1)
Line:SetThickness(DB.margin)
Line:SetStartPoint("CENTER", StartPoint, "CENTER", 0, 0)
Line:SetEndPoint("CENTER", EndPoint, "CENTER", 0, 0)

local function MapLine_Update(self)
	mapID = self:GetMapID()
	mapWidth, mapHeight = MapCanvas:GetSize()
	Line:SetThickness(DB.margin / MapCanvas:GetScale())
end

hooksecurefunc(WorldMapFrame, "OnFrameSizeChanged", MapLine_Update)
hooksecurefunc(WorldMapFrame, "OnMapChanged", MapLine_Update)

local function MapLine_OnUpdate(self, elapsed)
	local playerX, playerY = C_Map.GetPlayerMapPosition(mapID, "player"):GetXY()
	local playerD = GetPlayerFacing()

	if not (mapID or playerX or playerY or playerD) then
		Line:Hide()
		return
	end

	local startX = playerX * mapWidth
	local startY = -playerY * mapHeight
	local endX = startX + (-math.sin(playerD) * lineLength)
	local endY = startY - (-math.cos(playerD) * lineLength)

	B.UpdatePoint(StartPoint, "CENTER", MapCanvas, "TOPLEFT", startX, startY)
	B.UpdatePoint(EndPoint, "CENTER", MapCanvas, "TOPLEFT", endX, endY)

	Line:Show()
end

local function MapLine_OnShow()
	mapID = WorldMapFrame:GetMapID()
	mapWidth, mapHeight = MapCanvas:GetSize()

	if not IsInInstance() and (IsPlayerMoving() or UnitOnTaxi("player")) then
		LineFrame:SetScript("OnUpdate", MapLine_OnUpdate)
	else
		LineFrame:SetScript("OnUpdate", nil)
	end
end

local function MapLine_OnHide()
	Line:Hide()
end

WorldMapFrame:HookScript("OnShow", MapLine_OnShow)
WorldMapFrame:HookScript("OnHide", MapLine_OnHide)
