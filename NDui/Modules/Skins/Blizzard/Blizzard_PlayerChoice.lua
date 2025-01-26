local _, ns = ...
local B, C, L, DB = unpack(ns)

local Type_ItemDisplay = Enum.UIWidgetVisualizationType.ItemDisplay

-- Needs review, still buggy on blizz
local function ReskinOptionButton(self)
	if not self or self.__bg then return end

	B.StripTextures(self, true)
	B.ReskinButton(self)
end

local function ReskinSpellWidget(spell)
	if not spell.bg then
		spell.Border:SetAlpha(0)
		spell.bg = B.ReskinIcon(spell.Icon)
	end

	spell.IconMask:Hide()
	spell.Text:SetTextColor(1, 1, 1)
end

local ignoredTextureKit = {
	["jailerstower"] = true,
	["cypherchoice"] = true,
	["genericplayerchoice"] = true,
}

local uglyBackground = {
	["ui-frame-genericplayerchoice-cardparchment"] = true
}

C.OnLoadThemes["Blizzard_PlayerChoice"] = function()
	hooksecurefunc(PlayerChoiceFrame, "TryShow", function(self)
		B.StripTextures(self)
		B.CleanTextures(self.CloseButton)

		if not self.bg then
			B.StripTextures(self.Title)
			B.ReskinText(self.Title.Text, 1, .8, 0, nil, SystemFont_Huge1)

			B.ReskinClose(self.CloseButton)
			self.bg = B.SetBD(self)

			if GenericPlayerChoiceToggleButton then
				B.ReskinButton(GenericPlayerChoiceToggleButton)
			end
		end

		local isIgnored = ignoredTextureKit[self.uiTextureKit]
		self.bg:SetShown(not isIgnored)

		if not self.optionFrameTemplate then return end

		for optionFrame in self.optionPools:EnumerateActiveByTemplate(self.optionFrameTemplate) do
			optionFrame:DisableDrawLayer("BACKGROUND")
			if not optionFrame.bg then
				optionFrame.bg = B.CreateBDFrame(optionFrame, .25)
				B.UpdateSize(optionFrame.bg, 0, -15, 0, -15)
			end

			local header = optionFrame.Header
			if header then
				B.StripTextures(header)
				B.ReskinText(header.Text, 1, .8, 0)
				if header.Contents then B.ReskinText(header.Contents.Text, 1, .8, 0) end
			end
			B.ReskinText(optionFrame.OptionText, 1, 1, 1)
			B.ReplaceIconString(optionFrame.OptionText.String)

			if optionFrame.Artwork and isIgnored then optionFrame.Artwork:SetSize(64, 64) end -- fix high resolution icons
--[[
			local optionBG = optionFrame.Background
			if optionBG then
				if not optionBG.bg then
					optionBG.bg = B.SetBD(optionBG)
					optionBG.bg:SetInside(optionBG, 4, 4)
				end
				local isUgly = uglyBackground[optionBG:GetAtlas()]
				optionBG:SetShown(not isUgly)
				optionBG.bg:SetShown(isUgly)
			end
]]
			local optionButtonsContainer = optionFrame.OptionButtonsContainer
			if optionButtonsContainer and optionButtonsContainer.buttonPool then
				for button in optionButtonsContainer.buttonPool:EnumerateActive() do
					ReskinOptionButton(button)
				end
			end

			local rewards = optionFrame.Rewards
			if rewards then
				for rewardFrame in rewards.rewardsPool:EnumerateActive() do
					local text = rewardFrame.Name or rewardFrame.Text -- .Text for PlayerChoiceBaseOptionReputationRewardTemplate
					if text then
						B.ReskinText(text, .9, .8, .5)
					end

					if not rewardFrame.styled then
						-- PlayerChoiceBaseOptionItemRewardTemplate, PlayerChoiceBaseOptionCurrencyContainerRewardTemplate
						local itemButton = rewardFrame.itemButton
						if itemButton then
							B.StripTextures(itemButton, 1)
							itemButton.bg = B.ReskinIcon((itemButton:GetRegions()))
							B.ReskinBorder(itemButton.IconBorder, true)
						end
						-- PlayerChoiceBaseOptionCurrencyRewardTemplate
						local count = rewardFrame.Count
						if count then
							rewardFrame.bg = B.ReskinIcon(rewardFrame.Icon)
							B.ReskinBorder(rewardFrame.IconBorder, true)
						end

						rewardFrame.styled = true
					end
				end
			end

			local widgetContainer = optionFrame.WidgetContainer
			if widgetContainer and widgetContainer.widgetFrames then
				for _, widgetFrame in pairs(widgetContainer.widgetFrames) do
					B.ReskinText(widgetFrame.Text, 1, 1, 1)
					if widgetFrame.Spell then
						ReskinSpellWidget(widgetFrame.Spell)
					end
					if widgetFrame.widgetType == Type_ItemDisplay then
						local item = widgetFrame.Item
						if item then
							item.IconMask:Hide()
							item.NameFrame:SetAlpha(0)
							if not item.bg then
								item.bg = B.ReskinIcon(item.Icon)
								B.ReskinBorder(item.IconBorder, true)
							end
						end
					end
				end
			end
		end
	end)
end