local _, ns = ...
local B, C, L, DB = unpack(ns)
if not C.Infobar.Location then return end

local module = B:GetModule("Infobar")
local info = module:RegisterInfobar("Zone", C.Infobar.LocationPos)
local mapModule = B:GetModule("Maps")

local zoneInfo = {
	arena = {FREE_FOR_ALL_TERRITORY, {1, .1, .1}},
	combat = {COMBAT_ZONE, {1, .1, .1}},
	contested = {CONTESTED_TERRITORY, {1, .7, 0}},
	friendly = {FACTION_CONTROLLED_TERRITORY, {.1, 1, .1}},
	hostile = {FACTION_CONTROLLED_TERRITORY, {1, .1, .1}},
	neutral = {FACTION_CONTROLLED_TERRITORY, {1, 0.93, 0.76}},
	sanctuary = {SANCTUARY_TERRITORY, {.41, .8, .94}},
}

local zone, zoneType, zoneCoord, currentZone, totalZone, coordX, coordY, r, g, b

local function UpdateCoords(self, elapsed)
	if not IsPlayerMoving() then return end

	local uiMapID = C_Map.GetBestMapForUnit("player")
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed > .1 then
		coordX, coordY = mapModule:GetPlayerMapPos(uiMapID)

		self:onEvent()
		self.elapsed = 0
	end
end

local function FormatZones()
	local subZone = GetSubZoneText()
	local pvpType, _, faction = C_PvP.GetZonePVPInfo()
	local pvpType = pvpType or "neutral"
	zone = GetZoneText()
	r, g, b = unpack(zoneInfo[pvpType][2])
	zoneType = format(zoneInfo[pvpType][1], faction or FACTION_NEUTRAL)

	if subZone and subZone ~= "" and subZone ~= zone then
		currentZone = subZone
		totalZone = zone.." - "..subZone
	else
		currentZone = zone
		totalZone = zone
	end
end

local function FormatCoords()
	if IsInInstance() then
		local _, instanceType, difficultyID, difficultyName = GetInstanceInfo()
		if instanceType == "arena" then
			zoneCoord = ARENA
		elseif instanceType == "pvp" then
			zoneCoord = BATTLEGROUND
		elseif difficultyID == 8 then
			zoneCoord = difficultyName..":"..C_ChallengeMode.GetActiveKeystoneInfo()
		else
			zoneCoord = difficultyName
		end
	else
		if coordX and coordY then
			zoneCoord = format("%.1f , %.1f", coordX * 100, coordY * 100)
		else
			zoneCoord = "-- , --"
		end
	end
end

info.eventList = {
	"ZONE_CHANGED",
	"ZONE_CHANGED_INDOORS",
	"ZONE_CHANGED_NEW_AREA",
	"PLAYER_ENTERING_WORLD",
	"PLAYER_DIFFICULTY_CHANGED",
}

info.onEvent = function(self, event)
	if IsInInstance() then
		self:SetScript("OnUpdate", nil)
	else
		self:SetScript("OnUpdate", UpdateCoords)
	end

	FormatZones()
	FormatCoords()

	self.text:SetFormattedText("%s <%s>", currentZone, zoneCoord)
	self.text:SetTextColor(r, g, b)
end

info.onEnter = function(self)
	local _, anchor, offset = module:GetTooltipAnchor(info)
	GameTooltip:SetOwner(self, "ANCHOR_"..anchor, 0, offset)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(ZONE, 0,.6,1)
	GameTooltip:AddLine(" ")

	GameTooltip:AddDoubleLine(zone, zoneType, r,g,b, r,g,b)
	GameTooltip:AddDoubleLine(" ", DB.LineString)
	GameTooltip:AddDoubleLine(" ", DB.LeftButton..L["WorldMap"].." ", 1,1,1, .6,.8,1)
	GameTooltip:AddDoubleLine(" ", DB.RightButton..L["Send My Pos"].." ", 1,1,1, .6,.8,1)
	GameTooltip:Show()
end

info.onLeave = function()
	GameTooltip:Hide()
end

local zoneString = "|cffffff00|Hworldmap:%d+:%d+:%d+|h[|A:Waypoint-MapPin-ChatIcon:13:13:0:0|a %s: %s (%s) %s]|h|r"

info.onMouseUp = function(_, btn)
	if btn == "LeftButton" then
		--if InCombatLockdown() then UIErrorsFrame:AddMessage(DB.InfoColor..ERR_NOT_IN_COMBAT) return end -- fix by LibShowUIPanel
		ToggleFrame(WorldMapFrame)
	elseif btn == "RightButton" then
		local mapID = C_Map.GetBestMapForUnit("player")
		local hasUnit = UnitExists("target") and not UnitIsPlayer("target")
		local unitName = hasUnit and "<"..UnitName("target")..">" or ""

		print(format(zoneString, mapID, coordX*10000, coordY*10000, L["My Position"], totalZone, zoneCoord, unitName))
	end
end