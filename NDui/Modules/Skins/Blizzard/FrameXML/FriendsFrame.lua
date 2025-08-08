local _, ns = ...
local B, C, L, DB = unpack(ns)

local atlasToTex = {
	["friendslist-invitebutton-horde-normal"] = "Interface\\FriendsFrame\\PlusManz-Horde",
	["friendslist-invitebutton-alliance-normal"] = "Interface\\FriendsFrame\\PlusManz-Alliance",
	["friendslist-invitebutton-default-normal"] = "Interface\\FriendsFrame\\PlusManz-PlusManz",
}
local function replaceInviteTex(self, atlas)
	local tex = atlasToTex[atlas]
	if tex then
		self.ownerIcon:SetTexture(tex)
	end
end

local function reskinFriendButton(button)
	if not button.styled then
		button.background:Hide()
		B.ReskinHLTex(button)

		local travelPass = button.travelPassButton
		travelPass:SetSize(22, 22)
		travelPass.NormalTexture:SetAlpha(0)
		travelPass.PushedTexture:SetAlpha(0)
		travelPass.DisabledTexture:SetAlpha(0)
		travelPass.HighlightTexture:SetAlpha(0)
		B.UpdatePoint(travelPass, "RIGHT", button, "RIGHT", -3, 0)

		local icon = travelPass:CreateTexture(nil, "ARTWORK")
		icon:SetTexCoord(.1, .9, .1, .9)
		icon:SetAllPoints()
		button.newIcon = icon
		travelPass.NormalTexture.ownerIcon = icon
		hooksecurefunc(travelPass.NormalTexture, "SetAtlas", replaceInviteTex)

		local gameIcon = button.gameIcon
		gameIcon:SetSize(22, 22)
		B.UpdatePoint(gameIcon, "RIGHT", travelPass, "LEFT", -3, 0)

		button.styled = true
	end
end

C.OnLoginThemes["FriendsFrame"] = function()
	B.ReskinFrameTab(FriendsFrame, 4)

	local INVITE_RESTRICTION_NONE = 9
	hooksecurefunc("FriendsFrame_UpdateFriendButton", function(button)
		if button.gameIcon then
			reskinFriendButton(button)
		end

		if button.newIcon and button.buttonType == FRIENDS_BUTTON_TYPE_BNET then
			if FriendsFrame_GetInviteRestriction(button.id) == INVITE_RESTRICTION_NONE then
				button.newIcon:SetVertexColor(1, 1, 1)
			else
				button.newIcon:SetVertexColor(.5, .5, .5)
			end
		end
	end)

	hooksecurefunc("FriendsFrame_UpdateFriendInviteButton", function(button)
		if not button.styled then
			B.ReskinButton(button.AcceptButton)
			B.ReskinButton(button.DeclineButton)

			button.styled = true
		end
	end)

	hooksecurefunc("FriendsFrame_UpdateFriendInviteHeaderButton", function(button)
		if not button.styled then
			button:DisableDrawLayer("BACKGROUND")
			local bg = B.CreateBDFrame(button, .25)
			bg:SetInside(button, 2, 2)
			local hl = button:GetHighlightTexture()
			hl:SetColorTexture(.24, .56, 1, .25)
			hl:SetInside(bg)

			button.styled = true
		end
	end)

	-- FriendsFrameBattlenetFrame
	local battlenetFrame = FriendsFrameBattlenetFrame
	B.StripTextures(battlenetFrame)
	B.UpdatePoint(battlenetFrame, "TOP", FriendsFrameTitleText, "BOTTOM", 0, -3)

	local statusDropdown = FriendsFrameStatusDropdown
	statusDropdown:SetWidth(58)
	B.ReskinDropDown(statusDropdown)
	B.UpdatePoint(statusDropdown, "RIGHT", battlenetFrame, "LEFT", -3, 0)

	local bubg = B.CreateBDFrame(battlenetFrame, .25)
	bubg:SetInside(nil, 2, 3)
	bubg:SetBackdropColor(0, .8, 1, .25)

	local broadcastButton = battlenetFrame.BroadcastButton
	broadcastButton:SetSize(20, 20)
	broadcastButton:GetNormalTexture():SetAlpha(0)
	broadcastButton:GetPushedTexture():SetAlpha(0)
	B.ReskinButton(broadcastButton)
	B.UpdatePoint(broadcastButton, "LEFT", battlenetFrame, "RIGHT", 3, 0)
	local newIcon = broadcastButton:CreateTexture(nil, "ARTWORK")
	newIcon:SetAllPoints()
	newIcon:SetTexture("Interface\\FriendsFrame\\BroadcastIcon")

	local broadcastFrame = battlenetFrame.BroadcastFrame
	B.ReskinFrame(broadcastFrame)
	B.ReskinInput(broadcastFrame.EditBox)
	B.ReskinButton(broadcastFrame.UpdateButton)
	B.ReskinButton(broadcastFrame.CancelButton)
	B.UpdatePoint(broadcastFrame, "TOPLEFT", FriendsFrame, "TOPRIGHT", 3, 0)

	local unavailableFrame = battlenetFrame.UnavailableInfoFrame
	B.ReskinFrame(unavailableFrame)
	unavailableFrame:SetPoint("TOPLEFT", FriendsFrame, "TOPRIGHT", 3, -18)

	B.ReskinFrame(AddFriendFrame)
	B.ReskinButton(AddFriendEntryFrameAcceptButton)
	B.ReskinButton(AddFriendEntryFrameCancelButton)
	B.ReskinInput(AddFriendNameEditBox)

	B.ReskinFrame(FriendsFrame)
	B.ReskinButton(FriendsFrameAddFriendButton)
	B.ReskinButton(FriendsFrameIgnorePlayerButton)
	B.ReskinButton(FriendsFrameSendMessageButton)
	B.ReskinButton(FriendsFrameUnsquelchButton)
	B.ReskinScroll(FriendsListFrame.ScrollBar)

	B.ReskinFrame(FriendsFriendsFrame)
	B.ReskinButton(FriendsFriendsFrame.SendRequestButton)
	B.ReskinButton(FriendsListFrameContinueButton)
	B.ReskinDropDown(FriendsFriendsFrameDropdown)
	B.ReskinScroll(FriendsFriendsFrame.ScrollBar)

	B.StripTextures(IgnoreListFrame)
	B.ReskinScroll(IgnoreListFrame.ScrollBar)

	B.ReskinButton(WhoFrameAddFriendButton)
	B.ReskinButton(WhoFrameGroupInviteButton)
	B.ReskinButton(WhoFrameWhoButton)
	B.ReskinDropDown(WhoFrameDropdown)
	B.ReskinScroll(WhoFrame.ScrollBar)

	for i = 1, 4 do
		B.StripTextures(_G["WhoFrameColumnHeader"..i])
	end

	B.StripTextures(WhoFrameListInset)
	WhoFrameEditBox.Backdrop:Hide()
	local whoBg = B.CreateBDFrame(WhoFrameEditBox, 0, true)
	whoBg:SetPoint("TOPLEFT", WhoFrameEditBox, -3, -2)
	whoBg:SetPoint("BOTTOMRIGHT", WhoFrameEditBox, -1, 2)

	for i = 1, 3 do
		B.StripTextures(_G["FriendsTabHeaderTab"..i])
	end

	-- Recruite frame

	RecruitAFriendFrame.SplashFrame.Description:SetTextColor(1, 1, 1)
	B.ReskinButton(RecruitAFriendFrame.SplashFrame.OKButton)
	B.StripTextures(RecruitAFriendFrame.RewardClaiming)
	B.ReskinButton(RecruitAFriendFrame.RewardClaiming.ClaimOrViewRewardButton)
	B.ReskinButton(RecruitAFriendFrame.RecruitmentButton)

	local recruitList = RecruitAFriendFrame.RecruitList
	B.StripTextures(recruitList.Header)
	B.CreateBDFrame(recruitList.Header, .25)
	recruitList.ScrollFrameInset:Hide()
	B.ReskinScroll(recruitList.ScrollBar)

	local recruitmentFrame = RecruitAFriendRecruitmentFrame
	B.ReskinFrame(recruitmentFrame)
	B.StripTextures(recruitmentFrame.EditBox)
	local bg = B.CreateBDFrame(recruitmentFrame.EditBox, .25)
	bg:SetPoint("TOPLEFT", -3, -3)
	bg:SetPoint("BOTTOMRIGHT", 0, 3)
	B.ReskinButton(recruitmentFrame.GenerateOrCopyLinkButton)

	local rewardsFrame = RecruitAFriendRewardsFrame
	B.ReskinFrame(rewardsFrame)

	rewardsFrame:HookScript("OnShow", function(self)
		for i = 1, self:GetNumChildren() do
			local child = select(i, self:GetChildren())
			local button = child and child.Button
			if button and not button.styled then
				B.ReskinIcon(button.Icon)
				button.IconBorder:Hide()
				button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)

				button.styled = true
			end
		end
	end)
end