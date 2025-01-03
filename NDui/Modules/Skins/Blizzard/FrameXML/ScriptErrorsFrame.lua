local _, ns = ...
local B, C, L, DB = unpack(ns)

table.insert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	ScriptErrorsFrame:SetScale(UIParent:GetScale())
	B.StripTextures(ScriptErrorsFrame)
	B.SetBD(ScriptErrorsFrame)

	B.ReskinArrow(ScriptErrorsFrame.PreviousError, "left")
	B.ReskinArrow(ScriptErrorsFrame.NextError, "right")
	B.ReskinButton(ScriptErrorsFrame.Reload)
	B.ReskinButton(ScriptErrorsFrame.Close)
	B.ReskinTrimScroll(ScriptErrorsFrame.ScrollFrame.ScrollBar)
	B.ReskinClose(ScriptErrorsFrameClose)
end)