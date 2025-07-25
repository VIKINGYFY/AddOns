local _, ns = ...
local B, C, L, DB = unpack(ns)
local G = B:RegisterModule("GUI")

local cr, cg, cb = DB.r, DB.g, DB.b
local guiTab, guiPage, f = {}, {}

-- Default Settings
G.DefaultSettings = {
	Reset = false,
	Mover = {},
	InternalCD = {},
	AuraWatchMover = {},
	TempAnchor = {},
	AuraWatchList = {
		Switcher = {},
		IgnoreSpells = {},
	},
	Actionbar = {
		Enable = true,
		Hotkeys = true,
		Macro = true,
		Grid = true,
		Cooldown = true,
		MmssTH = 120,
		TenthTH = 5,
		BindType = 1,
		OverrideWA = false,
		MicroMenu = true,
		ShowStance = true,
		SendActionCD = true,
		KeyDown = true,
		ButtonLock = true,

		Bar1 = true,
		Bar1Flyout = 1,
		Bar1Size = 34,
		Bar1Font = 12,
		Bar1Num = 12,
		Bar1PerRow = 12,
		Bar2 = true,
		Bar2Flyout = 1,
		Bar2Size = 34,
		Bar2Font = 12,
		Bar2Num = 12,
		Bar2PerRow = 12,
		Bar3 = true,
		Bar3Flyout = 1,
		Bar3Size = 34,
		Bar3Font = 12,
		Bar3Num = 12,
		Bar3PerRow = 12,
		Bar4 = false,
		Bar4Flyout = 3,
		Bar4Size = 32,
		Bar4Font = 12,
		Bar4Num = 12,
		Bar4PerRow = 1,
		Bar5 = false,
		Bar5Flyout = 3,
		Bar5Size = 32,
		Bar5Font = 12,
		Bar5Num = 12,
		Bar5PerRow = 1,
		Bar6 = false,
		Bar6Flyout = 1,
		Bar6Size = 34,
		Bar6Font = 12,
		Bar6Num = 12,
		Bar6PerRow = 12,
		Bar7 = false,
		Bar7Flyout = 1,
		Bar7Size = 34,
		Bar7Font = 12,
		Bar7Num = 12,
		Bar7PerRow = 12,
		Bar8 = false,
		Bar8Flyout = 1,
		Bar8Size = 34,
		Bar8Font = 12,
		Bar8Num = 12,
		Bar8PerRow = 12,

		BarPetSize = 26,
		BarPetFont = 12,
		BarPetPerRow = 10,
		BarStanceSize = 30,
		BarStanceFont = 12,
		BarStancePerRow = 10,
		VehButtonSize = 34,
		MBSize = 22,
		MBPerRow = 12,
	},
	Bags = {
		Enable = true,
		IconSize = 34,
		FontSize = 12,
		BagsWidth = 14,
		BankWidth = 14,
		AccountWidth = 20,
		BagSortMode = 1,
		ItemFilter = true,
		CustomItems = {},
		CustomNames = {},
		GatherEmpty = true,
		SplitCount = 1,
		iLvlToShow = 1,
		iExpToShow = 0,
		AutoDeposit = false,
		SpecialJunk = true,
		BagsPerRow = 7,
		BankPerRow = 7,
		HideWidgets = true,

		FilterJunk = true,
		FilterConsumable = true,
		FilterEquipment = true,
		FilterLegendary = true,
		FilterCollection = true,
		FilterFavourite = true,
		FilterEquipSet = true,
		FilterFeature = true,
		FilterAuE = true,
		FilterBoN = true,
	},
	Auras = {
		Reminder = false,
		Totems = true,
		VerticalTotems = false,
		TotemSize = 32,
		BuffFrame = true,
		HideBlizBuff = false,
		ReverseBuff = false,
		BuffSize = 30,
		BuffsPerRow = 16,
		ReverseDebuff = false,
		DebuffSize = 30,
		DebuffsPerRow = 16,
		PrivateSize = 30,
		ReversePrivate = false,
	},
	AuraWatch = {
		Enable = true,
		ClickThrough = false,
		IconScale = 1,
		DeprecatedAuras = false,
		MinCD = 3,
	},
	Avada = {
		Enable = false,
	},
	UFs = {
		Enable = true,
		Portrait = true,
		ShowAuras = true,
		Arena = true,
		Castbars = true,
		AddPower = true,
		SwingBar = false,
		SwingWidth = 275,
		SwingHeight = 3,
		SwingTimer = false,
		OffOnTop = false,
		RaidFrame = true,
		AutoRes = true,
		NumGroups = 8,
		RaidDirec = 1,
		RaidRows = 1,
		RaidSpacing = 5,
		SimpleMode = false,
		SMRScale = 10,
		SMRPerCol = 20,
		SMRGroupBy = 1,
		SMRGroups = 8,
		SMRDirec = 1,
		InstanceAuras = true,
		DispellType = 1,
		RaidDebuffScale = 1,
		SpecRaidPos = false,
		RaidHealthColor = 1,
		ShowSolo = false,
		RaidWidth = 80,
		RaidHeight = 32,
		RaidPowerHeight = 2,
		RaidHPMode = 1,
		AuraClickThru = false,
		CombatText = true,
		FCTFontSize = 18,
		PetCombatText = true,
		RaidClickSets = false,
		TeamIndex = false,
		ClassPower = true,
		RaidBuffIndicator = true,
		PartyFrame = true,
		PartyDirec = 2,
		PartyWidth = 100,
		PartyHeight = 32,
		PartyPowerHeight = 2,
		PartySpacing = 5,
		PartyPetFrame = false,
		PartyPetWidth = 100,
		PartyPetHeight = 22,
		PartyPetPowerHeight = 2,
		PartyPetPerCol = 5,
		PartyPetMaxCol = 1,
		PartyPetVsby = 1,
		PetDirec = 1,
		HealthColor = 1,
		BuffIndicatorType = 2,
		BuffIndicatorScale = 1,
		UFTextScale = 1,
		PartyAltPower = true,
		RaidTextScale = 1,
		ShowRaidBuff = false,
		RaidBuffSize = 12,
		BuffClickThru = true,
		ShowRaidDebuff = true,
		RaidDebuffSize = 12,
		DebuffClickThru = true,
		SmartRaid = false,
		CCName = true,
		RCCName = true,
		HideTip = false,
		SortByRole = true,
		SortAscending = false,
		AutoBuffs = false,
		ShowRoleMode = 1,
		OverAbsorb = true,
		PrivateSize = 30,
		ReversePrivate = false,

		PlayerWidth = 250,
		PlayerHeight = 30,
		PlayerPowerHeight = 6,
		PlayerHPTag = 2,
		PlayerMPTag = 4,
		FocusWidth = 200,
		FocusHeight = 24,
		FocusPowerHeight = 4,
		FocusHPTag = 2,
		FocusMPTag = 4,
		PetWidth = 160,
		PetHeight = 20,
		PetPowerHeight = 2,
		PetHPTag = 4,
		BossWidth = 160,
		BossHeight = 24,
		BossPowerHeight = 4,
		BossHPTag = 5,
		BossMPTag = 5,

		CastingColor = {r=.25, g=.75, b=1},
		NotInterruptColor = {r=1, g=.25, b=.75},
		PlayerCB = true,
		PlayerCBWidth = 280,
		PlayerCBHeight = 20,
		TargetCB = true,
		TargetCBWidth = 300,
		TargetCBHeight = 20,
		FocusCB = true,
		FocusCBWidth = 320,
		FocusCBHeight = 20,

		PlayerNumBuff = 40,
		PlayerNumDebuff = 40,
		PlayerBuffType = 1,
		PlayerDebuffType = 2,
		PlayerAurasPerRow = 8,
		TargetNumBuff = 40,
		TargetNumDebuff = 40,
		TargetBuffType = 2,
		TargetDebuffType = 2,
		TargetAurasPerRow = 8,
		FocusNumBuff = 40,
		FocusNumDebuff = 40,
		FocusBuffType = 3,
		FocusDebuffType = 3,
		FocusAurasPerRow = 8,
		ToTNumBuff = 6,
		ToTNumDebuff = 30,
		ToTBuffType = 1,
		ToTDebuffType = 2,
		ToTAurasPerRow = 6,
		PetNumBuff = 6,
		PetNumDebuff = 30,
		PetBuffType = 1,
		PetDebuffType = 2,
		PetAurasPerRow = 6,
		BossNumBuff = 6,
		BossNumDebuff = 12,
		BossBuffType = 2,
		BossDebuffType = 3,
		BossBuffPerRow = 6,
		BossDebuffPerRow = 6,

		PlayerAuraDirec = 3,
		TargetAuraDirec = 1,
		ToTAuraDirec = 1,
		PetAuraDirec = 1,
		FocusAuraDirec = 1,

		CustomNameColor = {r=1, g=1, b=1},
	},
	Chat = {
		Sticky = false,
		Lock = true,
		Invite = true,
		Freedom = true,
		Keyword = "raid",
		Oldname = false,
		GuildInvite = true,
		EnableFilter = true,
		Matches = 1,
		BlockAddonAlert = true,
		ChatMenu = true,
		WhisperColor = true,
		ChatItemLevel = true,
		Chatbar = true,
		ChatWidth = 380,
		ChatHeight = 190,
		BlockStranger = false,
		BlockSpammer = false,
		ChatBGType = 2,
		WhisperSound = true,
		BottomBox = false,
		SysFont = false,
		EditFont = 14,
	},
	Map = {
		DisableMap = false,
		DisableMinimap = false,
		Clock = false,
		CombatPulse = true,
		MapScale = 1,
		MaxMapScale = 1,
		MinimapScale = 1.2,
		MinimapSize = 160,
		ShowRecycleBin = true,
		WhoPings = true,
		MapReveal = true,
		MapRevealGlow = true,
		Calendar = false,
		EasyVolume = true,
	},
	Nameplate = {
		Enable = true,
		maxAuras = 18,
		PlateAuras = true,
		perRow = 6,
		AuraFilter = 3,
		FriendlyCC = false,
		HostileCC = true,
		TargetIndicator = 2,
		InsideView = true,
		ShowCustomUnits = true,
		CustomColor = {r=0, g=.5, b=1},
		CustomUnits = {},
		ShowPowerUnits = true,
		PowerUnits = {},
		VerticalSpacing = 1,
		ShowPlayerPlate = false,
		PPWidth = 175,
		PPBarHeight = 5,
		PPHealthHeight = 5,
		PPPowerHeight = 5,
		PPPowerText = false,
		NameType = 5,
		HealthType = 2,
		SecureColor = {r=.5, g=1, b=.5},
		TransColor = {r=1, g=1, b=.5},
		InsecureColor = {r=1, g=.5, b=.5},
		OffTankColor = {r=.5, g=.5, b=1},
		HighlightColor = {r=1, g=1, b=1},
		TargetColor = {r=1, g=0, b=1},
		WarningColor = {r=1, g=.5, b=0},
		PPFadeout = true,
		PPFadeoutAlpha = 0,
		TargetPower = false,
		MinScale = 1,
		MinAlpha = 1,
		QuestIndicator = true,
		NameOnlyMode = false,
		PPGCDTicker = true,
		ExecuteRatio = 0,
		CastbarGlow = true,
		CastTarget = true,
		Interruptor = true,
		FriendPlate = false,
		EnemyThru = false,
		FriendlyThru = false,
		BlockDBM = true,
		DispellMode = 1,
		UnitTargeted = true,
		ColorByDot = false,
		DotColor = {r=.5, g=0, b=.5},
		DotSpells = {},
		RaidTargetX = 0,
		RaidTargetY = 0,
		PlateRange = 45,

		PlateWidth = 200,
		PlateHeight = 10,
		PlateMargin = 5,
		InteractWidth = 200,
		InteractHeight = 50,
		NameTextSize = 14,
		HealthTextSize = 16,
		CastBarTextSize = 16,

		NameOnlyTextSize = 14,
		NameOnlyTitleSize = 12,
		NameOnlyTitle = true,
		NameOnlyGuild = false,
		CVarOnlyNames = false,
		CVarShowNPCs = false,
	},
	Skins = {
		DBM = true,
		Skada = true,
		Bigwigs = true,
		TMW = true,
		WeakAuras = true,
		InfobarLine = true,
		ChatbarLine = true,
		MenuLine = true,
		ClassLine = true,
		Details = true,
		ToggleDirection = 1,
		BlizzardSkins = true,
		SkinAlpha = .5,
		FontOutline = true,
		Shadow = false,
		BgTex = true,
		CustomBD = true,
		CustomBDColor = {r=.5, g=.5, b=.5},
		FontScale = 1,
	},
	Tooltip = {
		HideInCombat = 1,
		CursorMode = 4,
		TipAnchor = 4,
		Scale = 1,
		AzeriteArmor = true,
		OnlyArmorIcons = false,
		HideAllID = false,
		MythicScore = true,
	},
	Misc = {
		Mail = true,
		MailSaver = false,
		MailTarget = "",
		ItemLevel = true,
		GemNEnchant = true,
		AzeriteTraits = true,
		MissingStats = true,
		SoloInfo = true,
		RareAlerter = true,
		Focuser = true,
		ExpRep = true,
		Screenshot = true,
		TradeTabs = true,
		InterruptAlert = false,
		OwnInterrupt = true,
		DispellAlert = false,
		OwnDispell = true,
		InstAlertOnly = true,
		BrokenAlert = false,
		LeaderOnly = true,
		FasterLoot = true,
		AutoQuest = false,
		IgnoreQuestNPC = {},
		HideTalking = true,
		HideBossBanner = true,
		HideBossEmote = false,
		PetFilter = true,
		QuestNotification = false,
		QuestProgress = false,
		OnlyCompleteRing = false,
		SpellItemAlert = false,
		RareAlertInWild = false,
		AutoConfirm = true,
		InstantDelete = true,
		RaidTool = true,
		RMRune = false,
		DBMCount = "10",
		EasyMarkKey = 1,
		ShowMarkerBar = 1,
		MarkerSize = 28,
		BlockInvite = false,
		BlockRequest = false,
		NzothVision = true,
		MDGuildBest = true,
		FasterSkip = false,
		EnhanceDressup = true,
		QuestTool = true,
		InfoStrLeft = "[guild][friend][ping][fps][zone]",
		InfoStrRight = "[spec][dura][gold][time]",
		InfoSize = 13,
		MaxAddOns = 12,
		MenuButton = true,
		QuickJoin = true,
		MaxZoom = 2.6,
		SingingSocket = true,
	},
	Tutorial = {
		Complete = false,
	},
}

G.AccountSettings = {
	ChatFilterList = "%*",
	ChatFilterWhiteList = "",
	TimestampFormat = 4,
	RaidDebuffs = {},
	Changelog = {},
	totalGold = {},
	ShowSlots = false,
	RepairType = 1,
	AutoSell = true,
	GuildSortBy = 1,
	GuildSortOrder = true,
	DetectVersion = DB.Version,
	LockUIScale = false,
	UIScale = .75,
	NumberFormat = 2,
	VersionCheck = true,
	DBMRequest = false,
	SkadaRequest = false,
	BWRequest = false,
	ClickSets = {},
	TexStyle = 3,
	KeystoneInfo = {},
	AutoBubbles = false,
	DisableInfobars = false,
	ContactList = {},
	CustomJunkList = {},
	ProfileIndex = {},
	ProfileNames = {},
	Help = {},
	CornerSpells = {},
	CustomTex = "",
	MajorSpells = {},
	SmoothAmount = .25,
	AutoRecycle = true,
	IgnoredButtons = "",
	RaidBuffsWhite = {},
	RaidDebuffsBlack = {},
	NameplateWhite = {},
	NameplateBlack = {},
	IgnoreNotes = {},
	GlowMode = 3,
	IgnoredRares = "",
	AvadaIndex = {},
	AvadaProfile = {},
}

-- Initial settings
G.TextureList = {
	[1] = {texture = DB.normTex, name = L["Highlight"]},
	[2] = {texture = DB.gradTex, name = L["Gradient"]},
	[3] = {texture = DB.flatTex, name = L["Flat"]},
}

local ignoredTable = {
	["AuraWatchList"] = true,
	["AuraWatchMover"] = true,
	["InternalCD"] = true,
	["Mover"] = true,
	["TempAnchor"] = true,
}

local function InitialSettings(source, target, fullClean)
	for i, j in pairs(source) do
		if type(j) == "table" then
			if target[i] == nil then target[i] = {} end
			for k, v in pairs(j) do
				if target[i][k] == nil then
					target[i][k] = v
				end
			end
		else
			if target[i] == nil then target[i] = j end
		end
	end

	for i, j in pairs(target) do
		if source[i] == nil then target[i] = nil end
		if fullClean and type(j) == "table" and not ignoredTable[i] then
			for k, v in pairs(j) do
				if source[i] and source[i][k] == nil then
					target[i][k] = nil
				end
			end
		end
	end
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(self, _, addon)
	if addon ~= "NDui" then return end

	-- Transfer old data START
	if NDuiADB["NameplateFilter"] then
		if NDuiADB["NameplateFilter"][1] then
			if not NDuiADB["NameplateWhite"] then NDuiADB["NameplateWhite"] = {} end
			for spellID, value in pairs(NDuiADB["NameplateFilter"][1]) do
				NDuiADB["NameplateWhite"][spellID] = value
			end
		end
		if NDuiADB["NameplateFilter"][2] then
			if not NDuiADB["NameplateBlack"] then NDuiADB["NameplateBlack"] = {} end
			for spellID, value in pairs(NDuiADB["NameplateFilter"][2]) do
				NDuiADB["NameplateBlack"][spellID] = value
			end
		end
	end
	if NDuiADB["RaidAuraWatch"] then
		if not NDuiADB["RaidBuffsWhite"] then NDuiADB["RaidBuffsWhite"] = {} end
		for spellID in pairs(NDuiADB["RaidAuraWatch"]) do
			NDuiADB["RaidBuffsWhite"][spellID] = true
		end
	end
	-- Transfer old data END

	InitialSettings(G.AccountSettings, NDuiADB)
	if not next(NDuiPDB) then
		for i = 1, 5 do NDuiPDB[i] = {} end
	end

	if not NDuiADB["ProfileIndex"][DB.MyFullName] then
		NDuiADB["ProfileIndex"][DB.MyFullName] = 1
	end

	if NDuiADB["ProfileIndex"][DB.MyFullName] == 1 then
		C.db = NDuiDB
	else
		C.db = NDuiPDB[NDuiADB["ProfileIndex"][DB.MyFullName] - 1]
	end
	InitialSettings(G.DefaultSettings, C.db, true)

	if not C.db["Reset"] then
		C.db["Actionbar"]["Enable"] = true
		C.db["Reset"] = true
	end

	B:SetupUIScale(true)
	if NDuiADB["CustomTex"] ~= "" then
		DB.normTex = "Interface\\"..NDuiADB["CustomTex"]
	else
		if not G.TextureList[NDuiADB["TexStyle"]] then
			NDuiADB["TexStyle"] = 3 -- reset value if not exists
		end
		DB.normTex = G.TextureList[NDuiADB["TexStyle"]].texture
	end

	if not C.db["Map"]["DisableMinimap"] then
		GetMinimapShape = B.GetMinimapShape
	end

	self:UnregisterAllEvents()
end)

-- Callbacks
local function setupBagFilter()
	G:SetupBagFilter(guiPage[2])
end

local function setupUnitFrame()
	G:SetupUnitFrame(guiPage[3])
end

local function setupCastbar()
	G:SetupCastbar(guiPage[3])
end

local function setupUFAuras()
	G:SetupUFAuras(guiPage[3])
end

local function setupSwingBars()
	G:SetupSwingBars(guiPage[3])
end

local function setupRaidFrame()
	G:SetupRaidFrame(guiPage[4])
end

local function setupSimpleRaidFrame()
	G:SetupSimpleRaidFrame(guiPage[4])
end

local function setupPartyFrame()
	G:SetupPartyFrame(guiPage[4])
end

local function setupPartyPetFrame()
	G:SetupPartyPetFrame(guiPage[4])
end

local function setupRaidDebuffs()
	G:SetupRaidDebuffs(guiPage[4])
end

local function setupClickCast()
	G:SetupClickCast(guiPage[4])
end

local function setupDebuffsIndicator()
	G:SetupDebuffsIndicator(guiPage[4])
end

local function setupBuffsIndicator()
	G:SetupBuffsIndicator(guiPage[4])
end

local function setupSpellsIndicator()
	G:SetupSpellsIndicator(guiPage[4])
end

local function setupNameplateFilter()
	G:SetupNameplateFilter(guiPage[5])
end

local function setupNameplateColorDots()
	G:NameplateColorDots(guiPage[5])
end

local function setupNameplateUnitFilter()
	G:NameplateUnitFilter(guiPage[5])
end

local function setupNameplatePowerUnits()
	G:NameplatePowerUnits(guiPage[5])
end

local function setupNameplateSize()
	G:SetupNameplateSize(guiPage[5])
end

local function setupNameOnlySize()
	G:SetupNameOnlySize(guiPage[5])
end

local function setupPlateCastbarGlow()
	G:PlateCastbarGlow(guiPage[5])
end

local function setupBuffFrame()
	G:SetupBuffFrame(guiPage[7])
end

local function setupAuraWatch()
	f:Hide()
	SlashCmdList["NDUI_AWCONFIG"]()
end

local function updateBagSortOrder()
	C_Container.SetSortBagsRightToLeft(C.db["Bags"]["BagSortMode"] == 1)
end

local function updateBagStatus()
	B:GetModule("Bags"):UpdateAllBags()
end

local function updateBagAnchor()
	B:GetModule("Bags"):UpdateAllAnchors()
end

local function updateBagSize()
	B:GetModule("Bags"):UpdateBagSize()
end

local function setupActionBar()
	G:SetupActionBar(guiPage[1])
end

local function setupMicroMenu()
	G:SetupMicroMenu(guiPage[1])
end

local function setupStanceBar()
	G:SetupStanceBar(guiPage[1])
end

local function updateHotkeys()
	B:GetModule("Actionbar"):UpdateBarConfig()
end

local function updateOverlays()
	B:GetModule("Actionbar"):UpdateOverlays()
end
local function updateReminder()
	B:GetModule("Auras"):InitReminder()
end

local function refreshTotemBar()
	if not C.db["Auras"]["Totems"] then return end
	B:GetModule("Auras"):TotemBar_Init()
end

local function updateChatSticky()
	B:GetModule("Chat"):ChatWhisperSticky()
end

local function updateWhisperList()
	B:GetModule("Chat"):UpdateWhisperList()
end

local function updateFilterList()
	B:GetModule("Chat"):UpdateFilterList()
end

local function updateFilterWhiteList()
	B:GetModule("Chat"):UpdateFilterWhiteList()
end

local function updateChatSize()
	B:GetModule("Chat"):UpdateChatSize()
end

local function toggleChatBackground()
	B:GetModule("Chat"):ToggleChatBackground()
end

local function toggleLanguageFilter()
	B:GetModule("Chat"):ToggleLanguageFilter()
end

local function toggleEditBoxAnchor()
	B:GetModule("Chat"):ToggleEditBoxAnchor()
end

local function updateToggleDirection()
	B:GetModule("Skins"):RefreshToggleDirection()
end

local function updatePlateCVars()
	B:GetModule("UnitFrames"):UpdatePlateCVars()
end

local function updateCustomUnitList()
	B:GetModule("UnitFrames"):CreateUnitTable()
end

local function updatePowerUnitList()
	B:GetModule("UnitFrames"):CreatePowerUnitTable()
end

local function refreshNameplates()
	B:GetModule("UnitFrames"):RefreshAllPlates()
end

local function updateClickThru()
	B:GetModule("UnitFrames"):UpdatePlateClickThru()
end

local function togglePlatePower()
	B:GetModule("UnitFrames"):TogglePlatePower()
end

local function togglePlateVisibility()
	B:GetModule("UnitFrames"):TogglePlateVisibility()
end

local function toggleAvada()
	B:GetModule("UnitFrames"):Avada_Toggle()
end

local function toggleAvadaGUI()
	G:SetupAvada()
	if f then f:Hide() end
end

local function togglePlayerPlate()
	refreshNameplates()
	B:GetModule("UnitFrames"):TogglePlayerPlate()
end

local function toggleTargetClassPower()
	refreshNameplates()
	B:GetModule("UnitFrames"):ToggleTargetClassPower()
end

local function toggleGCDTicker()
	B:GetModule("UnitFrames"):ToggleGCDTicker()
end

local function updateUFTextScale()
	B:GetModule("UnitFrames"):UpdateTextScale()
end

local function toggleAddPower()
	B:GetModule("UnitFrames"):ToggleAddPower()
end

local function toggleUFClassPower()
	B:GetModule("UnitFrames"):ToggleUFClassPower()
end

local function togglePortraits()
	B:GetModule("UnitFrames"):TogglePortraits()
end

local function toggleAllAuras()
	B:GetModule("UnitFrames"):ToggleAllAuras()
end

local function updateRaidTextScale()
	B:GetModule("UnitFrames"):UpdateRaidTextScale()
end

local function toggleCastBarLatency()
	B:GetModule("UnitFrames"):ToggleCastBarLatency()
end

local function toggleSwingBars()
	B:GetModule("UnitFrames"):ToggleSwingBars()
end

local function updateSmoothingAmount()
	B:SetSmoothingAmount(NDuiADB["SmoothAmount"])
end

local function updateAllHeaders()
	B:GetModule("UnitFrames"):UpdateAllHeaders()
end

local function updateTeamIndex()
	local UF = B:GetModule("UnitFrames")
	if UF.CreateAndUpdateRaidHeader then
		UF:CreateAndUpdateRaidHeader()
		UF:UpdateRaidTeamIndex()
	end
	updateRaidTextScale()
end

local function updatePartyElements()
	B:GetModule("UnitFrames"):UpdatePartyElements()
end

local function refreshPlateByEvents()
	B:GetModule("UnitFrames"):RefreshPlateByEvents()
end

local function updateScrollingFont()
	B:GetModule("UnitFrames"):UpdateScrollingFont()
end

local function updateRaidAurasOptions()
	B:GetModule("UnitFrames"):RaidAuras_UpdateOptions()
end

local function updateMinimapScale()
	B:GetModule("Maps"):UpdateMinimapScale()
end

local function showMinimapClock()
	B:GetModule("Maps"):ShowMinimapClock()
end

local function showCalendar()
	B:GetModule("Maps"):ShowCalendar()
end

local function updateInterruptAlert()
	B:GetModule("Misc"):InterruptAlert()
end

local function updateRareAlert()
	B:GetModule("Misc"):RareAlert()
end

local function updateIgnoredRares()
	B:GetModule("Misc"):RareAlert_UpdateIgnored()
end

local function updateSoloInfo()
	B:GetModule("Misc"):SoloInfo()
end

local function updateSpellItemAlert()
	B:GetModule("Misc"):SpellItemAlert()
end

local function updateQuestNotification()
	B:GetModule("Misc"):QuestNotification()
end

local function updateScreenShot()
	B:GetModule("Misc"):UpdateScreenShot()
end

local function updateFasterLoot()
	B:GetModule("Misc"):UpdateFasterLoot()
end

local function toggleBossBanner()
	B:GetModule("Misc"):ToggleBossBanner()
end

local function toggleBossEmote()
	B:GetModule("Misc"):ToggleBossEmote()
end

local function updateMarkerGrid()
	B:GetModule("Misc"):RaidTool_UpdateGrid()
end

local function updateMaxZoomLevel()
	B:GetModule("Misc"):UpdateMaxZoomLevel()
end

local function updateInfobarAnchor(self)
	if self:GetText() == "" then
		self:SetText(self.__default)
		C.db[self.__key][self.__value] = self:GetText()
	end

	if not NDuiADB["DisableInfobars"] then
		B:GetModule("Infobar"):Infobar_UpdateAnchor()
	end
end

local function updateInfobarSize()
	B:GetModule("Infobar"):UpdateInfobarSize()
end

local function updateSkinAlpha()
	for _, frame in pairs(C.frames) do
		frame:SetBackdropColor(0, 0, 0, C.db["Skins"]["SkinAlpha"])
	end
end

StaticPopupDialogs["RESET_DETAILS"] = {
	text = L["Reset Details check"],
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		B:GetModule("Skins"):ResetDetailsAnchor(true)
	end,
	whileDead = 1,
}
local function resetDetails()
	StaticPopup_Show("RESET_DETAILS")
end

local function AddTextureToOption(parent, index)
	local tex = parent[index]:CreateTexture(nil, "ARTWORK")
	tex:SetInside(nil, 4, 4)
	tex:SetTexture(G.TextureList[index].texture)
	tex:SetVertexColor(cr, cg, cb)
end

-- Config
local HeaderTag = "|cff00FF00"
local IsNew = "ISNEW"
G.HealthValues = {DISABLE, L["ShowHealthDefault"], L["ShowHealthCurMax"], L["ShowHealthCurrent"], L["ShowHealthPercent"], L["ShowHealthLoss"], L["ShowHealthLossPercent"], L["ShowHealthAbsorb"]}

local function AddNewTag(parent, anchor)
	local tag = CreateFrame("Frame", nil, parent, "NewFeatureLabelTemplate")
	tag:SetPoint("LEFT", anchor or parent, -25, 10)
	tag:Show()
end

G.TabList = {
	L["Actionbar"],
	L["Bags"],
	L["Unitframes"],
	IsNew..L["RaidFrame"],
	L["Nameplate"],
	IsNew..L["PlayerPlate"],
	L["Auras"],
	L["Raid Tools"],
	L["ChatFrame"],
	L["Maps"],
	L["Skins"],
	L["Tooltip"],
	L["Misc"],
	L["UI Settings"],
	L["Profile"],
}

G.OptionList = { -- type, key, value, name, horizon, doubleline
	[1] = {
		{1, "Actionbar", "Enable", HeaderTag..L["Enable Actionbar"], nil, setupActionBar},
		{}, -- blank
		{1, "Actionbar", "MicroMenu", L["Micromenu"], nil, setupMicroMenu, nil, L["MicroMenuTip"]},
		{1, "Actionbar", "ShowStance", L["ShowStanceBar"], true, setupStanceBar},
		{}, -- blank
		{1, "Actionbar", "Cooldown", HeaderTag..L["Show Cooldown"]},
		{1, "Actionbar", "OverrideWA", L["HideCooldownOnWA"].."*", true},
		{3, "Actionbar", "MmssTH", L["MmssThreshold"].."*", nil, {60, 600, 1}, nil, L["MmssThresholdTip"]},
		{3, "Actionbar", "TenthTH", L["TenthThreshold"].."*", true, {0, 60, 1}, nil, L["TenthThresholdTip"]},
		{}, -- blank
		{1, "Actionbar", "KeyDown", L["KeyDown"].."*", nil, nil, updateHotkeys, L["KeyDownTip"]},
		{1, "Actionbar", "ButtonLock", L["ButtonLock"].."*", true, nil, updateHotkeys, L["ButtonLockTip"]},
		{1, "Actionbar", "Hotkeys", L["Actionbar Hotkey"].."*", nil, nil, updateHotkeys},
		{1, "Actionbar", "SendActionCD", HeaderTag..L["SendActionCD"].."*", true, nil, nil, L["SendActionCDTip"]},
		{1, "Actionbar", "Macro", L["Actionbar Macro"].."*", nil, nil, updateHotkeys},
		{1, "Actionbar", "Grid", L["Actionbar Grid"].."*", nil, nil, updateHotkeys},
		{4, "ACCOUNT", "GlowMode", L["GlowMode"].."*", true, {"Pixel", "Autocast", "Action Button", "Proc Glow"}},
	},
	[2] = {
		{1, "Bags", "Enable", HeaderTag..L["Enable Bags"]},
		{1, "Bags", "ItemFilter", L["Bags ItemFilter"].."*", true, setupBagFilter, updateBagStatus},
		{}, -- blank
		{1, "Bags", "GatherEmpty", L["Bags GatherEmpty"].."*", nil, nil, updateBagStatus},
		{1, "Bags", "SpecialJunk", L["SpecialJunk"], nil, nil, nil, L["SpecialJunkTip"]},
		{4, "Bags", "BagSortMode", L["BagSortMode"].."*", true, {L["Forward"], L["Backward"]}, updateBagSortOrder, L["BagSortTip"]},
		{3, "Bags", "iLvlToShow", L["iLvlToShow"].."*", nil, {1, 1000, 1}, nil, L["iLvlToShowTip"]},
		{3, "Bags", "iExpToShow", L["iExpToShow"].."*", true, {0, 10, 1}, nil, L["iExpToShowTip"]},
		{}, -- blank
		{3, "Bags", "BagsPerRow", L["BagsPerRow"].."*", nil, {1, 20, 1}, updateBagAnchor, L["BagsPerRowTip"]},
		{3, "Bags", "BankPerRow", L["BankPerRow"].."*", true, {1, 20, 1}, updateBagAnchor, L["BankPerRowTip"]},
		{3, "Bags", "IconSize", L["Bags IconSize"].."*", nil, {20, 50, 1}, updateBagSize},
		{3, "Bags", "FontSize", L["Bags FontSize"].."*", true, {10, 50, 1}, updateBagSize},
		{3, "Bags", "BagsWidth", L["Bags Width"].."*", false, {10, 40, 1}, updateBagSize},
		{3, "Bags", "BankWidth", L["Bank Width"].."*", true, {10, 40, 1}, updateBagSize},
		{3, "Bags", "AccountWidth", L["AccountBank Width"].."*", nil, {10, 40, 1}, updateBagSize},
	},
	[3] = {
		{1, "UFs", "Enable", HeaderTag..L["Enable UFs"], nil, setupUnitFrame, nil, L["HideUFWarning"]},
		{1, "UFs", "Arena", L["Arena Frame"], true},
		{1, "UFs", "ShowAuras", L["ShowAuras"].."*", nil, setupUFAuras, toggleAllAuras},
		{1, "UFs", "ClassPower", L["UFs ClassPower"].."*", true, nil, toggleUFClassPower},
		{1, "UFs", "Portrait", L["UFs Portrait"].."*", nil, nil, togglePortraits},
		{1, "UFs", "AddPower", L["AddPower"].."*", true, nil, toggleAddPower, L["AddPowerTip"]},
		{1, "UFs", "OverAbsorb", L["OverAbsorb"].."*", nil, nil, nil, L["OverAbsorbTip"]},
		{1, "UFs", "CCName", L["ClassColor Name"].."*", true, nil, updateUFTextScale, L["CustomNameColorTip"]},
		{5, "UFs", "CustomNameColor", L["CustomNameColor"], 3},
		{3, "UFs", "UFTextScale", L["UFTextScale"].."*", nil, {.8, 1.5, .05}, updateUFTextScale},
		{4, "UFs", "HealthColor", L["HealthColor"].."*", true, {L["Default Dark"], L["ClassColorHP"], L["GradientHP"], L["ClearHealth"], L["ClearClass"]}, updateUFTextScale},
		{}, -- blank
		{1, "UFs", "Castbars", HeaderTag..L["UFs Castbar"], nil, setupCastbar},
		{1, "UFs", "SwingBar", L["UFs SwingBar"].."*", true, setupSwingBars, toggleSwingBars},
		{}, -- blank
		{1, "UFs", "CombatText", HeaderTag..L["UFs CombatText"]},
		{1, "UFs", "PetCombatText", L["CombatText ShowPets"].."*"},
		{3, "UFs", "FCTFontSize", L["FCTFontSize"].."*", true, {12, 40, 1}, updateScrollingFont},
	},
	[4] = {
		{1, "UFs", "RaidFrame", IsNew..HeaderTag..L["UFs RaidFrame"], nil, setupRaidFrame, nil, L["RaidFrameTip"]},
		{1, "UFs", "SimpleMode", L["SimpleRaidFrame"], true, setupSimpleRaidFrame, nil, L["SimpleRaidFrameTip"]},
		{1, "UFs", "PartyFrame", IsNew..HeaderTag..L["PartyFrame"], nil, setupPartyFrame, nil, L["PartyFrameTip"]},
		{1, "UFs", "PartyPetFrame", HeaderTag..L["PartyPetFrame"], true, setupPartyPetFrame, nil, L["PartyPetTip"]},
		{}, -- blank
		{1, "UFs", "ShowRaidDebuff", L["ShowRaidDebuff"].."*", nil, setupDebuffsIndicator, updateRaidAurasOptions, L["ShowRaidDebuffTip"]},
		{1, "UFs", "ShowRaidBuff", L["ShowRaidBuff"].."*", true, setupBuffsIndicator, updateRaidAurasOptions, L["ShowRaidBuffTip"]},
		{1, "UFs", "DebuffClickThru", L["DebuffClickThru"].."*", nil, nil, updateRaidAurasOptions, L["ClickThroughTip"]},
		{1, "UFs", "BuffClickThru", L["BuffClickThru"].."*", true, nil, updateRaidAurasOptions, L["ClickThroughTip"]},
		{3, "UFs", "RaidDebuffSize", L["RaidDebuffSize"].."*", nil, {5, 30, 1}, updateRaidAurasOptions},
		{3, "UFs", "RaidBuffSize", L["RaidBuffSize"].."*", true, {5, 30, 1}, updateRaidAurasOptions},
		{}, -- blank
		{1, "UFs", "RaidBuffIndicator", HeaderTag..L["RaidBuffIndicator"].."*", nil, setupSpellsIndicator, updateRaidAurasOptions, L["RaidBuffIndicatorTip"]},
		{4, "UFs", "BuffIndicatorType", L["BuffIndicatorType"].."*", nil, {L["BI_Blocks"], L["BI_Icons"], L["BI_Numbers"]}, updateRaidAurasOptions},
		{3, "UFs", "BuffIndicatorScale", L["BuffIndicatorScale"].."*", true, {.8, 2, .1}, updateRaidAurasOptions},
		{}, -- blank
		{1, "UFs", "InstanceAuras", HeaderTag..L["Instance Auras"].."*", nil, setupRaidDebuffs, updateRaidAurasOptions, L["InstanceAurasTip"]},
		{1, "UFs", "AuraClickThru", L["RaidAuras ClickThrough"].."*", true, nil, updateRaidAurasOptions, L["ClickThroughTip"]},
		{4, "UFs", "DispellType", L["Dispellable"].."*", nil, {L["Always"], L["Filter"], DISABLE}, updateRaidAurasOptions, L["DispellTypeTip"]},
		{3, "UFs", "RaidDebuffScale", L["RaidDebuffScale"].."*", true, {.8, 2, .1}, updateRaidAurasOptions},
		{}, -- blank
		{1, "UFs", "RaidClickSets", HeaderTag..L["Enable ClickSets"], nil, setupClickCast},
		{1, "UFs", "AutoRes", HeaderTag..L["UFs AutoRes"], true},
		{}, -- blank
		{4, "UFs", "RaidHealthColor", L["HealthColor"].."*", nil, {L["Default Dark"], L["ClassColorHP"], L["GradientHP"], L["ClearHealth"], L["ClearClass"]}, updateRaidTextScale},
		{4, "UFs", "RaidHPMode", L["HealthValueType"].."*", true, {DISABLE, L["ShowHealthPercent"], L["ShowHealthCurrent"], L["ShowHealthLoss"], L["ShowHealthLossPercent"], L["ShowHealthAbsorb"]}, updateRaidTextScale},
		{4, "UFs", "ShowRoleMode", L["ShowRoleMode"], nil, {ALL, DISABLE, L["HideDPSRole"]}},
		{3, "UFs", "RaidTextScale", L["UFTextScale"].."*", true, {.8, 1.5, .05}, updateRaidTextScale},
		{1, "UFs", "ShowSolo", L["ShowSolo"].."*", nil, nil, updateAllHeaders, L["ShowSoloTip"]},
		{1, "UFs", "SmartRaid", HeaderTag..L["SmartRaid"].."*", true, nil, updateAllHeaders, L["SmartRaidTip"]},
		{1, "UFs", "TeamIndex", L["RaidFrame TeamIndex"].."*", nil, nil, updateTeamIndex},
		{1, "UFs", "SpecRaidPos", L["Spec RaidPos"], true, nil, nil, L["SpecRaidPosTip"]},
		{1, "UFs", "RCCName", L["ClassColor Name"].."*", nil, nil, updateRaidTextScale, L["CustomNameColorTip"]},
		{1, "UFs", "HideTip", L["HideTooltip"].."*", true, nil, updateRaidTextScale, L["HideTooltipTip"]},
	},
	[5] = {
		{1, "Nameplate", "Enable", HeaderTag..L["Enable Nameplate"], nil, setupNameplateSize, refreshNameplates},
		{1, "Nameplate", "NameOnlyMode", L["NameOnlyMode"].."*", true, setupNameOnlySize, nil, L["NameOnlyModeTip"]},
		{4, "Nameplate", "NameType", L["NameTextType"].."*", nil, {DISABLE, L["Tag:name"], L["Tag:levelname"], L["Tag:rarename"], L["Tag:rarelevelname"]}, refreshNameplates, L["PlateLevelTagTip"]},
		{4, "Nameplate", "HealthType", L["HealthValueType"].."*", true, G.HealthValues, refreshNameplates, L["100PercentTip"]},
		{}, -- blank
		{1, "Nameplate", "PlateAuras", HeaderTag..L["PlateAuras"].."*", nil, setupNameplateFilter, refreshNameplates},
		{4, "Nameplate", "DispellMode", L["Dispellable"].."*", nil, {L["Filter"], L["Always"], DISABLE}, refreshNameplates, L["DispellableTip"]},
		{4, "Nameplate", "AuraFilter", L["NameplateAuraFilter"].."*", true, {L["BlackNWhite"], L["PlayerOnly"], L["IncludeCrowdControl"]}, refreshNameplates},
		{3, "Nameplate", "maxAuras", L["Max Auras"].."*", false, {10, 30, 1}, refreshNameplates},
		{3, "Nameplate", "perRow", L["IconsPerRow"].."*", true, {5, 10, 1}, refreshNameplates},
		{}, -- blank
		{4, "Nameplate", "TargetIndicator", L["TargetIndicator"].."*", nil, {DISABLE, L["TargetGlow"]}, refreshNameplates},
		{3, "Nameplate", "ExecuteRatio", L["ExecuteRatio"].."*", true, {0, 90, 1}, nil, L["ExecuteRatioTip"]},
		{1, "Nameplate", "FriendlyCC", L["Friendly CC"].."*"},
		{1, "Nameplate", "HostileCC", L["Hostile CC"].."*", true},
		{1, "Nameplate", "FriendlyThru", "|cffFF0000"..L["Friendly ClickThru"].."*", nil, nil, updateClickThru, L["PlateClickThruTip"]},
		{1, "Nameplate", "EnemyThru", "|cffFF0000"..L["Enemy ClickThru"].."*", true, nil, updateClickThru, L["PlateClickThruTip"]},
		{1, "Nameplate", "UnitTargeted", L["Show TargetedBy"].."*", nil, nil, refreshPlateByEvents, L["TargetedByTip"]},
		{1, "Nameplate", "CastTarget", L["PlateCastTarget"].."*", true, nil, nil, L["PlateCastTargetTip"]},
		{1, "Nameplate", "InsideView", L["Nameplate InsideView"].."*", nil, nil, UpdatePlateCVars},
		{1, "Nameplate", "Interruptor", L["ShowInterruptor"].."*", true},
		{1, "Nameplate", "QuestIndicator", L["QuestIndicator"]},
		{1, "Nameplate", "BlockDBM", L["BlockDBM"], true, nil, nil, L["BlockDBMTip"]},
		{}, -- blank
		{1, "Nameplate", "ColorByDot", HeaderTag..L["ColorByDot"].."*", nil, setupNameplateColorDots, nil, L["ColorByDotTip"]},
		{1, "Nameplate", "CastbarGlow", HeaderTag..L["PlateCastbarGlow"].."*", true, setupPlateCastbarGlow, nil, L["PlateCastbarGlowTip"]},
		{1, "Nameplate", "ShowCustomUnits", HeaderTag..L["ShowCustomUnits"].."*", nil, setupNameplateUnitFilter, updateCustomUnitList, L["CustomUnitsTip"]},
		{1, "Nameplate", "ShowPowerUnits", HeaderTag..L["ShowPowerUnits"].."*", true, setupNameplatePowerUnits, updatePowerUnitList, L["PowerUnitsTip"]},
		{}, -- blank
		{5, "Nameplate", "SecureColor", L["Secure Color"].."*"},
		{5, "Nameplate", "TransColor", L["Trans Color"].."*", 1},
		{5, "Nameplate", "InsecureColor", L["Insecure Color"].."*", 2},
		{5, "Nameplate", "OffTankColor", L["OffTank Color"].."*", 3},
		{5, "Nameplate", "HighlightColor", L["Highlight Color"].."*"},
		{5, "Nameplate", "TargetColor", L["Target Color"].."*", 1},
		{5, "Nameplate", "WarningColor", L["Warning Color"].."*", 2},
		{}, -- blank
		{1, "Nameplate", "CVarOnlyNames", L["CVarOnlyNames"], nil, nil, updatePlateCVars, L["CVarOnlyNamesTip"]},
		{1, "Nameplate", "CVarShowNPCs", L["CVarShowNPCs"].."*", true, nil, updatePlateCVars, L["CVarShowNPCsTip"]},
		{3, "Nameplate", "PlateRange", L["PlateRange"].."*", nil, {0, 60, 1}, updatePlateCVars, L["PlateRangeTip"]},
		{3, "Nameplate", "VerticalSpacing", L["NP VerticalSpacing"].."*", true, {.5, 2.5, .1}, updatePlateCVars},
		{3, "Nameplate", "MinScale", L["Nameplate MinScale"].."*", nil, {.5, 1, .1}, updatePlateCVars},
		{3, "Nameplate", "MinAlpha", L["Nameplate MinAlpha"].."*", true, {.3, 1, .1}, updatePlateCVars},
	},
	[6] = {
		{1, "Nameplate", "ShowPlayerPlate", HeaderTag..L["Enable PlayerPlate"].."*", nil, nil, togglePlayerPlate},
		{1, "Nameplate", "TargetPower", HeaderTag..L["TargetClassPower"].."*", true, nil, toggleTargetClassPower},
		{}, -- blank
		{1, "Avada", "Enable", IsNew..HeaderTag..L["Enable ClassAuras"].."*", nil, toggleAvadaGUI, toggleAvada},
		{1, "Nameplate", "PPFadeout", L["PlayerPlate Fadeout"].."*", true, nil, togglePlateVisibility},
		{1, "Nameplate", "PPPowerText", L["PlayerPlate PowerText"].."*", nil, nil, togglePlatePower},
		{1, "Nameplate", "PPGCDTicker", L["PlayerPlate GCDTicker"].."*", nil, nil, toggleGCDTicker},
		{3, "Nameplate", "PPFadeoutAlpha", L["PlayerPlate FadeoutAlpha"].."*", true, {0, .5, .05}, togglePlateVisibility},
		{}, -- blank
		{3, "Nameplate", "PPWidth", L["Width"].."*", false, {100, 500, 1}, refreshNameplates},
		{3, "Nameplate", "PPBarHeight", L["PlayerPlate CPHeight"].."*", true, {2, 15, 1}, refreshNameplates},
		{3, "Nameplate", "PPHealthHeight", L["PlayerPlate HPHeight"].."*", false, {2, 15, 1}, refreshNameplates},
		{3, "Nameplate", "PPPowerHeight", L["PlayerPlate MPHeight"].."*", true, {2, 15, 1}, refreshNameplates},
	},
	[7] = {
		{1, "Auras", "BuffFrame", HeaderTag..L["BuffFrame"], nil, setupBuffFrame, nil, L["BuffFrameTip"]},
		{1, "Auras", "HideBlizBuff", L["HideBlizUI"], true, nil, nil, L["HideBlizBuffTip"]},
		{}, -- blank
		{1, "AuraWatch", "Enable", HeaderTag..L["Enable AuraWatch"], nil, setupAuraWatch},
		{1, "AuraWatch", "DeprecatedAuras", L["DeprecatedAuras"], true},
		{1, "AuraWatch", "ClickThrough", L["AuraWatch ClickThrough"], nil, nil, nil, L["ClickThroughTip"]},
		{3, "AuraWatch", "IconScale", L["AuraWatch IconScale"], nil, {.8, 2, .1}},
		{3, "AuraWatch", "MinCD", L["AuraWatch MinCD"].."*", true, {1, 60, 1}, nil, L["MinCDTip"]},
		{}, -- blank
		{1, "Auras", "Totems", HeaderTag..L["Enable Totembar"]},
		{1, "Auras", "VerticalTotems", L["VerticalTotems"].."*", nil, nil, refreshTotemBar},
		{3, "Auras", "TotemSize", L["TotemSize"].."*", true, {24, 60, 1}, refreshTotemBar},
		{}, -- blank
		{1, "Auras", "Reminder", L["Enable Reminder"].."*", nil, nil, updateReminder, L["ReminderTip"]},
	},
	[8] = {
		{1, "Misc", "RaidTool", HeaderTag..L["Raid Manger"]},
		{1, "Misc", "RMRune", L["Runes Check"].."*", true},
		{4, "Misc", "EasyMarkKey", L["EasyMark"].."*", nil, {"CTRL", "ALT", "SHIFT", DISABLE}, nil, L["EasyMarkTip"]},
		{2, "Misc", "DBMCount", L["DBMCount"].."*", true, nil, nil, L["DBMCountTip"]},
		{4, "Misc", "ShowMarkerBar", L["ShowMarkerBar"].."*", nil, {L["Grids"], L["Horizontal"], L["Vertical"], DISABLE}, updateMarkerGrid, L["ShowMarkerBarTip"]},
		{3, "Misc", "MarkerSize", L["MarkerSize"].."*", true, {20, 50, 1}, updateMarkerGrid},
		{}, -- blank
		{1, "Misc", "QuestNotification", HeaderTag..L["QuestNotification"].."*", nil, nil, updateQuestNotification},
		{1, "Misc", "QuestProgress", L["QuestProgress"].."*"},
		{1, "Misc", "OnlyCompleteRing", L["OnlyCompleteRing"].."*", true, nil, nil, L["OnlyCompleteRingTip"]},
		{}, -- blank
		{1, "Misc", "InterruptAlert", HeaderTag..L["InterruptAlert"].."*", nil, nil, updateInterruptAlert},
		{1, "Misc", "OwnInterrupt", L["OwnInterrupt"].."*", true},
		{1, "Misc", "DispellAlert", HeaderTag..L["DispellAlert"].."*", nil, nil, updateInterruptAlert},
		{1, "Misc", "OwnDispell", L["OwnDispell"].."*", true},
		{1, "Misc", "BrokenAlert", HeaderTag..L["BrokenAlert"].."*", nil, nil, updateInterruptAlert, L["BrokenAlertTip"]},
		{1, "Misc", "InstAlertOnly", L["InstAlertOnly"].."*", true, nil, updateInterruptAlert, L["InstAlertOnlyTip"]},
		{1, "Misc", "SpellItemAlert", HeaderTag..L["SpellItemAlert"].."*", nil, nil, updateSpellItemAlert, L["SpellItemAlertTip"]},
		{1, "Misc", "LeaderOnly", IsNew..L["LeaderOnly"].."*", true, nil, nil, L["LeaderOnlyTip"]},
		{}, -- blank
		{1, "Misc", "NzothVision", L["NzothVision"]},
		{1, "Misc", "SoloInfo", L["SoloInfo"].."*", true, nil, updateSoloInfo},
		{}, -- blank
		{1, "Misc", "RareAlerter", HeaderTag..L["Rare Alert"].."*", nil, nil, updateRareAlert},
		{1, "Misc", "RareAlertInWild", L["RareAlertInWild"].."*"},
		{2, "ACCOUNT", "IgnoredRares", IsNew..L["IgnoredRares"].."*", true, nil, updateIgnoredRares, L["IgnoredRaresTip"]},
	},
	[9] = {
		{1, "Chat", "Lock", HeaderTag..L["Lock Chat"]},
		{3, "Chat", "ChatWidth", L["LockChatWidth"].."*", nil, {200, 600, 1}, updateChatSize},
		{3, "Chat", "ChatHeight", L["LockChatHeight"].."*", true, {100, 500, 1}, updateChatSize},
		{}, -- blank
		{4, "ACCOUNT", "TimestampFormat", L["TimestampFormat"].."*", nil, {DISABLE, "03:27 PM", "03:27:32 PM", "15:27", "15:27:32"}},
		{4, "Chat", "ChatBGType", L["ChatBGType"].."*", true, {DISABLE, L["Default Dark"], L["Gradient"]}, toggleChatBackground},
		{1, "Chat", "Oldname", L["Default Channel"]},
		{1, "Chat", "Sticky", L["Chat Sticky"].."*", nil, nil, updateChatSticky},
		{3, "Chat", "EditFont", L["EditFont"].."*", true, {10, 30, 1}, toggleEditBoxAnchor},
		{1, "Chat", "Chatbar", L["ShowChatbar"]},
		{1, "Chat", "WhisperColor", L["Differ WhisperColor"].."*", true},
		{1, "Chat", "ChatItemLevel", L["ShowChatItemLevel"]},
		{1, "Chat", "Freedom", L["Language Filter"].."*", true, nil, toggleLanguageFilter},
		{1, "Chat", "WhisperSound", L["WhisperSound"].."*", nil, nil, nil, L["WhisperSoundTip"]},
		{1, "Chat", "BottomBox", L["BottomBox"].."*", true, nil, toggleEditBoxAnchor},
		{1, "Chat", "SysFont", L["SysFont"], nil, nil, nil, L["SysFontTip"]},
		{}, -- blank
		{1, "Chat", "EnableFilter", HeaderTag..L["Enable Chatfilter"]},
		{1, "Chat", "BlockAddonAlert", L["Block Addon Alert"], true},
		{1, "Chat", "BlockSpammer", L["BlockSpammer"].."*", nil, nil, nil, L["BlockSpammerTip"]},
		{1, "Chat", "BlockStranger", "|cffFF0000"..L["BlockStranger"].."*", nil, nil, nil, L["BlockStrangerTip"]},
		{2, "ACCOUNT", "ChatFilterWhiteList", HeaderTag..L["ChatFilterWhiteList"].."*", true, nil, updateFilterWhiteList, L["ChatFilterWhiteListTip"]},
		{3, "Chat", "Matches", L["Keyword Match"].."*", false, {1, 3, 1}},
		{2, "ACCOUNT", "ChatFilterList", L["Filter List"].."*", true, nil, updateFilterList, L["FilterListTip"]},
		{}, -- blank
		{1, "Chat", "Invite", HeaderTag..L["Whisper Invite"]},
		{1, "Chat", "GuildInvite", L["Guild Invite Only"].."*"},
		{2, "Chat", "Keyword", L["Whisper Keyword"].."*", true, nil, updateWhisperList, L["WhisperKeywordTip"]},
	},
	[10] = {
		{1, "Map", "DisableMap", "|cffFF0000"..L["DisableMap"], nil, nil, nil, L["DisableMapTip"]},
		{1, "Map", "MapRevealGlow", L["MapRevealGlow"].."*", true, nil, nil, L["MapRevealGlowTip"]},
		{3, "Map", "MapScale", L["Map Scale"].."*", false, {.8, 2, .1}},
		{3, "Map", "MaxMapScale", L["Maximize Map Scale"].."*", true, {.5, 1, .1}},
		{}, -- blank
		{1, "Map", "DisableMinimap", "|cffFF0000"..L["DisableMinimap"], nil, nil, nil, L["DisableMinimapTip"]},
		{3, "Map", "MinimapScale", L["Minimap Scale"].."*", nil, {.5, 3, .1}, updateMinimapScale},
		{3, "Map", "MinimapSize", L["Minimap Size"].."*", true, {100, 500, 1}, updateMinimapScale},
		{1, "Map", "Calendar", L["MinimapCalendar"].."*", nil, nil, showCalendar, L["MinimapCalendarTip"]},
		{1, "Map", "Clock", L["Minimap Clock"].."*", true, nil, showMinimapClock},
		{1, "Map", "CombatPulse", L["Minimap Pulse"]},
		{1, "Map", "WhoPings", L["Show WhoPings"], true},
		{1, "Map", "EasyVolume", L["EasyVolume"], nil, nil, nil, L["EasyVolumeTip"]},
		{1, "Misc", "ExpRep", L["Show Expbar"], true},
		{1, "Map", "ShowRecycleBin", L["Show RecycleBin"]},
		{2, "ACCOUNT", "IgnoredButtons", L["IgnoredButtons"], nil, nil, nil, L["IgnoredButtonsTip"]},
	},
	[11] = {
		{1, "Skins", "BlizzardSkins", HeaderTag..L["BlizzardSkins"], nil, nil, nil, L["BlizzardSkinsTips"]},
		{}, -- blank
		{1, "Skins", "Shadow", L["Shadow"]},
		{1, "Skins", "FontOutline", L["FontOutline"], true},
		{1, "Skins", "BgTex", L["BgTex"]},
		{1, "Skins", "CustomBD", L["CustomBD"], true, nil, nil, L["CustomBDColorTip"]},
		{5, "Skins", "CustomBDColor", L["CustomBDColor"], 3},
		{3, "Skins", "SkinAlpha", L["SkinAlpha"].."*", nil, {0, 1, .05}, updateSkinAlpha},
		{3, "Skins", "FontScale", L["GlobalFontScale"], true, {.5, 1.5, .05}},
		{}, -- blank
		{1, "Skins", "ClassLine", L["ClassColor Line"], nil, nil, nil, L["ClassColor Line Tip"]},
		{1, "Skins", "InfobarLine", L["Infobar Line"], true},
		{1, "Skins", "ChatbarLine", L["Chat Line"]},
		{1, "Skins", "MenuLine", L["Menu Line"], true},
		{}, -- blank
		{1, "Skins", "Skada", L["Skada Skin"]},
		{1, "Skins", "Details", L["Details Skin"], nil, resetDetails},
		{4, "Skins", "ToggleDirection", L["ToggleDirection"].."*", true, {L["LEFT"], L["RIGHT"], L["TOP"], L["BOTTOM"], DISABLE}, updateToggleDirection},
		{}, -- blank
		{1, "Skins", "DBM", L["DBM Skin"]},
		{1, "Skins", "Bigwigs", L["Bigwigs Skin"], true},
		{1, "Skins", "TMW", L["TMW Skin"]},
		{1, "Skins", "WeakAuras", L["WeakAuras Skin"], true},
	},
	[12] = {
		{3, "Tooltip", "Scale", L["Tooltip Scale"].."*", nil, {.5, 1.5, .1}},
		{4, "Tooltip", "TipAnchor", L["TipAnchor"].."*", true, {L["TOPLEFT"], L["TOPRIGHT"], L["BOTTOMLEFT"], L["BOTTOMRIGHT"]}, nil, L["TipAnchorTip"]},
		{4, "Tooltip", "HideInCombat", L["HideInCombat"].."*", nil, {DISABLE, "ALT", "SHIFT", "CTRL", ALWAYS}, nil, L["HideInCombatTip"]},
		{4, "Tooltip", "CursorMode", L["Follow Cursor"].."*", true, {DISABLE, L["LEFT"], L["TOP"], L["RIGHT"]}},
		{1, "Tooltip", "MythicScore", L["MDScore"].."*", nil, nil, nil, L["MDScoreTip"]},
		{1, "Tooltip", "HideAllID", "|cffFF0000"..L["HideAllID"], true},
		{}, -- blank
		{1, "Tooltip", "AzeriteArmor", HeaderTag..L["Show AzeriteArmor"]},
		{1, "Tooltip", "OnlyArmorIcons", L["Armor icons only"].."*", true},
	},
	[13] = {
		{1, "Misc", "ItemLevel", HeaderTag..L["Show ItemLevel"], nil, nil, nil, L["ItemLevelTip"]},
		{1, "Misc", "MissingStats", HeaderTag..L["Show MissingStats"], true},
		{1, "Misc", "GemNEnchant", L["Show GemNEnchant"].."*"},
		{1, "Misc", "AzeriteTraits", L["Show AzeriteTraits"].."*", true},
		{}, -- blank
		{1, "Misc", "HideTalking", L["No Talking"]},
		{1, "ACCOUNT", "AutoBubbles", L["AutoBubbles"], true},
		{1, "Misc", "HideBossEmote", L["HideBossEmote"].."*", nil, nil, toggleBossEmote},
		{1, "Misc", "HideBossBanner", L["Hide Bossbanner"].."*", true, nil, toggleBossBanner},
		{1, "Misc", "InstantDelete", L["InstantDelete"].."*"},
		{1, "Misc", "FasterLoot", L["Faster Loot"].."*", true, nil, updateFasterLoot},
		{1, "Misc", "BlockInvite", "|cffFF0000"..L["BlockInvite"].."*", nil, nil, nil, L["BlockInviteTip"]},
		{1, "Misc", "FasterSkip", L["FasterMovieSkip"].."*", true, nil, nil, L["FasterMovieSkipTip"]},
		{1, "Misc", "BlockRequest", "|cffFF0000"..L["BlockRequest"].."*", nil, nil, nil, L["BlockRequestTip"]},
		{1, "Misc", "AutoConfirm", L["AutoConfirm"], true},
		{1, "Misc", "Mail", L["Mail Tool"]},
		{1, "Misc", "TradeTabs", L["TradeTabs"], true},
		{1, "Misc", "PetFilter", L["Show PetFilter"]},
		{1, "Misc", "Screenshot", L["Auto ScreenShot"].."*", true, nil, updateScreenShot},
		{1, "Misc", "Focuser", L["Easy Focus"]},
		{1, "Misc", "MDGuildBest", L["MDGuildBest"], true, nil, nil, L["MDGuildBestTip"]},
		{1, "Misc", "MenuButton", L["MenuButton"], nil, nil, nil, L["MenuButtonTip"]},
		{1, "Misc", "EnhanceDressup", L["EnhanceDressup"], true, nil, nil, L["EnhanceDressupTip"]},
		{1, "Misc", "QuestTool", L["QuestTool"], nil, nil, nil, L["QuestToolTip"]},
		{1, "Misc", "QuickJoin", HeaderTag..L["EnhancedPremade"], nil, nil, nil, L["EnhancedPremadeTip"]},
		{3, "Misc", "MaxZoom", L["MaxZoom"].."*", true, {1, 2.6, .1}, updateMaxZoomLevel},
		{1, "Misc", "SingingSocket", IsNew..L["SingingSocket"], nil, nil, nil, L["SingingSocketTip"]},
	},
	[14] = {
		{1, "ACCOUNT", "VersionCheck", L["Version Check"]},
		{1, "ACCOUNT", "LockUIScale", L["Lock UIScale"]},
		{3, "ACCOUNT", "UIScale", L["Setup UIScale"], true, {.4, 1.15, .01}},
		{}, -- blank
		{1, "ACCOUNT", "DisableInfobars", "|cffFF0000"..L["DisableInfobars"]},
		{3, "Misc", "MaxAddOns", L["SysMaxAddOns"].."*", nil,  {1, 50, 1}, nil, L["SysMaxAddOnsTip"]},
		{3, "Misc", "InfoSize", L["InfobarFontSize"].."*", true,  {10, 50, 1}, updateInfobarSize},
		{2, "Misc", "InfoStrLeft", L["LeftInfobar"].."*", nil, nil, updateInfobarAnchor, L["InfobarStrTip"]},
		{2, "Misc", "InfoStrRight", L["RightInfobar"].."*", true, nil, updateInfobarAnchor, L["InfobarStrTip"]},
		{}, -- blank
		{4, "ACCOUNT", "TexStyle", L["Texture Style"], false, {}},
		{4, "ACCOUNT", "NumberFormat", L["Numberize"], true, {L["Number Type1"], L["Number Type2"], L["Number Type3"]}},
		{2, "ACCOUNT", "CustomTex", L["CustomTex"], nil, nil, nil, L["CustomTexTip"]},
		{3, "ACCOUNT", "SmoothAmount", L["SmoothAmount"].."*", true, {.1, 1, .05}, updateSmoothingAmount, L["SmoothAmountTip"]},
	},
	[15] = {
	},
}

local function SelectTab(i)
	for num = 1, #G.TabList do
		if num == i then
			guiTab[num].__bg:SetBackdropColor(cr, cg, cb, .25)
			guiTab[num].checked = true
			guiPage[num]:Show()
		else
			guiTab[num].__bg:SetBackdropColor(0, 0, 0, 0)
			guiTab[num].checked = false
			guiPage[num]:Hide()
		end
	end
end

local function tabOnClick(self)
	PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK)
	SelectTab(self.index)
end

local function CreateTab(parent, i, name)
	local tab = CreateFrame("Button", nil, parent, "BackdropTemplate")
	tab:SetPoint("TOPLEFT", 20, -30*i - 20 + C.mult)
	tab:SetSize(130, 28)
	B.ReskinButton(tab)
	B.CreateFS(tab, 15, name, "system", "LEFT", 10, 0)
	tab.index = i

	tab:SetScript("OnClick", tabOnClick)

	return tab
end

local function CheckUIOption(key, value, newValue)
	if key == "ACCOUNT" then
		if newValue ~= nil then
			NDuiADB[value] = newValue
		else
			return NDuiADB[value]
		end
	else
		if newValue ~= nil then
			C.db[key][value] = newValue
		else
			return C.db[key][value]
		end
	end
end

G.needUIReload = nil

local function CheckUIReload(name)
	if not string.find(name, "%*") then
		G.needUIReload = true
	end
end

local function onCheckboxClick(self)
	CheckUIOption(self.__key, self.__value, self:GetChecked())
	CheckUIReload(self.__name)
	if self.__callback then self:__callback() end
end

local function restoreEditbox(self)
	self:SetText(CheckUIOption(self.__key, self.__value))
end
local function acceptEditbox(self)
	CheckUIOption(self.__key, self.__value, self:GetText())
	CheckUIReload(self.__name)
	if self.__callback then self:__callback() end
end

local function onSliderChanged(self, v)
	local current = B:Round(tonumber(v), 2)
	CheckUIOption(self.__key, self.__value, current)
	CheckUIReload(self.__name)
	self.value:SetText(current)
	if self.__callback then self:__callback() end
end

local function updateDropdownSelection(self)
	local dd = self.__owner
	for i = 1, #dd.__options do
		local option = dd.options[i]
		if i == CheckUIOption(dd.__key, dd.__value) then
			option:SetBackdropColor(1, 1, 0, .25)
			option.selected = true
		else
			option:SetBackdropColor(0, 0, 0, .25)
			option.selected = false
		end
	end
end
local function updateDropdownClick(self)
	local dd = self.__owner
	CheckUIOption(dd.__key, dd.__value, self.index)
	CheckUIReload(dd.__name)
	if dd.__callback then dd:__callback() end
end

local function CreateOption(i)
	local parent, offset = guiPage[i].child, 20

	for _, option in pairs(G.OptionList[i]) do
		local optType, key, value, name, horizon, data, callback, tooltip, disabled = unpack(option)
		local isNew
		if name then
			local rawName, hasNew = string.gsub(name, "ISNEW", "")
			name = rawName
			if hasNew > 0 then isNew = true end
		end

		-- Checkboxes
		if optType == 1 then
			local cb = B.CreateCheckBox(parent)
			if horizon then
				cb:SetPoint("TOPLEFT", 330, -offset + 35)
			else
				cb:SetPoint("TOPLEFT", 20, -offset)
				offset = offset + 35
			end
			cb.__key = key
			cb.__value = value
			cb.__name = name
			cb.__callback = callback
			cb.name = B.CreateFS(cb, 14, name, false, "LEFT", 30, 0)
			if isNew then AddNewTag(cb, cb.name) end
			cb:SetChecked(CheckUIOption(key, value))
			cb:SetScript("OnClick", onCheckboxClick)
			if data and type(data) == "function" then
				local bu = B.CreateGear(parent)
				bu:SetPoint("LEFT", cb.name, "RIGHT", -2, 1)
				bu:SetScript("OnClick", data)
			end
			if tooltip then
				B.AddTooltip(cb, "ANCHOR_RIGHT", tooltip, "info", true)
			end
			if disabled then cb:Hide() end
		-- Editbox
		elseif optType == 2 then
			local eb = B.CreateEditBox(parent, 200, 28)
			eb:SetMaxLetters(999)
			eb.__key = key
			eb.__value = value
			eb.__name = name
			eb.__callback = callback
			eb.__default = (key == "ACCOUNT" and G.AccountSettings[value]) or G.DefaultSettings[key][value]
			if horizon then
				eb:SetPoint("TOPLEFT", 345, -offset + 45)
			else
				eb:SetPoint("TOPLEFT", 35, -offset - 25)
				offset = offset + 70
			end
			eb:SetText(CheckUIOption(key, value))
			eb:HookScript("OnEscapePressed", restoreEditbox)
			eb:HookScript("OnEnterPressed", acceptEditbox)

			local fs = B.CreateFS(eb, 14, name, "system", "CENTER", 0, 25)
			if isNew then AddNewTag(eb, fs) end
			local tip = L["EditBox Tip"]
			if tooltip then tip = tooltip.."|n"..tip end
			B.AddTooltip(eb, "ANCHOR_RIGHT", tip, "info", true)
		-- Slider
		elseif optType == 3 then
			local min, max, step = unpack(data)
			local x, y
			if horizon then
				x, y = 350, -offset + 40
			else
				x, y = 40, -offset - 30
				offset = offset + 70
			end
			local s = B.CreateSlider(parent, name, min, max, step, x, y)
			if isNew then AddNewTag(s, s.Text) end
			s.__key = key
			s.__value = value
			s.__name = name
			s.__callback = callback
			s.__default = (key == "ACCOUNT" and G.AccountSettings[value]) or G.DefaultSettings[key][value]
			s:SetValue(CheckUIOption(key, value))
			s:SetScript("OnValueChanged", onSliderChanged)
			s.value:SetText(B:Round(CheckUIOption(key, value), 2))
			if tooltip then
				B.AddTooltip(s, "ANCHOR_RIGHT", tooltip, "info", true)
			end
		-- Dropdown
		elseif optType == 4 then
			if value == "TexStyle" then
				for _, v in ipairs(G.TextureList) do
					table.insert(data, v.name)
				end
			end

			local dd = B.CreateDropDown(parent, 200, 28, data)
			if horizon then
				dd:SetPoint("TOPLEFT", 345, -offset + 45)
			else
				dd:SetPoint("TOPLEFT", 35, -offset - 25)
				offset = offset + 70
			end
			dd.Text:SetText(data[CheckUIOption(key, value)])
			dd.__key = key
			dd.__value = value
			dd.__name = name
			dd.__options = data
			dd.__callback = callback
			dd.button.__owner = dd
			dd.button:HookScript("OnClick", updateDropdownSelection)

			for i = 1, #data do
				dd.options[i]:HookScript("OnClick", updateDropdownClick)
				if value == "TexStyle" then
					AddTextureToOption(dd.options, i) -- texture preview
				end
			end

			local fs = B.CreateFS(dd, 14, name, "system", "CENTER", 0, 25)
			if isNew then AddNewTag(dd, fs) end
			if tooltip then
				B.AddTooltip(dd, "ANCHOR_RIGHT", tooltip, "info", true)
			end
		-- Colorswatch
		elseif optType == 5 then
			local swatch = B.CreateColorSwatch(parent, name, CheckUIOption(key, value))
			if isNew then AddNewTag(swatch) end
			local width = 25 + (horizon or 0)*155
			if horizon then
				swatch:SetPoint("TOPLEFT", width, -offset + 31)
			else
				swatch:SetPoint("TOPLEFT", width, -offset - 4)
				offset = offset + 35
			end
			swatch.__default = (key == "ACCOUNT" and G.AccountSettings[value]) or G.DefaultSettings[key][value]
		-- Blank, no optType
		else
			if not key then
				local line = B.SetGradient(parent, "H", 1, 1, 1, DB.alpha, DB.alpha, 560, C.mult)
				line:SetPoint("TOPLEFT", 25, -offset - 12)
			end
			offset = offset + 35
		end
	end

	local footer = CreateFrame("Frame", nil, parent)
	footer:SetSize(20, 20)
	footer:SetPoint("TOPLEFT", 25, -offset)
end

local function resetUrlBox(self)
	self:SetText(self.url)
	self:HighlightText()
end

local function CreateContactBox(parent, text, url, index)
	B.CreateFS(parent, 14, text, "system", "TOP", 0, -50 - (index-1) * 60)
	local box = B.CreateEditBox(parent, 250, 24)
	box:SetPoint("TOP", 0, -70 - (index-1) * 60)
	box.url = url
	resetUrlBox(box)
	box:SetScript("OnTextChanged", resetUrlBox)
	box:SetScript("OnCursorChanged", resetUrlBox)
end

local donationList = {
	["爱发电"] = "33578473, normanvon, y368413, EK, msylgj, 夜丨灬清寒, akakai, reisen410, 其实你很帥, 萨菲尔, Antares, RyanZ, fldqw, Mario, 时光旧予, 食铁骑兵, 爱蕾丝的基总, 施然, 命运镇魂曲, 不可语上, Leo(En-布鲁), 忘川, 刘翰承, 悟空海外党, cncj, 暗月, 汪某人, 黑手, iraq120, 嗜血未冷, 我又不是妖怪, 养乐多, 无人知晓, 秋末旷夜-迪瑟洛克, Teo, 莉拉斯塔萨, 音尘绝, 刺王杀驾, 醉跌-凤凰之神, 灬麦加灬-阿古斯, 漂舟不系, 朵小熙, 山岸逢花, 乄阿财-帕奇维克, 乌鸦岭守墓饼-罗宁, 自在独踽踽-霜之哀伤, 御行宇航-碧玉矿洞, 末日伯爵-奥罗, 阿玛忆-白银之手, 零氪-罗宁, 粉色刘老头-黑曜石之锋, shadowlezi, 風雲再起-帕奇维克, congfeng, 东叫兽, solor, DC_Doraemon, 不明飞行物，Seraphinee-冰风岗，怜悯，小甜甜赵顶天-贫瘠之地，浅羽凝-湖畔镇，十方-火妖，科比小迷弟-哈霍兰，信仰之业-霜之哀伤，喷大水丶-奥罗，卓越，白色恶魔-风行者，Shadowbaner-死亡之翼，霸亡别姬-埃提耶什，惊雪-遗忘海岸，Ayukawa-布鲁，天天洗澡-德姆塞卡尔，江表之力牧-碧玉矿洞，射鸡大师-灰烬使者，星辰花，玛拉的万花筒-埃苏雷格，园城寺怜-维希度斯，泽尔里奇-席瓦莱恩，孤木不似林-无尽之海，悪夢灬旧城-伊森利恩，逸星-匕首岭，假胯宽不宽-哈霍兰，农富三拳-燃烧之刃，蛮多基尔-夏挚生，喻大脑壳-维希度斯，岁月碎月-法尔班克斯，随性丶丶-安苏，陈一发儿丷-死亡之翼，东谐西毒-祈福，大洋大洋大洋-厄运之槌，Spritejj-安苏，Kyrielight-憤怒使者，十六爸爸-巨人追猎者，一白夜一-燃烧之刃，一瓶东方树叶-怒炉，你乖一点-格瑞姆巴托，Zev-席瓦莱恩，大黑手丶-燃烧之刃，偶爾琳琳雨-暗影之月(亚服)，琉璃绯雪，片山城西-世界之树，江城之下-寒冰皇冠, 楓聖御雷，神奇的胖虎，北宸，清风徐來，步履望星辰丶，Spiritcivet-Atiesh(美服)，Kaguya, Nataly-希瓦莱恩，露露缇娅丶-霜语，Rena，z3gws555，贴饼子-罗宁，有点儿-凤凰之神，秋末旷叶-凤凰之神，星霜-试炼之环，维拉奥力-主宰之剑，Ericyyds-Aegwynn，左佐佑-奥尔加隆，Nickreborn，钛锬-罗宁，清风徐來-罗宁，索德列斯-白银之手以及部分未备注名字的用户。",
	["Patreon"] = "Quentin, Julian Neigefind, silenkin, imba Villain, Zeyu Zhu, Kon Floros, Distortedmind87, Boldboy, taelle.",
	["CurseForge"] = "A world of endless gaming possibilities for modders and gamers alike.|n|nKeep your NDui update to date.",
	["新手盒子"] = "集插件更新工具和游戏助手为一体！|n|n你可以在此更新你的NDui",
	["海豚加速器"] = "新用户7天畅游兑换码: |nndui",
}
local function CreateDonationIcon(parent, texture, name, xOffset)
	local button = B.CreateButton(parent, 30, 30, true, texture)
	button:SetPoint("BOTTOMLEFT", xOffset, 10)
	button.title = name
	B.AddTooltip(button, "ANCHOR_TOP", "|n"..donationList[name], "info")
end

function G:AddContactFrame()
	if G.ContactFrame then G.ContactFrame:Show() return end

	local frame = CreateFrame("Frame", nil, UIParent)
	frame:SetSize(300, 300)
	frame:SetPoint("CENTER")
	B.SetBD(frame)
	B.CreateWatermark(frame)

	B.CreateFS(frame, 16, L["Contact"], true, "TOP", 0, -10)
	local ll = B.SetGradient(frame, "H", 1, 1, 1, 0, DB.alpha, 80, C.mult)
	ll:SetPoint("TOP", -40, -32)
	local lr = B.SetGradient(frame, "H", 1, 1, 1, DB.alpha, 0, 80, C.mult)
	lr:SetPoint("TOP", 40, -32)

	CreateContactBox(frame, "NGA.CN", "https://bbs.nga.cn/read.php?tid=5483616", 1)
	CreateContactBox(frame, "GitHub", "https://github.com/siweia/NDui", 2)
	CreateContactBox(frame, "Discord", "https://discord.gg/WXgrfBm", 3)

	local back = B.CreateButton(frame, 120, 20, OKAY)
	back:SetPoint("BOTTOM", 0, 15)
	back:SetScript("OnClick", function() frame:Hide() end)

	G.ContactFrame = frame
end

local function scrollBarHook(self, delta)
	local scrollBar = self.ScrollBar
	scrollBar:SetValue(scrollBar:GetValue() - delta*35)
end

StaticPopupDialogs["RELOAD_NDUI"] = {
	text = L["ReloadUI Required"],
	button1 = APPLY,
	button2 = CLASS_TRIAL_THANKS_DIALOG_CLOSE_BUTTON,
	OnAccept = function()
		ReloadUI()
	end,
}

function G:AddSponsor()
	CreateDonationIcon(f, DB.afdianTex, "爱发电", 160)
	CreateDonationIcon(f, DB.patreonTex, "Patreon", 200)
	CreateDonationIcon(f, DB.curseforgeTex, "CurseForge", 240)
	if DB.Client == "zhCN" or DB.Client == "zhTW" then
		CreateDonationIcon(f, DB.boxTex, "新手盒子", 280)
	end
end

local function OpenGUI()
	if f then f:Show() return end

	-- Main Frame
	f = CreateFrame("Frame", "NDuiGUI", UIParent)
	table.insert(UISpecialFrames, "NDuiGUI")
	f:SetSize(800, 600)
	f:SetPoint("CENTER")
	f:SetFrameStrata("HIGH")
	B.CreateMF(f)
	B.SetBD(f)
	B.CreateFS(f, 18, L["NDui Console"], true, "TOP", 0, -10)
	B.CreateFS(f, 16, DB.Version.." ("..DB.Support..")", false, "TOP", 0, -30)

	local contact = B.CreateButton(f, 130, 20, L["Contact"])
	contact:SetPoint("BOTTOMLEFT", 20, 15)
	contact:SetScript("OnClick", function()
		f:Hide()
		G:AddContactFrame()
	end)

	local unlock = B.CreateButton(f, 130, 20, L["UnlockUI"])
	unlock:SetPoint("BOTTOM", contact, "TOP", 0, 2)
	unlock:SetScript("OnClick", function()
		f:Hide()
		SlashCmdList["NDUI_MOVER"]()
	end)

	local close = B.CreateButton(f, 80, 20, CLOSE)
	close:SetPoint("BOTTOMRIGHT", -20, 15)
	close:SetScript("OnClick", function() f:Hide() end)

	local ok = B.CreateButton(f, 80, 20, OKAY)
	ok:SetPoint("RIGHT", close, "LEFT", -5, 0)
	ok:SetScript("OnClick", function()
		B:SetupUIScale()
		f:Hide()
		if G.needUIReload then
			StaticPopup_Show("RELOAD_NDUI")
			G.needUIReload = nil
		end
	end)

	G:AddSponsor()

	for i, name in pairs(G.TabList) do
		local rawName, isNew = string.gsub(name, "ISNEW", "")
		guiTab[i] = CreateTab(f, i, rawName)
		if isNew > 0 then AddNewTag(guiTab[i]) end

		guiPage[i] = CreateFrame("ScrollFrame", nil, f, "UIPanelScrollFrameTemplate")
		guiPage[i]:SetPoint("TOPLEFT", 160, -50)
		guiPage[i]:SetSize(610, 500)
		B.CreateBDFrame(guiPage[i], .25)
		guiPage[i]:Hide()
		guiPage[i].child = CreateFrame("Frame", nil, guiPage[i])
		guiPage[i].child:SetSize(610, 1)
		guiPage[i]:SetScrollChild(guiPage[i].child)
		B.ReskinScroll(guiPage[i].ScrollBar)
		guiPage[i]:SetScript("OnMouseWheel", scrollBarHook)

		CreateOption(i)
	end

	G:CreateProfileGUI(guiPage[15]) -- profile GUI
	G:SetupActionbarStyle(guiPage[1])

	local helpInfo = B.CreateHelpInfo(f, L["Option* Tips"])
	helpInfo:SetPoint("TOPLEFT", 20, -5)
	local guiHelpInfo = {
		text = L["GUIPanelHelp"],
		buttonStyle = HelpTip.ButtonStyle.GotIt,
		targetPoint = HelpTip.Point.LeftEdgeCenter,
		onAcknowledgeCallback = B.HelpInfoAcknowledge,
		callbackArg = "GUIPanel",
	}
	if not NDuiADB["Help"]["GUIPanel"] then
		HelpTip:Show(helpInfo, guiHelpInfo)
	end

	local credit = CreateFrame("Button", nil, f)
	credit:SetPoint("TOPRIGHT", -20, -5)
	credit:SetSize(40, 40)
	credit.Icon = credit:CreateTexture(nil, "ARTWORK")
	credit.Icon:SetAllPoints()
	credit.Icon:SetTexture(DB.creditTex)
	credit:SetHighlightTexture(DB.creditTex)
	credit.title = "Credits"
	B.AddTooltip(credit, "ANCHOR_BOTTOMLEFT", "|n"..C_AddOns.GetAddOnMetadata("NDui", "X-Credits"), "info")

	local function showLater(event)
		if event == "PLAYER_REGEN_DISABLED" then
			if f:IsShown() then
				f:Hide()
				B:RegisterEvent("PLAYER_REGEN_ENABLED", showLater)
			end
		else
			f:Show()
			B:UnregisterEvent(event, showLater)
		end
	end
	B:RegisterEvent("PLAYER_REGEN_DISABLED", showLater)

	SelectTab(1)
end

function G:OnLogin()
	local function toggleGUI()
		if InCombatLockdown() then UIErrorsFrame:AddMessage(DB.InfoColor..ERR_NOT_IN_COMBAT) return end
		OpenGUI()
		HideUIPanel(GameMenuFrame)
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
	end

	hooksecurefunc(GameMenuFrame, "InitButtons", function(self)
		self:AddButton("|T"..DB.chatLogo..":12:24|t |cff0080FFNDui|r", toggleGUI)

		for button in self.buttonPool:EnumerateActive() do
			if not button.resized then
				button:SetNormalFontObject("GameFontHighlight")
				button:SetHighlightFontObject("GameFontHighlight")
				button:SetDisabledFontObject("GameFontDisable")
				button:SetSize(160, 25)

				button.resized = true
			end
		end
	end)
end