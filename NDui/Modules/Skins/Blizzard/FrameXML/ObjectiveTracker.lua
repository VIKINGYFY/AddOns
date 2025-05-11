local _, ns = ...
local B, C, L, DB = unpack(ns)

local cr, cg, cb = DB.r, DB.g, DB.b
local select, pairs = select, pairs

local function reskinQuestIcon(button)
	if not button then return end
	if not button.SetNormalTexture then return end

	if not button.styled then
		B.CleanTextures(button)

		local icon = button.icon or button.Icon
		if icon then
			button.bg = B.ReskinIcon(icon, true)
			B.ReskinHLTex(button, button.bg)
			B.ReskinCPTex(button, button.bg)
		end

		button.styled = true
	end
end

local function reskinQuestIcons(_, block)
	reskinQuestIcon(block.ItemButton)
	reskinQuestIcon(block.rightEdgeFrame)
end

local function reskinHeader(header)
	header.Text:SetTextColor(cr, cg, cb)
	header.Background:SetTexture(nil)
	local bg = header:CreateTexture(nil, "ARTWORK")
	bg:SetTexture("Interface\\LFGFrame\\UI-LFG-SEPARATOR")
	bg:SetTexCoord(0, .66, 0, .31)
	bg:SetVertexColor(cr, cg, cb)
	bg:SetPoint("BOTTOM", 0, -4)
	bg:SetSize(250, 30)
	header.bg = bg -- accessable for other addons
end

local function reskinProgress(self, key)
	local progressBar = self.usedProgressBars[key]
	local bar = progressBar and progressBar.Bar

	if bar and not bar.styled then
		B.ReskinStatusBar(bar, false, true)

		bar.styled = true
	end

	local icon = bar.Icon
	if icon then
		if not icon.bg then
			icon:SetMask("")
			icon.bg = B.ReskinIcon(icon, true)
			icon:ClearAllPoints()
			icon:SetPoint("TOPLEFT", bar, "TOPRIGHT", DB.margin, 0)
			icon:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", DB.margin + bar:GetHeight(), 0)
		end

		if icon.bg then
			icon.bg:SetShown(icon:IsShown() and icon:GetTexture() ~= nil)
		end
	end
end

local function reskinTimer(self, key)
	local timerBar = self.usedTimerBars[key]
	local bar = timerBar and timerBar.Bar

	if bar and not bar.styled then
		B.ReskinStatusBar(bar, false, true)

		bar.styled = true
	end
end

local function updateMinimizeButton(button, collapsed)
	button = button.MinimizeButton
	button.__texture:DoCollapse(collapsed)
end

local function reskinMinimizeButton(button, header)
	B.ReskinCollapse(button)
	button:GetNormalTexture():SetAlpha(0)
	button:GetPushedTexture():SetAlpha(0)
	button.__texture:DoCollapse(false)
	if header.SetCollapsed then
		hooksecurefunc(header, "SetCollapsed", updateMinimizeButton)
	end
end

local function GetMawBuffsAnchor(frame)
	local center = frame:GetCenter()
	if center and center < GetScreenWidth()/2 then
		return "LEFT"
	else
		return "RIGHT"
	end
end

local function container_OnClick(container)
	local direc = GetMawBuffsAnchor(container)
	if not container.lastDirec or container.lastDirec ~= direc then
		container.List:ClearAllPoints()
		if direc == "LEFT" then
			container.List:SetPoint("TOPLEFT", container, "TOPRIGHT", 15, 1)
		else
			container.List:SetPoint("TOPRIGHT", container, "TOPLEFT", 15, 1)
		end
		container.lastDirec = direc
	end
end

local function blockList_Show(self)
	self.button:SetWidth(253)
	self.button:SetButtonState("NORMAL")
	self.button:SetPushedTextOffset(1.25, -1)
	self.button:SetButtonState("PUSHED", true)
	self.__bg:SetBackdropBorderColor(1, 1, 0)
end

local function blockList_Hide(self)
	B.SetBorderColor(self.__bg)
end

local function ReskinMawBuffsContainer(container)
	B.StripTextures(container)
	container:GetPushedTexture():SetAlpha(0)
	container:GetHighlightTexture():SetAlpha(0)
	local bg = B.SetBD(container, 13, -11, -3, 11)
	container:HookScript("OnClick", container_OnClick)

	local blockList = container.List
	B.StripTextures(blockList)
	blockList.__bg = bg
	local bg = B.SetBD(blockList)
	bg:SetPoint("TOPLEFT", 7, -12)
	bg:SetPoint("BOTTOMRIGHT", -7, 12)

	blockList:HookScript("OnShow", blockList_Show)
	blockList:HookScript("OnHide", blockList_Hide)
end

C.OnLoginThemes["ObjectiveTracker"] = function()
	if C_AddOns.IsAddOnLoaded("!KalielsTracker") then return end

	-- Reskin Headers
	local mainHeader = ObjectiveTrackerFrame.Header
	B.StripTextures(mainHeader) -- main header looks simple this way

	-- Minimize Button
	local mainMinimize =mainHeader.MinimizeButton
	reskinMinimizeButton(mainMinimize, mainHeader)
	mainMinimize.bg:SetBackdropBorderColor(1, 1, 0)

	local trackers = {
		ScenarioObjectiveTracker,
		UIWidgetObjectiveTracker,
		CampaignQuestObjectiveTracker,
		QuestObjectiveTracker,
		AdventureObjectiveTracker,
		AchievementObjectiveTracker,
		MonthlyActivitiesObjectiveTracker,
		ProfessionsRecipeTracker,
		BonusObjectiveTracker,
		WorldQuestObjectiveTracker,
	}
	for _, tracker in pairs(trackers) do
		reskinHeader(tracker.Header)
		hooksecurefunc(tracker, "AddBlock", reskinQuestIcons)
		hooksecurefunc(tracker, "GetProgressBar", reskinProgress)
		hooksecurefunc(tracker, "GetTimerBar", reskinTimer)
	end

	-- Handle blocks, untest
	hooksecurefunc(ScenarioObjectiveTracker.StageBlock, "UpdateStageBlock", function(block)
		block.NormalBG:SetTexture("")
		if not block.bg then
			block.bg = B.SetBD(block.GlowTexture, 0, -2, 4, 2)
		end
	end)

	local isIgnoredTex = {
		[6013778] = true, -- 生命值图标
	}

	hooksecurefunc(ScenarioObjectiveTracker.StageBlock, "UpdateWidgetRegistration", function(self)
		local widgetContainer = self.WidgetContainer
		if widgetContainer.widgetFrames then
			for _, widgetFrame in pairs(widgetContainer.widgetFrames) do
				if widgetFrame.Frame then widgetFrame.Frame:SetAlpha(0) end

				local bar = widgetFrame.TimerBar
				if bar and not bar.bg then
					bar.bg = B.CreateBDFrame(bar, .25)
				end

				if widgetFrame.CurrencyContainer then
					for currencyFrame in widgetFrame.currencyPool:EnumerateActive() do
						local tex = currencyFrame.Icon:GetTexture()
						if not isIgnoredTex[tex] and not currencyFrame.bg then
							currencyFrame.bg = B.ReskinIcon(currencyFrame.Icon)
						end
					end
				end
			end
		end
	end)

	hooksecurefunc(ScenarioObjectiveTracker.ChallengeModeBlock, "SetUpAffixes", function(self)
		for frame in self.affixPool:EnumerateActive() do
			frame.Border:SetTexture("")
			frame.Portrait:SetTexture("")

			if not frame.bg then
				frame.bg = B.ReskinIcon(frame.Portrait)
			end

			if frame.info then
				frame.Portrait:SetTexture(CHALLENGE_MODE_EXTRA_AFFIX_INFO[frame.info.key].texture)
			elseif frame.affixID then
				local _, _, filedataid = C_ChallengeMode.GetAffixInfo(frame.affixID)
				frame.Portrait:SetTexture(filedataid)
			end
		end
	end)

	hooksecurefunc(ScenarioObjectiveTracker.ChallengeModeBlock, "Activate", function(block)
		if not block.bg then
			B.StripTextures(block)
			B.ReskinStatusBar(block.StatusBar)
			block.StatusBar:SetHeight(10)
			block.bg = B.SetBD(block, 4, -2, -4, 0)
		end
	end)

	hooksecurefunc(ScenarioObjectiveTracker, "UpdateSpellCooldowns", function(self)
		for spellFrame in self.spellFramePool:EnumerateActive() do
			local spellButton = spellFrame.SpellButton
			if spellButton and not spellButton.styled then
				B.CleanTextures(spellButton)

				local bg = B.ReskinIcon(spellButton.Icon)
				B.ReskinHLTex(spellButton, bg)
				B.ReskinCPTex(spellButton, bg)

				spellButton.styled = true
			end
		end
	end)

	-- Maw buffs container
	ReskinMawBuffsContainer(ScenarioObjectiveTracker.MawBuffsBlock.Container)
end