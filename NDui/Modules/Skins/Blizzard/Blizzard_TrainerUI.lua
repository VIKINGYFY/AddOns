local _, ns = ...
local B, C, L, DB = unpack(ns)

C.OnLoadThemes["Blizzard_TrainerUI"] = function()

	B.ReskinFrame(ClassTrainerFrame)
	ClassTrainerStatusBarSkillRank:ClearAllPoints()
	ClassTrainerStatusBarSkillRank:SetPoint("CENTER", ClassTrainerStatusBar, "CENTER", 0, 0)

	local icbg = B.ReskinIcon(ClassTrainerFrameSkillStepButtonIcon)
	local bg = B.CreateBDFrame(ClassTrainerFrameSkillStepButton, .25)
	bg:SetPoint("TOPLEFT", icbg, "TOPRIGHT", 1, 0)
	bg:SetPoint("BOTTOMRIGHT", icbg, "BOTTOMRIGHT", 270, 0)

	ClassTrainerFrameSkillStepButton:SetNormalTexture(0)
	ClassTrainerFrameSkillStepButton:SetHighlightTexture(0)
	ClassTrainerFrameSkillStepButton.disabledBG:SetTexture(nil)
	ClassTrainerFrameSkillStepButton.selectedTex:SetInside(bg)
	ClassTrainerFrameSkillStepButton.selectedTex:SetColorTexture(DB.r, DB.g, DB.b, .25)

	B.ReskinStatusBar(ClassTrainerStatusBar)
	B.ReskinScroll(ClassTrainerFrame.ScrollBar)

	hooksecurefunc(ClassTrainerFrame.ScrollBox, "Update", function(self)
		for i = 1, self.ScrollTarget:GetNumChildren() do
			local button = select(i, self.ScrollTarget:GetChildren())
			if not button.styled then
				local icbg = B.ReskinIcon(button.icon)
				local bg = B.CreateBDFrame(button, .25)
				bg:SetPoint("TOPLEFT", icbg, "TOPRIGHT", 1, 0)
				bg:SetPoint("BOTTOMRIGHT", icbg, "BOTTOMRIGHT", 253, 0)

				button.name:SetParent(bg)
				button.name:SetPoint("TOPLEFT", button.icon, "TOPRIGHT", 6, -2)
				button.subText:SetParent(bg)
				button.money:SetParent(bg)
				button.money:SetPoint("TOPRIGHT", button, "TOPRIGHT", 5, -8)
				button:SetNormalTexture(0)
				button:SetHighlightTexture(0)
				button.disabledBG:SetTexture(nil)
				button.selectedTex:SetInside(bg)
				button.selectedTex:SetColorTexture(DB.r, DB.g, DB.b, .25)

				button.styled = true
			end
		end
	end)

	B.ReskinButton(ClassTrainerTrainButton)
	B.ReskinFilterButton(ClassTrainerFrame.FilterDropdown)
end