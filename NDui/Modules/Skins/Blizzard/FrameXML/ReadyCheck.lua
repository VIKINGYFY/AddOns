local _, ns = ...
local B, C, L, DB = unpack(ns)

C.OnLoginThemes["ReadyCheck"] = function()

	-- Ready check
	B.StripTextures(ReadyCheckListenerFrame)
	B.SetBD(ReadyCheckListenerFrame, 30, -1, 1, -1)
	ReadyCheckPortrait:SetAlpha(0)

	B.ReskinButton(ReadyCheckFrameYesButton)
	B.ReskinButton(ReadyCheckFrameNoButton)

	-- Role poll
	B.StripTextures(RolePollPopup)
	B.SetBD(RolePollPopup)
	B.ReskinButton(RolePollPopupAcceptButton)
	B.ReskinClose(RolePollPopupCloseButton)

	B.ReskinRole(RolePollPopupRoleButtonTank, "TANK")
	B.ReskinRole(RolePollPopupRoleButtonHealer, "HEALER")
	B.ReskinRole(RolePollPopupRoleButtonDPS, "DPS")
end