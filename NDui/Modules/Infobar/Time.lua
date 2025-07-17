local _, ns = ...
local B, C, L, DB = unpack(ns)
if not C.Infobar.Time then return end

local module = B:GetModule("Infobar")
local info = module:RegisterInfobar("Time", C.Infobar.TimePos)

local HORRIFIC_VISION = SPLASH_BATTLEFORAZEROTH_8_3_0_FEATURE1_TITLE
local COMMUNITY_FEAST = C_Spell.GetSpellName(388961)
local DIFFICULTY_COLOR = {
	[ 7] = {0.1, 1.0, 0.0},
	[17] = {0.1, 1.0, 0.0},

	[ 1] = {0.0, 0.4, 0.9},
	[ 3] = {0.0, 0.4, 0.9},
	[ 4] = {0.0, 0.4, 0.9},
	[14] = {0.0, 0.4, 0.9},

	[ 2] = {0.6, 0.2, 0.9},
	[ 5] = {0.6, 0.2, 0.9},
	[ 6] = {0.6, 0.2, 0.9},
	[15] = {0.6, 0.2, 0.9},

	[ 9] = {1.0, 0.5, 0.0},
	[16] = {1.0, 0.5, 0.0},
	[23] = {1.0, 0.5, 0.0},

	[24] = {0.9, 0.8, 0.5},
	[33] = {0.9, 0.8, 0.5},
}

local function updateTimerFormat(color, hour, minute)
	if GetCVarBool("timeMgrUseMilitaryTime") then
		return format(color..TIMEMANAGER_TICKER_24HOUR, hour, minute)
	else
		local timerUnit = DB.MyColor..(hour < 12 and "AM" or "PM")
		if hour > 12 then hour = hour - 12 end
		return format(color..TIMEMANAGER_TICKER_12HOUR..timerUnit, hour, minute)
	end
end

info.onUpdate = function(self, elapsed)
	self.timer = (self.timer or 3) + elapsed
	if self.timer > 5 then
		local color = C_Calendar.GetNumPendingInvites() > 0 and "|cffFF0000" or ""

		local hour, minute
		if GetCVarBool("timeMgrUseLocalTime") then
			hour, minute = tonumber(date("%H")), tonumber(date("%M"))
		else
			hour, minute = GetGameTime()
		end
		self.text:SetText(updateTimerFormat(color, hour, minute))

		self.timer = 0
	end
end

local function GetTimeWalkerName(id)
	return _G["PLAYER_DIFFICULTY_TIMEWALKER"].." - ".._G["EXPANSION_NAME"..id]
end

local questList = {
	{name = GetTimeWalkerName(0), id = 83285}, -- 经典旧世
	{name = GetTimeWalkerName(1), id = 40168}, -- 燃烧的远征
	{name = GetTimeWalkerName(2), id = 40173}, -- 巫妖王之怒
	{name = GetTimeWalkerName(3), id = 40786}, -- 大地的裂变
	{name = GetTimeWalkerName(4), id = 45563}, -- 熊猫人之谜
	{name = GetTimeWalkerName(5), id = 55498}, -- 德拉诺之王
	{name = GetTimeWalkerName(6), id = 64710}, -- 军团再临

	{name = "", id = 47523, questName = true}, -- 干扰检测-黑暗神殿
	{name = "", id = 50316, questName = true}, -- 干扰检测-奥杜尔
	{name = "", id = 57637, questName = true}, -- 干扰检测-火焰之地
	{name = "", id = 82817, questName = true}, -- 干扰检测-黑石深渊

	{name = "", id = 76586, questName = true}, -- 散布圣光
	{name = "", id = 80670, questName = true}, -- 纺丝者之眼
	{name = "", id = 80671, questName = true}, -- 将军之锋
	{name = "", id = 80672, questName = true}, -- 宰相之手
	{name = "", id = 83240, questName = true}, -- 剧场巡演
	{name = "", id = 83333, questName = true}, -- 谨防麻烦
	{name = "", id = 91173, questName = true}, -- 圣焰永明耀
}

local delvesKeys = {84736, 84737, 84738, 84739}
local keyName = C_CurrencyInfo.GetCurrencyInfo(3028).name

-- Check Invasion Status
local region = GetCVar("portal")
local legionZoneTime = {
	["EU"] = 1565168400, -- CN-16
	["US"] = 1565197200, -- CN-8
	["CN"] = 1565226000, -- CN time 8/8/2019 09:00 [1]
}
local bfaZoneTime = {
	["CN"] = 1546743600, -- CN time 1/6/2019 11:00 [1]
	["EU"] = 1546768800, -- CN+7
	["US"] = 1546769340, -- CN+16
}

local invIndex = {
	[1] = {title = L["Legion Invasion"], duration = 66600, maps = {630, 641, 650, 634}, timeTable = {}, baseTime = legionZoneTime[region] or legionZoneTime["CN"]},
	[2] = {title = L["BfA Invasion"], duration = 68400, maps = {862, 863, 864, 896, 942, 895}, timeTable = {4, 1, 6, 2, 5, 3}, baseTime = bfaZoneTime[region] or bfaZoneTime["CN"]},
}

local mapAreaPoiIDs = {
	[630] = 5175,
	[641] = 5210,
	[650] = 5177,
	[634] = 5178,
	[862] = 5973,
	[863] = 5969,
	[864] = 5970,
	[896] = 5964,
	[942] = 5966,
	[895] = 5896,
}

local function getInvasionInfo(mapID)
	local areaPoiID = mapAreaPoiIDs[mapID]
	local seconds = C_AreaPoiInfo.GetAreaPOISecondsLeft(areaPoiID)
	local mapInfo = C_Map.GetMapInfo(mapID)
	return seconds, mapInfo.name
end

local function CheckInvasion(index)
	for _, mapID in pairs(invIndex[index].maps) do
		local timeLeft, name = getInvasionInfo(mapID)
		if timeLeft and timeLeft > 0 then
			return timeLeft, name
		end
	end
end

local function GetNextTime(baseTime, index)
	local currentTime = time()
	local duration = invIndex[index].duration
	local elapsed = mod(currentTime - baseTime, duration)
	return duration - elapsed + currentTime
end

local function GetNextLocation(nextTime, index)
	local inv = invIndex[index]
	local count = #inv.timeTable
	if count == 0 then return QUEUE_TIME_UNAVAILABLE end

	local elapsed = nextTime - inv.baseTime
	local round = mod(math.floor(elapsed / inv.duration) + 1, count)
	if round == 0 then round = count end
	return C_Map.GetMapInfo(inv.maps[inv.timeTable[round]]).name
end

-- Grant hunts
local huntAreaToMapID = { -- 狩猎区域ID转换为地图ID
	[7342] = 2023, -- 欧恩哈拉平原
	[7343] = 2022, -- 觉醒海岸
	[7344] = 2025, -- 索德拉苏斯
	[7345] = 2024, -- 碧蓝林海
}

-- Elemental invasion
local stormPoiIDs = {
	[2022] = {
		{7249, 7250, 7251, 7252},
		{7253, 7254, 7255, 7256},
		{7257, 7258, 7259, 7260},
	},
	[2023] = {
		{7221, 7222, 7223, 7224},
		{7225, 7226, 7227, 7228},
	},
	[2024] = {
		{7229, 7230, 7231, 7232},
		{7233, 7234, 7235, 7236},
		{7237, 7238, 7239, 7240},
	},
	[2025] = {
		{7245, 7246, 7247, 7248},
		{7298, 7299, 7300, 7301},
	},
	--[2085] = {
	--	{7241, 7242, 7243, 7244},
	--},
}

local atlasCache = {}
local function GetElementalType(element) -- 获取入侵类型图标
	local str = atlasCache[element]
	if not str then
		local info = C_Texture.GetAtlasInfo("ElementalStorm-Lesser-"..element)
		if info then
			str = B:GetTextureStrByAtlas(info, 16, 16)
			atlasCache[element] = str
		end
	end
	return str
end

local function GetFormattedTimeLeft(timeLeft)
	return format("%.2d:%.2d", timeLeft/60, timeLeft%60)
end

local itemCache = {}
local function GetItemLink(itemID)
	local link = itemCache[itemID]
	if not link then
		link = select(2, C_Item.GetItemInfo(itemID))
		itemCache[itemID] = link
	end
	return link
end

local title
local function addTitle(text1, text2)
	if not title then
		GameTooltip:AddLine(" ")

		if text2 then
			GameTooltip:AddDoubleLine(text1..":", text2, 0,1,1, 1,1,1)
		else
			GameTooltip:AddLine(text1..":", 0,1,1)
		end

		title = true
	end
end

info.onShiftDown = function()
	if info.entered then
		info:onEnter()
	end
end

local communityFeastTime = {
	["CN"] = 1679747400, -- 20:30
	["TW"] = 1679747400, -- 20:30
	["KR"] = 1679747400, -- 20:30
	["EU"] = 1679749200, -- 21:00
	["US"] = 1679751000, -- 21:30
}

local delveList = {
	{uiMapID = 2214, delveID = 7782}, -- The Waterworks
	{uiMapID = 2214, delveID = 7788}, -- The Dread Pit
	{uiMapID = 2214, delveID = 8181}, -- Excavation Site 9
	{uiMapID = 2215, delveID = 7780}, -- Mycomancer Cavern
	{uiMapID = 2215, delveID = 7783}, -- The Sinkhole
	{uiMapID = 2215, delveID = 7785}, -- Nightfall Sanctum
	{uiMapID = 2215, delveID = 7789}, -- Skittering Breach
	{uiMapID = 2248, delveID = 7779}, -- Fungal Folly
	{uiMapID = 2248, delveID = 7781}, -- Kriegval's Rest
	{uiMapID = 2248, delveID = 7787}, -- Earthcrawl Mines
	{uiMapID = 2255, delveID = 7784}, -- Tak-Rethan Abyss
	{uiMapID = 2255, delveID = 7786}, -- The Underkeep
	{uiMapID = 2255, delveID = 7790}, -- The Spiral Weave
	{uiMapID = 2346, delveID = 8246}, -- Sidestree Sluice
}

info.onEnter = function(self)
	self.entered = true

	RequestRaidInfo()

	local r,g,b = 1,1,1
	local _, anchor, offset = module:GetTooltipAnchor(info)
	GameTooltip:SetOwner(self, "ANCHOR_"..anchor, 0, offset)
	GameTooltip:ClearLines()
	local today = C_DateAndTime.GetCurrentCalendarTime()
	local w, m, d, y = today.weekday, today.month, today.monthDay, today.year
	GameTooltip:AddLine(format(FULLDATE, CALENDAR_WEEKDAY_NAMES[w], CALENDAR_FULLDATE_MONTH_NAMES[m], d, y), 0,1,1)
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(L["Local Time"], GameTime_GetLocalTime(true), 0,1,1 ,1,1,1)
	GameTooltip:AddDoubleLine(L["Realm Time"], GameTime_GetGameTime(true), 0,1,1 ,1,1,1)

	-- World bosses
	title = false
	for i = 1, GetNumSavedWorldBosses() do
		local name, id, reset = GetSavedWorldBossInfo(i)
		if not (id == 11 or id == 12 or id == 13) then
			addTitle(RAID_INFO_WORLD_BOSS)
			GameTooltip:AddDoubleLine(name, SecondsToTime(reset, true, true, 3), 1,1,1, 1,1,1)
		end
	end

	-- Dungeons
	title = false
	for i = 1, GetNumSavedInstances() do
		local name, _, reset, diffID, locked, extended, _, _, _, diffName, bossTotal, bossCurrent = GetSavedInstanceInfo(i)
		if diffID == 23 and (locked or extended) then
			addTitle(MYTHIC_DUNGEONS, SecondsToTime(reset, true, true, 3))
			local pR, pG, pB = B.SmoothColor(bossCurrent, bossTotal)
			GameTooltip:AddDoubleLine(name, format("%s %s / %s", diffName, bossCurrent, bossTotal), 1,1,1, pR,pG,pB)
		end
	end

	-- Raids
	title = false
	for i = 1, GetNumSavedInstances() do
		local name, _, reset, diffID, locked, extended, _, isRaid, _, diffName, bossTotal, bossCurrent = GetSavedInstanceInfo(i)
		if isRaid and (locked or extended) then
			addTitle(RAIDS, SecondsToTime(reset, true, true, 3))
			local dR, dG, dB = unpack(DIFFICULTY_COLOR[diffID])
			GameTooltip:AddDoubleLine(name, format("%s %s / %s", diffName, bossCurrent, bossTotal), 1,1,1, dR,dG,dB)
		end
	end

	-- Quests
	title = false
	for _, v in pairs(questList) do
		if v.id and C_QuestLog.IsQuestFlaggedCompleted(v.id) then
			addTitle(QUESTS_LABEL)
			GameTooltip:AddDoubleLine((v.itemID and GetItemLink(v.itemID)) or (v.questName and QuestUtils_GetQuestName(v.id)) or v.name, QUEST_COMPLETE, 1,1,1, 1,0,0)
		end
	end

	local currentKeys, maxKeys = 0, #delvesKeys
	for _, questID in pairs(delvesKeys) do
		if C_QuestLog.IsQuestFlaggedCompleted(questID) then
			currentKeys = currentKeys + 1
		end
	end
	if currentKeys > 0 then
		addTitle(QUESTS_LABEL)
		r, g, b = B.SmoothColor(currentKeys, maxKeys)
		GameTooltip:AddDoubleLine(keyName, format("%d / %d", currentKeys, maxKeys), 1,1,1, r,g,b)
	end

	-- Delves
	title = false
	for _, v in pairs(delveList) do
		local delveInfo = C_AreaPoiInfo.GetAreaPOIInfo(v.uiMapID, v.delveID)
		if delveInfo then
			addTitle(delveInfo.description)
			local mapInfo = C_Map.GetMapInfo(v.uiMapID)
			GameTooltip:AddDoubleLine(mapInfo.name.." - "..delveInfo.name, SecondsToTime(GetQuestResetTime(), true, true, 3), 1,1,1, 0,1,0)
		end
	end

	if IsShiftKeyDown() then
		-- Elemental threats
		title = false
		for mapID, stormGroup in next, stormPoiIDs do
			for _, areaPoiIDs in next, stormGroup do
				for _, areaPoiID in next, areaPoiIDs do
					local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(mapID, areaPoiID)
					local elementType = poiInfo and poiInfo.atlasName and string.match(poiInfo.atlasName, "ElementalStorm%-Lesser%-(.+)")
					if elementType then
						addTitle(poiInfo.name)
						local mapInfo = C_Map.GetMapInfo(mapID)
						local timeLeft = C_AreaPoiInfo.GetAreaPOISecondsLeft(areaPoiID) or 0
						timeLeft = timeLeft/60
						if timeLeft < 60 then r,g,b = 1,0,0 else r,g,b = 0,1,0 end
						GameTooltip:AddDoubleLine(mapInfo.name..GetElementalType(elementType), GetFormattedTimeLeft(timeLeft), 1,1,1, r,g,b)
						break
					end
				end
			end
		end

		-- Grand hunts
		title = false
		for areaPoiID, mapID in pairs(huntAreaToMapID) do
			local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(1978, areaPoiID) -- Dragon isles
			if poiInfo then
				addTitle(poiInfo.name)
				local mapInfo = C_Map.GetMapInfo(mapID)
				local timeLeft = C_AreaPoiInfo.GetAreaPOISecondsLeft(areaPoiID) or 0
				timeLeft = timeLeft/60
				if timeLeft < 60 then r,g,b = 1,0,0 else r,g,b = 0,1,0 end
				GameTooltip:AddDoubleLine(mapInfo.name, GetFormattedTimeLeft(timeLeft), 1,1,1, r,g,b)
				break
			end
		end

		-- Community feast
		title = false
		local feastTime = communityFeastTime[region]
		if feastTime then
			local currentTime = time()
			local duration = 5400 -- 1.5hrs
			local elapsed = mod(currentTime - feastTime, duration)
			local nextTime = duration - elapsed + currentTime

			addTitle(COMMUNITY_FEAST)
			if currentTime - (nextTime-duration) < 900 then r,g,b = 0,1,0 else r,g,b = .6,.6,.6 end -- green text if progressing
			GameTooltip:AddDoubleLine(date("%m/%d %H:%M", nextTime-duration*2), date("%m/%d %H:%M", nextTime-duration), .6,.6,.6, r,g,b)
			GameTooltip:AddDoubleLine(date("%m/%d %H:%M", nextTime), date("%m/%d %H:%M", nextTime+duration), 1,1,1, 1,1,1)
		end

		-- Invasions
		for index, value in ipairs(invIndex) do
			title = false
			addTitle(value.title)
			local timeLeft, zoneName = CheckInvasion(index)
			local nextTime = GetNextTime(value.baseTime, index)
			if timeLeft then
				timeLeft = timeLeft/60
				if timeLeft < 60 then r,g,b = 1,0,0 else r,g,b = 0,1,0 end
				GameTooltip:AddDoubleLine(L["Current Invasion"]..zoneName, GetFormattedTimeLeft(timeLeft), 1,1,1, r,g,b)
			end
			local nextLocation = GetNextLocation(nextTime, index)
			GameTooltip:AddDoubleLine(L["Next Invasion"]..nextLocation, date("%m/%d %H:%M", nextTime), 1,1,1, 1,1,1)
		end
	else
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(L["Hold Shift"], 0,1,1)
	end

	-- Help Info
	GameTooltip:AddDoubleLine(" ", DB.LineString)
	GameTooltip:AddDoubleLine(" ", DB.LeftButton..L["Toggle Calendar"].." ", 1,1,1, 0,1,1)
	GameTooltip:AddDoubleLine(" ", DB.ScrollButton..RATED_PVP_WEEKLY_VAULT.." ", 1,1,1, 0,1,1)
	GameTooltip:AddDoubleLine(" ", DB.RightButton..L["Toggle Clock"].." ", 1,1,1, 0,1,1)
	GameTooltip:Show()

	B:RegisterEvent("MODIFIER_STATE_CHANGED", info.onShiftDown)
end

info.onLeave = function(self)
	self.entered = true
	B.HideTooltip()
	B:UnregisterEvent("MODIFIER_STATE_CHANGED", info.onShiftDown)
end

info.onMouseUp = function(_, btn)
	if btn == "RightButton" then
		ToggleTimeManager()
	elseif btn == "MiddleButton" then
		if not WeeklyRewardsFrame then C_AddOns.LoadAddOn("Blizzard_WeeklyRewards") end
		if InCombatLockdown() then
			B:TogglePanel(WeeklyRewardsFrame)
		else
			ToggleFrame(WeeklyRewardsFrame)
		end
		local dialog = WeeklyRewardExpirationWarningDialog
		if dialog and dialog:IsShown() then
			dialog:Hide()
		end
	else
		if InCombatLockdown() then UIErrorsFrame:AddMessage(DB.InfoColor..ERR_NOT_IN_COMBAT) return end -- fix by LibShowUIPanel
		ToggleCalendar()
	end
end