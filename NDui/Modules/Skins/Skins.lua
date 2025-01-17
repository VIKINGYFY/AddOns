local _, ns = ...
local B, C, L, DB = unpack(ns)
local S = B:GetModule("Skins")

C.OnLoginThemes = {}
C.OnLoadThemes = {}
C.OtherThemes = {}

function S:RegisterSkin(addonName, func)
	C.OtherThemes[addonName] = func
end

function S:LoadSkins(name, func)
	local function loadFunc(event, addon)
		if event == "PLAYER_ENTERING_WORLD" then
			B:UnregisterEvent(event, loadFunc)

			local isLoaded, isFinished = C_AddOns.IsAddOnLoaded(name)
			if isLoaded and isFinished then
				func()
				B:UnregisterEvent("ADDON_LOADED", loadFunc)
			end
		elseif event == "ADDON_LOADED" and addon == name then
			func()
			B:UnregisterEvent(event, loadFunc)
		end
	end

	B:RegisterEvent("PLAYER_ENTERING_WORLD", loadFunc)
	B:RegisterEvent("ADDON_LOADED", loadFunc)
end

function S:LoadAddOnSkins()
	if C_AddOns.IsAddOnLoaded("AuroraClassic") or C_AddOns.IsAddOnLoaded("Aurora") then return end

	-- Blizzard UIs
	if C.db["Skins"]["BlizzardSkins"] then
		-- OnLogin Themes
		for name, func in pairs(C.OnLoginThemes) do
			if name and type(func) == "function" then
				func()
			end
		end

		-- OnLoad Themes
		for name, func in pairs(C.OnLoadThemes) do
			if name and type(func) == "function" then
				S:LoadSkins(name, func)
			end
		end
	end

	-- Other Themes
	for name, func in pairs(C.OtherThemes) do
		if name and type(func) == "function" then
			S:LoadSkins(name, func)
		end
	end
end

function S:OnLogin()
	self:LoadAddOnSkins()

	-- Add Skins
	self:DBMSkin()
	self:SkadaSkin()
	self:PGFSkin()
	self:ReskinRematch()
	self:OtherSkins()

	-- Register skin
	local media = LibStub and LibStub("LibSharedMedia-3.0", true)
	if media then
		media:Register("statusbar", "normTex", DB.normTex)
	end
end
