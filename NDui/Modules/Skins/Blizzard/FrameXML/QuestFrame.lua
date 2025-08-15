local _, ns = ...
local B, C, L, DB = unpack(ns)

local function Reskin_TitleTextColor(fontString)
	B.ReskinText(fontString, 1, .8, 0)
end

local function Reskin_TextColor(fontString)
	B.ReskinText(fontString, 1, 1, 1)
end

local function Fix_ShowQuestPortrait(parentFrame, _, _, _, _, _, x, y)
	x = (parentFrame == WorldMapFrame) and 2 or 1
	B.UpdatePoint(QuestModelScene, "TOPLEFT", parentFrame, "TOPRIGHT", x, -25)
end

local function Update_ProgressItemQuality(self)
	local button = self.__owner
	local index = button:GetID()
	local buttonType = button.type
	local objectType = button.objectType

	local quality
	if objectType == "item" then
		quality = select(4, GetQuestItemInfo(buttonType, index))
	elseif objectType == "currency" then
		local info = C_QuestOffer.GetQuestRewardCurrencyInfo(buttonType, index)
		quality = info and info.quality
	end

	if quality then
		local r, g, b = C_Item.GetItemQualityColor(quality)
		button.icbg:SetBackdropBorderColor(r, g, b)
		button.bubg:SetBackdropBorderColor(r, g, b)
	end
end

C.OnLoginThemes["QuestFrame"] = function()
	B.ReskinFrame(QuestFrame)
	B.ReskinText(QuestProgressRequiredItemsText, 1, 0, 0)

	QuestDetailScrollFrame:SetWidth(302)

	local line = QuestFrameGreetingPanel:CreateTexture(nil, "ARTWORK")
	line:SetColorTexture(1, 1, 1, .25)
	line:SetSize(256, C.mult)
	line:SetPoint("CENTER", QuestGreetingFrameHorizontalBreak)
	QuestGreetingFrameHorizontalBreak:SetTexture("")
	QuestFrameGreetingPanel:HookScript("OnShow", function()
		line:SetShown(QuestGreetingFrameHorizontalBreak:IsShown())
	end)

	local lists = {
		QuestFrameDetailPanel,
		QuestFrameGreetingPanel,
		QuestFrameProgressPanel,
		QuestFrameRewardPanel,
	}
	for _, list in pairs(lists) do
		B.StripTextures(list, 99)
	end

	local buttons = {
		QuestFrameAcceptButton,
		QuestFrameCompleteButton,
		QuestFrameCompleteQuestButton,
		QuestFrameDeclineButton,
		QuestFrameGoodbyeButton,
		QuestFrameGreetingGoodbyeButton,
	}
	for _, button in pairs(buttons) do
		B.ReskinButton(button)
	end

	local scrolls = {
		QuestProgressScrollFrame,
		QuestRewardScrollFrame,
		QuestDetailScrollFrame,
		QuestGreetingScrollFrame,
	}
	for _, scroll in pairs(scrolls) do
		B.ReskinScroll(scroll.ScrollBar)
	end

	hooksecurefunc("QuestFrame_SetTextColor", Reskin_TextColor)
	hooksecurefunc("QuestFrame_SetTitleTextColor", Reskin_TitleTextColor)
	hooksecurefunc(QuestProgressRequiredMoneyText, "SetTextColor", B.ReskinRMTColor)

	-- QuestModelScene
	B.StripTextures(QuestModelScene.ModelTextFrame)
	B.ReskinScroll(QuestNPCModelTextScrollFrame.ScrollBar)

	local boss = B.ReskinFrame(QuestModelScene)
	boss:SetOutside(QuestModelScene, 0, 0, QuestModelScene.ModelTextFrame)

	hooksecurefunc("QuestFrame_ShowQuestPortrait", Fix_ShowQuestPortrait)

	-- Quest Progress Item
	for i = 1, MAX_REQUIRED_ITEMS do
		local button = _G["QuestProgressItem"..i]
		B.StripTextures(button)

		button.icbg = B.ReskinIcon(button.Icon)
		button.bubg = B.ReskinNameFrame(button, button.icbg, -3)
		button.Icon.__owner = button

		hooksecurefunc(button.Icon, "SetTexture", Update_ProgressItemQuality)
	end
end