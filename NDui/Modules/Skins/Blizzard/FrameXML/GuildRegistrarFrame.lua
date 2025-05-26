local _, ns = ...
local B, C, L, DB = unpack(ns)

C.OnLoginThemes["GuildRegistrarFrame"] = function()
	B.ReskinFrame(GuildRegistrarFrame)
	B.ReskinButton(GuildRegistrarFrameGoodbyeButton)
	B.ReskinButton(GuildRegistrarFramePurchaseButton)
	B.ReskinButton(GuildRegistrarFrameCancelButton)
	B.ReskinInput(GuildRegistrarFrameEditBox, 20)
	B.ReskinText(AvailableServicesText, 1, 1, 1)
end