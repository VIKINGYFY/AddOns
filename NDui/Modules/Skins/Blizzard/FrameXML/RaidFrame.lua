local _, ns = ...
local B, C, L, DB = unpack(ns)

table.insert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	B.StripTextures(RaidInfoFrame)
	B.SetBD(RaidInfoFrame)
	B.ReskinCheck(RaidFrameAllAssistCheckButton)
	B.StripTextures(RaidInfoFrame.Header)

	RaidInfoFrame:SetPoint("TOPLEFT", RaidFrame, "TOPRIGHT", 1, -28)
	RaidInfoDetailFooter:Hide()
	RaidInfoDetailHeader:Hide()

	B.ReskinButton(RaidFrameRaidInfoButton)
	B.ReskinButton(RaidFrameConvertToRaidButton)
	B.ReskinButton(RaidInfoExtendButton)
	B.ReskinButton(RaidInfoCancelButton)
	B.ReskinClose(RaidInfoCloseButton)
	B.ReskinScroll(RaidInfoFrame.ScrollBar)
	B.ReskinClose(RaidParentFrameCloseButton)

	B.ReskinFrame(RaidParentFrame)
	RaidInfoInstanceLabel:DisableDrawLayer("BACKGROUND")
	RaidInfoIDLabel:DisableDrawLayer("BACKGROUND")

	B.ReskinSmallRole(RaidFrame.RoleCount.TankIcon, "TANK")
	B.ReskinSmallRole(RaidFrame.RoleCount.HealerIcon, "HEALER")
	B.ReskinSmallRole(RaidFrame.RoleCount.DamagerIcon, "DPS")
end)