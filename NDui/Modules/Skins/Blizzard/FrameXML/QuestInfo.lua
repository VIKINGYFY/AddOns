local _, ns = ...
local B, C, L, DB = unpack(ns)

local cr, cg, cb = DB.r, DB.g, DB.b

local function Reset_Highlight()
	for _, button in pairs(QuestInfoRewardsFrame.RewardButtons) do
		button.nf:SetBackdropColor(0, 0, 0, .25)
	end
end

local function Update_Highlight(self)
	Reset_Highlight()

	local _, frame = self:GetPoint()
	if frame then
		frame.nf:SetBackdropColor(cr, cg, cb, .5)
	end
end

local function QuestInfo_GetQuestID()
	if QuestInfoFrame.questLog then
		return C_QuestLog.GetSelectedQuest()
	else
		return GetQuestID()
	end
end

local function Reskin_ObjectivesText()
	if not QuestInfoFrame.questLog then return end

	local questID = QuestInfo_GetQuestID()
	local objectivesTable = QuestInfoObjectivesFrame.Objectives
	local numVisibleObjectives = 0
	local objective

	local waypointText = C_QuestLog.GetNextWaypointText(questID);
	if waypointText then
		numVisibleObjectives = numVisibleObjectives + 1;
		objective = objectivesTable[numVisibleObjectives]

		B.ReskinText(objective, 1, 1, 0)
	end

	for i = 1, GetNumQuestLeaderBoards() do
		local _, objectiveType, isCompleted = GetQuestLogLeaderBoard(i)

		if (objectiveType ~= "spell" and objectiveType ~= "log" and numVisibleObjectives < MAX_OBJECTIVES) then
			numVisibleObjectives = numVisibleObjectives + 1
			objective = objectivesTable[numVisibleObjectives]

			if objective then
				if isCompleted then
					B.ReskinText(objective, 0, 1, 0)
				else
					B.ReskinText(objective, 1, 0, 0)
				end
			end
		end
	end
end

local function Reskin_GeneralsText()
	local titles = {
		QuestInfoDescriptionHeader,
		QuestInfoObjectivesHeader,
		QuestInfoRewardsFrame.Header,
		QuestInfoSpellObjectiveLearnLabel,
		QuestInfoTitleHeader,
	}
	for _, title in pairs(titles) do
		B.ReskinText(title, 1, .8, 0)
	end

	local texts = {
		QuestInfoDescriptionText,
		QuestInfoGroupSize,
		QuestInfoObjectivesText,
		QuestInfoRewardsFrame.ItemChooseText,
		QuestInfoRewardsFrame.ItemReceiveText,
		QuestInfoRewardsFrame.PlayerTitleText,
		QuestInfoRewardsFrame.XPFrame.ReceiveText,
		QuestInfoRewardText,
	}
	for _, text in pairs(texts) do
		B.ReskinText(text, 1, 1, 1)
	end

	B.ReskinText(QuestInfoQuestType, 0, 1, 1)
end

local function Reskin_RewardButton(self, isMapQuestInfo)
	if not self then return end

	B.StripTextures(self, 1)

	if self.Icon then
		if isMapQuestInfo then
			if self.Name then self.Name:SetFontObject(Game12Font) end
			self.Icon:SetSize(28, 28)
		else
			self.Icon:SetSize(38, 38)
		end

		self.bg = B.ReskinIcon(self.Icon)
		self.nf = B.ReskinNameFrame(self, self.bg)
		B.ReskinBorder(self.IconBorder)

		B.UpdatePoint(self.Count, "BOTTOMRIGHT", self.bg, "BOTTOMRIGHT", 0, 1)
	end
end

local function Reskin_GetRewardButton(rewardsFrame, index)
	local button = rewardsFrame.RewardButtons[index]

	if not button.styled then
		Reskin_RewardButton(button, rewardsFrame == MapQuestInfoRewardsFrame)

		button.styled = true
	end
end

local function Reskin_SpecialReward()
	local rewardsFrame = QuestInfoFrame.rewardsFrame
	local isQuestLog = QuestInfoFrame.questLog ~= nil
	local numSpellRewards = C_QuestInfoSystem.GetQuestRewardSpells(questID) or {}

	if #numSpellRewards > 0 then
		-- Spell Rewards
		for spellReward in rewardsFrame.spellRewardPool:EnumerateActive() do
			if not spellReward.styled then
				Reskin_RewardButton(spellReward, isQuestLog)

				spellReward.styled = true
			end
		end

		-- Follower Rewards
		for followerReward in rewardsFrame.followerRewardPool:EnumerateActive() do
			local portrait, class
			if followerReward.AdventuresFollowerPortraitFrame and followerReward.AdventuresFollowerPortraitFrame:IsShown() then
				portrait = followerReward.AdventuresFollowerPortraitFrame
				class = nil
			else
				portrait = followerReward.PortraitFrame
				class = followerReward.Class
			end

			if not followerReward.styled then
				followerReward.BG:Hide()

				local bubg = B.CreateBGFrame(followerReward, 0, -3, 2, 7)
				B.ReskinFollowerPortrait(portrait)
				B.UpdatePoint(portrait, "LEFT", bubg, "LEFT", .5, .5)

				if class then
					B.ReskinFollowerClass(class, 36, "RIGHT", -4, 0, bubg)
				end

				followerReward.bubg = bubg
				followerReward.styled = true
			end

			if isQuestLog then
				followerReward.bubg:ClearAllPoints()
				followerReward.bubg:SetPoint("TOPLEFT", 0, 1)
				followerReward.bubg:SetPoint("BOTTOMRIGHT", 2, -3)
			end

			if portrait then
				B.UpdateFollowerQuality(portrait)
			end
		end
	end
end

local replacedSealColor = {
	["480404"] = "c20606",
	["042c54"] = "1c86ee",
}

local function Reskin_SealFrameText(self, text)
	if text and text ~= "" then
		local colorStr, rawText = string.match(text, "|c[fF][fF](%x%x%x%x%x%x)(.-)|r")
		if colorStr and rawText then
			colorStr = replacedSealColor[colorStr] or "99ccff"
			self:SetFormattedText("|cff%s%s|r", colorStr, rawText)
		end
	end
end

C.OnLoginThemes["QuestInfoFrame"] = function()
	-- Text Color
	B.ReskinText(QuestProgressRequiredItemsText, 1, .8, 0)
	hooksecurefunc("QuestInfo_Display", Reskin_GeneralsText)
	hooksecurefunc("QuestInfo_Display", Reskin_ObjectivesText)
	hooksecurefunc("QuestInfo_Display", Reskin_SpecialReward)
	hooksecurefunc(QuestInfoSealFrame.Text, "SetText", Reskin_SealFrameText)
	hooksecurefunc(QuestInfoRequiredMoneyText, "SetTextColor", B.ReskinRMTColor)

	-- Quest Info Item
	local ItemHighlight = QuestInfoItemHighlight
	B.StripTextures(ItemHighlight)
	hooksecurefunc(ItemHighlight, "SetPoint", Update_Highlight)
	ItemHighlight:HookScript("OnShow", Update_Highlight)
	ItemHighlight:HookScript("OnHide", Reset_Highlight)

	local frames = {
		"ArtifactXPFrame",
		"HonorFrame",
		"MoneyFrame",
		"SkillPointFrame",
		"TitleFrame",
		"WarModeBonusFrame",
		"XPFrame",
	}
	for _, frame in pairs(frames) do
		local quests = QuestInfoRewardsFrame[frame]
		if quests then Reskin_RewardButton(quests) end

		local maps = MapQuestInfoRewardsFrame[frame]
		if maps then Reskin_RewardButton(maps, true) end
	end

	hooksecurefunc("QuestInfo_GetRewardButton", Reskin_GetRewardButton)
end