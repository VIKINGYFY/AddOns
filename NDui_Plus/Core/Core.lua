local AddOnName, ns = ...
local B, C, L, DB, P = unpack(ns)

local pairs, type, next= pairs, type, next
local tinsert = table.insert
local xpcall = xpcall

local modules, initQueue, addonsToLoad, addonsToLoadEarly = {}, {}, {}, {}

P.DefaultSettings = {
	Debug = false,
	Changelog = {
		Version = "",
	},
	TexStyle = {
		Enable = false,
		Texture = "NDui_Plus",
		Index = 0,
	},
	RoleStyle = {
		Enable = false,
		Index = 1,
	},
	ActionBar = {
		FinisherGlow = false,
		GlobalFade = false,
		Alpha = .1,
		Delay = 0,
		Combat = true,
		Target = true,
		Casting = true,
		Health = true,
		Vehicle = true,
		DynamicFlight = true,
		Bar1 = false,
		Bar2 = false,
		Bar3 = false,
		Bar4 = false,
		Bar5 = false,
		Bar6 = false,
		Bar7 = false,
		Bar8 = false,
		PetBar = false,
		StanceBar = false
	},
	UnitFrames= {
		Fader = false,
		Hover = true,
		Combat = true,
		Target = true,
		Focus = true,
		Health = true,
		Vehicle = true,
		Casting = true,
		Delay = 0,
		Smooth = .4,
		MinAlpha = .1,
		MaxAlpha = 1,
		RolePos = false,
		RolePoint = 1,
		RoleXOffset = 0,
		RoleYOffset = 1,
		RoleSize = 14,
	},
	Chat = {
		Emote = false,
		ClassColor = true,
		RaidIndex = false,
		Role = false,
		Icon = true,
		ChatHide = true,
		AutoShow = false,
		AutoHide = false,
		AutoHideTime = 10,
		ASWhisper = true,
		ASGroup = false,
		ASGuild = false,
	},
	Loot = {
		Enable = false,
		Announce = false,
		AnnounceTitle = false,
		AnnounceRarity = 1,
	},
	LootRoll = {
		Enable = true,
		Width = 328,
		Height = 28,
		Style = 1,
		Direction = 2,
		ItemLevel = true,
		ItemQuality = false,
	},
	AFK = {
		Enable = true,
	},
	Skins = {
		Ace3 = true,
		AdiBags = true,
		Auctionator = true,
		BetterBags = true,
		BtWLoadouts = true,
		BtWQuests = true,
		ButtonForge = true,
		Immersion = true,
		InboxMailBag = true,
		ls_Toasts = true,
		MeetingStone = true,
		RareScanner = true,
		ShadowDancer = true,
		SimpleAddonManager = true,
		tdBattlePetScript = true,
		TinyInspect = false,
		WeakAurasOptions = true,
		WhisperPop = true,
		WorldQuestTab = true,
		HideToggle = true,
	},
	Tooltip = {
		Progression = true,
		CombatHide = true,
		ShowByShift = true,
		ProgRaids = true,
		ProgDungeons = true,
		ProgAchievement = true,
		KeystoneMaster = true,
		AchievementList = "",
		MountsSource = true,
		HideCreator = false,
	},
	Misc = {
		LootSpecManager = false,
		TalentManager = true,
		QuestHelper = true,
		CopyMog = true,
		ShowHideVisual = true,
		ShowIllusion = true,
		IconSearch = true,
		ParagonRepRewards = true,
		GarrisonTabs = true,
		AuctionEnhanced = true,
		GuildBankItemLevel = true,
		ExtVendorUI = false,
		ExtMacroUI =  false,
		WormholeHelper = true,
		TrainAll = true,
		AutoRoll = 3,
	},
}

P.CharacterSettings = {
	LootSpecManager = {},
	TalentManager = {},
	RenownLevels = {},
}

function P:InitialSettings(source, target, fullClean)
	for i, j in pairs(source) do
		if type(j) == "table" then
			if target[i] == nil or type(target[i]) ~= "table" then target[i] = {} end
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
		if fullClean and type(j) == "table" then
			for k, v in pairs(j) do
				if type(v) ~= "table" and source[i] and source[i][k] == nil then
					target[i][k] = nil
				end
			end
		end
	end
end

function P.IsRetail()
	return _G.WOW_PROJECT_ID == _G.WOW_PROJECT_MAINLINE
end

function P.IsCata()
	return _G.WOW_PROJECT_ID == _G.WOW_PROJECT_CATACLYSM_CLASSIC
end

function P.IsWrath()
	return _G.WOW_PROJECT_ID == _G.WOW_PROJECT_WRATH_CLASSIC
end

function P.IsBCC()
	return _G.WOW_PROJECT_ID == _G.WOW_PROJECT_BURNING_CRUSADE_CLASSIC
end

function P.IsClassic()
	return _G.WOW_PROJECT_ID == _G.WOW_PROJECT_CLASSIC
end

function P.ThrowError(...)
	local message = strjoin(" ", ...)
	_G.geterrorhandler()(format("|cFF70B8FFNDui_Plus:|r %s", message))
end

function P.Developer_ThrowError(...)
	if NDuiPlusDB["Debug"] then
		local message = strjoin(" ", ...)
		_G.geterrorhandler()(format("|cFF70B8FFNDui_Plus:|r %s", message))
	end
end

function P:Debug(...)
	if NDuiPlusDB["Debug"] then
		_G.DEFAULT_CHAT_FRAME:AddMessage("|cFF70B8FFNDui_Plus:|r " .. format(...))
	end
end

function P:Print(...)
	_G.DEFAULT_CHAT_FRAME:AddMessage("|cFF70B8FFNDui_Plus:|r " .. format(...))
end

function P:Error(...)
	_G.UIErrorsFrame:AddMessage(DB.InfoColor..format(...).."|r")
end

function P:VersionCheck_Compare(new, old)
	local new1, new2, new3 = strsplit(".", new)
	new1, new2, new3 = tonumber(new1), tonumber(new2), tonumber(new3)

	local old1, old2, old3 = strsplit(".", old)
	old1, old2, old3 = tonumber(old1), tonumber(old2), tonumber(old3)

	if new1 > old1 or (new1 == old1 and new2 > old2) or (new1 == old1 and new2 == old2 and new3 > old3) then
		return "IsNew"
	elseif new1 < old1 or (new1 == old1 and new2 < old2) or (new1 == old1 and new2 == old2 and new3 < old3) then
		return "IsOld"
	end
end

function P:Notifications()
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:SetPoint("CENTER")
	frame:SetSize(300, 150)
	frame:SetFrameStrata("HIGH")
	B.CreateMF(frame)
	B.SetBD(frame)

	local close = B.CreateButton(frame, 16, 16, true, DB.closeTex)
	close:SetPoint("TOPRIGHT", -10, -10)
	close:SetScript("OnClick", function() frame:Hide() end)

	B.CreateFS(frame, 18, AddOnName, true, "TOP", 0, -10)
	B.CreateFS(frame, 16, format(L["Version Check"], P.SupportVersion), false, "CENTER")
end

function P:CallLoadedAddon(addonName, object)
	for _, func in next, object do
		xpcall(func, P.ThrowError)
	end

	addonsToLoad[addonName] = nil
end

function P:AddCallbackForAddon(addonName, func)
	local addon = addonsToLoad[addonName]
	if not addon then
		addonsToLoad[addonName] = {}
		addon = addonsToLoad[addonName]
	end

	tinsert(addon, func)
end

function P:CallLoadedAddonEarly(addonName, object)
	for _, func in next, object do
		xpcall(func, P.ThrowError)
	end

	addonsToLoadEarly[addonName] = nil
end

function P:AddCallbackForAddonEarly(addonName, func)
	local addon = addonsToLoadEarly[addonName]
	if not addon then
		addonsToLoadEarly[addonName] = {}
		addon = addonsToLoadEarly[addonName]
	end

	tinsert(addon, func)
end

-- Modules
function P:RegisterModule(name)
	if modules[name] then P:Print("Module <"..name.."> has been registered.") return end
	local module = {}
	module.name = name
	modules[name] = module

	tinsert(initQueue, module)
	return module
end

function P:GetModule(name)
	if not modules[name] then P:Print("Module <"..name.."> does not exist.") return end

	return modules[name]
end

-- Command
function P:AddCommand(name, keys, func)
	if not SlashCmdList["NDUI_PLUS_" .. name] then
		SlashCmdList["NDUI_PLUS_" .. name] = func

		if type(keys) == "table" then
			for i, key in next, keys do
				if strsub(key, 1, 1) ~= "/" then
					key = "/" .. key
				end
				_G["SLASH_NDUI_PLUS_" .. name .. i] = key
			end
		else
			if strsub(keys, 1, 1) ~= "/" then
				keys = "/" .. keys
			end
			_G["SLASH_NDUI_PLUS_" .. name .. "1"] = keys
		end
	end
end

SlashCmdList["NDUI_PLUS"] = function(msg)
	local status = P:VersionCheck_Compare(DB.Version, P.SupportVersion)
	if status == "IsOld" then
		P:Print(format(L["Version Check"], P.SupportVersion))
		return
	end

	if msg and strlen(msg) > 0 then
		P:Developer_Command(msg:lower())
	else
		P:OpenGUI()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
	end
end
SLASH_NDUI_PLUS1 = "/ndp"
SLASH_NDUI_PLUS2 = "/nduiplus"

function P:Initialize()
	local status = P:VersionCheck_Compare(DB.Version, P.SupportVersion)
	if status == "IsOld" then
		P:Print(L["Version Check"], P.SupportVersion)
		P:Notifications()
		return
	end

	for _, module in next, initQueue do
		if module.OnLogin then
			xpcall(module.OnLogin, P.ThrowError, module)
		else
			P:Print("Module <"..module.name.."> does not loaded.")
		end
	end

	for addonName, object in pairs(addonsToLoad) do
		local isLoaded, isFinished = C_AddOns.IsAddOnLoaded(addonName)
		if isLoaded and isFinished then
			P:CallLoadedAddon(addonName, object)
		end
	end

	B:RegisterEvent("ADDON_LOADED", function(_, addonName)
		local object = addonsToLoad[addonName]
		if object then
			P:CallLoadedAddon(addonName, object)
		end
	end)

	P.Initialized = true
end

function B:InitCallback()
	P:Initialize()
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(self, event, addon)
	if event == "ADDON_LOADED" and addon == "NDui_Plus" then
		P:InitialSettings(P.DefaultSettings, NDuiPlusDB, true)
		P:InitialSettings(P.CharacterSettings, NDuiPlusCharDB)

		for _, module in next, initQueue do
			module.db = NDuiPlusDB[module.name]

			local charDB = NDuiPlusCharDB[module.name]
			if module.db and charDB then
				setmetatable(module.db, {__index=charDB})
			elseif charDB then
				module.db = charDB
			end
		end

		for _, module in next, initQueue do
			if module.OnInitialize then
				xpcall(module.OnInitialize, P.ThrowError, module)
			end
		end

		for addonName, object in pairs(addonsToLoadEarly) do
			local isLoaded, isFinished = C_AddOns.IsAddOnLoaded(addonName)
			if isLoaded and isFinished then
				P:CallLoadedAddonEarly(addonName, object)
			end
		end

		P:BuildTextureTable()
		P:ReplaceTexture()

		self:UnregisterEvent(event)
	end
end)