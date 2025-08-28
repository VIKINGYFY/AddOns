local _, ns = ...
local B, C, L, DB = unpack(ns)
local S = B:GetModule("Skins")

S.LoadSkins = B.LoadAddOns
C.OnLoginThemes = {}
C.OnLoadThemes = {}
C.OtherThemes = {}

function S:RegisterSkin(addonName, func)
	C.OtherThemes[addonName] = func
end

function S:LoadAddOnSkins()
	if C_AddOns.IsAddOnLoaded("AuroraClassic") or C_AddOns.IsAddOnLoaded("Aurora") then return end

	-- Blizzard UIs
	if C.db["Skins"]["BlizzardSkins"] then
		-- OnLogin Themes
		for name, func in pairs(C.OnLoginThemes) do
			if name and type(func) == "function" then
				xpcall(func, geterrorhandler())
			end
		end

		-- OnLoad Themes
		for name, func in pairs(C.OnLoadThemes) do
			if name and type(func) == "function" then
				B:LoadAddOns(name, func)
			end
		end
	end

	-- Other Themes
	for name, func in pairs(C.OtherThemes) do
		if name and type(func) == "function" then
			B:LoadAddOns(name, func)
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
