local _, ns = ...
local B, C, L, DB = unpack(ns)

C.OnLoginThemes["ScriptErrorsFrame"] = function()

	ScriptErrorsFrame:SetScale(UIParent:GetScale())
	B.StripTextures(ScriptErrorsFrame)
	B.CreateBG(ScriptErrorsFrame)

	B.ReskinArrow(ScriptErrorsFrame.PreviousError, "left")
	B.ReskinArrow(ScriptErrorsFrame.NextError, "right")
	B.ReskinButton(ScriptErrorsFrame.Reload)
	B.ReskinButton(ScriptErrorsFrame.Close)
	B.ReskinScroll(ScriptErrorsFrame.ScrollFrame.ScrollBar)
	B.ReskinClose(ScriptErrorsFrameClose)
end