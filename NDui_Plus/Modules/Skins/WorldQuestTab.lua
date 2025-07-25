local _, ns = ...
local B, C, L, DB, P = unpack(ns)
local S = P:GetModule("Skins")

local function HandleListButton(button)
	for index = 1, 4 do
		local reward = button.Rewards["Reward"..index]
		if reward then
			reward.BorderMask:Hide()
			reward.bg = B.ReskinIcon(reward.Icon)
			B.ReskinIconBorder(reward.QualityColor)

			local Amount = reward.Amount
			Amount:SetJustifyH("CENTER")
			Amount:ClearAllPoints()
			Amount:SetPoint("BOTTOM", reward, "BOTTOM", 1, 0)
		end
	end

	local Title = button.Title
	Title:ClearAllPoints()
	Title:SetPoint("BOTTOMLEFT", button.Type, "RIGHT", 0, 0)
	Title:SetPoint("RIGHT", button.Rewards, "LEFT", 0, 0)

	button.Time:SetPoint("BOTTOM", button, "BOTTOM", 0, 3)
end

local buttonList = {"Button", "ButtonConfirm", "ButtonDecline", "Picker", "ResetButton"}

local function ReskinCategory(category)
	B.StripTextures(category)
	B.ReskinButton(category)

	for _, setting in ipairs(category.settings) do
		for _, button in ipairs(buttonList) do
			if setting[button] then
				B.ReskinButton(setting[button])
			end
		end

		if setting.Dropdown then
			B.ReskinDropDown(setting.Dropdown)
		end

		if setting.SliderWithSteppers then
			B.ReskinStepperSlider(setting.SliderWithSteppers)
		end

		if setting.TextBox then
			B.ReskinInput(setting.TextBox)
		end

		if setting.CheckBox then
			B.ReskinCheck(setting.CheckBox)
		end

		if setting.Picker then
			setting.Picker.Color:SetAllPoints(setting.Picker.__bg)
		end
	end
end

function S:WorldQuestTab()
	if not S.db["WorldQuestTab"] then return end

	local frame = _G.WQT_WorldQuestFrame
	if not frame then return end

	local ScrollFrame = frame.ScrollFrame
	if ScrollFrame then
		ScrollFrame.Background:Hide()
		B.CreateBDFrame(ScrollFrame, .25, nil, -2)

		S:Proxy("StripTextures", ScrollFrame.BorderFrame)
		S:Proxy("ReskinTrimScroll", ScrollFrame.ScrollBar)
		S:Proxy("ReskinDropDown", ScrollFrame.SortDropdown)
		S:Proxy("ReskinFilterButton", ScrollFrame.FilterDropdown)
	end

	local QuestMapTab = _G.WQT_QuestMapTab
	if QuestMapTab then
		B.StripTextures(QuestMapTab, 2)

		QuestMapTab.bg = B.SetBD(QuestMapTab, 1, -4, -5, 4)
		B.ReskinHLTex(QuestMapTab.SelectedTexture, QuestMapTab.bg, true)
	end

	local ListButtonMixin = _G.WQT_ListButtonMixin
	if ListButtonMixin then
		hooksecurefunc(ListButtonMixin, "OnLoad", function(self)
			HandleListButton(self)

			local Highlight = self.Highlight
			B.StripTextures(Highlight)
			Highlight.HL = Highlight:CreateTexture(nil, "ARTWORK")
			Highlight.HL:SetTexture(DB.bdTex)
			Highlight.HL:SetVertexColor(DB.r, DB.g, DB.b, .25)
			Highlight.HL:SetInside()
		end)
	end

	local WhatsNewFrame = _G.WQT_WhatsNewFrame
	if WhatsNewFrame then
		B.StripTextures(WhatsNewFrame)
		B.CreateBDFrame(WhatsNewFrame, .25, nil, -2)
		S:Proxy("ReskinTrimScroll", WhatsNewFrame.ScrollBar)
	end

	local SettingsFrame = _G.WQT_SettingsFrame
	if SettingsFrame then
		B.StripTextures(SettingsFrame)
		B.CreateBDFrame(SettingsFrame, .25, nil, -2)
		S:Proxy("ReskinTrimScroll", SettingsFrame.ScrollBar)

		P:Delay(1, function()
			for _, category in ipairs(SettingsFrame.categories) do
				ReskinCategory(category)

				for _, subCategory in ipairs(category.subCategories) do
					ReskinCategory(subCategory)
				end
			end
		end)
	end

	if _G.WQT_FlightMapContainer then
		B.ReskinFrame(_G.WQT_FlightMapContainer)
		B.ReskinButton(_G.WQT_FlightMapContainerButton)
	end

	if _G.WQT_SettingsQuestListPreview then
		HandleListButton(_G.WQT_SettingsQuestListPreview.Preview)
	end
end

S:RegisterSkin("WorldQuestTab", S.WorldQuestTab)