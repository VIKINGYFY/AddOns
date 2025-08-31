local _, ns = ...
local B, C, L, DB = unpack(ns)

C.OnLoginThemes["ColorPickerFrame"] = function()

	B.StripTextures(ColorPickerFrame.Header)
	ColorPickerFrame.Header:ClearAllPoints()
	ColorPickerFrame.Header:SetPoint("TOP", ColorPickerFrame, 0, 10)
	ColorPickerFrame.Border:Hide()

	B.CreateBG(ColorPickerFrame)
	B.ReskinButton(ColorPickerFrame.Footer.OkayButton)
	B.ReskinButton(ColorPickerFrame.Footer.CancelButton)
end