local _, ns = ...
local B, C, L, DB = unpack(ns)

C.OnLoginThemes["SplashFrame"] = function()

	B.ReskinButton(SplashFrame.BottomCloseButton)
	B.ReskinClose(SplashFrame.TopCloseButton, SplashFrame, -18, -18)
	SplashFrame.Label:SetTextColor(1, 1, 0)
end