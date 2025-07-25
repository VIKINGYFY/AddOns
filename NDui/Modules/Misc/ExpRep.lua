local _, ns = ...
local B, C, L, DB = unpack(ns)
local M = B:GetModule("Misc")

local function IsAzeriteAvailable()
	local itemLocation = C_AzeriteItem.FindActiveAzeriteItem()
	return itemLocation and itemLocation:IsEquipmentSlot() and not C_AzeriteItem.IsAzeriteItemAtMaxLevel()
end

local function GetCMPText(var, varMax)
	return format("%s / %s (%.1f%%)", B.Numb(var), B.Numb(varMax), var / varMax * 100)
end

function M:ExpBar_Update()
	local rest = self.restBar
	if rest then rest:Hide() end

	local factionData = C_Reputation.GetWatchedFactionData()
	if not IsPlayerAtEffectiveMaxLevel() then
		local xp, mxp, rxp = UnitXP("player"), UnitXPMax("player"), GetXPExhaustion()
		self:SetStatusBarColor(0, .7, 1)
		self:SetMinMaxValues(0, mxp)
		self:SetValue(xp)
		self:Show()
		if rxp then
			rest:SetMinMaxValues(0, mxp)
			rest:SetValue(math.min(xp + rxp, mxp))
			rest:Show()
		end
		if IsXPUserDisabled() then self:SetStatusBarColor(.7, 0, 0) end
	elseif factionData then
		local standing = factionData.reaction
		local barMin = factionData.currentReactionThreshold
		local barMax = factionData.nextReactionThreshold
		local value = factionData.currentStanding
		local factionID = factionData.factionID
		if factionID and C_Reputation.IsMajorFaction(factionID) then
			local majorFactionData = C_MajorFactions.GetMajorFactionData(factionID)
			local isMaxRenown = C_MajorFactions.HasMaximumRenown(factionID)
			if isMaxRenown then
				barMin, barMax, value = 0, 1, 1
			else
				value = majorFactionData.renownReputationEarned or 0
				barMin, barMax = 0, majorFactionData.renownLevelThreshold
			end
		else
			local repInfo = C_GossipInfo.GetFriendshipReputation(factionID)
			local friendID, friendRep, friendThreshold, nextFriendThreshold = repInfo.friendshipFactionID, repInfo.standing, repInfo.reactionThreshold, repInfo.nextThreshold
			if C_Reputation.IsFactionParagon(factionID) then
				local currentValue, threshold = C_Reputation.GetFactionParagonInfo(factionID)
				currentValue = mod(currentValue, threshold)
				barMin, barMax, value = 0, threshold, currentValue
			elseif friendID and friendID ~= 0 then
				if nextFriendThreshold then
					barMin, barMax, value = friendThreshold, nextFriendThreshold, friendRep
				else
					barMin, barMax, value = 0, 1, 1
				end
				standing = 5
			else
				if standing == MAX_REPUTATION_REACTION then barMin, barMax, value = 0, 1, 1 end
			end
		end
		local color = FACTION_BAR_COLORS[standing] or FACTION_BAR_COLORS[5]
		self:SetStatusBarColor(color.r, color.g, color.b)
		self:SetMinMaxValues(barMin, barMax)
		self:SetValue(value)
		self:Show()
	elseif IsWatchingHonorAsXP() then
		local current, barMax = UnitHonor("player"), UnitHonorMax("player")
		self:SetStatusBarColor(1, .24, 0)
		self:SetMinMaxValues(0, barMax)
		self:SetValue(current)
		self:Show()
	elseif IsAzeriteAvailable() then
		local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem()
		local xp, totalLevelXP = C_AzeriteItem.GetAzeriteItemXPInfo(azeriteItemLocation)
		self:SetStatusBarColor(.9, .8, .6)
		self:SetMinMaxValues(0, totalLevelXP)
		self:SetValue(xp)
		self:Show()
	elseif HasArtifactEquipped() then
		if C_ArtifactUI.IsEquippedArtifactDisabled() then
			self:SetStatusBarColor(.6, .6, .6)
			self:SetMinMaxValues(0, 1)
			self:SetValue(1)
		else
			local _, _, _, _, totalXP, pointsSpent, _, _, _, _, _, _, artifactTier = C_ArtifactUI.GetEquippedArtifactInfo()
			local _, xp, xpForNextPoint = ArtifactBarGetNumArtifactTraitsPurchasableFromXP(pointsSpent, totalXP, artifactTier)
			xp = xpForNextPoint == 0 and 0 or xp
			self:SetStatusBarColor(.9, .8, .6)
			self:SetMinMaxValues(0, xpForNextPoint)
			self:SetValue(xp)
		end
		self:Show()
	else
		self:Hide()
	end
end

function M:ExpBar_UpdateTooltip()
	GameTooltip:SetOwner(self, "ANCHOR_LEFT")
	GameTooltip:ClearLines()
	GameTooltip:AddLine(LEVEL..UnitLevel("player"), 0,1,1)

	if not IsPlayerAtEffectiveMaxLevel() then
		GameTooltip:AddLine(" ")
		local xp, mxp, rxp = UnitXP("player"), UnitXPMax("player"), GetXPExhaustion()
			GameTooltip:AddDoubleLine(EXPERIENCE_COLON, GetCMPText(xp, mxp), 0,1,1, 1,1,1)
			GameTooltip:AddDoubleLine(NEXT_RANK_COLON, GetCMPText(mxp-xp, mxp), 0,1,1, 1,1,1)
		if rxp then
			GameTooltip:AddDoubleLine(TUTORIAL_TITLE26..":", GetCMPText(rxp, mxp), 0,1,1, 1,1,1)
		end
		if IsXPUserDisabled() then GameTooltip:AddLine("|cffFF0000"..XP..GLYPH_LOCKED) end
	end

	local factionData = C_Reputation.GetWatchedFactionData()
	if factionData then
		local name = factionData.name
		local standing = factionData.reaction
		local barMin = factionData.currentReactionThreshold
		local barMax = factionData.nextReactionThreshold
		local value = factionData.currentStanding
		local factionID = factionData.factionID
		local standingtext
		if factionID and C_Reputation.IsMajorFaction(factionID) then
			local majorFactionData = C_MajorFactions.GetMajorFactionData(factionID)
			name = majorFactionData.name
			standingtext = format(RENOWN_LEVEL_LABEL, majorFactionData.renownLevel)

			local isMaxRenown = C_MajorFactions.HasMaximumRenown(factionID)
			if isMaxRenown then
				barMin, barMax, value = 0, 1, 1
			else
				value = majorFactionData.renownReputationEarned or 0
				barMin, barMax = 0, majorFactionData.renownLevelThreshold
			end
		else
			local repInfo = C_GossipInfo.GetFriendshipReputation(factionID)
			local friendID, friendRep, friendThreshold, nextFriendThreshold = repInfo.friendshipFactionID, repInfo.standing, repInfo.reactionThreshold, repInfo.nextThreshold
			local repRankInfo = C_GossipInfo.GetFriendshipReputationRanks(factionID)
			local currentRank, maxRank = repRankInfo.currentLevel, repRankInfo.maxLevel
			if friendID and friendID ~= 0 then
				if maxRank > 0 then
					name = name.." ("..currentRank.." / "..maxRank..")"
				end
				if nextFriendThreshold then
					barMin, barMax, value = friendThreshold, nextFriendThreshold, friendRep
				else
					barMax = barMin + 1e3
					value = barMax - 1
				end
				standingtext = repInfo.reaction
			else
				if standing == MAX_REPUTATION_REACTION then
					barMax = barMin + 1e3
					value = barMax - 1
				end
				standingtext = _G["FACTION_STANDING_LABEL"..standing] or UNKNOWN
			end
		end
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(name, 0,1,1)
		GameTooltip:AddDoubleLine(standingtext, GetCMPText(value - barMin, barMax - barMin), 0,1,1, 1,1,1)

		if C_Reputation.IsFactionParagon(factionID) then
			local currentValue, threshold = C_Reputation.GetFactionParagonInfo(factionID)
			currentValue = mod(currentValue, threshold)
			GameTooltip:AddDoubleLine(L["Paragon"]..math.floor(currentValue/threshold), GetCMPText(currentValue, threshold), 0,1,1, 1,1,1)
		end

		if factionID == 2465 then -- 荒猎团
			local repInfo = C_GossipInfo.GetFriendshipReputation(2463) -- 玛拉斯缪斯
			local standing, name, reaction, reactionThreshold, nextThreshold = repInfo.standing, repInfo.name, repInfo.reaction, repInfo.reactionThreshold, repInfo.nextThreshold
			if nextThreshold and standing > 0 then
				local current = standing - reactionThreshold
				local currentMax = nextThreshold - reactionThreshold
				GameTooltip:AddLine(" ")
				GameTooltip:AddLine(name, 0,1,1)
				GameTooltip:AddDoubleLine(reaction, GetCMPText(current, currentMax), 0,1,1, 1,1,1)
			end
		elseif factionID == 2574 then -- 梦境守望者
			local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(2649) -- 梦境注能
			local quantity = currencyInfo.quantity
			local maxQuantity = currencyInfo.maxQuantity
			local name = C_CurrencyInfo.GetCurrencyInfo(2777).name
			GameTooltip:AddDoubleLine(name, GetCMPText(quantity, maxQuantity), 0,1,1, 1,1,1)
		end
	end

	if IsWatchingHonorAsXP() then
		local current, barMax, level = UnitHonor("player"), UnitHonorMax("player"), UnitHonorLevel("player")
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(HONOR, 0,1,1)
		GameTooltip:AddDoubleLine(LEVEL..level, GetCMPText(current, barMax), 0,1,1, 1,1,1)
	end

	if IsAzeriteAvailable() then
		local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem()
		local azeriteItem = Item:CreateFromItemLocation(azeriteItemLocation)
		local xp, totalLevelXP = C_AzeriteItem.GetAzeriteItemXPInfo(azeriteItemLocation)
		local currentLevel = C_AzeriteItem.GetPowerLevel(azeriteItemLocation)
		azeriteItem:ContinueWithCancelOnItemLoad(function()
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(azeriteItem:GetItemName().." ("..format(SPELLBOOK_AVAILABLE_AT, currentLevel)..")", 0,1,1)
			GameTooltip:AddDoubleLine(ARTIFACT_POWER, GetCMPText(xp, totalLevelXP), 0,1,1, 1,1,1)
		end)
	end

	if HasArtifactEquipped() then
		local _, _, name, _, totalXP, pointsSpent, _, _, _, _, _, _, artifactTier = C_ArtifactUI.GetEquippedArtifactInfo()
		local num, xp, xpForNextPoint = ArtifactBarGetNumArtifactTraitsPurchasableFromXP(pointsSpent, totalXP, artifactTier)
		GameTooltip:AddLine(" ")
		if C_ArtifactUI.IsEquippedArtifactDisabled() then
			GameTooltip:AddLine(name, 0,1,1)
			GameTooltip:AddLine(ARTIFACT_RETIRED, 0,1,1, 1)
		else
			GameTooltip:AddLine(name.." ("..format(SPELLBOOK_AVAILABLE_AT, pointsSpent)..")", 0,1,1)
			local numText = num > 0 and " ("..num..")" or ""
			GameTooltip:AddDoubleLine(ARTIFACT_POWER, BreakUpLargeNumbers(totalXP)..numText, 0,1,1, 1,1,1)
			if xpForNextPoint ~= 0 then
				GameTooltip:AddDoubleLine(L["Next Trait"], GetCMPText(xp, xpForNextPoint), 0,1,1, 1,1,1)
			end
		end
	end
	GameTooltip:Show()
end

function M:SetupScript(bar)
	bar.eventList = {
		"ARTIFACT_XP_UPDATE",
		"AZERITE_ITEM_EXPERIENCE_CHANGED",
		"CONFIRM_XP_LOSS",
		"DISABLE_XP_GAIN",
		"ENABLE_XP_GAIN",
		"HONOR_LEVEL_UPDATE",
		"HONOR_XP_UPDATE",
		"PLAYER_ENTERING_WORLD",
		"PLAYER_EQUIPMENT_CHANGED",
		"PLAYER_LEVEL_CHANGED",
		"PLAYER_TRIAL_XP_UPDATE",
		"PLAYER_XP_UPDATE",
		"UPDATE_EXHAUSTION",
		"UPDATE_FACTION",
	}
	for _, event in pairs(bar.eventList) do
		bar:RegisterEvent(event)
	end
	bar:SetScript("OnEvent", M.ExpBar_Update)
	bar:SetScript("OnEnter", M.ExpBar_UpdateTooltip)
	bar:SetScript("OnLeave", B.HideTooltip)
	bar:SetScript("OnMouseUp", function(_, btn)
		if not HasArtifactEquipped() or btn ~= "LeftButton" then return end
		if not ArtifactFrame or not ArtifactFrame:IsShown() then
			SocketInventoryItem(16)
		else
			B:TogglePanel(ArtifactFrame)
		end
	end)
	hooksecurefunc(StatusTrackingBarManager, "UpdateBarsShown", function()
		M.ExpBar_Update(bar)
	end)
end

function M:Expbar()
	if C.db["Map"]["DisableMinimap"] then return end
	if not C.db["Misc"]["ExpRep"] then return end

	local bar = B.CreateSB(MinimapCluster, nil, nil, "NDuiExpRepBar")
	bar:SetPoint("TOPLEFT", Minimap, "BOTTOMLEFT", 0, -DB.margin)
	bar:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", 0, -DB.margin)
	bar:SetHeight(2*DB.margin)

	local rest = CreateFrame("StatusBar", nil, bar)
	rest:SetAllPoints()
	rest:SetStatusBarTexture(DB.normTex)
	rest:SetStatusBarColor(0, .5, 1, .5)
	rest:SetFrameLevel(bar:GetFrameLevel() - 1)
	bar.restBar = rest

	M:SetupScript(bar)
end
M:RegisterMisc("ExpRep", M.Expbar)
