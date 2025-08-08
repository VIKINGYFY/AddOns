local _, ns = ...
local B, C, L, DB = unpack(ns)

C.OnLoginThemes["ChatConfigFrame"] = function()

	B.StripTextures(ChatConfigFrame)
	B.SetBD(ChatConfigFrame)
	B.StripTextures(ChatConfigFrame.Header)

	hooksecurefunc("ChatConfig_UpdateCheckboxes", function(frame)
		if not FCF_GetCurrentChatFrame() then return end
		if not frame.styled then
			B.StripTextures(frame)

			local nameString = frame:GetName().."Checkbox"
			for index in pairs(frame.checkBoxTable) do
				local buttonName = nameString..index

				local button = _G[buttonName]
				B.StripTextures(button)
				B.CreateBDFrame(button, .25):SetInside()

				local check = _G[buttonName.."Check"]
				B.ReskinCheck(check)

				local swatch = _G[buttonName.."ColorSwatch"]
				if swatch then
					B.ReskinColorSwatch(swatch)
				end
			end

			frame.styled = true
		end
	end)

	hooksecurefunc("ChatConfig_CreateTieredCheckboxes", function(frame, checkBoxTable)
		if frame.styled then return end

		local nameString = frame:GetName().."Checkbox"
		for index, value in ipairs(checkBoxTable) do
			local checkBoxName = nameString..index
			B.ReskinCheck(_G[checkBoxName])

			if value.subTypes then
				for i in ipairs(value.subTypes) do
					B.ReskinCheck(_G[checkBoxName.."_"..i])
				end
			end
		end

		frame.styled = true
	end)

	hooksecurefunc(ChatConfigFrameChatTabManager, "UpdateWidth", function(self)
		for tab in self.tabPool:EnumerateActive() do
			if not tab.styled then
				B.StripTextures(tab)

				tab.styled = true
			end
		end
	end)

	for i = 1, 5 do
		local tab = _G["CombatConfigTab"..i]
		if tab then
			B.StripTextures(tab)
			if tab.Text then
				tab.Text:SetWidth(tab.Text:GetWidth() + 10)
			end
		end
	end

	local line = ChatConfigFrame:CreateTexture(nil, "ARTWORK")
	line:SetSize(C.mult, 460)
	line:SetPoint("TOPLEFT", ChatConfigCategoryFrame, "TOPRIGHT")
	line:SetColorTexture(1, 1, 1, .25)

	local backdrops = {
		ChatConfigCategoryFrame,
		ChatConfigBackgroundFrame,
		ChatConfigCombatSettingsFilters,
		CombatConfigColorsHighlighting,
		CombatConfigColorsColorizeUnitName,
		CombatConfigColorsColorizeSpellNames,
		CombatConfigColorsColorizeDamageNumber,
		CombatConfigColorsColorizeDamageSchool,
		CombatConfigColorsColorizeEntireLine,
		ChatConfigChatSettingsLeft,
		ChatConfigOtherSettingsCombat,
		ChatConfigOtherSettingsPVP,
		ChatConfigOtherSettingsSystem,
		ChatConfigOtherSettingsCreature,
		ChatConfigChannelSettingsLeft,
		CombatConfigMessageSourcesDoneBy,
		CombatConfigColorsUnitColors,
		CombatConfigMessageSourcesDoneTo,
	}
	for _, frame in pairs(backdrops) do
		B.StripTextures(frame)
	end

	local combatBoxes = {
		CombatConfigColorsHighlightingLine,
		CombatConfigColorsHighlightingAbility,
		CombatConfigColorsHighlightingDamage,
		CombatConfigColorsHighlightingSchool,
		CombatConfigColorsColorizeUnitNameCheck,
		CombatConfigColorsColorizeSpellNamesCheck,
		CombatConfigColorsColorizeSpellNamesSchoolColoring,
		CombatConfigColorsColorizeDamageNumberCheck,
		CombatConfigColorsColorizeDamageNumberSchoolColoring,
		CombatConfigColorsColorizeDamageSchoolCheck,
		CombatConfigColorsColorizeEntireLineCheck,
		CombatConfigFormattingShowTimeStamp,
		CombatConfigFormattingShowBraces,
		CombatConfigFormattingUnitNames,
		CombatConfigFormattingSpellNames,
		CombatConfigFormattingItemNames,
		CombatConfigFormattingFullText,
		CombatConfigSettingsShowQuickButton,
		CombatConfigSettingsSolo,
		CombatConfigSettingsParty,
		CombatConfigSettingsRaid
	}
	for _, box in pairs(combatBoxes) do
		B.ReskinCheck(box)
	end

	hooksecurefunc("ChatConfig_UpdateSwatches", function(frame)
		if not frame.swatchTable then return end
		if not frame.styled then
			B.StripTextures(frame)

			local nameString = frame:GetDebugName().."Swatch"
			for index in pairs(frame.swatchTable) do
				local buttonName = frame:GetDebugName().."Swatch"..index
				local button = _G[buttonName]
				local swatch = _G[buttonName.."ColorSwatch"]

				B.StripTextures(button)
				B.ReskinColorSwatch(swatch)
			end

			frame.styled = true
		end
	end)

	local bg = B.CreateBDFrame(ChatConfigCombatSettingsFilters, .25)
	bg:SetPoint("TOPLEFT", 3, 0)
	bg:SetPoint("BOTTOMRIGHT", 0, 1)

	B.ReskinButton(CombatLogDefaultButton)
	B.ReskinButton(ChatConfigCombatSettingsFiltersCopyFilterButton)
	B.ReskinButton(ChatConfigCombatSettingsFiltersAddFilterButton)
	B.ReskinButton(ChatConfigCombatSettingsFiltersDeleteButton)
	B.ReskinButton(CombatConfigSettingsSaveButton)
	B.ReskinButton(ChatConfigFrameOkayButton)
	B.ReskinButton(ChatConfigFrameDefaultButton)
	B.ReskinButton(ChatConfigFrameRedockButton)
	B.ReskinArrow(ChatConfigMoveFilterUpButton, "up")
	B.ReskinArrow(ChatConfigMoveFilterDownButton, "down")
	B.ReskinInput(CombatConfigSettingsNameEditBox)
	B.ReskinRadio(CombatConfigColorsColorizeEntireLineBySource)
	B.ReskinRadio(CombatConfigColorsColorizeEntireLineByTarget)
	B.ReskinColorSwatch(CombatConfigColorsColorizeSpellNamesColorSwatch)
	B.ReskinColorSwatch(CombatConfigColorsColorizeDamageNumberColorSwatch)
	B.ReskinScroll(ChatConfigCombatSettingsFilters.ScrollBar)

	ChatConfigMoveFilterUpButton:SetSize(22, 22)
	ChatConfigMoveFilterDownButton:SetSize(22, 22)

	ChatConfigCombatSettingsFiltersAddFilterButton:SetPoint("RIGHT", ChatConfigCombatSettingsFiltersDeleteButton, "LEFT", -1, 0)
	ChatConfigCombatSettingsFiltersCopyFilterButton:SetPoint("RIGHT", ChatConfigCombatSettingsFiltersAddFilterButton, "LEFT", -1, 0)
	ChatConfigMoveFilterUpButton:SetPoint("TOPLEFT", ChatConfigCombatSettingsFilters, "BOTTOMLEFT", 3, 0)
	ChatConfigMoveFilterDownButton:SetPoint("LEFT", ChatConfigMoveFilterUpButton, "RIGHT", 1, 0)

	-- TextToSpeech
	B.StripTextures(TextToSpeechButton, 5)
	B.ReskinButton(TextToSpeechDefaultButton)
	B.ReskinCheck(TextToSpeechCharacterSpecificButton)

	local checkboxes = {
		"PlayActivitySoundWhenNotFocusedCheckButton",
		"PlaySoundSeparatingChatLinesCheckButton",
		"AddCharacterNameToSpeechCheckButton",
		"NarrateMyMessagesCheckButton",
		"UseAlternateVoiceForSystemMessagesCheckButton",
	}
	for _, checkbox in pairs(checkboxes) do
		local check = TextToSpeechFramePanelContainer[checkbox]
		B.ReskinCheck(check)
		check.bg:SetInside(check, 6, 6)
	end

	hooksecurefunc("TextToSpeechFrame_UpdateMessageCheckboxes", function(frame)
		local checkBoxTable = frame.checkBoxTable
		if checkBoxTable then
			local checkBoxNameString = frame:GetName().."Checkbox"
			local checkBoxName, checkBox
			for index in ipairs(checkBoxTable) do
				checkBoxName = checkBoxNameString..index
				checkBox = _G[checkBoxName]
				if checkBox and not checkBox.styled then
					B.ReskinCheck(checkBox)
					checkBox.bg:SetInside(checkBox, 6, 6)
					checkBox.styled = true
				end
			end
		end
	end)

	-- voice pickers
	B.StripTextures(ChatConfigTextToSpeechChannelSettingsLeft)
end