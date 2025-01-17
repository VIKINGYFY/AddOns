local _, ns = ...
local B, C, L, DB = unpack(ns)

local function reskinOptionCheck(button)
	B.ReskinCheck(button)
	button.bg:SetInside(button, 6, 6)
end

C.OnLoginThemes["EditModeManager"] = function()

	local frame = EditModeManagerFrame

	B.StripTextures(frame)
	B.SetBD(frame)
	B.ReskinClose(frame.CloseButton)
	B.ReskinButton(frame.RevertAllChangesButton)
	B.ReskinButton(frame.SaveChangesButton)
	B.ReskinDropDown(frame.LayoutDropdown)
	reskinOptionCheck(frame.ShowGridCheckButton.Button)
	reskinOptionCheck(frame.EnableSnapCheckButton.Button)
	reskinOptionCheck(frame.EnableAdvancedOptionsCheckButton.Button)
	B.ReskinStepperSlider(frame.GridSpacingSlider.Slider, true)
	if frame.Tutorial then
		frame.Tutorial.Ring:Hide()
	end

	local dialog = EditModeSystemSettingsDialog
	B.StripTextures(dialog)
	B.SetBD(dialog)
	B.ReskinClose(dialog.CloseButton)
	frame.AccountSettings.SettingsContainer.BorderArt:Hide()
	B.CreateBDFrame(frame.AccountSettings.SettingsContainer, .25)
	B.ReskinScroll(frame.AccountSettings.SettingsContainer.ScrollBar)

	local function reskinOptionChecks(settings)
		for i = 1, settings:GetNumChildren() do
			local option = select(i, settings:GetChildren())
			if option.Button and not option.styled then
				reskinOptionCheck(option.Button)
				option.styled = true
			end
		end
	end

	hooksecurefunc(frame.AccountSettings, "OnEditModeEnter", function(self)
		local basicOptions = self.SettingsContainer.ScrollChild.BasicOptionsContainer
		if basicOptions then
			reskinOptionChecks(basicOptions)
		end

		local advancedOptions = self.SettingsContainer.ScrollChild.AdvancedOptionsContainer
		if advancedOptions.FramesContainer then
			reskinOptionChecks(advancedOptions.FramesContainer)
		end
		if advancedOptions.CombatContainer then
			reskinOptionChecks(advancedOptions.CombatContainer)
		end
		if advancedOptions.MiscContainer then
			reskinOptionChecks(advancedOptions.MiscContainer)
		end
	end)

	hooksecurefunc(dialog, "UpdateExtraButtons", function(self)
		local revertButton = self.Buttons and self.Buttons.RevertChangesButton
		if revertButton and not revertButton.styled then
			B.ReskinButton(revertButton)
			revertButton.styled = true
		end

		for button in self.pools:EnumerateActiveByTemplate("EditModeSystemSettingsDialogExtraButtonTemplate") do
			if not button.styled then
				B.ReskinButton(button)
				button.styled = true
			end
		end

		for check in self.pools:EnumerateActiveByTemplate("EditModeSettingCheckboxTemplate") do
			if not check.styled then
				B.ReskinCheck(check.Button)
				check.Button.bg:SetInside(nil, 6, 6)
				check.styled = true
			end
		end

		for dropdown in self.pools:EnumerateActiveByTemplate("EditModeSettingDropdownTemplate") do
			if not dropdown.styled then
				B.ReskinDropDown(dropdown.Dropdown)
				dropdown.styled = true
			end
		end

		for slider in self.pools:EnumerateActiveByTemplate("EditModeSettingSliderTemplate") do
			if not slider.styled then
				B.ReskinStepperSlider(slider.Slider, true)
				slider.styled = true
			end
		end
	end)

	local dialog = EditModeUnsavedChangesDialog
	B.StripTextures(dialog)
	B.SetBD(dialog)
	B.ReskinButton(dialog.SaveAndProceedButton)
	B.ReskinButton(dialog.ProceedButton)
	B.ReskinButton(dialog.CancelButton)

	local function ReskinLayoutDialog(dialog)
		B.StripTextures(dialog)
		B.SetBD(dialog)
		B.ReskinButton(dialog.AcceptButton)
		B.ReskinButton(dialog.CancelButton)

		local check = dialog.CharacterSpecificLayoutCheckButton
		if check then
			B.ReskinCheck(check.Button)
			check.Button.bg:SetInside(nil, 6, 6)
		end

		local editbox = dialog.LayoutNameEditBox
		if editbox then
			B.ReskinInput(editbox)
			editbox.__bg:SetPoint("TOPLEFT", -5, -5)
			editbox.__bg:SetPoint("BOTTOMRIGHT", 5, 5)
		end

		local importBox = dialog.ImportBox
		if importBox then
			B.StripTextures(importBox)
			B.CreateBDFrame(importBox, .25)
		end
	end

	ReskinLayoutDialog(EditModeNewLayoutDialog)
	ReskinLayoutDialog(EditModeImportLayoutDialog)
end