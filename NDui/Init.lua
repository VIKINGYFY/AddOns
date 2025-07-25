local addonName, ns = ...
ns[1] = {}			-- B, Basement
ns[2] = {}			-- C, Config
ns[3] = {}			-- L, Locales
ns[4] = {}			-- DB, Database

NDuiDB, NDuiADB, NDuiPDB = {}, {}, {}

local B, C, L, DB = unpack(ns)

-- Events
local events = {}

local host = CreateFrame("Frame")
host:SetScript("OnEvent", function(_, event, ...)
	for func in pairs(events[event]) do
		if event == "COMBAT_LOG_EVENT_UNFILTERED" then
			func(event, CombatLogGetCurrentEventInfo())
		else
			func(event, ...)
		end
	end
end)

function B:RegisterEvent(event, func, unit1, unit2)
	if event == "CLEU" then
		event = "COMBAT_LOG_EVENT_UNFILTERED"
	end
	if not events[event] then
		events[event] = {}
		if unit1 then
			host:RegisterUnitEvent(event, unit1, unit2)
		else
			host:RegisterEvent(event)
		end
	end

	events[event][func] = true
end

function B:UnregisterEvent(event, func)
	if event == "CLEU" then
		event = "COMBAT_LOG_EVENT_UNFILTERED"
	end
	local funcs = events[event]
	if funcs and funcs[func] then
		funcs[func] = nil

		if not next(funcs) then
			events[event] = nil
			host:UnregisterEvent(event)
		end
	end
end

-- Modules
local modules, initQueue = {}, {}

function B:RegisterModule(name)
	if modules[name] then print("Module <"..name.."> has been registered.") return end
	local module = {}
	module.name = name
	modules[name] = module

	table.insert(initQueue, module)
	return module
end

function B:GetModule(name)
	if not modules[name] then print("Module <"..name.."> does not exist.") return end

	return modules[name]
end

-- Init
local function GetBestScale()
	local scale = (768 / DB.ScreenHeight) * 1.5
	return B:Round(scale, 2)
end

function B:SetupUIScale(init)
	if NDuiADB["LockUIScale"] then NDuiADB["UIScale"] = GetBestScale() end
	local scale = NDuiADB["UIScale"]
	if init then
		local pixel = 1
		local ratio = 768 / DB.ScreenHeight
		C.mult = (pixel / scale) - ((pixel - ratio) / scale)
		if DB.ScreenHeight >= 2160 then C.mult = C.mult * 2 end
	elseif not InCombatLockdown() then
		UIParent:SetScale(scale)
	end
end

local isScaling = false
local function UpdatePixelScale(event)
	if isScaling then return end
	isScaling = true

	if event == "UI_SCALE_CHANGED" then
		DB.ScreenWidth, DB.ScreenHeight = GetPhysicalScreenSize()
	end
	B:SetupUIScale(true)
	B:SetupUIScale()

	isScaling = false
end

local function IncorrectExpansion() -- left it for the future
	local f = CreateFrame("Frame", nil, UIParent)
	f:SetPoint("CENTER")
	f:SetSize(10, 10)
	local text = f:CreateFontString()
	text:SetPoint("CENTER")
	text:SetFont(STANDARD_TEXT_FONT, 20, "OUTLINE")
	text:SetText(L["IncorrectExpansion"])
end

B:RegisterEvent("PLAYER_LOGIN", function()
	-- Initial
	SetCVar("ActionButtonUseKeyDown", 1)
	B:SetupUIScale()
	B:RegisterEvent("UI_SCALE_CHANGED", UpdatePixelScale)
	B:SetSmoothingAmount(NDuiADB["SmoothAmount"])

	local LCG = LibStub("LibCustomGlow-1.0-NDui")
	if LCG then
		B.ShowOverlayGlow = LCG.ShowOverlayGlow
		B.HideOverlayGlow = LCG.HideOverlayGlow
	end

	for _, module in next, initQueue do
		if module.OnLogin then
			xpcall(module.OnLogin, geterrorhandler(), module)
		else
			print("Module <"..module.name.."> does not loaded.")
		end
	end

	B.Modules = modules

	if B.InitCallback then B:InitCallback() end
end)

_G[addonName] = ns