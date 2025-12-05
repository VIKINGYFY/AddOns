local _, ns = ...
local B, C, L, DB = unpack(ns)

local function ReskinChatScroll(self)
	B.ReskinScroll(self.ScrollBar)

	B.StripTextures(self.ScrollToBottomButton)
	local flash = self.ScrollToBottomButton.Flash
	B.SetupArrow(flash, "bottom")
	flash:SetVertexColor(1, 1, 0)
end

C.OnLoginThemes["ChatFrame"] = function()

	-- Battlenet toast frame
	B.ReskinFrame(BNToastFrame)
	B.ReskinFrame(BNToastFrame.TooltipFrame)
	B.ReskinFrame(TimeAlertFrame)

	-- Battletag invite frame
	local border, send, cancel = BattleTagInviteFrame:GetChildren()
	border:Hide()
	B.ReskinButton(send)
	B.ReskinButton(cancel)
	B.CreateBG(BattleTagInviteFrame)

	local friendTex = "Interface\\HELPFRAME\\ReportLagIcon-Chat"
	local queueTex = "Interface\\HELPFRAME\\HelpIcon-ItemRestoration"
	local homeTex = "Interface\\Buttons\\UI-HomeButton"

	QuickJoinToastButton.FriendsButton:SetTexture(friendTex)
	QuickJoinToastButton.QueueButton:SetTexture(queueTex)
	QuickJoinToastButton:SetHighlightTexture(0)
	hooksecurefunc(QuickJoinToastButton, "ToastToFriendFinished", function(self)
		self.FriendsButton:SetShown(not self.displayedToast)
	end)
	hooksecurefunc(QuickJoinToastButton, "UpdateQueueIcon", function(self)
		if not self.displayedToast then return end
		self.QueueButton:SetTexture(queueTex)
		self.FlashingLayer:SetTexture(queueTex)
		self.FriendsButton:SetShown(false)
	end)
	QuickJoinToastButton:HookScript("OnMouseDown", function(self)
		self.FriendsButton:SetTexture(friendTex)
	end)
	QuickJoinToastButton:HookScript("OnMouseUp", function(self)
		self.FriendsButton:SetTexture(friendTex)
	end)
	QuickJoinToastButton.Toast.Background:SetTexture(nil)
	local bg = B.CreateBG(QuickJoinToastButton.Toast)
	bg:SetPoint("TOPLEFT", 10, -1)
	bg:SetPoint("BOTTOMRIGHT", 0, 3)
	bg:Hide()
	hooksecurefunc(QuickJoinToastButton, "ShowToast", function() bg:Show() end)
	hooksecurefunc(QuickJoinToastButton, "HideToast", function() bg:Hide() end)

	-- ChatFrame
	B.ReskinButton(ChatFrameChannelButton, nil, true)
	ChatFrameChannelButton:SetSize(20, 20)
	B.ReskinButton(ChatFrameToggleVoiceDeafenButton, nil, true)
	ChatFrameToggleVoiceDeafenButton:SetSize(20, 20)
	B.ReskinButton(ChatFrameToggleVoiceMuteButton, nil, true)
	ChatFrameToggleVoiceMuteButton:SetSize(20, 20)
	B.ReskinButton(ChatFrameMenuButton, nil, true)
	ChatFrameMenuButton:SetSize(20, 20)
	ChatFrameMenuButton:SetNormalTexture(homeTex)
	ChatFrameMenuButton:SetPushedTexture(homeTex)

	for i = 1, Constants.ChatFrameConstants.MaxChatWindows do
		ReskinChatScroll(_G["ChatFrame"..i])
	end

	-- ChannelFrame
	B.ReskinFrame(ChannelFrame)
	B.ReskinButton(ChannelFrame.NewButton)
	B.ReskinButton(ChannelFrame.SettingsButton)
	B.ReskinScroll(ChannelFrame.ChannelList.ScrollBar)
	B.ReskinScroll(ChannelFrame.ChannelRoster.ScrollBar)

	hooksecurefunc(ChannelFrame.ChannelList, "Update", function(self)
		for i = 1, self.Child:GetNumChildren() do
			local tab = select(i, self.Child:GetChildren())
			if not tab.styled and tab:IsHeader() then
				tab:SetNormalTexture(0)
				tab.bg = B.CreateBDFrame(tab, .25)
				tab.bg:SetAllPoints()

				tab.styled = true
			end
		end
	end)

	B.StripTextures(CreateChannelPopup)
	B.CreateBG(CreateChannelPopup)
	B.ReskinButton(CreateChannelPopup.OKButton)
	B.ReskinButton(CreateChannelPopup.CancelButton)
	B.ReskinClose(CreateChannelPopup.CloseButton)
	B.ReskinInput(CreateChannelPopup.Name)
	B.ReskinInput(CreateChannelPopup.Password)

	B.CreateBG(VoiceChatPromptActivateChannel)
	B.ReskinButton(VoiceChatPromptActivateChannel.AcceptButton)
	VoiceChatChannelActivatedNotification:SetBackdrop(nil)
	B.CreateBG(VoiceChatChannelActivatedNotification)

	-- VoiceActivityManager
	hooksecurefunc(VoiceActivityManager, "LinkFrameNotificationAndGuid", function(_, _, notification, guid)
		local class = select(2, GetPlayerInfoByGUID(guid))
		if class then
			local color = DB.ClassColors[class]
			if notification.Name then
				notification.Name:SetTextColor(color.r, color.g, color.b)
			end
		end
	end)
end