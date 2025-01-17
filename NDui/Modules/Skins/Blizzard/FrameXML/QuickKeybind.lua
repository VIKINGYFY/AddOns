local _, ns = ...
local B, C, L, DB = unpack(ns)

C.OnLoginThemes["QuickKeybind"] = function()

	local frame = QuickKeybindFrame
	B.StripTextures(frame)
	B.StripTextures(frame.Header)
	B.SetBD(frame)
	B.ReskinCheck(frame.UseCharacterBindingsButton)
	frame.UseCharacterBindingsButton:SetSize(24, 24)
	B.ReskinButton(frame.OkayButton)
	B.ReskinButton(frame.DefaultsButton)
	B.ReskinButton(frame.CancelButton)
end