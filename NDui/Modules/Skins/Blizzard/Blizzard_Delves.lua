local _, ns = ...
local B, C, L, DB = unpack(ns)

local function reskinButton(button)
	if not button.styled then
		if button.Border then button.Border:SetAlpha(0) end
		if button.Icon then B.ReskinIcon(button.Icon) end

		button.styled = true
	end
end

local function updateButton(self)
	self:ForEachFrame(reskinButton)
end

local function reskinOptionSlot(frame, skip)
	local option = frame.OptionsList
	option.bg = B.ReskinFrame(option)

	if not skip then
		hooksecurefunc(option.ScrollBox, "Update", updateButton)
		B.UpdateSize(option.bg, -1, 0, 0, -2)
	end
end

C.OnLoadThemes["Blizzard_DelvesCompanionConfiguration"] = function()
	B.ReskinFrame(DelvesCompanionConfigurationFrame)
	B.ReskinButton(DelvesCompanionConfigurationFrame.CompanionConfigShowAbilitiesButton)

	reskinOptionSlot(DelvesCompanionConfigurationFrame.CompanionCombatRoleSlot, true)
	reskinOptionSlot(DelvesCompanionConfigurationFrame.CompanionUtilityTrinketSlot)
	reskinOptionSlot(DelvesCompanionConfigurationFrame.CompanionCombatTrinketSlot)

	B.ReskinFrame(DelvesCompanionAbilityListFrame)
	B.ReskinDropDown(DelvesCompanionAbilityListFrame.DelvesCompanionRoleDropdown)
	B.ReskinArrow(DelvesCompanionAbilityListFrame.DelvesCompanionAbilityListPagingControls.PrevPageButton, "left")
	B.ReskinArrow(DelvesCompanionAbilityListFrame.DelvesCompanionAbilityListPagingControls.NextPageButton, "right")

	hooksecurefunc(DelvesCompanionAbilityListFrame, "UpdatePaginatedButtonDisplay", function(self)
		for _, button in pairs(self.buttons) do
			if not button.styled then
				if button.Icon then B.ReskinIcon(button.Icon) end

				button.styled = true
			end
		end
	end)
end

C.OnLoadThemes["Blizzard_DelvesDashboardUI"] = function()
	DelvesDashboardFrame.DashboardBackground:SetAlpha(0)
	B.ReskinButton(DelvesDashboardFrame.ButtonPanelLayoutFrame.CompanionConfigButtonPanel.CompanionConfigButton)
end

local function handleRewards(self)
	for rewardFrame in self.rewardPool:EnumerateActive() do
		if not rewardFrame.bg then
			rewardFrame.bg = B.ReskinIcon(rewardFrame.Icon)
			B.ReskinBorder(rewardFrame.IconBorder, true)
			B.ReskinNameFrame(rewardFrame, rewardFrame.bg)
		end
	end
end

C.OnLoadThemes["Blizzard_DelvesDifficultyPicker"] = function()
	B.ReskinFrame(DelvesDifficultyPickerFrame)
	B.ReskinDropDown(DelvesDifficultyPickerFrame.Dropdown)
	B.ReskinButton(DelvesDifficultyPickerFrame.EnterDelveButton)

	DelvesDifficultyPickerFrame.DelveRewardsContainerFrame:HookScript("OnShow", handleRewards)
	hooksecurefunc(DelvesDifficultyPickerFrame.DelveRewardsContainerFrame, "SetRewards", handleRewards)
end
