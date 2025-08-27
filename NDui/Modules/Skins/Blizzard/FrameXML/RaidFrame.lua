local _, ns = ...
local B, C, L, DB = unpack(ns)

C.OnLoginThemes["RaidFrame"] = function()
	B.ReskinFrame(RaidParentFrame)
	B.ReskinFrame(RaidInfoFrame)
	B.ReskinButton(RaidFrameConvertToRaidButton)
	B.ReskinButton(RaidFrameRaidInfoButton)
	B.ReskinButton(RaidInfoCancelButton)
	B.ReskinButton(RaidInfoExtendButton)
	B.ReskinCheck(RaidFrameAllAssistCheckButton)
	B.ReskinClose(RaidInfoCloseButton)
	B.ReskinScroll(RaidInfoFrame.ScrollBar)

	B.StripTextures(RaidInfoFrame.Header)
	B.UpdatePoint(RaidInfoFrame, "TOPLEFT", RaidFrame, "TOPRIGHT", 3, 0)

	RaidInfoDetailFooter:Hide()
	RaidInfoDetailHeader:Hide()
	RaidInfoInstanceLabel:DisableDrawLayer("BACKGROUND")
	RaidInfoIDLabel:DisableDrawLayer("BACKGROUND")

	local roleCount = RaidFrame.RoleCount
	B.ReskinSmallRole(roleCount.TankIcon, "TANK")
	B.ReskinSmallRole(roleCount.HealerIcon, "HEALER")
	B.ReskinSmallRole(roleCount.DamagerIcon, "DPS")
	B.UpdatePoint(roleCount, "TOP", FriendsFrameTitleText, "BOTTOM", -9, -6)
	B.UpdatePoint(RaidFrameRaidInfoButton, "LEFT", roleCount, "RIGHT", 3, 0)
	B.UpdatePoint(RaidFrameAllAssistCheckButton, "RIGHT", roleCount, "LEFT", -70, 0)

end