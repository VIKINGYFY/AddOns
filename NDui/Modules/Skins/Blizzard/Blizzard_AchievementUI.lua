local _, ns = ...
local B, C, L, DB = unpack(ns)
local cr, cg, cb = DB.r, DB.g, DB.b

local function SetupButtonHighlight(button, bg)
	button:SetHighlightTexture(DB.bdTex)
	local hl = button:GetHighlightTexture()
	hl:SetVertexColor(cr, cg, cb, .25)
	hl:SetInside(bg)
end

local function UpdateStringColors(button)
	if button.DateCompleted:IsShown() then
		if button.accountWide then
			button.Label:SetTextColor(0, .8, 1)
		else
			button.Label:SetTextColor(1, .8, 0)
		end
		if button.Description then
			button.Description:SetTextColor(1, 1, 1)
		end
		if button.Reward then
			button.Reward:SetTextColor(0, 1, 0)
		end
	else
		if button.accountWide then
			button.Label:SetTextColor(0, .4, .5)
		else
			button.Label:SetTextColor(.5, .4, 0)
		end
		if button.Description then
			button.Description:SetTextColor(.5, .5, .5)
		end
		if button.Reward then
			button.Reward:SetTextColor(0, .5, 0)
		end
	end
end

local function UpdateProgressBars(frame)
	local objectives = frame:GetObjectiveFrame()
	if objectives and objectives.progressBars then
		for _, bar in next, objectives.progressBars do
			if bar and not bar.styled then
				B.ReskinStatusBar(bar)
				bar.styled = true
			end
		end
	end
end

C.OnLoadThemes["Blizzard_AchievementUI"] = function()
	B.StripTextures(AchievementFrame)
	B.SetBD(AchievementFrame)
	AchievementFrameWaterMark:SetAlpha(0)
	B.StripTextures(AchievementFrame.Header)
	AchievementFrame.Header.Title:Hide()
	AchievementFrame.Header.Points:SetPoint("TOP", AchievementFrame, 0, -3)

	B.ReskinFrameTab(AchievementFrame, 3)

	B.ReskinFilterButton(AchievementFrameFilterDropdown)
	AchievementFrameFilterDropdown:ClearAllPoints()
	AchievementFrameFilterDropdown:SetPoint("TOPLEFT", 25, -5)
	B.ReskinClose(AchievementFrameCloseButton)

	-- Search box
	B.ReskinInput(AchievementFrame.SearchBox)
	AchievementFrame.SearchBox:ClearAllPoints()
	AchievementFrame.SearchBox:SetPoint("TOPRIGHT", AchievementFrame, "TOPRIGHT", -25, -5)
	AchievementFrame.SearchBox:SetPoint("BOTTOMLEFT", AchievementFrame, "TOPRIGHT", -130, -25)

	local previewContainer = AchievementFrame.SearchPreviewContainer
	local showAllSearchResults = previewContainer.ShowAllSearchResults
	B.StripTextures(previewContainer)
	previewContainer:ClearAllPoints()
	previewContainer:SetPoint("TOPLEFT", AchievementFrame, "TOPRIGHT", 7, -2)
	local bg = B.SetBD(previewContainer)
	bg:SetPoint("TOPLEFT", -3, 3)
	bg:SetPoint("BOTTOMRIGHT", showAllSearchResults, 3, -3)

	for i = 1, 5 do
		B.ReskinSearchList(previewContainer["SearchPreview"..i])
	end
	B.ReskinSearchList(showAllSearchResults)

	local result = AchievementFrame.SearchResults
	result:SetPoint("BOTTOMLEFT", AchievementFrame, "BOTTOMRIGHT", 15, -1)
	B.StripTextures(result)
	local bg = B.SetBD(result)
	bg:SetPoint("TOPLEFT", -10, 0)
	bg:SetPoint("BOTTOMRIGHT")

	B.ReskinClose(result.CloseButton)
	B.ReskinScroll(result.ScrollBar)
	hooksecurefunc(result.ScrollBox, "Update", function(self)
		for i = 1, self.ScrollTarget:GetNumChildren() do
			local child = select(i, self.ScrollTarget:GetChildren())
			if not child.styled then
				B.StripTextures(child, 2)
				B.ReskinIcon(child.Icon)
				local bg = B.CreateBDFrame(child, .25)
				bg:SetInside()
				SetupButtonHighlight(child, bg)

				child.styled = true
			end
		end
	end)

	-- AchievementFrameCategories
	B.StripTextures(AchievementFrameCategories)
	B.ReskinScroll(AchievementFrameCategories.ScrollBar)
	hooksecurefunc(AchievementFrameCategories.ScrollBox, "Update", function(self)
		for i = 1, self.ScrollTarget:GetNumChildren() do
			local child = select(i, self.ScrollTarget:GetChildren())
			local button = child.Button
			if button and not button.styled then
				button.Background:Hide()
				local bg = B.CreateBDFrame(button, .25)
				bg:SetPoint("TOPLEFT", 0, -1)
				bg:SetPoint("BOTTOMRIGHT")
				SetupButtonHighlight(button, bg)

				button.styled = true
			end
		end
	end)

	B.StripTextures(AchievementFrameAchievements)
	B.ReskinScroll(AchievementFrameAchievements.ScrollBar)
	select(3, AchievementFrameAchievements:GetChildren()):Hide()

	hooksecurefunc(AchievementFrameAchievements.ScrollBox, "Update", function(self)
		for i = 1, self.ScrollTarget:GetNumChildren() do
			local child = select(i, self.ScrollTarget:GetChildren())
			if child and not child.styled then
				B.StripTextures(child, true)
				UpdateStringColors(child)
				child.Background:SetAlpha(0)
				child.Highlight:SetAlpha(0)
				child.Icon.frame:Hide()

				local bg = B.CreateBDFrame(child, .25)
				bg:SetPoint("TOPLEFT", 1, -1)
				bg:SetPoint("BOTTOMRIGHT", 0, 2)
				B.ReskinIcon(child.Icon.texture)

				B.ReskinCheck(child.Tracked)
				child.Tracked:SetSize(20, 20)
				child.Check:SetAlpha(0)

				hooksecurefunc(child, "UpdatePlusMinusTexture", UpdateStringColors)
				hooksecurefunc(child, "DisplayObjectives", UpdateProgressBars)

				child.styled = true
			end
		end
	end)

	B.StripTextures(AchievementFrameSummary)
	AchievementFrameSummary:GetChildren():Hide()
	AchievementFrameSummaryAchievementsHeaderHeader:SetVertexColor(1, 1, 1, .25)
	AchievementFrameSummaryCategoriesHeaderTexture:SetVertexColor(1, 1, 1, .25)

	hooksecurefunc("AchievementFrameSummary_UpdateAchievements", function()
		for i = 1, ACHIEVEMENTUI_MAX_SUMMARY_ACHIEVEMENTS do
			local bu = _G["AchievementFrameSummaryAchievement"..i]
			UpdateStringColors(bu)

			if not bu.styled then
				bu:DisableDrawLayer("BORDER")
				bu:HideBackdrop()

				local bd = bu.Background
				bd:SetTexture(DB.bdTex)
				bd:SetVertexColor(0, 0, 0, .25)

				bu.TitleBar:Hide()
				bu.Glow:Hide()
				bu.Highlight:SetAlpha(0)
				bu.Icon.frame:Hide()
				B.ReskinIcon(bu.Icon.texture)

				local bg = B.CreateBDFrame(bu, 0)
				bg:SetPoint("TOPLEFT", 2, -2)
				bg:SetPoint("BOTTOMRIGHT", -2, 2)

				bu.styled = true
			end
		end
	end)

	for i = 1, 12 do
		local bu = _G["AchievementFrameSummaryCategoriesCategory"..i]
		B.ReskinStatusBar(bu)
		_G[bu:GetName().."ButtonHighlight"]:SetAlpha(0)
		bu.Label:SetTextColor(1, 1, 1)
		bu.Label:SetPoint("LEFT", bu, "LEFT", 6, -1)
		bu.Text:SetTextColor(1, 1, 1)
		bu.Text:SetPoint("RIGHT", bu, "RIGHT", -5, -1)
	end

	local bar = AchievementFrameSummaryCategoriesStatusBar
	if bar then
		B.ReskinStatusBar(bar)
		_G[bar:GetName().."Title"]:SetTextColor(1, 1, 1)
		_G[bar:GetName().."Title"]:SetPoint("LEFT", bar, "LEFT", 6, -1)
	end

	AchievementFrameSummaryAchievementsEmptyText:SetText("")

	hooksecurefunc("AchievementObjectives_DisplayCriteria", function(objectivesFrame, id)
		local numCriteria = GetAchievementNumCriteria(id)
		local textStrings, metas, criteria, object = 0, 0
		for i = 1, numCriteria do
			local _, criteriaType, completed, _, _, _, _, assetID = GetAchievementCriteriaInfo(id, i)
			if assetID and criteriaType == _G.CRITERIA_TYPE_ACHIEVEMENT then
				metas = metas + 1
				criteria, object = objectivesFrame:GetMeta(metas), "Label"
			elseif criteriaType ~= 1 then
				textStrings = textStrings + 1
				criteria, object = objectivesFrame:GetCriteria(textStrings), "Name"
			end

			local text = criteria and criteria[object]
			if text and completed and objectivesFrame.completed then
				text:SetTextColor(1, 1, 1)
			end
		end
	end)

	-- Summaries
	AchievementFrameStatsBG:Hide()
	select(4, AchievementFrameStats:GetChildren()):Hide()
	B.ReskinScroll(AchievementFrameStats.ScrollBar)
	hooksecurefunc(AchievementFrameStats.ScrollBox, "Update", function(self)
		for i = 1, self.ScrollTarget:GetNumChildren() do
			local child = select(i, self.ScrollTarget:GetChildren())
			if not child.styled then
				B.StripTextures(child)
				local bg = B.CreateBDFrame(child, .25)
				bg:SetPoint("TOPLEFT", 2, -C.mult)
				bg:SetPoint("BOTTOMRIGHT", 4, C.mult)
				SetupButtonHighlight(child, bg)

				child.styled = true
			end
		end
	end)

	-- Comparison

	AchievementFrameComparisonHeaderBG:Hide()
	AchievementFrameComparisonHeaderPortrait:Hide()
	AchievementFrameComparisonHeaderPortraitBg:Hide()
	AchievementFrameComparisonHeader:SetPoint("BOTTOMRIGHT", AchievementFrameComparison, "TOPRIGHT", 39, 26)
	local headerbg = B.SetBD(AchievementFrameComparisonHeader)
	headerbg:SetPoint("TOPLEFT", 20, -20)
	headerbg:SetPoint("BOTTOMRIGHT", -28, -5)

	B.StripTextures(AchievementFrameComparison)
	select(5, AchievementFrameComparison:GetChildren()):Hide()
	B.ReskinScroll(AchievementFrameComparison.AchievementContainer.ScrollBar)

	local function handleCompareSummary(frame)
		B.StripTextures(frame)
		if frame.StatusBar then
			B.ReskinStatusBar(frame.StatusBar)
		end
	end
	handleCompareSummary(AchievementFrameComparison.Summary.Player)
	handleCompareSummary(AchievementFrameComparison.Summary.Friend)

	local function handleCompareCategory(button)
		button:DisableDrawLayer("BORDER")
		button:HideBackdrop()
		button.Background:Hide()
		local bg = B.CreateBDFrame(button, .25)
		bg:SetInside(button, 2, 2)

		button.TitleBar:Hide()
		button.Glow:Hide()
		button.Icon.frame:Hide()
		B.ReskinIcon(button.Icon.texture)
	end

	hooksecurefunc(AchievementFrameComparison.AchievementContainer.ScrollBox, "Update", function(self)
		for i = 1, self.ScrollTarget:GetNumChildren() do
			local child = select(i, self.ScrollTarget:GetChildren())
			if not child.styled then
				handleCompareCategory(child.Player)
				handleCompareCategory(child.Friend)

				child.styled = true
			end
		end
	end)
end