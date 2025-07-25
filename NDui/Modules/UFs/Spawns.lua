local _, ns = ...
local B, C, L, DB = unpack(ns)
local oUF = ns.oUF
local UF = B:GetModule("UnitFrames")

-- Units
local UFRangeAlpha = {insideAlpha = 1, outsideAlpha = .4}

local function SetUnitFrameSize(self, unit)
	local width = C.db["UFs"][unit.."Width"]
	local healthHeight = C.db["UFs"][unit.."Height"]
	local powerHeight = C.db["UFs"][unit.."PowerHeight"]
	local height = healthHeight + powerHeight + C.mult
	self:SetSize(width, height)
end

local function CreateMainStyle(self)
	UF:CreateHeader(self)
	UF:CreateHealthBar(self)
	UF:CreateHealthText(self)
	UF:CreatePowerBar(self)
	UF:CreatePowerText(self)
	UF:CreatePortrait(self)
	UF:CreateCastBar(self)
	UF:CreatePrediction(self)
	UF:CreateRaidMark(self)
end

local function CreateSubStyle(self)
	UF:CreateHeader(self)
	UF:CreateHealthBar(self)
	UF:CreateHealthText(self)
	UF:CreatePowerBar(self)
	UF:CreateRaidMark(self)
end

local function CreatePlayerStyle(self)
	self.mystyle = "player"
	SetUnitFrameSize(self, "Player")

	CreateMainStyle(self)

	UF:CreateIcons(self)
	UF:CreateRestingIndicator(self)
	UF:CreateFCT(self)
	UF:CreateAddPower(self)
	UF:CreateQuestSync(self)
	UF:CreateClassPower(self)
	UF:StaggerBar(self)
	UF:CreateAuras(self)
	UF:CreateSwing(self)

	if C.db["UFs"]["Castbars"] then
		UF:ReskinMirrorBars()
		UF:ReskinTimerTrakcer(self)
	end
	if C.db["Map"]["DisableMinimap"] or not C.db["Misc"]["ExpRep"] then
		UF:CreateExpRepBar(self)
	end
end

local function CreateTargetStyle(self)
	self.mystyle = "target"
	SetUnitFrameSize(self, "Player")

	CreateMainStyle(self)

	UF:CreateIcons(self)
	UF:CreateFCT(self)
	UF:CreateAuras(self)
end

local function CreateFocusStyle(self)
	self.mystyle = "focus"
	SetUnitFrameSize(self, "Focus")

	CreateMainStyle(self)

	UF:CreateAuras(self)
end

local function CreateToTStyle(self)
	self.mystyle = "tot"
	SetUnitFrameSize(self, "Pet")

	CreateSubStyle(self)

	UF:CreateAuras(self)
end

local function CreateFoTStyle(self)
	self.mystyle = "fot"
	SetUnitFrameSize(self, "Pet")

	CreateSubStyle(self)
end

local function CreatePetStyle(self)
	self.mystyle = "pet"
	SetUnitFrameSize(self, "Pet")

	CreateSubStyle(self)

	UF:CreateAuras(self)
	UF:CreateSparkleCastBar(self)
end

local function CreateBossStyle(self)
	self.mystyle = "boss"
	self.EnemyRange = UFRangeAlpha
	SetUnitFrameSize(self, "Boss")

	CreateMainStyle(self)

	UF:CreateAltPower(self)
	UF:CreateBuffs(self)
	UF:CreateDebuffs(self)
	UF:CreateClickSets(self)
	UF:CreatePrivateAuras(self)
end

local function CreateArenaStyle(self)
	self.mystyle = "arena"
	SetUnitFrameSize(self, "Boss")

	CreateMainStyle(self)

	UF:CreateBuffs(self)
	UF:CreateDebuffs(self)
	UF:CreatePVPClassify(self)
end

local function CreateRaidStyle(self)
	self.mystyle = "raid"
	self.Range = UFRangeAlpha
	self.disableTooltip = C.db["UFs"]["HideTip"]

	UF:CreateHeader(self)
	UF:CreateHealthBar(self)
	UF:CreateHealthText(self)
	UF:CreatePowerBar(self)
	UF:CreateRaidMark(self)
	UF:CreateIcons(self)
	UF:CreateTargetBorder(self)
	UF:CreateRaidIcons(self)
	UF:CreatePrediction(self)
	UF:CreateClickSets(self)
	UF:CreateThreatBorder(self)
	UF:CreatePrivateAuras(self)

	if self.raidType ~= "simple" then
		UF:CreateRaidAuras(self)
	end
end

local function CreateSimpleRaidStyle(self)
	self.raidType = "simple"

	CreateRaidStyle(self)
end

local function CreatePartyStyle(self)
	self.raidType = "party"

	CreateRaidStyle(self)

	UF:CreatePartyAltPower(self)
end

local function CreatePartyPetStyle(self)
	self.mystyle = "raid"
	self.raidType = "pet"
	self.Range = UFRangeAlpha
	self.disableTooltip = C.db["UFs"]["HideTip"]

	UF:CreateHeader(self)
	UF:CreateHealthBar(self)
	UF:CreateHealthText(self)
	UF:CreatePowerBar(self)
	UF:CreateRaidMark(self)
	UF:CreateTargetBorder(self)
	UF:CreatePrediction(self)
	UF:CreateClickSets(self)
	UF:CreateThreatBorder(self)
end

-- Spawns
local function GetPartyVisibility()
	local visibility = "[group:party,nogroup:raid] show;hide"
	if C.db["UFs"]["SmartRaid"] then
		visibility = "[@raid6,noexists,group] show;hide"
	end
	if C.db["UFs"]["ShowSolo"] then
		visibility = "[nogroup] show;"..visibility
	end
	return visibility
end

local function GetRaidVisibility()
	local visibility
	if C.db["UFs"]["PartyFrame"] then
		if C.db["UFs"]["SmartRaid"] then
			visibility = "[@raid6,exists] show;hide"
		else
			visibility = "[group:raid] show;hide"
		end
	else
		if C.db["UFs"]["ShowSolo"] then
			visibility = "show"
		else
			visibility = "[group] show;hide"
		end
	end
	return visibility
end

local function GetPartyPetVisibility()
	local visibility
	if C.db["UFs"]["PartyPetVsby"] == 1 then
		if C.db["UFs"]["SmartRaid"] then
			visibility = "[@raid6,noexists,group] show;hide"
		else
			visibility = "[group:party,nogroup:raid] show;hide"
		end
	elseif C.db["UFs"]["PartyPetVsby"] == 2 then
		if C.db["UFs"]["SmartRaid"] then
			visibility = "[@raid6,exists] show;hide"
		else
			visibility = "[group:raid] show;hide"
		end
	elseif C.db["UFs"]["PartyPetVsby"] == 3 then
		visibility = "[group] show;hide"
	end
	if C.db["UFs"]["ShowSolo"] then
		visibility = "[nogroup] show;"..visibility
	end
	return visibility
end

function UF:UpdateAllHeaders()
	if not UF.headers then return end

	for _, header in pairs(UF.headers) do
		if header.groupType == "party" then
			RegisterStateDriver(header, "visibility", GetPartyVisibility())
		elseif header.groupType == "pet" then
			RegisterStateDriver(header, "visibility", GetPartyPetVisibility())
		elseif header.groupType == "raid" then
			if header.__disabled then
				RegisterStateDriver(header, "visibility", "hide")
			else
				RegisterStateDriver(header, "visibility", GetRaidVisibility())
			end
		end
	end
end

local function GetGroupFilterByIndex(numGroups)
	local groupFilter
	for i = 1, numGroups do
		if not groupFilter then
			groupFilter = i
		else
			groupFilter = groupFilter..","..i
		end
	end
	return groupFilter
end

local function ResetHeaderPoints(header)
	for i = 1, header:GetNumChildren() do
		select(i, header:GetChildren()):ClearAllPoints()
	end
end

UF.PartyDirections = {
	[1] = {name = L["GO_DOWN"], point = "TOP", xOffset = 0, yOffset = -5, initAnchor = "TOPLEFT"},
	[2] = {name = L["GO_UP"], point = "BOTTOM", xOffset = 0, yOffset = 5, initAnchor = "BOTTOMLEFT"},
	[3] = {name = L["GO_RIGHT"], point = "LEFT", xOffset = 5, yOffset = 0, initAnchor = "TOPLEFT"},
	[4] = {name = L["GO_LEFT"], point = "RIGHT", xOffset = -5, yOffset = 0, initAnchor = "TOPRIGHT"},
}

UF.RaidDirections = {
	[1] = {name = L["DOWN_RIGHT"], point = "TOP", xOffset = 0, yOffset = -5, initAnchor = "TOPLEFT", relAnchor = "TOPRIGHT", x = 5, y = 0, columnAnchorPoint = "LEFT", multX = 1, multY = -1},
	[2] = {name = L["DOWN_LEFT"], point = "TOP", xOffset = 0, yOffset = -5, initAnchor = "TOPRIGHT", relAnchor = "TOPLEFT", x = -5, y = 0, columnAnchorPoint = "RIGHT", multX = -1, multY = -1},
	[3] = {name = L["UP_RIGHT"], point = "BOTTOM", xOffset = 0, yOffset = 5, initAnchor = "BOTTOMLEFT", relAnchor = "BOTTOMRIGHT", x = 5, y = 0, columnAnchorPoint = "LEFT", multX = 1, multY = 1},
	[4] = {name = L["UP_LEFT"], point = "BOTTOM", xOffset = 0, yOffset = 5, initAnchor = "BOTTOMRIGHT", relAnchor = "BOTTOMLEFT", x = -5, y = 0, columnAnchorPoint = "RIGHT", multX = -1, multY = 1},
	[5] = {name = L["RIGHT_DOWN"], point = "LEFT", xOffset = 5, yOffset = 0, initAnchor = "TOPLEFT", relAnchor = "BOTTOMLEFT", x = 0, y = -5, columnAnchorPoint = "TOP", multX = 1, multY = -1},
	[6] = {name = L["RIGHT_UP"], point = "LEFT", xOffset = 5, yOffset = 0, initAnchor = "BOTTOMLEFT", relAnchor = "TOPLEFT", x = 0, y = 5, columnAnchorPoint = "BOTTOM", multX = 1, multY = 1},
	[7] = {name = L["LEFT_DOWN"], point = "RIGHT", xOffset = -5, yOffset = 0, initAnchor = "TOPRIGHT", relAnchor = "BOTTOMRIGHT", x = 0, y = -5, columnAnchorPoint = "TOP", multX = -1, multY = -1},
	[8] = {name = L["LEFT_UP"], point = "RIGHT", xOffset = -5, yOffset = 0, initAnchor = "BOTTOMRIGHT", relAnchor = "TOPRIGHT", x = 0, y = 5, columnAnchorPoint = "BOTTOM", multX = -1, multY = 1},
}

function UF:OnLogin()
	if C.db["Nameplate"]["Enable"] then
		UF:SetupCVars()
		UF:BlockAddons()
		UF:CreateUnitTable()
		UF:CreatePowerUnitTable()
		UF:UpdateGroupRoles()
		UF:QuestIconCheck()
		UF:RefreshPlateByEvents()
		UF:RefreshMajorSpells()
		UF:RefreshNameplateFilters()

		oUF:RegisterStyle("Nameplates", UF.CreatePlates)
		oUF:SetActiveStyle("Nameplates")
		oUF:SpawnNamePlates("oUF_NPs", UF.PostUpdatePlates)
	end

	do -- a playerplate-like PlayerFrame
		oUF:RegisterStyle("PlayerPlate", UF.CreatePlayerPlate)
		oUF:SetActiveStyle("PlayerPlate")
		local plate = oUF:Spawn("player", "oUF_PlayerPlate", true)
		plate.mover = B.Mover(plate, L["PlayerPlate"], "PlayerPlate", C.UFs.PlayerPlate)
		UF:TogglePlayerPlate()
	end

	do	-- fake nameplate for target class power
		oUF:RegisterStyle("TargetPlate", UF.CreateTargetPlate)
		oUF:SetActiveStyle("TargetPlate")
		oUF:Spawn("player", "oUF_TargetPlate", true)
		UF:ToggleTargetClassPower()
	end

	-- Default Clicksets for RaidFrame
	UF:DefaultClickSets()

	if C.db["UFs"]["Enable"] then
		-- Register
		oUF:RegisterStyle("Player", CreatePlayerStyle)
		oUF:RegisterStyle("Target", CreateTargetStyle)
		oUF:RegisterStyle("ToT", CreateToTStyle)
		oUF:RegisterStyle("Focus", CreateFocusStyle)
		oUF:RegisterStyle("FoT", CreateFoTStyle)
		oUF:RegisterStyle("Pet", CreatePetStyle)

		-- Loader
		oUF:SetActiveStyle("Player")
		local player = oUF:Spawn("player", "oUF_Player")
		B.Mover(player, L["PlayerUF"], "PlayerUF", C.UFs.PlayerPos)
		UF.ToggleCastBar(player, "Player")

		oUF:SetActiveStyle("Pet")
		local pet = oUF:Spawn("pet", "oUF_Pet")
		B.Mover(pet, L["PetUF"], "PetUF", {"BOTTOMLEFT", oUF_Player, "BOTTOMRIGHT", 5, 0})

		oUF:SetActiveStyle("Target")
		local target = oUF:Spawn("target", "oUF_Target")
		B.Mover(target, L["TargetUF"], "TargetUF", C.UFs.TargetPos)
		UF.ToggleCastBar(target, "Target")

		oUF:SetActiveStyle("ToT")
		local targettarget = oUF:Spawn("targettarget", "oUF_ToT")
		B.Mover(targettarget, L["TotUF"], "TotUF", {"BOTTOMRIGHT", oUF_Target, "BOTTOMLEFT", -5, 0})

		oUF:SetActiveStyle("Focus")
		local focus = oUF:Spawn("focus", "oUF_Focus")
		B.Mover(focus, L["FocusUF"], "FocusUF", C.UFs.FocusPos)
		UF.ToggleCastBar(focus, "Focus")

		oUF:SetActiveStyle("FoT")
		local focustarget = oUF:Spawn("focustarget", "oUF_FoT")
		B.Mover(focustarget, L["FotUF"], "FotUF", {"BOTTOMLEFT", oUF_Focus, "BOTTOMRIGHT", 5, 0})

		oUF:RegisterStyle("Boss", CreateBossStyle)
		oUF:SetActiveStyle("Boss")
		local boss = {}
		for i = 1, 10 do -- MAX_BOSS_FRAMES, 10 in 11.0?
			boss[i] = oUF:Spawn("boss"..i, "oUF_Boss"..i)
			local moverWidth, moverHeight = boss[i]:GetWidth(), boss[i]:GetHeight()+8
			local title = i > 5 and "Boss"..i or L["BossFrame"]..i
			if i == 1 then
				boss[i].mover = B.Mover(boss[i], title, "Boss1", {"RIGHT", UIParent, "RIGHT", -50, -150}, moverWidth, moverHeight)
			elseif i == 6 then
				boss[i].mover = B.Mover(boss[i], title, "Boss"..i, {"BOTTOMRIGHT", boss[1].mover, "BOTTOMLEFT", -50, 0}, moverWidth, moverHeight)
			else
				boss[i].mover = B.Mover(boss[i], title, "Boss"..i, {"BOTTOMLEFT", boss[i-1], "TOPLEFT", 0, 50}, moverWidth, moverHeight)
			end
		end

		if C.db["UFs"]["Arena"] then
			oUF:RegisterStyle("Arena", CreateArenaStyle)
			oUF:SetActiveStyle("Arena")
			local arena = {}
			for i = 1, 5 do
				arena[i] = oUF:Spawn("arena"..i, "oUF_Arena"..i)
				arena[i]:SetPoint("TOPLEFT", boss[i].mover)
			end
		end

		UF:ToggleAddPower()
		UF:ToggleSwingBars()
		UF:ToggleUFClassPower()
		UF:UpdateTextScale()
		UF:ToggleAllAuras()
		UF:UpdateScrollingFont()
		UF:TogglePortraits()
		UF:CheckPowerBars()
		UF:UpdateRaidInfo() -- RaidAuras
	end

	if C.db["UFs"]["RaidFrame"] then
		B:LockCVar("predictedHealth", "1")
		UF:AddClickSetsListener()
		UF:UpdateCornerSpells()
		UF:UpdateRaidBuffsWhite()
		UF:UpdateRaidDebuffsBlack()
		UF.headers = {}

		-- Hide Default RaidFrame
		if CompactPartyFrame then
			CompactPartyFrame:UnregisterAllEvents()
		end
		if CompactRaidFrameManager_SetSetting then
			CompactRaidFrameManager_SetSetting("IsShown", "0")
			UIParent:UnregisterEvent("GROUP_ROSTER_UPDATE")
			CompactRaidFrameManager:UnregisterAllEvents()
			CompactRaidFrameManager:SetParent(B.HiddenFrame)
		end

		-- Group Styles
		local partyMover
		if C.db["UFs"]["PartyFrame"] then
			local party
			oUF:RegisterStyle("Party", CreatePartyStyle)
			oUF:SetActiveStyle("Party")

			local function CreatePartyHeader(name, width, height)
				local group = oUF:SpawnHeader(name, nil, nil,
				"showPlayer", true,
				"showSolo", true,
				"showParty", true,
				"showRaid", true,
				"sortMethod", "INDEX",
				"columnAnchorPoint", "LEFT",
				"oUF-initialConfigFunction", ([[
					self:SetWidth(%d)
					self:SetHeight(%d)
				]]):format(width, height))
				return group
			end

			function UF:CreateAndUpdatePartyHeader()
				local index = C.db["UFs"]["PartyDirec"]
				local sortData = UF.PartyDirections[index]
				local partyWidth, partyHeight = C.db["UFs"]["PartyWidth"], C.db["UFs"]["PartyHeight"]
				local partyFrameHeight = partyHeight + C.db["UFs"]["PartyPowerHeight"] + C.mult
				local spacing = C.db["UFs"]["PartySpacing"]
				local sortByRole = C.db["UFs"]["SortByRole"]
				local sortAscending = C.db["UFs"]["SortAscending"]

				if not party then
					party = CreatePartyHeader("oUF_Party", partyWidth, partyFrameHeight)
					party.groupType = "party"
					table.insert(UF.headers, party)
					RegisterStateDriver(party, "visibility", GetPartyVisibility())
					partyMover = B.Mover(party, L["PartyFrame"], "PartyFrame", {"LEFT", UIParent, 35, 135})
				end

				local moverWidth = index < 3 and partyWidth or (partyWidth+spacing)*5-spacing
				local moverHeight = index < 3 and (partyFrameHeight+spacing)*5-spacing or partyFrameHeight
				partyMover:SetSize(moverWidth, moverHeight)
				party:ClearAllPoints()
				party:SetPoint(sortData.initAnchor, partyMover)

				ResetHeaderPoints(party)
				party:SetAttribute("point", sortData.point)
				party:SetAttribute("xOffset", sortData.xOffset/5*spacing)
				party:SetAttribute("yOffset", sortData.yOffset/5*spacing)
				party:SetAttribute("groupingOrder", "TANK,HEALER,DAMAGER,NONE")
				party:SetAttribute("groupBy", sortByRole and "ASSIGNEDROLE")
				party:SetAttribute("sortDir", sortAscending and "ASC" or "DESC")
			end

			UF:CreateAndUpdatePartyHeader()

			if C.db["UFs"]["PartyPetFrame"] then
				local partyPet, petMover
				oUF:RegisterStyle("PartyPet", CreatePartyPetStyle)
				oUF:SetActiveStyle("PartyPet")

				local function CreatePetGroup(name, width, height)
					local group = oUF:SpawnHeader(name, "SecureGroupPetHeaderTemplate", nil,
					"showPlayer", true,
					"showSolo", true,
					"showParty", true,
					"showRaid", true,
					"columnSpacing", 5,
					"oUF-initialConfigFunction", ([[
						self:SetWidth(%d)
						self:SetHeight(%d)
					]]):format(width, height))
					return group
				end

				function UF:UpdatePartyPetHeader()
					local petWidth, petHeight, petPowerHeight = C.db["UFs"]["PartyPetWidth"], C.db["UFs"]["PartyPetHeight"], C.db["UFs"]["PartyPetPowerHeight"]
					local petFrameHeight = petHeight + petPowerHeight + C.mult
					local petsPerColumn = C.db["UFs"]["PartyPetPerCol"]
					local maxColumns = C.db["UFs"]["PartyPetMaxCol"]
					local index = C.db["UFs"]["PetDirec"]
					local sortData = UF.RaidDirections[index]

					if not partyPet then
						partyPet = CreatePetGroup("oUF_PartyPet", petWidth, petFrameHeight)
						partyPet.groupType = "pet"
						table.insert(UF.headers, partyPet)
						RegisterStateDriver(partyPet, "visibility", GetPartyPetVisibility())
						petMover = B.Mover(partyPet, L["PartyPetFrame"], "PartyPet", {"TOPLEFT", partyMover, "BOTTOMLEFT", 0, -5})
					end
					ResetHeaderPoints(partyPet)

					partyPet:SetAttribute("point", sortData.point)
					partyPet:SetAttribute("xOffset", sortData.xOffset)
					partyPet:SetAttribute("yOffset", sortData.yOffset)
					partyPet:SetAttribute("columnAnchorPoint", sortData.columnAnchorPoint)
					partyPet:SetAttribute("unitsPerColumn", petsPerColumn)
					partyPet:SetAttribute("maxColumns", maxColumns)

					local moverWidth = (petWidth+5)*maxColumns - 5
					local moverHeight = (petFrameHeight+5)*petsPerColumn - 5
					if index > 4 then
						moverWidth = (petWidth+5)*petsPerColumn - 5
						moverHeight = (petFrameHeight+5)*maxColumns - 5
					end
					petMover:SetSize(moverWidth, moverHeight)
					partyPet:ClearAllPoints()
					partyPet:SetPoint(sortData.initAnchor, petMover)
				end

				UF:UpdatePartyPetHeader()
			end
		end

		local raidMover
		if C.db["UFs"]["SimpleMode"] then
			oUF:RegisterStyle("Raid", CreateSimpleRaidStyle)
			oUF:SetActiveStyle("Raid")

			local scale = C.db["UFs"]["SMRScale"]/10
			local sortData = UF.RaidDirections[C.db["UFs"]["SMRDirec"]]

			local function CreateGroup(name)
				local group = oUF:SpawnHeader(name, nil, nil,
				"showPlayer", true,
				"showSolo", true,
				"showParty", true,
				"showRaid", true,
				"point", sortData.point,
				"xOffset", sortData.xOffset,
				"yOffset", sortData.yOffset,
				"columnSpacing", 5,
				"columnAnchorPoint", sortData.columnAnchorPoint,
				"oUF-initialConfigFunction", ([[
					self:SetWidth(%d)
					self:SetHeight(%d)
				]]):format(100*scale, 20*scale))
				return group
			end

			local group = CreateGroup("oUF_Raid")
			group.groupType = "raid"
			table.insert(UF.headers, group)
			RegisterStateDriver(group, "visibility", GetRaidVisibility())
			raidMover = B.Mover(group, L["RaidFrame"], "RaidFrame", {"TOPLEFT", UIParent, 35, -50})
			group:ClearAllPoints()
			group:SetPoint(sortData.initAnchor, raidMover)

			local groupByTypes = {
				[1] = {"1,2,3,4,5,6,7,8", "GROUP", "INDEX"},
				[2] = {"DEATHKNIGHT,WARRIOR,DEMONHUNTER,ROGUE,MONK,PALADIN,DRUID,SHAMAN,HUNTER,EVOKER,PRIEST,MAGE,WARLOCK", "CLASS", "NAME"},
				[3] = {"TANK,HEALER,DAMAGER,NONE", "ASSIGNEDROLE", "NAME"},
			}
			function UF:UpdateSimpleModeHeader()
				ResetHeaderPoints(group)

				local groupByIndex = C.db["UFs"]["SMRGroupBy"]
				local unitsPerColumn = C.db["UFs"]["SMRPerCol"]
				local numGroups = C.db["UFs"]["SMRGroups"]
				local scale = C.db["UFs"]["SMRScale"]/10
				local maxColumns = math.ceil(numGroups*5 / unitsPerColumn)

				group:SetAttribute("groupingOrder", groupByTypes[groupByIndex][1])
				group:SetAttribute("groupBy", groupByTypes[groupByIndex][2])
				group:SetAttribute("sortMethod", groupByTypes[groupByIndex][3])
				group:SetAttribute("groupFilter", GetGroupFilterByIndex(numGroups))
				group:SetAttribute("unitsPerColumn", unitsPerColumn)
				group:SetAttribute("maxColumns", maxColumns)

				local moverWidth = (100*scale*maxColumns + 5*(maxColumns-1))
				local moverHeight = 20*scale*unitsPerColumn + 5*(unitsPerColumn-1)
				raidMover:SetSize(moverWidth, moverHeight)
			end

			UF:UpdateSimpleModeHeader()
		else
			oUF:RegisterStyle("Raid", CreateRaidStyle)
			oUF:SetActiveStyle("Raid")

			local function CreateGroup(name, i, width, height)
				local group = oUF:SpawnHeader(name, nil, nil,
				"showPlayer", true,
				"showSolo", true,
				"showParty", true,
				"showRaid", true,
				"groupFilter", tostring(i),
				"groupingOrder", "1,2,3,4,5,6,7,8",
				"groupBy", "GROUP",
				"sortMethod", "INDEX",
				"maxColumns", 1,
				"unitsPerColumn", 5,
				"columnSpacing", 5,
				"columnAnchorPoint", "LEFT",
				"oUF-initialConfigFunction", ([[
					self:SetWidth(%d)
					self:SetHeight(%d)
				]]):format(width, height))
				return group
			end

			local teamIndexes = {}
			local teamIndexAnchor = {
				[1] = {"BOTTOM", "TOP", 0, 5},
				[2] = {"BOTTOM", "TOP", 0, 5},
				[3] = {"TOP", "BOTTOM", 0, -5},
				[4] = {"TOP", "BOTTOM", 0, -5},
				[5] = {"RIGHT", "LEFT", -5, 0},
				[6] = {"RIGHT", "LEFT", -5, 0},
				[7] = {"LEFT", "RIGHT", 5, 0},
				[8] = {"LEFT", "RIGHT", 5, 0},
			}

			local function UpdateTeamIndex(teamIndex, showIndex, direc)
				if not showIndex then
					teamIndex:Hide()
				else
					teamIndex:Show()
					teamIndex:ClearAllPoints()
					local anchor = teamIndexAnchor[direc]
					teamIndex:SetPoint(anchor[1], teamIndex.__owner, anchor[2], anchor[3], anchor[4])
				end
			end

			local function CreateTeamIndex(header)
				local showIndex = C.db["UFs"]["TeamIndex"]
				local direc = C.db["UFs"]["RaidDirec"]
				local parent = _G[header:GetName().."UnitButton1"]
				if parent and not parent.teamIndex then
					local teamIndex = B.CreateFS(parent, 14, header.index, "info")
					teamIndex.__owner = parent
					UpdateTeamIndex(teamIndex, showIndex, direc)
					teamIndexes[header.index] = teamIndex

					parent.teamIndex = teamIndex
				end
			end

			function UF:UpdateRaidTeamIndex()
				local showIndex = C.db["UFs"]["TeamIndex"]
				local direc = C.db["UFs"]["RaidDirec"]
				for _, teamIndex in pairs(teamIndexes) do
					UpdateTeamIndex(teamIndex, showIndex, direc)
				end
			end

			local groups = {}

			function UF:CreateAndUpdateRaidHeader(direction)
				local index = C.db["UFs"]["RaidDirec"]
				local rows = C.db["UFs"]["RaidRows"]
				local numGroups = C.db["UFs"]["NumGroups"]
				local raidWidth, raidHeight = C.db["UFs"]["RaidWidth"], C.db["UFs"]["RaidHeight"]
				local raidFrameHeight = raidHeight + C.db["UFs"]["RaidPowerHeight"] + C.mult
				local indexSpacing = C.db["UFs"]["TeamIndex"] and 20 or 0
				local spacing = C.db["UFs"]["RaidSpacing"]

				local sortData = UF.RaidDirections[index]
				for i = 1, numGroups do
					local group = groups[i]
					if not group then
						group = CreateGroup("oUF_Raid"..i, i, raidWidth, raidFrameHeight)
						group.index = i
						group.groupType = "raid"
						table.insert(UF.headers, group)
						RegisterStateDriver(group, "visibility", "show")
						RegisterStateDriver(group, "visibility", GetRaidVisibility())
						CreateTeamIndex(group)

						groups[i] = group
					end

					if not raidMover and i == 1 then
						raidMover = B.Mover(groups[i], L["RaidFrame"], "RaidFrame", {"TOPLEFT", UIParent, 35, -50})
					end

					local groupWidth = index < 5 and raidWidth+spacing or (raidWidth+spacing)*5
					local groupHeight = index < 5 and (raidFrameHeight+spacing)*5 or raidFrameHeight+spacing
					local numX = math.ceil(numGroups/rows)
					local numY = math.min(rows, numGroups)
					local indexSpacings = indexSpacing*(numY-1)
					if index < 5 then
						raidMover:SetSize(groupWidth*numX - spacing, groupHeight*numY - spacing + indexSpacings)
					else
						raidMover:SetSize(groupWidth*numY - spacing + indexSpacings, groupHeight*numX - spacing)
					end

					--if direction then
						ResetHeaderPoints(group)
						group:SetAttribute("point", sortData.point)
						group:SetAttribute("xOffset", sortData.xOffset/5*spacing)
						group:SetAttribute("yOffset", sortData.yOffset/5*spacing)
					--end

					group:ClearAllPoints()
					if i == 1 then
						group:SetPoint(sortData.initAnchor, raidMover)
					elseif (i-1) % rows == 0 then
						group:SetPoint(sortData.initAnchor, groups[i-rows], sortData.relAnchor, sortData.x/5*spacing, sortData.y/5*spacing)
					else
						local x = math.floor((i-1)/rows)
						local y = (i-1)%rows
						if index < 5 then
							group:SetPoint(sortData.initAnchor, raidMover, sortData.initAnchor, sortData.multX*groupWidth*x, sortData.multY*(groupHeight+indexSpacing)*y)
						else
							group:SetPoint(sortData.initAnchor, raidMover, sortData.initAnchor, sortData.multX*(groupWidth+indexSpacing)*y, sortData.multY*groupHeight*x)
						end
					end
				end

				for i = 1, 8 do
					local group = groups[i]
					if group then
						group.__disabled = i > C.db["UFs"]["NumGroups"]
					end
				end
			end

			UF:CreateAndUpdateRaidHeader(true)
			UF:UpdateRaidTeamIndex()
		end

		if C.db["UFs"]["SpecRaidPos"] then
			local function UpdateSpecPos(event, ...)
				local unit, _, spellID = ...
				if (event == "UNIT_SPELLCAST_SUCCEEDED" and unit == "player" and spellID == 200749) or event == "ON_LOGIN" then
					local specIndex = GetSpecialization()
					if not specIndex then return end

					if not C.db["Mover"]["RaidPos"..specIndex] then
						C.db["Mover"]["RaidPos"..specIndex] = {"TOPLEFT", "UIParent", "TOPLEFT", 35, -50}
					end
					if raidMover then
						raidMover:ClearAllPoints()
						raidMover:SetPoint(unpack(C.db["Mover"]["RaidPos"..specIndex]))
					end

					if not C.db["Mover"]["PartyPos"..specIndex] then
						C.db["Mover"]["PartyPos"..specIndex] = {"LEFT", "UIParent", "LEFT", 350, 0}
					end
					if partyMover then
						partyMover:ClearAllPoints()
						partyMover:SetPoint(unpack(C.db["Mover"]["PartyPos"..specIndex]))
					end
				end
			end
			UpdateSpecPos("ON_LOGIN")
			B:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", UpdateSpecPos)

			if raidMover then
				local function updateRaidMover()
					local specIndex = GetSpecialization()
					if not specIndex then return end
					C.db["Mover"]["RaidPos"..specIndex] = C.db["Mover"]["RaidFrame"]
				end
				raidMover:HookScript("OnDragStop", updateRaidMover)
				raidMover:HookScript("OnHide", updateRaidMover)
			end
			if partyMover then
				local function updatePartyMover()
					local specIndex = GetSpecialization()
					if not specIndex then return end
					C.db["Mover"]["PartyPos"..specIndex] = C.db["Mover"]["PartyFrame"]
				end
				partyMover:HookScript("OnDragStop", updatePartyMover)
				partyMover:HookScript("OnHide", updatePartyMover)
			end
		end
	end
end