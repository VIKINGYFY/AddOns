local _, ns = ...
local B, C, L, DB = unpack(ns)

C.OnLoadThemes["Blizzard_BattlefieldMap"] = function()
	local BattlefieldMapFrame = _G.BattlefieldMapFrame
	local BorderFrame = BattlefieldMapFrame.BorderFrame

	B.StripTextures(BorderFrame)
	B.SetBD(BattlefieldMapFrame, -1, 3, -1, 2)
	B.ReskinClose(BorderFrame.CloseButton)

	B.StripTextures(OpacityFrame)
	B.SetBD(OpacityFrame)
	B.ReskinSlider(OpacityFrameSlider, true)
end