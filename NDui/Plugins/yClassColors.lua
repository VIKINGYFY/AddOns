local _, ns = ...
local B, C, L, DB = unpack(ns)
local S = B:GetModule("Skins")
local oUF = ns.oUF

----------------------------
-- yClassColors, by yleaf
-- NDui MOD
----------------------------

local function classColor(class, showRGB)
	local color = DB.ClassColors[DB.ClassList[class] or class]
	if not color then color = DB.ClassColors["PRIEST"] end

	if showRGB then
		return color.r, color.g, color.b
	else
		return color.colorStr
	end
end

local function diffColor(level)
	return B.HexRGB(GetCreatureDifficultyColor(level))
end

-- Communities
local function updateColumns(self)
	if not self.expanded then return end

	local playerArea = GetAreaText()
	local playerGuild, playerRank = GetGuildInfo("player")

	local memberInfo = self:GetMemberInfo()
	if memberInfo then
		local level = memberInfo.level
		if level then
			self.Level:SetText(diffColor(level)..level.."|r")
		end

		local zone = memberInfo.zone
		if zone and zone == playerArea then
			self.Zone:SetText("|cff00FF00"..zone.."|r")
		end

		local rank = memberInfo.guildRank
		if rank and rank == playerRank then
			self.Rank:SetText("|cff00FF00"..rank.."|r")
		end
	end
end

local function updateCommunities()
	hooksecurefunc(CommunitiesFrame.MemberList.ScrollBox, "Update", function(self)
		for i = 1, self.ScrollTarget:GetNumChildren() do
			local child = select(i, self.ScrollTarget:GetChildren())
			if not child.hooked then
				hooksecurefunc(child, "RefreshExpandedColumns", updateColumns)

				child.hooked = true
			end
		end
	end)
end
S:LoadSkins("Blizzard_Communities", updateCommunities)

-- Friends
hooksecurefunc(FriendsListFrame.ScrollBox, "Update", function(self)
	local playerArea = GetAreaText()

	for i = 1, self.ScrollTarget:GetNumChildren() do
		local button = select(i, self.ScrollTarget:GetChildren())
		local nameText, infoText
		if button:IsShown() then
			if button.buttonType == FRIENDS_BUTTON_TYPE_WOW then
				local info = C_FriendList.GetFriendInfoByIndex(button.id)
				if info and info.connected then
					nameText = format("%s - %s", classColor(info.className)..info.name.."|r", diffColor(info.level)..info.level.."|r")
					if info.area == playerArea then
						infoText = format("|cff00FF00%s|r", info.area)
					end
				end
			elseif button.buttonType == FRIENDS_BUTTON_TYPE_BNET then
				local accountInfo = C_BattleNet.GetFriendAccountInfo(button.id)
				if accountInfo then
					local accountName = accountInfo.accountName
					local gameAccountInfo = accountInfo.gameAccountInfo
					if gameAccountInfo.isOnline and gameAccountInfo.clientProgram == BNET_CLIENT_WOW then
						local name = gameAccountInfo.characterName
						local class = gameAccountInfo.className or UNKNOWN
						local area = gameAccountInfo.areaName or UNKNOWN
						if accountName and name and class then
							nameText = format("%s (%s)", accountName, classColor(class)..name.."|r")
							if area == playerArea then
								infoText = format("|cff00FF00%s|r", area)
							end
						end
					end
				end
			end
		end

		if nameText then button.name:SetText(nameText) end
		if infoText then button.info:SetText(infoText) end
	end
end)

-- Whoframe
local columnTable = {
	["zone"] = "",
	["guild"] = "",
	["race"] = "",
}

local currentType = "zone"
hooksecurefunc(C_FriendList, "SortWho", function(sortType)
	currentType = sortType
end)

hooksecurefunc(WhoFrame.ScrollBox, "Update", function(self)
	local playerArea = GetAreaText()
	local playerRace = UnitRace("player")
	local playerGuild, playerRank = GetGuildInfo("player")

	for i = 1, self.ScrollTarget:GetNumChildren() do
		local button = select(i, self.ScrollTarget:GetChildren())

		local nameText = button.Name
		local levelText = button.Level
		local variableText = button.Variable

		local info = C_FriendList.GetWhoInfo(button.index)
		if info then
			local guild, level, race, zone, class = info.fullGuildName, info.level, info.raceStr, info.area, info.filename
			if zone == playerZone then zone = "|cff00FF00"..zone.."|r" end
			if guild == playerGuild then guild = "|cff00FF00"..guild.."|r" end
			if race == playerRace then race = "|cff00FF00"..race.."|r" end

			columnTable.zone = zone or ""
			columnTable.guild = guild or ""
			columnTable.race = race or ""

			nameText:SetTextColor(classColor(class, true))
			levelText:SetText(diffColor(level)..level)
			variableText:SetText(columnTable[currentType])
		end
	end
end)
