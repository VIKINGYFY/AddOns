local _, ns = ...
local B, C, L, DB = unpack(ns)
local TT = B:RegisterModule("Tooltip")

local classification = {
	elite = " |cffFFFF00"..ELITE.."|r",
	rare = " |cff00FFFF"..MAP_LEGEND_RARE.."|r",
	rareelite = " |cffFF00FF"..MAP_LEGEND_RAREELITE.."|r",
	worldboss = " |cffFF0000"..BOSS.."|r",
}

function TT:GetUnit()
	local data = self:GetTooltipData()
	local guid = data and data.guid
	local unit = guid and UnitTokenFromGUID(guid)
	return unit, guid
end

local FACTION_COLORS = {
	[FACTION_ALLIANCE] = "|cff4080FF%s|r",
	[FACTION_HORDE] = "|cffFF5040%s|r",
}

local function replaceSpecInfo(str)
	return string.find(str, "%s") and "|cffFFCC00"..SPECIALIZATION..":|r "..str or str
end

function TT:UpdateFactionLine(lineData)
	if self:IsForbidden() then return end
	if not self:IsTooltipType(Enum.TooltipDataType.Unit) then return end

	local unit = TT.GetUnit(self)
	local unitClass = unit and UnitIsPlayer(unit) and UnitClass(unit)
	local unitCreature = unit and UnitCreatureType(unit)

	local linetext = lineData.leftText
	if linetext == PVP then
		return true
	elseif FACTION_COLORS[linetext] then
		return true
		--lineData.leftText = format(FACTION_COLORS[linetext], linetext)
	elseif unitClass and string.find(linetext, unitClass) then
		lineData.leftText = string.gsub(linetext, "(.-)%S+$", replaceSpecInfo)
	elseif unitCreature and linetext == unitCreature then
		return true
	end
end

function TT:GetLevelLine()
	for i = 2, self:NumLines() do
		local tiptext = _G["GameTooltipTextLeft"..i]
		if not tiptext then break end
		local linetext = tiptext:GetText()
		if linetext and string.find(linetext, LEVEL) then
			return tiptext
		end
	end
end

function TT:InsertFactionFrame(faction)
	if not self.factionLogo then
		local f = self:CreateTexture(nil, "OVERLAY")
		f:SetPoint("RIGHT", self, "RIGHT", 25, 0)
		f:SetBlendMode("ADD")
		f:SetScale(.4)
		f:SetAlpha(.6)
		self.factionLogo = f
	end
	self.factionLogo:SetTexture("Interface\\Timer\\"..faction.."-Logo")
	self.factionLogo:Show()
end

function TT:OnTooltipCleared()
	if self:IsForbidden() then return end

	GameTooltip_ClearMoney(self)
	GameTooltip_ClearStatusBars(self)
	GameTooltip_ClearProgressBars(self)
	GameTooltip_ClearWidgetSet(self)

	if self.StatusBar then
		self.StatusBar:ClearWatch()
	end

	if self.factionLogo and self.factionLogo:IsShown() then
		self.factionLogo:Hide()
	end
end

function TT.GetDungeonScore(score)
	local color = C_ChallengeMode.GetDungeonScoreRarityColor(score) or HIGHLIGHT_FONT_COLOR
	return color:WrapTextInColorCode(score)
end

function TT:ShowUnitMythicPlusScore(unit)
	if not C.db["Tooltip"]["MythicScore"] then return end

	local summary = C_PlayerInfo.GetPlayerMythicPlusRatingSummary(unit)
	local score = summary and summary.currentSeasonScore
	if score and score > 0 then
		GameTooltip:AddLine(format(L["MythicScore"], TT.GetDungeonScore(score)))
	end
end

local function ShouldHideInCombat()
	local index = C.db["Tooltip"]["HideInCombat"]
	if index == 1 then
		return true
	elseif index == 2 then
		return IsAltKeyDown()
	elseif index == 3 then
		return IsShiftKeyDown()
	elseif index == 4 then
		return IsControlKeyDown()
	elseif index == 5 then
		return false
	end
end

function TT:OnTooltipSetUnit()
	if self:IsForbidden() or self ~= GameTooltip then return end

	if not ShouldHideInCombat() and InCombatLockdown() then
		self:Hide()
		return
	end

	local unit, guid = TT.GetUnit(self)
	if not unit or not UnitExists(unit) then return end

	local isShiftKeyDown = IsShiftKeyDown()
	local isPlayer = UnitIsPlayer(unit)
	local unitFullName
	if isPlayer then
		local name, realm = UnitName(unit)
		unitFullName = name.."-"..(realm or DB.MyRealm)

		local pvpName = UnitPVPName(unit)
		if pvpName and pvpName ~= "" then
			name = pvpName
		end

		local relationship = UnitRealmRelationship(unit)
		if realm and realm ~= "" then
			name = name.." - "..realm
			if relationship == LE_REALM_RELATION_COALESCED then
				name = name..DB.InfoColor..FOREIGN_SERVER_LABEL.."|r"
			elseif relationship == LE_REALM_RELATION_VIRTUAL then
				name = name..DB.GreenColor..INTERACTIVE_SERVER_LABEL.."|r"
			end
		end

		local status = (UnitIsAFK(unit) and AFK) or (UnitIsDND(unit) and DND) or (not UnitIsConnected(unit) and PLAYER_OFFLINE)
		if status then
			status = format(" |cffFFFF00[%s]|r", status)
		end

		GameTooltipTextLeft1:SetFormattedText("%s%s", name, (status or ""))

		local faction = UnitFactionGroup(unit)
		if faction and faction ~= "Neutral" then
			TT.InsertFactionFrame(self, faction)
		end

		local guildInfo
		local guildName, rank, rankIndex, guildRealm = GetGuildInfo(unit)
		local hasText = GameTooltipTextLeft2:GetText()
		if guildName and hasText then
			local myGuild, _, _, myGuildRealm = GetGuildInfo("player")
			if IsInGuild() and guildName == myGuild and guildRealm == myGuildRealm then
				GameTooltipTextLeft2:SetTextColor(0, 1, 0)
			else
				GameTooltipTextLeft2:SetTextColor(0, 1, 1)
			end

			if guildRealm then
				guildName = guildName.." - "..guildRealm
			end

			rankIndex = rankIndex + 1
			guildInfo = format("<%s> %s(%s)", guildName, rank, rankIndex)

			if string.len(guildInfo) > 64 then
				guildInfo = L["Hold Shift"]..GUILD_INFORMATION
			end

			GameTooltipTextLeft2:SetText(guildInfo)
		end
	end

	local r, g, b = B.UnitColor(unit)
	local hexColor = B.HexRGB(r, g, b)
	local text = GameTooltipTextLeft1:GetText()
	if text then
		local ricon = GetRaidTargetIndex(unit)
		GameTooltipTextLeft1:SetFormattedText("%s%s", (ricon and ICON_LIST[ricon].."18|t " or ""), hexColor..text.."|r")
	end

	local tiptextLevel = TT.GetLevelLine(self)
	if tiptextLevel then
		local level
		if UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit) then
			level = UnitBattlePetLevel(unit)
		else
			level = UnitLevel(unit)
		end

		local boss
		if level < 0 then boss = "|cffFF0000??|r" end

		local diffColor = GetCreatureDifficultyColor(level)
		local unitLevel = format("%s%s|r", B.HexRGB(diffColor), (boss or level))
		local unitStatus = UnitIsDeadOrGhost(unit) and " |cffFF0000"..DEAD.."|r" or ""

		local pvpFlag = isPlayer and (UnitIsPVP(unit) and " |cffFF0000"..PVP.."|r" or "")
		local unitClass = isPlayer and (hexColor..UnitClass(unit).."|r" or "")
		local unitRace = isPlayer and (UnitRace(unit) or "")

		local classify = UnitClassification(unit)
		local reaction = UnitReaction(unit, "player")
		local classifyText = not isPlayer and (classify and classification[classify] or "")
		local standingText = not isPlayer and (reaction and hexColor.._G["FACTION_STANDING_LABEL"..reaction].."|r" or "")
		local unitType = not isPlayer and (UnitCreatureType(unit) or "")

		tiptextLevel:SetFormattedText("%s%s %s %s%s", unitLevel, pvpFlag or classifyText, unitClass or standingText, unitRace or unitType, unitStatus)
	end

	local unitTarget = unit.."target"
	if UnitExists(unitTarget) then
		local tarRicon = GetRaidTargetIndex(unitTarget)
		local tar = format("%s%s", (tarRicon and ICON_LIST[tarRicon].."10|t") or "", B.GetUnitTarget(unitTarget))
		self:AddLine(format("%s: %s", TARGET, tar))
	end

	if not isPlayer and isShiftKeyDown then
		local npcID = B.GetNPCID(guid)
		if npcID then
			self:AddLine(format("NpcID: |cff00FFFF%s|r", npcID))

			local npcName = UnitName("mouseover") or UNKNOWN
			print(format("[%s] = true, -- %s", npcID, npcName))
		end
	end

	if isPlayer then
		TT.InspectUnitItemLevel(self, unit)
		TT.ShowUnitMythicPlusScore(self, unit)
	end
	TT.ScanTargets(self, unit)
	TT.PetInfo_Setup(self, unit)

	-- Ignore note
	local ignoreNote = unitFullName and NDuiADB["IgnoreNotes"][unitFullName]
	if ignoreNote then
		self:AddLine(format("|cffFF0000%s:|r %s", IGNORED, ignoreNote), 1,1,1, 1)
	end
end

function TT:RefreshStatusBar(value)
	if not self.text then
		self.text = B.CreateFS(self, 12)
	end
	local unit = self.guid and UnitTokenFromGUID(self.guid)
	local unitHealthMax = unit and UnitHealthMax(unit)
	if unitHealthMax and unitHealthMax ~= 0 then
		self.text:SetText(B.Numb(value*unitHealthMax)..DB.Separator..B.Numb(unitHealthMax))
		self:SetStatusBarColor(B.UnitColor(unit))
	else
		self.text:SetFormattedText("%.1f%%", value*100)
	end
end

function TT:GameTooltip_ShowStatusBar()
	if not self or self:IsForbidden() then return end
	if not self.statusBarPool then return end

	local bar = self.statusBarPool:GetNextActive()
	if bar and not bar.styled then
		B.ReskinStatusBar(bar)

		bar.styled = true
	end
end

function TT:GameTooltip_ShowProgressBar()
	if not self or self:IsForbidden() then return end
	if not self.progressBarPool then return end

	local bar = self.progressBarPool:GetNextActive()
	if bar and not bar.styled then
		B.ReskinStatusBar(bar.Bar)

		bar.styled = true
	end
end

-- Anchor and mover
local cursorIndex = {
	[1] = "ANCHOR_NONE",
	[2] = "ANCHOR_CURSOR_LEFT",
	[3] = "ANCHOR_CURSOR",
	[4] = "ANCHOR_CURSOR_RIGHT"
}
local anchorIndex = {
	[1] = "TOPLEFT",
	[2] = "TOPRIGHT",
	[3] = "BOTTOMLEFT",
	[4] = "BOTTOMRIGHT",
}
local mover
function TT:GameTooltip_SetDefaultAnchor(parent)
	if self:IsForbidden() then return end
	if not parent then return end

	local mode = C.db["Tooltip"]["CursorMode"]
	self:SetOwner(parent, cursorIndex[mode])
	if mode == 1 then
		if not mover then
			mover = B.Mover(self, L["Tooltip"], "GameTooltip", C.Tooltips.Pos, 100, 100)
		end
		self:ClearAllPoints()
		self:SetPoint(anchorIndex[C.db["Tooltip"]["TipAnchor"]], mover)
	end
end

function TT:SetupTooltipFonts()
	local textSize = DB.Font[2] + 2
	local headerSize = DB.Font[2] + 4

	B.SetFontSize(GameTooltipHeaderText, headerSize)
	B.SetFontSize(GameTooltipText, textSize)
	B.SetFontSize(GameTooltipTextSmall, textSize)

	if not GameTooltip.hasMoney then
		SetTooltipMoney(GameTooltip, 1, nil, "", "")
		SetTooltipMoney(GameTooltip, 1, nil, "", "")
		GameTooltip_ClearMoney(GameTooltip)
	end
	if GameTooltip.hasMoney then
		for i = 1, GameTooltip.numMoneyFrames do
			B.SetFontSize(_G["GameTooltipMoneyFrame"..i.."PrefixText"], textSize)
			B.SetFontSize(_G["GameTooltipMoneyFrame"..i.."SuffixText"], textSize)
		end
	end

	for _, tt in ipairs(GameTooltip.shoppingTooltips) do
		for i = 1, tt:GetNumRegions() do
			local region = select(i, tt:GetRegions())
			if region:IsObjectType("FontString") then
				B.SetFontSize(region, textSize)
			end
		end
	end
end

function TT:FixRecipeItemNameWidth()
	if not self.GetName then return end

	local name = self:GetName()
	for i = 1, self:NumLines() do
		local line = _G[name.."TextLeft"..i]
		if line and line:GetHeight() > 40 then
			line:SetWidth(line:GetWidth() + 2)
		end
	end
end

function TT:ResetUnit(btn)
	if btn == "LSHIFT" and UnitExists("mouseover") then
		GameTooltip:RefreshData()
	end
end

function TT:FixStoneSoupError()
	local blockTooltips = {
		[556] = true -- Stone Soup
	}
	hooksecurefunc(_G.UIWidgetTemplateStatusBarMixin, "Setup", function(self)
		if self:IsForbidden() and blockTooltips[self.widgetSetID] and self.Bar then
			self.Bar.tooltip = nil
		end
	end)
end

function TT:OnLogin()
	GameTooltip:HookScript("OnTooltipCleared", TT.OnTooltipCleared)
	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, TT.OnTooltipSetUnit)
	hooksecurefunc(GameTooltip.StatusBar, "SetValue", TT.RefreshStatusBar)
	TooltipDataProcessor.AddLinePreCall(Enum.TooltipDataLineType.None, TT.UpdateFactionLine)
	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, TT.FixRecipeItemNameWidth)

	hooksecurefunc("GameTooltip_ShowStatusBar", TT.GameTooltip_ShowStatusBar)
	hooksecurefunc("GameTooltip_ShowProgressBar", TT.GameTooltip_ShowProgressBar)
	hooksecurefunc("GameTooltip_SetDefaultAnchor", TT.GameTooltip_SetDefaultAnchor)
	TT:SetupTooltipFonts()
	TT:FixStoneSoupError()

	-- Elements
	TT:ReskinTooltipIcons()
	TT:SetupTooltipID()
	TT:AzeriteArmor()
	B:RegisterEvent("MODIFIER_STATE_CHANGED", TT.ResetUnit)
end

-- Tooltip Skin Registration
local tipTable = {}
function TT:RegisterTooltips(addon, func)
	tipTable[addon] = func
end
local function addonStyled(_, addon)
	if tipTable[addon] then
		tipTable[addon]()
		tipTable[addon] = nil
	end
end
B:RegisterEvent("ADDON_LOADED", addonStyled)

TT:RegisterTooltips("NDui", function()
	local tooltips = {
		ChatMenu,
		EmoteMenu,
		LanguageMenu,
		VoiceMacroMenu,
		GameTooltip,
		EmbeddedItemTooltip,
		ItemRefTooltip,
		ItemRefShoppingTooltip1,
		ItemRefShoppingTooltip2,
		ShoppingTooltip1,
		ShoppingTooltip2,
		AutoCompleteBox,
		FriendsTooltip,
		QuestScrollFrame.StoryTooltip,
		QuestScrollFrame.CampaignTooltip,
		GeneralDockManagerOverflowButtonList,
		ReputationParagonTooltip,
		NamePlateTooltip,
		QueueStatusFrame,
		FloatingGarrisonFollowerTooltip,
		FloatingGarrisonFollowerAbilityTooltip,
		FloatingGarrisonMissionTooltip,
		GarrisonFollowerAbilityTooltip,
		GarrisonFollowerTooltip,
		FloatingGarrisonShipyardFollowerTooltip,
		GarrisonShipyardFollowerTooltip,
		BattlePetTooltip,
		PetBattlePrimaryAbilityTooltip,
		PetBattlePrimaryUnitTooltip,
		FloatingBattlePetTooltip,
		FloatingPetBattleAbilityTooltip,
		IMECandidatesFrame,
		QuickKeybindTooltip,
		GameSmallHeaderTooltip,
	}
	for _, f in pairs(tooltips) do
		f:HookScript("OnShow", B.ReskinTooltip)
	end

	if SettingsTooltip then
		B.ReskinTooltip(SettingsTooltip)
		SettingsTooltip:SetScale(UIParent:GetScale())
	end

	-- DropdownMenu
	local dropdowns = {"DropDownList", "L_DropDownList", "Lib_DropDownList"}
	local function reskinDropdown()
		for _, name in pairs(dropdowns) do
			for i = 1, UIDROPDOWNMENU_MAXLEVELS do
				local menu = _G[name..i.."MenuBackdrop"]
				if menu and not menu.styled then
					menu:HookScript("OnShow", B.ReskinTooltip)
					menu.styled = true
				end
			end
		end
	end
	hooksecurefunc("UIDropDownMenu_CreateFrames", reskinDropdown)

	-- IME
	IMECandidatesFrame.selection:SetVertexColor(DB.r, DB.g, DB.b)

	-- Pet Tooltip
	PetBattlePrimaryUnitTooltip:HookScript("OnShow", function(self)
		self.Border:SetAlpha(0)
		if not self.iconStyled then
			if self.glow then self.glow:Hide() end
			self.Icon:SetTexCoord(unpack(DB.TexCoord))
			self.iconStyled = true
		end
	end)

	hooksecurefunc("PetBattleUnitTooltip_UpdateForUnit", function(self)
		local nextBuff, nextDebuff = 1, 1
		for i = 1, C_PetBattles.GetNumAuras(self.petOwner, self.petIndex) do
			local _, _, _, isBuff = C_PetBattles.GetAuraInfo(self.petOwner, self.petIndex, i)
			if isBuff and self.Buffs then
				local frame = self.Buffs.frames[nextBuff]
				if frame and frame.Icon then
					frame.Icon:SetTexCoord(unpack(DB.TexCoord))
				end
				nextBuff = nextBuff + 1
			elseif (not isBuff) and self.Debuffs then
				local frame = self.Debuffs.frames[nextDebuff]
				if frame and frame.Icon then
					frame.DebuffBorder:Hide()
					frame.Icon:SetTexCoord(unpack(DB.TexCoord))
				end
				nextDebuff = nextDebuff + 1
			end
		end
	end)

	-- Others
	C_Timer.After(5, function()
		-- BagSync
		if BSYC_EventAlertTooltip then
			B.ReskinTooltip(BSYC_EventAlertTooltip)
		end
		-- Libs
		if LibDBIconTooltip then
			B.ReskinTooltip(LibDBIconTooltip)
		end
		if AceConfigDialogTooltip then
			B.ReskinTooltip(AceConfigDialogTooltip)
		end
		-- TomTom
		if TomTomTooltip then
			B.ReskinTooltip(TomTomTooltip)
		end
		-- RareScanner
		if RSMapItemToolTip then
			B.ReskinTooltip(RSMapItemToolTip)
		end
		if LootBarToolTip then
			B.ReskinTooltip(LootBarToolTip)
		end
		-- Narcissus
		if NarciGameTooltip then
			B.ReskinTooltip(NarciGameTooltip)
		end
		-- Altoholic
		if AltoTooltip then
			B.ReskinTooltip(AltoTooltip)
		end
	end)

	if C_AddOns.IsAddOnLoaded("BattlePetBreedID") then
		hooksecurefunc("BPBID_SetBreedTooltip", function(parent)
			if parent == FloatingBattlePetTooltip then
				B.ReskinTooltip(BPBID_BreedTooltip2)
			else
				B.ReskinTooltip(BPBID_BreedTooltip)
			end
		end)
	end

	-- MDT and DT
	if MDT and MDT.ShowInterface then
		local styledMDT
		hooksecurefunc(MDT, "ShowInterface", function()
			if not styledMDT then
				B.ReskinTooltip(MDT.tooltip)
				B.ReskinTooltip(MDT.pullTooltip)
				styledMDT = true
			end
		end)
	end
end)

TT:RegisterTooltips("Blizzard_DebugTools", function()
	B.ReskinTooltip(FrameStackTooltip)
	FrameStackTooltip:SetScale(UIParent:GetScale())
end)

TT:RegisterTooltips("Blizzard_EventTrace", function()
	B.ReskinTooltip(EventTraceTooltip)
end)

TT:RegisterTooltips("Blizzard_Collections", function()
	PetJournalPrimaryAbilityTooltip:HookScript("OnShow", B.ReskinTooltip)
	PetJournalSecondaryAbilityTooltip:HookScript("OnShow", B.ReskinTooltip)
	PetJournalPrimaryAbilityTooltip.Delimiter1:SetHeight(1)
	PetJournalPrimaryAbilityTooltip.Delimiter1:SetColorTexture(0, 0, 0)
	PetJournalPrimaryAbilityTooltip.Delimiter2:SetHeight(1)
	PetJournalPrimaryAbilityTooltip.Delimiter2:SetColorTexture(0, 0, 0)
end)

TT:RegisterTooltips("Blizzard_GarrisonUI", function()
	local gt = {
		GarrisonMissionMechanicTooltip,
		GarrisonMissionMechanicFollowerCounterTooltip,
		GarrisonShipyardMapMissionTooltip,
		GarrisonBonusAreaTooltip,
		GarrisonBuildingFrame.BuildingLevelTooltip,
		GarrisonFollowerAbilityWithoutCountersTooltip,
		GarrisonFollowerMissionAbilityWithoutCountersTooltip
	}
	for _, f in pairs(gt) do
		f:HookScript("OnShow", B.ReskinTooltip)
	end
end)

TT:RegisterTooltips("Blizzard_PVPUI", function()
	ConquestTooltip:HookScript("OnShow", B.ReskinTooltip)
end)

TT:RegisterTooltips("Blizzard_Contribution", function()
	ContributionBuffTooltip:HookScript("OnShow", B.ReskinTooltip)
	ContributionBuffTooltip.Icon:SetTexCoord(unpack(DB.TexCoord))
	ContributionBuffTooltip.Border:SetAlpha(0)
end)

TT:RegisterTooltips("Blizzard_EncounterJournal", function()
	EncounterJournalTooltip:HookScript("OnShow", B.ReskinTooltip)
	EncounterJournalTooltip.Item1.icon:SetTexCoord(unpack(DB.TexCoord))
	EncounterJournalTooltip.Item1.IconBorder:SetAlpha(0)
	EncounterJournalTooltip.Item2.icon:SetTexCoord(unpack(DB.TexCoord))
	EncounterJournalTooltip.Item2.IconBorder:SetAlpha(0)
end)

TT:RegisterTooltips("Blizzard_PerksProgram", function()
	if PerksProgramTooltip then
		B.ReskinTooltip(PerksProgramTooltip)
		PerksProgramTooltip:SetScale(UIParent:GetScale())
	end
end)