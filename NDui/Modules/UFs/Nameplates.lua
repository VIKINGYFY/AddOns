local _, ns = ...
local B, C, L, DB = unpack(ns)
local UF = B:GetModule("UnitFrames")

-- Init
function UF:UpdatePlateCVars()
	if C.db["Nameplate"]["InsideView"] then
		SetCVar("nameplateOtherTopInset", .05)
		SetCVar("nameplateOtherBottomInset", .08)
	elseif GetCVar("nameplateOtherTopInset") == "0.05" and GetCVar("nameplateOtherBottomInset") == "0.08" then
		SetCVar("nameplateOtherTopInset", -1)
		SetCVar("nameplateOtherBottomInset", -1)
	end

	SetCVar("namePlateMinScale", C.db["Nameplate"]["MinScale"])
	SetCVar("namePlateMaxScale", C.db["Nameplate"]["MinScale"])
	SetCVar("nameplateMinAlpha", C.db["Nameplate"]["MinAlpha"])
	SetCVar("nameplateMaxAlpha", C.db["Nameplate"]["MinAlpha"])
	SetCVar("nameplateOverlapV", C.db["Nameplate"]["VerticalSpacing"])
	SetCVar("nameplateShowOnlyNames", C.db["Nameplate"]["CVarOnlyNames"] and 1 or 0)
	SetCVar("nameplateShowFriendlyNPCs", C.db["Nameplate"]["CVarShowNPCs"] and 1 or 0)
	SetCVar("nameplateMaxDistance", C.db["Nameplate"]["PlateRange"])
end

function UF:UpdateClickableSize()
	if InCombatLockdown() then return end

	local uiScale = NDuiADB["UIScale"]
	local harmWidth = C.db["Nameplate"]["PlateWidth"] + C.db["Nameplate"]["PlateMargin"] * 2
	local harmHeight = C.db["Nameplate"]["PlateHeight"] * 2 + C.db["Nameplate"]["PlateMargin"] * 3

	C_NamePlate.SetNamePlateEnemySize(harmWidth*uiScale, harmHeight*uiScale)
	C_NamePlate.SetNamePlateFriendlySize(harmWidth*uiScale, harmHeight*uiScale)
end

function UF:SetupCVars()
	UF:UpdatePlateCVars()
	SetCVar("nameplateOverlapH", .8)
	SetCVar("nameplateSelectedAlpha", 1)
	SetCVar("showQuestTrackingTooltips", 1)

	SetCVar("nameplateSelectedScale", 1)
	SetCVar("nameplateLargerScale", 1)
	SetCVar("nameplateGlobalScale", 1)
	SetCVar("NamePlateHorizontalScale", 1)
	SetCVar("NamePlateVerticalScale", 1)
	SetCVar("NamePlateClassificationScale", 1)

	SetCVar("nameplateShowSelf", 0)
	SetCVar("nameplateResourceOnTarget", 0)
	SetCVar("nameplatePlayerMaxDistance", 60)

	C_NamePlate.SetNamePlateEnemyClickThrough(false)
	C_NamePlate.SetNamePlateFriendlyClickThrough(false)

	UF:UpdateClickableSize()
	hooksecurefunc(NamePlateDriverFrame, "UpdateNamePlateOptions", UF.UpdateClickableSize)
end

function UF:BlockAddons()
	if not C.db["Nameplate"]["BlockDBM"] then return end
	if not DBM or not DBM.Nameplate then return end

	if DBM.Options then
		DBM.Options.DontShowNameplateIcons = true
		DBM.Options.DontShowNameplateIconsCD = true
		DBM.Options.DontShowNameplateIconsCast = true
	end

	local function showAurasForDBM(_, _, _, spellID)
		if not tonumber(spellID) then return end
		if not C.WhiteList[spellID] then
			C.WhiteList[spellID] = true
		end
	end
	hooksecurefunc(DBM.Nameplate, "Show", showAurasForDBM)
end

-- Elements
local function refreshNameplateUnits(VALUE)
	table.wipe(UF[VALUE])
	if not C.db["Nameplate"]["Show"..VALUE] then return end

	for npcID in pairs(C[VALUE]) do
		if C.db["Nameplate"][VALUE][npcID] == nil then
			UF[VALUE][npcID] = true
		end
	end
	for npcID, value in pairs(C.db["Nameplate"][VALUE]) do
		if value then
			UF[VALUE][npcID] = true
		end
	end
end

UF.CustomUnits = {}
function UF:CreateUnitTable()
	refreshNameplateUnits("CustomUnits")
end

UF.PowerUnits = {}
function UF:CreatePowerUnitTable()
	refreshNameplateUnits("PowerUnits")
end

function UF:UpdateUnitPower()
	local unitName = self.unitName
	local npcID = self.npcID
	local shouldShowPower = UF.PowerUnits[unitName] or UF.PowerUnits[npcID]
	self.powerText:SetShown(shouldShowPower)
end


-- Player Status
local isInInstance, isInGroup, isInRaid
local function checkPlayerStatus()
	isInInstance = IsInInstance()
	isInGroup = IsInGroup()
	isInRaid = IsInRaid()
end

function UF:UpdatePlayerStatus()
	checkPlayerStatus()
	B:RegisterEvent("PLAYER_ENTERING_WORLD", checkPlayerStatus)
	B:RegisterEvent("PLAYER_DIFFICULTY_CHANGED", checkPlayerStatus)
end

-- Off-tank threat color
local groupRoles = {}
local function refreshGroupRoles()
	isInGroup = IsInGroup()
	isInRaid = IsInRaid()
	table.wipe(groupRoles)

	if isInGroup then
		local maxMembers = GetNumGroupMembers()
		for index = 1, maxMembers do
			local member = B.GetGroupUnit(index, maxMembers, isInRaid)
			if UnitExists(member) then
				groupRoles[UnitName(member)] = UnitGroupRolesAssigned(member)
			end
		end
	end
end

local function resetGroupRoles()
	isInGroup = IsInGroup()
	table.wipe(groupRoles)
end

function UF:UpdateGroupRoles()
	refreshGroupRoles()
	B:RegisterEvent("GROUP_ROSTER_UPDATE", refreshGroupRoles)
	B:RegisterEvent("GROUP_LEFT", resetGroupRoles)
end

function UF:CheckThreatStatus(unit)
	if not UnitExists(unit) then return end

	local unitTarget = unit.."target"
	local unitRole = isInGroup and UnitExists(unitTarget) and not UnitIsUnit(unitTarget, "player") and groupRoles[UnitName(unitTarget)] or "NONE"
	if DB.Role == "Tank" and unitRole == "TANK" then
		return true, UnitThreatSituation(unitTarget, unit)
	else
		return false, UnitThreatSituation("player", unit)
	end
end

-- Update unit color
function UF:UpdateColor(_, unit)
	if not unit or self.unit ~= unit then return end

	local name = self.unitName
	local npcID = self.npcID
	local isPlayer = self.isPlayer
	local isFriendly = self.isFriendly
	local isDoTUnit = self.Auras.hasTheDot
	local isTrashUnit = C.TrashUnits[npcID]
	local isWarningUnit = C.WarningUnits[npcID]
	local isCustomUnit = UF.CustomUnits[name] or UF.CustomUnits[npcID]
	local isSpecialUnits = (isDoTUnit or isWarningUnit or isCustomUnit or isTrashUnit)

	local isOffTank, status = UF:CheckThreatStatus(unit)
	local healthPerc = UnitHealth(unit) / (UnitHealthMax(unit)+.0001) * 100

	local customColor = C.db["Nameplate"]["CustomColor"]
	local dotColor = C.db["Nameplate"]["DotColor"]
	local friendlyCC = C.db["Nameplate"]["FriendlyCC"]
	local hostileCC = C.db["Nameplate"]["HostileCC"]
	local insecureColor = C.db["Nameplate"]["InsecureColor"]
	local offTankColor = C.db["Nameplate"]["OffTankColor"]
	local secureColor = C.db["Nameplate"]["SecureColor"]
	local transColor = C.db["Nameplate"]["TransColor"]
	local targetColor = C.db["Nameplate"]["TargetColor"]
	local mouseoverColor = C.db["Nameplate"]["MouseoverColor"]
	local warningColor = C.db["Nameplate"]["WarningColor"]

	local r, g, b

	if not UnitIsConnected(unit) or (not UnitPlayerControlled(unit) and UnitIsTapDenied(unit)) or isTrashUnit then
		r, g, b = .5, .5, .5
	else
		if isDoTUnit then
			r, g, b = B.GetColor(dotColor)
		elseif isWarningUnit then
			r, g, b = B.GetColor(warningColor)
		elseif isCustomUnit then
			r, g, b = B.GetColor(customColor)
		elseif isPlayer and ((isFriendly and friendlyCC) or (not isFriendly and hostileCC)) then
			r, g, b = B.UnitColor(unit)
		else
			r, g, b = UnitSelectionColor(unit, true)
		end
	end

	if status then
		if status == 3 then
			if DB.Role == "Tank" then
				if not isSpecialUnits then
					r, g, b = B.GetColor(secureColor)
				end
			else
				if isOffTank then
					r, g, b = B.GetColor(offTankColor)
				else
					r, g, b = B.GetColor(insecureColor)
				end
			end
		elseif status == 2 or status == 1 then
			r, g, b = B.GetColor(transColor)
		elseif status == 0 then
			if DB.Role == "Tank" then
				if isOffTank then
					r, g, b = B.GetColor(offTankColor)
				else
					r, g, b = B.GetColor(insecureColor)
				end
			else
				if not isSpecialUnits then
					r, g, b = B.GetColor(secureColor)
				end
			end
		end
	end

	self.Health:SetStatusBarColor(r, g, b)
	self.TargetIndicator.Glow:SetBackdropBorderColor(B.GetColor(targetColor))
	self.TargetIndicator.nameGlow:SetVertexColor(B.GetColor(targetColor))
	self.MouseoverIndicator.Glow:SetBackdropBorderColor(B.GetColor(mouseoverColor))
	self.MouseoverIndicator.nameGlow:SetVertexColor(B.GetColor(mouseoverColor))
end

function UF:UpdateNameplateIndicator()
	local targetIndicator = self.TargetIndicator
	local mouseoverIndicator = self.MouseoverIndicator

	local isNameOnly = self.plateType == "NameOnly"
	if isNameOnly then
		targetIndicator.Glow:Hide()
		targetIndicator.nameGlow:Show()
		mouseoverIndicator.Glow:Hide()
		mouseoverIndicator.nameGlow:Show()
	else
		targetIndicator.Glow:Show()
		targetIndicator.nameGlow:Hide()
		mouseoverIndicator.Glow:Show()
		mouseoverIndicator.nameGlow:Hide()
	end
end

function UF:CreateNameplateIndicator()
	local indicator = CreateFrame("Frame", nil, self)
	indicator:SetAllPoints()
	indicator:SetFrameLevel(0)
	indicator:Hide()

	indicator.Glow = B.CreateSD(indicator, 8, true)
	indicator.Glow:SetOutside(self, 8+C.mult, 8+C.mult)

	indicator.nameGlow = indicator:CreateTexture(nil, "BACKGROUND")
	indicator.nameGlow:SetSize(150, 80)
	indicator.nameGlow:SetTexture("Interface\\GLUES\\Models\\UI_Draenei\\GenericGlow64")
	indicator.nameGlow:SetBlendMode("ADD")
	indicator.nameGlow:SetPoint("CENTER", self, "BOTTOM")

	return indicator
end

-- Target indicator
function UF:UpdateTargetChange()
	local element = self.TargetIndicator
	if element then
		element:SetShown(UnitExists("target") and UnitIsUnit(self.unit, "target"))
	end
end

function UF:AddTargetIndicator(self)
	local targetColor = C.db["Nameplate"]["TargetColor"]

	local target = UF.CreateNameplateIndicator(self)
	target.Glow:SetBackdropBorderColor(B.GetColor(targetColor))
	target.nameGlow:SetVertexColor(B.GetColor(targetColor))

	self.TargetIndicator = target
	self:RegisterEvent("PLAYER_TARGET_CHANGED", UF.UpdateTargetChange, true)
end

-- Mouseover indicator
function UF:UpdateMouseoverChange()
	local element = self.MouseoverIndicator
	if element then
		element:SetShown(UnitExists("mouseover") and UnitIsUnit(self.unit, "mouseover"))
	end
end

function UF:AddMouseoverIndicator(self)
	local mouseoverColor = C.db["Nameplate"]["MouseoverColor"]

	local mouseover = UF.CreateNameplateIndicator(self)
	mouseover.Glow:SetBackdropBorderColor(B.GetColor(mouseoverColor))
	mouseover.nameGlow:SetVertexColor(B.GetColor(mouseoverColor))

	self.MouseoverIndicator = mouseover
	self:RegisterEvent("UPDATE_MOUSEOVER_UNIT", UF.UpdateMouseoverChange, true)
end

function UF:UpdateQuestUnit(_, unit)
	if isInInstance then
		self.questIcon:Hide()
		self.questCount:SetText("")
		return
	end

	unit = unit or self.unit
	local prevDiff, questProgress = 0

	local data = C_TooltipInfo.GetUnit(unit)
	if data then
		for i = 1, #data.lines do
			local lineData = data.lines[i]
			if lineData.type == 8 then
				local text = lineData.leftText -- progress string
				if text then
					local current, goal = string.match(text, "(%d+)/(%d+)")
					local progress = string.match(text, "(%d+)%%")
					if current and goal then
						local diff = math.floor(goal - current)
						if diff > prevDiff then
							questProgress = diff
							prevDiff = diff
						end
					elseif progress and prevDiff == 0 then
						if math.floor(100 - progress) > 0 then
							questProgress = progress.."%" -- lower priority on progress, keep looking
						end
					end
				end
			end
		end
	end

	if questProgress then
		self.questCount:SetText(questProgress)
		self.questIcon:Show()
	else
		self.questCount:SetText("")
		self.questIcon:Hide()
	end
end

function UF:AddQuestIcon(self)
	local qicon = self.Health:CreateTexture(nil, "ARTWORK")
	qicon:SetPoint("LEFT", self, "RIGHT", 3, 0)
	qicon:SetAtlas(DB.questTex)
	qicon:SetSize(30, 30)
	qicon:Hide()

	local count = B.CreateFS(self.Health, 20, "", "info")
	count:SetJustifyH("LEFT")
	count:SetPoint("LEFT", qicon, "RIGHT", -3, 0)

	self.questIcon = qicon
	self.questCount = count
	self:RegisterEvent("QUEST_LOG_UPDATE", UF.UpdateQuestUnit, true)
end

-- Unit classification
local NPClassifies = {
	rare = {0, 1, 1},
	elite = {1, 1, 0},
	rareelite = {1, 0, 1},
	worldboss = {1, 0, 0},
}

function UF:AddCreatureIcon(self)
	local size = C.db["Nameplate"]["NameTextSize"] + 4
	local icon = self.Health:CreateTexture(nil, "ARTWORK")
	icon:SetPoint("RIGHT", self.nameText, "LEFT", 8, 1)
	icon:SetAtlas(DB.starTex)
	icon:SetSize(size, size)
	icon:Hide()

	self.ClassifyIndicator = icon
end

function UF:UpdateUnitClassify(unit)
	if not self.ClassifyIndicator then return end
	if not unit then unit = self.unit end

	self.ClassifyIndicator:Hide()

	if self.__tagIndex > 3 then
		local class = UnitClassification(unit)
		local classify = class and NPClassifies[class]
		if classify then
			local r, g, b = unpack(classify)
			self.ClassifyIndicator:SetVertexColor(r, g, b)
			self.ClassifyIndicator:SetDesaturated(true)
			self.ClassifyIndicator:Show()
		end
	end
end

-- Interrupt info on castbars
function UF:UpdateSpellInterruptor(...)
	local _, _, sourceGUID, sourceName, _, _, destGUID = ...
	if destGUID == self.unitGUID and sourceGUID and sourceName and sourceName ~= "" then
		local _, class = GetPlayerInfoByGUID(sourceGUID)
		local r, g, b = B.ClassColor(class)
		local color = B.HexRGB(r, g, b)
		local sourceName = Ambiguate(sourceName, "short")
		self.Castbar.Text:SetText(INTERRUPTED.." > "..color..sourceName)
		self.Castbar.Time:SetText("")
	end
end

function UF:SpellInterruptor(self)
	if not self.Castbar then return end
	self:RegisterCombatEvent("SPELL_INTERRUPT", UF.UpdateSpellInterruptor)
end

function UF:ShowUnitTargeted(self)
	local ticon = self.Health:CreateTexture(nil, "ARTWORK")
	ticon:SetPoint("LEFT", self, "RIGHT", 5, 0)
	ticon:SetAtlas("target")
	ticon:SetSize(20, 20)
	ticon:Hide()

	local count = B.CreateFS(self.Health, 20, "", "info")
	count:SetJustifyH("LEFT")
	count:SetPoint("LEFT", ticon, "RIGHT", 0, 0)

	self.targetIcon = ticon
	self.targetCount = count
end

-- Create Nameplates
local platesList = {}
function UF:CreatePlates()
	self.mystyle = "nameplate"
	self:SetSize(C.db["Nameplate"]["PlateWidth"], C.db["Nameplate"]["PlateHeight"])
	self:SetPoint("CENTER")
	self:SetScale(NDuiADB["UIScale"])

	local health = CreateFrame("StatusBar", nil, self)
	health:SetFrameLevel(self:GetFrameLevel() - 1)
	health:SetStatusBarTexture(DB.normTex)
	health:SetAllPoints()

	B.SetBD(health)
	B.SmoothBar(health)

	self.Health = health
	self.Health.UpdateColor = UF.UpdateColor

	UF:CreateHealthText(self)
	UF:CreateCastBar(self)
	UF:CreateRaidMark(self)
	UF:CreatePrediction(self)
	UF:CreateAuras(self)
	UF:CreatePVPClassify(self)

	self.Auras.showStealableBuffs = C.db["Nameplate"]["DispellMode"] == 1
	self.Auras.alwaysShowStealable = C.db["Nameplate"]["DispellMode"] == 2

	local targetName = B.CreateFS(self, C.db["Nameplate"]["NameTextSize"]+4)
	targetName:ClearAllPoints()
	targetName:SetPoint("TOP", self.Castbar, "BOTTOM", 0, -DB.margin)
	targetName:Hide()
	self:Tag(targetName, "[targetname]")
	self.targetName = targetName

	local powerText = B.CreateFS(self, C.db["Nameplate"]["NameTextSize"]+2)
	powerText:ClearAllPoints()
	powerText:SetPoint("TOP", self.targetName, "BOTTOM", 0, -DB.margin)
	powerText:Hide()
	self:Tag(powerText, "[nppower]")
	self.powerText = powerText

	local title = B.CreateFS(self, C.db["Nameplate"]["NameOnlyTitleSize"])
	title:ClearAllPoints()
	title:SetPoint("TOP", self.nameText, "BOTTOM", 0, -DB.margin)
	title:Hide()
	self:Tag(title, "[npctitle]")
	self.npcTitle = title

	UF:AddMouseoverIndicator(self)
	UF:AddTargetIndicator(self)
	UF:AddCreatureIcon(self)
	UF:AddQuestIcon(self)
	UF:SpellInterruptor(self)
	UF:ShowUnitTargeted(self)

	platesList[self] = self:GetName()
end

function UF:ToggleNameplateAuras()
	if C.db["Nameplate"]["PlateAuras"] then
		if not self:IsElementEnabled("Auras") then
			self:EnableElement("Auras")
		end
	else
		if self:IsElementEnabled("Auras") then
			self:DisableElement("Auras")
		end
	end
end

function UF:UpdateNameplateAuras()
	UF.ToggleNameplateAuras(self)

	if not C.db["Nameplate"]["PlateAuras"] then return end

	local element = self.Auras
	if C.db["Nameplate"]["TargetPower"] then
		element:SetPoint("BOTTOMLEFT", self.nameText, "TOPLEFT", 0, DB.margin*2 + C.db["Nameplate"]["PPBarHeight"])
	else
		element:SetPoint("BOTTOMLEFT", self.nameText, "TOPLEFT", 0, DB.margin)
	end
	element.numTotal = C.db["Nameplate"]["maxAuras"]
	element.iconsPerRow = C.db["Nameplate"]["perRow"]
	element.showStealableBuffs = C.db["Nameplate"]["DispellMode"] == 1
	element.alwaysShowStealable = C.db["Nameplate"]["DispellMode"] == 2
	element.showDebuffType = true
	element.desaturateDebuff = true
	UF:UpdateAuraContainer(self, element, element.numTotal)
	element:ForceUpdate()
end

UF.PlateNameTags = {
	[1] = "",
	[2] = "[name]",
	[3] = "[nplevel][name]",
	[4] = "[nprare][name]",
	[5] = "[nprare][nplevel][name]",
}
function UF:UpdateNameplateSize()
	local plateWidth, plateHeight = C.db["Nameplate"]["PlateWidth"], C.db["Nameplate"]["PlateHeight"]
	local plateMargin = C.db["Nameplate"]["PlateMargin"]
	local nameTextSize = C.db["Nameplate"]["NameTextSize"]
	local healthTextSize = C.db["Nameplate"]["HealthTextSize"]
	local castbarTextSize = C.db["Nameplate"]["CastBarTextSize"]

	local iconSize = plateHeight*2 + plateMargin
	local nameType = C.db["Nameplate"]["NameType"]
	local nameOnlyTextSize, nameOnlyTitleSize = C.db["Nameplate"]["NameOnlyTextSize"], C.db["Nameplate"]["NameOnlyTitleSize"]

	if self.plateType == "NameOnly" then
		B.SetFontSize(self.nameText, nameOnlyTextSize)
		B.SetFontSize(self.npcTitle, nameOnlyTitleSize)

		self.__tagIndex = 6
		self:Tag(self.nameText, "[nprare][nplevel][color][name]")
		self.npcTitle:UpdateTag()
	else
		self.__tagIndex = nameType

		B.SetFontSize(self.nameText, nameTextSize)
		B.SetFontSize(self.targetName, nameTextSize+4)
		B.SetFontSize(self.Castbar.Text, castbarTextSize)
		B.SetFontSize(self.Castbar.Time, castbarTextSize)
		B.SetFontSize(self.Castbar.spellTarget, castbarTextSize+2)
		B.SetFontSize(self.healthValue, healthTextSize)

		self:SetSize(plateWidth, plateHeight)
		self.Castbar:SetHeight(plateHeight)
		self.ClassifyIndicator:SetSize(nameTextSize+4, nameTextSize+4)

		self.Castbar.Icon:SetSize(iconSize, iconSize)
		self.Castbar.glowFrame:SetSize(iconSize+8, iconSize+8)
		self.Castbar.Shield:SetSize(plateHeight*2, plateHeight*2)

		self.nameText:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, plateMargin)
		self.nameText:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, plateMargin)
		self.Castbar:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -plateMargin)
		self.Castbar:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -plateMargin)
		self.Castbar.Icon:SetPoint("BOTTOMRIGHT", self.Castbar, "BOTTOMLEFT", -plateMargin, 0)
		self.RaidTargetIndicator:SetPoint("BOTTOMLEFT", self, "TOPRIGHT", C.db["Nameplate"]["RaidTargetX"], C.db["Nameplate"]["RaidTargetY"])

		self:Tag(self.nameText, UF.PlateNameTags[nameType])
		self:Tag(self.healthValue, "[VariousHP("..UF.VariousTagIndex[C.db["Nameplate"]["HealthType"]]..")]")
		self.healthValue:UpdateTag()
	end
	self.nameText:UpdateTag()
end

function UF:RefreshNameplats()
	for nameplate in pairs(platesList) do
		UF.UpdateNameplateSize(nameplate)
		UF.UpdateUnitClassify(nameplate)
		UF.UpdateNameplateAuras(nameplate)
		UF.UpdateNameplateIndicator(nameplate)
		UF.UpdateTargetChange(nameplate)
		UF.UpdateMouseoverChange(nameplate)
	end
end

function UF:RefreshAllPlates()
	UF:ResizePlayerPlate()
	UF:RefreshNameplats()
	UF:ResizeTargetPower()
	UF:UpdateClickableSize()
end

local DisabledElements = {
	"Health",
	"Castbar",
	"HealthPrediction",
	"PvPClassificationIndicator",
}

local SoftTargetBlockElements = {
	"Auras",
	"RaidTargetIndicator",
}

function UF:UpdatePlateByType()
	local name = self.nameText
	local hpval = self.healthValue
	local title = self.npcTitle
	local questIcon = self.questIcon
	local raidTarget = self.RaidTargetIndicator
	local widgetContainer = self.widgetContainer

	if self.widgetsOnly then
		name:Hide()
	else
		name:Show()
		name:UpdateTag()
	end

	if self.isSoftTarget then
		for _, element in pairs(SoftTargetBlockElements) do
			if self:IsElementEnabled(element) then
				self:DisableElement(element)
			end
		end
	else
		for _, element in pairs(SoftTargetBlockElements) do
			if not self:IsElementEnabled(element) then
				self:EnableElement(element)
			end
		end
	end

	if self.plateType == "NameOnly" then
		for _, element in pairs(DisabledElements) do
			if self:IsElementEnabled(element) then
				self:DisableElement(element)
			end
		end

		name:ClearAllPoints()
		name:SetJustifyH("CENTER")
		name:SetPoint("CENTER", self, "BOTTOM")
		hpval:Hide()
		title:Show()

		if questIcon then
			B.UpdatePoint(questIcon, "LEFT", name, "RIGHT", 3, 0)
		end

		if raidTarget then
			B.UpdatePoint(raidTarget, "RIGHT", name, "LEFT", 0, 0)
		end

		if widgetContainer then
			B.UpdatePoint(widgetContainer, "TOP", title, "BOTTOM", 0, 0)
		end
	else
		for _, element in pairs(DisabledElements) do
			if not self:IsElementEnabled(element) then
				self:EnableElement(element)
			end
		end

		name:ClearAllPoints()
		name:SetJustifyH("LEFT")
		name:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, C.db["Nameplate"]["PlateMargin"])
		name:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, C.db["Nameplate"]["PlateMargin"])
		hpval:Show()
		title:Hide()

		if questIcon then
			B.UpdatePoint(questIcon, "LEFT", self, "RIGHT", 3, 0)
		end

		if raidTarget then
			B.UpdatePoint(raidTarget, "BOTTOMLEFT", self, "TOPRIGHT", C.db["Nameplate"]["RaidTargetX"], C.db["Nameplate"]["RaidTargetY"])
		end

		if widgetContainer then
			B.UpdatePoint(widgetContainer, "TOP", self.Castbar, "BOTTOM", 0, -DB.margin)
		end
	end

	UF.UpdateNameplateSize(self)
	UF.UpdateNameplateIndicator(self)
	UF.ToggleNameplateAuras(self)
end

function UF:RefreshPlateType(unit)
	self.reaction = UnitReaction(unit, "player")
	self.isFriendly = self.reaction and self.reaction >= 4 and not UnitCanAttack("player", unit)
	self.isSoftTarget = UnitIsUnit(unit, "softinteract")
	if C.db["Nameplate"]["NameOnlyMode"] and self.isFriendly or self.widgetsOnly or self.isSoftTarget then
		self.plateType = "NameOnly"
	elseif self.isFriendly then
		self.plateType = "FriendPlate"
	else
		self.plateType = "None"
	end

	if self.previousType == nil or self.previousType ~= self.plateType then
		UF.UpdatePlateByType(self)
		self.previousType = self.plateType
	end
end

function UF:OnUnitFactionChanged(unit)
	local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
	local unitFrame = nameplate and nameplate.unitFrame
	if unitFrame and unitFrame.unitName then
		UF.RefreshPlateType(unitFrame, unit)
	end
end

function UF:OnUnitSoftTargetChanged(previousTarget, currentTarget)
	if not GetCVarBool("SoftTargetIconGameObject") then return end

	for _, nameplate in pairs(C_NamePlate.GetNamePlates()) do
		local unitFrame = nameplate and nameplate.unitFrame
		local guid = unitFrame and unitFrame.unitGUID
		if guid and (guid == previousTarget or guid == currentTarget) then
			unitFrame.previousType = nil
			UF.RefreshPlateType(unitFrame, unitFrame.unit)
			UF.UpdateTargetChange(unitFrame)
			UF.UpdateMouseoverChange(unitFrame)
		end
	end
end

local targetedList = {}
function UF:OnUnitTargetChanged()
	if not (isInInstance and isInGroup) then return end

	table.wipe(targetedList)

	local maxMembers = GetNumGroupMembers()
	for index = 1, maxMembers do
		local member = B.GetGroupUnit(index, maxMembers, isInRaid)
		local memberTarget = member.."target"
		if not UnitIsDeadOrGhost(member) and UnitExists(memberTarget) then
			local unitGUID = UnitGUID(memberTarget)
			targetedList[unitGUID] = (targetedList[unitGUID] or 0) + 1
		end
	end

	for nameplate in pairs(platesList) do
		nameplate.targetCount:SetText(targetedList[nameplate.unitGUID])
		nameplate.targetIcon:SetShown(targetedList[nameplate.unitGUID])
	end
end

function UF:RefreshPlateByEvents()
	B:RegisterEvent("PLAYER_SOFT_INTERACT_CHANGED", UF.OnUnitSoftTargetChanged)
	B:RegisterEvent("UNIT_FACTION", UF.OnUnitFactionChanged)
	B:RegisterEvent("UNIT_TARGET", UF.OnUnitTargetChanged)
end

function UF:PostUpdatePlates(event, unit)
	if not self then return end

	if event == "NAME_PLATE_UNIT_ADDED" then
		self.unitName = UnitName(unit)
		self.unitGUID = UnitGUID(unit)
		self.isPlayer = UnitIsPlayer(unit)
		self.npcID = B.GetNPCID(self.unitGUID)
		self.widgetsOnly = UnitNameplateShowsWidgetsOnly(unit)

		local blizzPlate = self:GetParent().UnitFrame
		if blizzPlate then
			self.widgetContainer = blizzPlate.WidgetContainer
			if self.widgetContainer then
				--self.widgetContainer:SetParent(self)
				self.widgetContainer:SetScale(1/NDuiADB["UIScale"])

				if self.widgetContainer.widgetFrames then
					for _, widgetFrame in pairs(self.widgetContainer.widgetFrames) do
						local spell = widgetFrame and widgetFrame.Spell
						if spell then
							if not spell.bg then
								spell.bg = B.ReskinIcon(spell.Icon)
							end
							spell.Border:Hide()
							spell.IconMask:Hide()
						end
					end
				end
			end

			self.softTargetFrame = blizzPlate.SoftTargetFrame
			if self.softTargetFrame then
				--self.softTargetFrame:SetParent(self)
				self.softTargetFrame:SetScale(1/NDuiADB["UIScale"])
			end
		end

		UF.RefreshPlateType(self, unit)
	elseif event == "NAME_PLATE_UNIT_REMOVED" then
		self.npcID = nil
		self.targetCount:SetText("")
		self.targetIcon:Hide()
	end

	if event ~= "NAME_PLATE_UNIT_REMOVED" then
		UF.UpdateUnitPower(self)
		UF.UpdateTargetChange(self)
		UF.UpdateMouseoverChange(self)
		UF.UpdateQuestUnit(self, event, unit)
		UF.UpdateUnitClassify(self, unit)
		UF:UpdateTargetClassPower()

		self.targetName:SetShown(C.ShowTargetNPCs[self.npcID])
	end
end

-- Player Nameplate
function UF:PlateVisibility(event)
	local alpha = C.db["Nameplate"]["PPFadeoutAlpha"]
	if (event == "PLAYER_REGEN_DISABLED" or InCombatLockdown()) and UnitIsUnit("player", self.unit) then
		UIFrameFadeIn(self.Health, .3, self.Health:GetAlpha(), 1)
		UIFrameFadeIn(self.Health.bg, .3, self.Health.bg:GetAlpha(), 1)
		UIFrameFadeIn(self.Power, .3, self.Power:GetAlpha(), 1)
		UIFrameFadeIn(self.Power.bg, .3, self.Power.bg:GetAlpha(), 1)
		UIFrameFadeIn(self.predicFrame, .3, self:GetAlpha(), 1)
	else
		UIFrameFadeOut(self.Health, 2, self.Health:GetAlpha(), alpha)
		UIFrameFadeOut(self.Health.bg, 2, self.Health.bg:GetAlpha(), alpha)
		UIFrameFadeOut(self.Power, 2, self.Power:GetAlpha(), alpha)
		UIFrameFadeOut(self.Power.bg, 2, self.Power.bg:GetAlpha(), alpha)
		UIFrameFadeOut(self.predicFrame, 2, self:GetAlpha(), alpha)
	end
end

function UF:ResizePlayerPlate()
	local plate = _G.oUF_PlayerPlate
	if plate then
		local barWidth = C.db["Nameplate"]["PPWidth"]
		local barHeight = C.db["Nameplate"]["PPBarHeight"]
		local healthHeight = C.db["Nameplate"]["PPHealthHeight"]
		local powerHeight = C.db["Nameplate"]["PPPowerHeight"]

		plate:SetSize(barWidth, healthHeight+powerHeight+C.mult)
		plate.mover:SetSize(barWidth, healthHeight+powerHeight+C.mult)
		plate.Health:SetHeight(healthHeight)
		plate.Power:SetHeight(powerHeight)

		local bars = plate.ClassPower or plate.Runes
		if bars then
			plate.ClassPowerBar:SetSize(barWidth, barHeight)
			local max = bars.__max
			for i = 1, max do
				bars[i]:SetHeight(barHeight)
				bars[i]:SetWidth((barWidth - (max-1)*DB.margin) / max)
			end
		end
		if plate.Stagger then
			plate.Stagger:SetSize(barWidth, barHeight)
		end
		if plate.Avada then
			local iconSize = (barWidth+2*C.mult - 5*DB.margin)/6
			for i = 1, 6 do
				plate.Avada[i]:SetSize(iconSize, iconSize)
			end
		end
		if plate.dices then
			local parent = C.db["Nameplate"]["TargetPower"] and plate.Health or plate.ClassPowerBar
			local size = (barWidth - 10)/6
			for i = 1, 6 do
				local dice = plate.dices[i]
				dice:SetSize(size, size/2)
				if i == 1 then
					dice:SetPoint("BOTTOMLEFT", parent, "TOPLEFT", 0, DB.margin)
				end
			end
		end
	end
end

function UF:CreatePlayerPlate()
	self.mystyle = "playerplate"
	self:EnableMouse(false)
	local healthHeight, powerHeight = C.db["Nameplate"]["PPHealthHeight"], C.db["Nameplate"]["PPPowerHeight"]
	self:SetSize(C.db["Nameplate"]["PPWidth"], healthHeight+powerHeight+C.mult)

	UF:CreateHealthBar(self)
	UF:CreatePowerBar(self)
	UF:CreatePrediction(self)
	UF:CreateClassPower(self)
	UF:StaggerBar(self)
	UF:AvadaKedavra(self)

	self.powerText = B.CreateFS(self.Power, 14)
	self:Tag(self.powerText, "[pppower]")
	UF:TogglePlatePower()

	UF:CreateGCDTicker(self)
	UF:TogglePlateVisibility()
end

function UF:TogglePlayerPlate()
	local plate = _G.oUF_PlayerPlate
	if not plate then return end

	if C.db["Nameplate"]["ShowPlayerPlate"] then
		plate:Enable()
	else
		plate:Disable()
	end
end

function UF:TogglePlatePower()
	local plate = _G.oUF_PlayerPlate
	if not plate then return end

	plate.powerText:SetShown(C.db["Nameplate"]["PPPowerText"])
end

function UF:TogglePlateVisibility()
	local plate = _G.oUF_PlayerPlate
	if not plate then return end

	if C.db["Nameplate"]["PPFadeout"] then
		plate:RegisterEvent("UNIT_EXITED_VEHICLE", UF.PlateVisibility)
		plate:RegisterEvent("UNIT_ENTERED_VEHICLE", UF.PlateVisibility)
		plate:RegisterEvent("PLAYER_REGEN_ENABLED", UF.PlateVisibility, true)
		plate:RegisterEvent("PLAYER_REGEN_DISABLED", UF.PlateVisibility, true)
		plate:RegisterEvent("PLAYER_ENTERING_WORLD", UF.PlateVisibility, true)
		UF.PlateVisibility(plate)
	else
		plate:UnregisterEvent("UNIT_EXITED_VEHICLE", UF.PlateVisibility)
		plate:UnregisterEvent("UNIT_ENTERED_VEHICLE", UF.PlateVisibility)
		plate:UnregisterEvent("PLAYER_REGEN_ENABLED", UF.PlateVisibility)
		plate:UnregisterEvent("PLAYER_REGEN_DISABLED", UF.PlateVisibility)
		plate:UnregisterEvent("PLAYER_ENTERING_WORLD", UF.PlateVisibility)
		UF.PlateVisibility(plate, "PLAYER_REGEN_DISABLED")
	end
end

-- Target nameplate
function UF:CreateTargetPlate()
	self.mystyle = "targetplate"
	self:EnableMouse(false)
	self:SetSize(10, 10)

	UF:CreateClassPower(self)
end

function UF:UpdateTargetClassPower()
	local plate = _G.oUF_TargetPlate
	if not plate then return end

	local bar = plate.ClassPowerBar
	local nameplate = C_NamePlate.GetNamePlateForUnit("target")
	if nameplate then
		bar:SetParent(nameplate.unitFrame)
		bar:ClearAllPoints()
		bar:SetPoint("BOTTOM", nameplate.unitFrame.nameText, "TOP", 0, C.db["Nameplate"]["PlateMargin"])
		bar:Show()
	else
		bar:Hide()
	end
end

function UF:ToggleTargetClassPower()
	local plate = _G.oUF_TargetPlate
	if not plate then return end

	local playerPlate = _G.oUF_PlayerPlate
	if C.db["Nameplate"]["TargetPower"] then
		plate:Enable()
		if plate.ClassPower then
			if not plate:IsElementEnabled("ClassPower") then
				plate:EnableElement("ClassPower")
				plate.ClassPower:ForceUpdate()
			end
			if playerPlate then
				if playerPlate:IsElementEnabled("ClassPower") then
					playerPlate:DisableElement("ClassPower")
				end
			end
		end
		if plate.Runes then
			if not plate:IsElementEnabled("Runes") then
				plate:EnableElement("Runes")
				plate.Runes:ForceUpdate()
			end
			if playerPlate then
				if playerPlate:IsElementEnabled("Runes") then
					playerPlate:DisableElement("Runes")
				end
			end
		end
	else
		plate:Disable()
		if plate.ClassPower then
			if plate:IsElementEnabled("ClassPower") then
				plate:DisableElement("ClassPower")
			end
			if playerPlate then
				if not playerPlate:IsElementEnabled("ClassPower") then
					playerPlate:EnableElement("ClassPower")
					playerPlate.ClassPower:ForceUpdate()
				end
			end
		end
		if plate.Runes then
			if plate:IsElementEnabled("Runes") then
				plate:DisableElement("Runes")
			end
			if playerPlate then
				if not playerPlate:IsElementEnabled("Runes") then
					playerPlate:EnableElement("Runes")
					playerPlate.Runes:ForceUpdate()
				end
			end
		end
	end
end

function UF:ResizeTargetPower()
	local plate = _G.oUF_TargetPlate
	if not plate then return end

	local barWidth = C.db["Nameplate"]["PlateWidth"]
	local barHeight = C.db["Nameplate"]["PPBarHeight"]
	local bars = plate.ClassPower or plate.Runes
	if bars then
		plate.ClassPowerBar:SetSize(barWidth, barHeight)
		local max = bars.__max
		for i = 1, max do
			bars[i]:SetHeight(barHeight)
			bars[i]:SetWidth((barWidth - (max-1)*DB.margin) / max)
		end
	end
end

function UF:UpdateGCDTicker()
	local cooldownInfo = C_Spell.GetSpellCooldown(61304)
	local start = cooldownInfo and cooldownInfo.startTime
	local duration = cooldownInfo and cooldownInfo.duration

	if start > 0 and duration > 0 then
		if self.duration ~= duration then
			self:SetMinMaxValues(0, duration)
			self.duration = duration
		end
		self:SetValue(GetTime() - start)
		self.spark:Show()
	else
		self.spark:Hide()
	end
end

function UF:CreateGCDTicker(self)
	local ticker = CreateFrame("StatusBar", nil, self.Power)
	ticker:SetStatusBarTexture(0)
	ticker:SetAllPoints()

	local spark = ticker:CreateTexture(nil, "OVERLAY")
	spark:SetTexture(DB.sparkTex)
	spark:SetBlendMode("ADD")
	spark:SetPoint("TOPLEFT", ticker:GetStatusBarTexture(), "TOPRIGHT", -10, 10)
	spark:SetPoint("BOTTOMRIGHT", ticker:GetStatusBarTexture(), "BOTTOMRIGHT", 10, -10)
	ticker.spark = spark

	ticker:SetScript("OnUpdate", UF.UpdateGCDTicker)
	self.GCDTicker = ticker

	UF:ToggleGCDTicker()
end

function UF:ToggleGCDTicker()
	local plate = _G.oUF_PlayerPlate
	local ticker = plate and plate.GCDTicker
	if not ticker then return end

	ticker:SetShown(C.db["Nameplate"]["PPGCDTicker"])
end

UF.MajorSpells = {}
function UF:RefreshMajorSpells()
	table.wipe(UF.MajorSpells)

	for spellID in pairs(C.MajorSpells) do
		local name = C_Spell.GetSpellName(spellID)
		if name then
			local modValue = NDuiADB["MajorSpells"][spellID]
			if modValue == nil then
				UF.MajorSpells[spellID] = true
			end
		end
	end

	for spellID, value in pairs(NDuiADB["MajorSpells"]) do
		if value then
			UF.MajorSpells[spellID] = true
		end
	end
end

UF.NameplateWhite = {}
UF.NameplateBlack = {}

local function RefreshNameplateFilter(list, key)
	table.wipe(UF[key])

	for spellID in pairs(list) do
		local name = C_Spell.GetSpellName(spellID)
		if name then
			if NDuiADB[key][spellID] == nil then
				UF[key][spellID] = true
			end
		end
	end

	for spellID, value in pairs(NDuiADB[key]) do
		if value then
			UF[key][spellID] = true
		end
	end
end

function UF:RefreshNameplateFilters()
	RefreshNameplateFilter(C.WhiteList, "NameplateWhite")
	RefreshNameplateFilter(C.BlackList, "NameplateBlack")
end