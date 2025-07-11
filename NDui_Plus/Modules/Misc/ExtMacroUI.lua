local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local M = P:GetModule("Misc")
local S = P:GetModule("Skins")

function M:ExtMacroUI()
	if not M.db["ExtMacroUI"] then return end

	_G.MacroFrame:SetHeight(624)
	_G.MacroFrameScrollFrame:SetHeight(185)
	_G.MacroFrameText:SetHeight(185)
	_G.MacroFrameTextButton:SetHeight(185)
	_G.MacroFrameTextBackground:SetHeight(195)
	_G.MacroFrame.MacroSelector:SetHeight(246)

	_G.MacroHorizontalBarLeft:SetPoint("TOPLEFT", 2, -310)
	_G.MacroFrameTextBackground:SetPoint("TOPLEFT", 6, -389)
	_G.MacroFrameSelectedMacroBackground:SetPoint("TOPLEFT", 2, -318)
end

P:AddCallbackForAddon("Blizzard_MacroUI", M.ExtMacroUI)