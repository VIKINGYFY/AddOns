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

local function GetZoneInfo()
	local mainZone, subZone = GetAreaText(), GetMinimapZoneText()
	local fullZone = (mainZone ~= subZone) and (mainZone.." - "..subZone) or subZone
	local pvpType, _, faction = C_PvP.GetZonePVPInfo()
	local zoneData = zoneInfo[pvpType or "neutral"]
	local zoneType = format(zoneData[1], faction or FACTION_NEUTRAL)
	local r, g, b = unpack(zoneData[2])

	return mainZone, subZone, fullZone, zoneType, r, g, b
end

local function GetZoneCoords()
	if IsInInstance() then
		local _, instanceType, difficultyID, difficultyName = GetInstanceInfo()
		if instanceType == "arena" then
			return ARENA
		elseif instanceType == "pvp" then
			return BATTLEGROUND
		elseif difficultyID == 8 then
			local activeLevel = C_ChallengeMode.GetActiveKeystoneInfo()
			return difficultyName.." - "..activeLevel
		else
			return difficultyName
		end
	else
		local mapID = C_Map.GetBestMapForUnit("player")
		if mapID then
			local x, y = mapModule:GetPlayerMapCoords(mapID)
			if x and y then
				return format("%.1f , %.1f", x * 100, y * 100), x, y, mapID
			end
		end
	end

	return "-- , --"
end

local function UpdateCoords(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed

	if self.elapsed > .1 then
		info:onEvent()
		self.elapsed = 0
	end
end

info.eventList = {
	"ZONE_CHANGED",
	"ZONE_CHANGED_INDOORS",
	"ZONE_CHANGED_NEW_AREA",
	"PLAYER_STARTED_MOVING",
}

info.onEvent = function(self)
	if not IsInInstance() and (IsPlayerMoving() or UnitOnTaxi("player")) then
		self:SetScript("OnUpdate", UpdateCoords)
	else
		self:SetScript("OnUpdate", nil)
	end

	local mainZone, subZone, fullZone, zoneType, r, g, b = GetZoneInfo()
	local coordText, x, y, mapID = GetZoneCoords()

	self.text:SetFormattedText("%s <%s>", subZone, coordText)
	self.text:SetTextColor(r, g, b)

	self._mainZone = mainZone
	self._subZone = subZone
	self._fullZone = fullZone
	self._zoneType = zoneType
	self._coordText = coordText
	self._zoneColor = {r, g, b}
	self._x, self._y, self._mapID = x, y, mapID
end

info.onEnter = function(self)
	local r, g, b = unpack(self._zoneColor)
	local _, anchor, offset = module:GetTooltipAnchor(info)

	GameTooltip:SetOwner(self, "ANCHOR_"..anchor, 0, offset)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(ZONE, 0,1,1)
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(self._mainZone, self._zoneType, r,g,b, r,g,b)
	GameTooltip:AddDoubleLine(" ", DB.LineString)
	GameTooltip:AddDoubleLine(" ", DB.LeftButton..L["WorldMap"].." ", 1,1,1, 0,1,1)
	GameTooltip:AddDoubleLine(" ", DB.RightButton..L["Send My Pos"].." ", 1,1,1, 0,1,1)
	GameTooltip:Show()
end

info.onLeave = function()
	GameTooltip:Hide()
end

local zoneString = "|cffFFFF00|Hworldmap:%d+:%d+:%d+|h[|A:Waypoint-MapPin-ChatIcon:13:13:0:0|a %s]|h|r"

info.onMouseUp = function(self, btn)
	if btn == "LeftButton" then
		if InCombatLockdown() then UIErrorsFrame:AddMessage(DB.InfoColor..ERR_NOT_IN_COMBAT) return end -- fix by LibShowUIPanel
		ToggleFrame(WorldMapFrame)
	elseif btn == "RightButton" then
		local hasUnit = UnitExists("target") and not UnitIsPlayer("target")
		local unitName = hasUnit and " <"..UnitName("target")..">" or ""
		local pointInfo = format("%s: %s <%s>%s", L["My Position"], self._fullZone, self._coordText, unitName)
		ChatFrame_OpenChat(pointInfo)

		if not IsInInstance() then
			local pointLink = format(zoneString, self._mapID, self._x * 10000, self._y * 10000, pointInfo)
			print(pointLink)
		end
	end
end
