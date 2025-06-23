local _, ns = ...
local B, C, L, DB = unpack(ns)

local function reskinTalentFrameDialog(dialog)
	B.StripTextures(dialog)
	B.SetBD(dialog)
	if dialog.AcceptButton then B.ReskinButton(dialog.AcceptButton) end
	if dialog.CancelButton then B.ReskinButton(dialog.CancelButton) end
	if dialog.DeleteButton then B.ReskinButton(dialog.DeleteButton) end

	B.ReskinInput(dialog.NameControl.EditBox)
	dialog.NameControl.EditBox.__bg:SetPoint("TOPLEFT", -5, -10)
	dialog.NameControl.EditBox.__bg:SetPoint("BOTTOMRIGHT", 5, 10)
end

C.OnLoadThemes["Blizzard_PlayerSpells"] = function()
	local frame = PlayerSpellsFrame
	B.ReskinFrame(frame)
	B.ReskinMinMax(frame.MaximizeMinimizeButton)

	local talentsFrame = frame.TalentsFrame
	B.ReskinButton(talentsFrame.ApplyButton)
	B.ReskinDropDown(talentsFrame.LoadSystem.Dropdown)
	B.ReskinButton(talentsFrame.InspectCopyButton)

	talentsFrame.BlackBG:Hide()
	talentsFrame.Background:SetAlpha(.5)
	talentsFrame.BottomBar:SetAlpha(.5)

	B.ReskinInput(talentsFrame.SearchBox)
	talentsFrame.SearchBox.__bg:SetPoint("TOPLEFT", -4, -5)
	talentsFrame.SearchBox.__bg:SetPoint("BOTTOMRIGHT", 0, 5)

	local specFrame = frame.SpecFrame
	specFrame.BlackBG:Hide()
	specFrame.Background:Hide()

	for i = 1, 3 do
		local tab = select(i, frame.TabSystem:GetChildren())
		B.ReskinTab(tab)
	end

	hooksecurefunc(frame.SpecFrame, "UpdateSpecFrame", function(self)
		for specContentFrame in self.SpecContentFramePool:EnumerateActive() do
			if not specContentFrame.styled then
				B.ReskinButton(specContentFrame.ActivateButton)

				local role = GetSpecializationRole(specContentFrame.specIndex)
				if role then
					B.ReskinSmallRole(specContentFrame.RoleIcon, role)
				end

				if specContentFrame.SpellButtonPool then
					for button in specContentFrame.SpellButtonPool:EnumerateActive() do
						button.Ring:Hide()
						B.ReskinIcon(button.Icon)

						local texture = button.spellID and C_Spell.GetSpellTexture(button.spellID)
						if texture then
							button.Icon:SetTexture(texture)
						end
					end
				end

				specContentFrame.styled = true
			end
		end
	end)

	local dialog = ClassTalentLoadoutImportDialog
	if dialog then
		reskinTalentFrameDialog(dialog)
		B.StripTextures(dialog.ImportControl.InputContainer)
		B.CreateBDFrame(dialog.ImportControl.InputContainer, .25)
	end

	local dialog = ClassTalentLoadoutCreateDialog
	if dialog then
		reskinTalentFrameDialog(dialog)
	end

	local dialog = ClassTalentLoadoutEditDialog
	if dialog then
		reskinTalentFrameDialog(dialog)

		local editbox = dialog.LoadoutName
		if editbox then
			B.ReskinInput(editbox)
			editbox.__bg:SetPoint("TOPLEFT", -5, -5)
			editbox.__bg:SetPoint("BOTTOMRIGHT", 5, 5)
		end

		local check = dialog.UsesSharedActionBars
		if check then
			B.ReskinCheck(check.CheckButton)
			check.CheckButton.bg:SetInside(nil, 6, 6)
		end
	end

	local dialog = HeroTalentsSelectionDialog
	if dialog then
		B.StripTextures(dialog)
		B.SetBD(dialog)
		B.ReskinClose(dialog.CloseButton)

		hooksecurefunc(dialog, "ShowDialog", function(self)
			for specFrame in self.SpecContentFramePool:EnumerateActive() do
				if not specFrame.styled then
					B.ReskinButton(specFrame.ActivateButton)
					B.ReskinButton(specFrame.ApplyChangesButton)
					specFrame.styled = true
				end
			end
		end)
	end

	local spellBook = PlayerSpellsFrame.SpellBookFrame
	if spellBook then
		B.StripTextures(spellBook)

		for i = 1, 3 do
			local tab = select(i, spellBook.CategoryTabSystem:GetChildren())
			B.ReskinTab(tab, true)
		end
		B.ReskinArrow(spellBook.PagedSpellsFrame.PagingControls.PrevPageButton, "left")
		B.ReskinArrow(spellBook.PagedSpellsFrame.PagingControls.NextPageButton, "right")
		spellBook.PagedSpellsFrame.PagingControls.PageText:SetTextColor(1, 1, 1)

		B.ReskinInput(spellBook.SearchBox)
		spellBook.SearchBox.__bg:SetPoint("TOPLEFT", -5, -3)
		spellBook.SearchBox.__bg:SetPoint("BOTTOMRIGHT", 2, 3)

		hooksecurefunc(spellBook.PagedSpellsFrame, "DisplayViewsForCurrentPage", function(self)
			for _, frame in self:EnumerateFrames() do
				if not frame.styled then
					if frame.Text then
						frame.Text:SetTextColor(1, .8, 0)
					end
					if frame.Name then
						frame.Name:SetTextColor(1, 1, 1)
					end
					if frame.SubName then
						frame.SubName:SetTextColor(.7, .7, .7)
					end

					frame.styled = true
				end
			end
		end)

		local button = spellBook.AssistedCombatRotationSpellFrame.Button
		if button then
			B.CleanTextures(button)

			local bg = B.ReskinIcon(button.Icon)
			B.ReskinHLTex(button, bg)
		end
	end
end