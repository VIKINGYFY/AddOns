local _, ns = ...
local B, C, L, DB = unpack(ns)

local function ReskinQuestHeader(header, isCalling)
	if not header.styled then
		B.StripTextures(header)
		header.Background:SetAlpha(.5)

		local bg = B.CreateBDFrame(header.Background, .25)
		bg:SetPoint("TOPLEFT", header.Background, 0, 0)
		bg:SetPoint("BOTTOMRIGHT", header.Background, 0, 8)

		header.styled = true
	end
end

local function ReskinSessionDialog(_, dialog)
	if not dialog.styled then
		B.StripTextures(dialog)
		B.SetBD(dialog)
		B.ReskinButton(dialog.ButtonContainer.Confirm)
		B.ReskinButton(dialog.ButtonContainer.Decline)
		if dialog.MinimizeButton then
			B.ReskinArrow(dialog.MinimizeButton, "down")
		end

		dialog.styled = true
	end
end

local function ReskinAWQHeader()
	if C_AddOns.IsAddOnLoaded("AngrierWorldQuests") then
		local button = _G["AngrierWorldQuestsHeader"]
		if button and not button.styled then
			B.StripTextures(button)
			B.CreateBDFrame(button, .25)
			button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)

			button.styled = true
		end
	end
end

C.OnLoginThemes["QuestMapFrame"] = function()

	-- Quest frame

	local QuestMapFrame = QuestMapFrame
	QuestMapFrame.VerticalSeparator:SetAlpha(0)

	local QuestScrollFrame = QuestScrollFrame
	QuestScrollFrame.Contents.Separator:SetAlpha(0)
	ReskinQuestHeader(QuestScrollFrame.Contents.StoryHeader)

	QuestScrollFrame.Background:SetAlpha(0)
	B.StripTextures(QuestScrollFrame.BorderFrame)
	B.StripTextures(QuestMapFrame.DetailsFrame.BackFrame)

	local campaignOverview = QuestMapFrame.QuestsFrame.CampaignOverview
	if campaignOverview then -- isNewPath, removed?
		B.StripTextures(campaignOverview)
		ReskinQuestHeader(campaignOverview.Header)
		B.ReskinScroll(campaignOverview.ScrollFrame.ScrollBar)
	end

	QuestScrollFrame.Edge:Hide()
	B.ReskinScroll(QuestScrollFrame.ScrollBar)
	B.ReskinInput(QuestScrollFrame.SearchBox)

	local tabs = {"QuestsTab", "EventsTab", "MapLegendTab"}
	for _, name in pairs(tabs) do
		local tab = QuestMapFrame[name]
		B.StripTextures(tab, 2)

		local bg = B.SetBD(tab, 1, -4, -5, 4)
		B.ReskinHLTex(tab.SelectedTexture, bg, true)
	end

	-- Quest details

	local DetailsFrame = QuestMapFrame.DetailsFrame
	local CompleteQuestFrame = DetailsFrame.CompleteQuestFrame

	B.StripTextures(DetailsFrame)
	B.StripTextures(DetailsFrame.ShareButton)
	DetailsFrame.Bg:SetAlpha(0)
	DetailsFrame.SealMaterialBG:SetAlpha(0)

	B.ReskinButton(DetailsFrame.AbandonButton)
	B.ReskinButton(DetailsFrame.ShareButton)
	B.ReskinButton(DetailsFrame.TrackButton)
	B.ReskinScroll(QuestMapDetailsScrollFrame.ScrollBar)

	B.ReskinButton(DetailsFrame.BackFrame.BackButton)
	B.StripTextures(DetailsFrame.RewardsFrameContainer.RewardsFrame)

	DetailsFrame.AbandonButton:ClearAllPoints()
	DetailsFrame.AbandonButton:SetPoint("BOTTOMLEFT", DetailsFrame, -1, 0)
	DetailsFrame.AbandonButton:SetWidth(95)

	DetailsFrame.ShareButton:ClearAllPoints()
	DetailsFrame.ShareButton:SetPoint("LEFT", DetailsFrame.AbandonButton, "RIGHT", 1, 0)
	DetailsFrame.ShareButton:SetWidth(94)

	DetailsFrame.TrackButton:ClearAllPoints()
	DetailsFrame.TrackButton:SetPoint("LEFT", DetailsFrame.ShareButton, "RIGHT", 1, 0)
	DetailsFrame.TrackButton:SetWidth(96)

	-- Scroll frame

	hooksecurefunc("QuestLogQuests_Update", function()
		for button in QuestScrollFrame.headerFramePool:EnumerateActive() do
			if button.ButtonText then
				if not button.styled then
					B.StripTextures(button)
					B.CreateBDFrame(button, .25)
					button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)

					button.styled = true
				end
			end
		end

		for button in QuestScrollFrame.titleFramePool:EnumerateActive() do
			if not button.styled then
				if button.Checkbox then
					B.StripTextures(button.Checkbox, 2)
					B.CreateBDFrame(button.Checkbox, 0, true)
				end
				button.styled = true
			end
		end

		for header in QuestScrollFrame.campaignHeaderFramePool:EnumerateActive() do
			ReskinQuestHeader(header)
		end

		for header in QuestScrollFrame.campaignHeaderMinimalFramePool:EnumerateActive() do
			if header.CollapseButton and not header.styled then
				B.StripTextures(header)
				B.CreateBDFrame(header.Background, .25)
				header.Highlight:SetColorTexture(1, 1, 1, .25)
				header.styled = true
			end
		end

		for header in QuestScrollFrame.covenantCallingsHeaderFramePool:EnumerateActive() do
			ReskinQuestHeader(header, true)
		end

		ReskinAWQHeader()
	end)

	-- Map legend
	local mapLegend = QuestMapFrame.MapLegend
	if mapLegend then
		B.StripTextures(mapLegend.BorderFrame)
		if mapLegend.BackButton then
			B.ReskinButton(mapLegend.BackButton)
		end
		B.ReskinScroll(mapLegend.ScrollFrame.ScrollBar)
		B.StripTextures(mapLegend.ScrollFrame)
		B.CreateBDFrame(mapLegend.ScrollFrame, .25, nil, -2)
	end

	-- Events
	local event = QuestMapFrame.EventsFrame
	if event then
		B.StripTextures(event)
		B.CreateBDFrame(event, .25, nil, -2)
		B.ReskinScroll(event.ScrollBar)
		event.ScrollBox.Background:Hide()

		local function updateCategory(_, button)
			if button.styled then return end
			if button.Highlight then
				button.Highlight:SetColorTexture(1, 1, 1, .25)
				button.Highlight:SetInside()
			end
			if button.Label then
				B.StripTextures(button)
				button.Label:SetTextColor(1, 1, 1)
				local bg = B.CreateBDFrame(button, .25)
				bg:SetPoint("TOPLEFT", 1, -2)
				bg:SetPoint("BOTTOMRIGHT", -1, 2)
			end
			if button.Location then
				button.Location:SetFontObject(Game13Font)
			end
			if button.Icon and not button.Timeline then
				button.Background:Hide()
				B.SetGradient(button, "H", 0, 1, 0, .25, 0, 290, 38):SetPoint("LEFT")
			end
			button.styled = true
		end
		ScrollUtil.AddAcquiredFrameCallback(event.ScrollBox, updateCategory, event, true)
	end

	-- [[ Quest log popup detail frame ]]

	local QuestLogPopupDetailFrame = QuestLogPopupDetailFrame

	B.ReskinFrame(QuestLogPopupDetailFrame)
	B.ReskinButton(QuestLogPopupDetailFrame.AbandonButton)
	B.ReskinButton(QuestLogPopupDetailFrame.TrackButton)
	B.ReskinButton(QuestLogPopupDetailFrame.ShareButton)
	QuestLogPopupDetailFrame.SealMaterialBG:SetAlpha(0)
	B.ReskinScroll(QuestLogPopupDetailFrameScrollFrame.ScrollBar)

	-- Show map button

	local ShowMapButton = QuestLogPopupDetailFrame.ShowMapButton

	ShowMapButton.Texture:SetAlpha(0)
	ShowMapButton.Highlight:SetTexture("")
	ShowMapButton.Highlight:SetTexture("")

	ShowMapButton:SetSize(ShowMapButton.Text:GetStringWidth() + 14, 22)
	ShowMapButton.Text:ClearAllPoints()
	ShowMapButton.Text:SetPoint("CENTER", 1, 0)

	ShowMapButton:ClearAllPoints()
	ShowMapButton:SetPoint("TOPRIGHT", QuestLogPopupDetailFrame, -30, -25)

	B.ReskinButton(ShowMapButton)

	ShowMapButton:HookScript("OnEnter", function(self)
		self.Text:SetTextColor(1, 1, 1)
	end)

	ShowMapButton:HookScript("OnLeave", function(self)
		self.Text:SetTextColor(1, .8, 0)
	end)

	-- Bottom buttons

	QuestLogPopupDetailFrame.ShareButton:ClearAllPoints()
	QuestLogPopupDetailFrame.ShareButton:SetPoint("LEFT", QuestLogPopupDetailFrame.AbandonButton, "RIGHT", 1, 0)
	QuestLogPopupDetailFrame.ShareButton:SetPoint("RIGHT", QuestLogPopupDetailFrame.TrackButton, "LEFT", -1, 0)

	-- Party Sync button

	local sessionManagement = QuestMapFrame.QuestSessionManagement
	sessionManagement.BG:Hide()
	B.CreateBDFrame(sessionManagement, .25)

	hooksecurefunc(QuestSessionManager, "NotifyDialogShow", ReskinSessionDialog)

	local executeSessionCommand = sessionManagement.ExecuteSessionCommand
	B.ReskinButton(executeSessionCommand)

	local icon = executeSessionCommand:CreateTexture(nil, "ARTWORK")
	icon:SetInside()
	executeSessionCommand.normalIcon = icon

	local sessionCommandToButtonAtlas = {
		[_G.Enum.QuestSessionCommand.Start] = "QuestSharing-DialogIcon",
		[_G.Enum.QuestSessionCommand.Stop] = "QuestSharing-Stop-DialogIcon"
	}

	hooksecurefunc(QuestMapFrame.QuestSessionManagement, "UpdateExecuteCommandAtlases", function(self, command)
		self.ExecuteSessionCommand:SetNormalTexture(0)
		self.ExecuteSessionCommand:SetPushedTexture(0)
		self.ExecuteSessionCommand:SetDisabledTexture(0)

		local atlas = sessionCommandToButtonAtlas[command]
		if atlas then
			self.ExecuteSessionCommand.normalIcon:SetAtlas(atlas)
		end
	end)
end