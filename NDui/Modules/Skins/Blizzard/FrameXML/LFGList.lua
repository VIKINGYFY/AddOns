local _, ns = ...
local B, C, L, DB = unpack(ns)

local function Highlight_OnEnter(self)
	self.hl:Show()
end

local function Highlight_OnLeave(self)
	self.hl:Hide()
end

local function HandleRoleAnchor(self, role)
	self[role.."Count"]:SetWidth(24)
	self[role.."Count"]:SetFontObject(Game13Font)
	self[role.."Count"]:SetPoint("RIGHT", self[role.."Icon"], "LEFT", 1, 0)
end

table.insert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	local cr, cg, cb = DB.r, DB.g, DB.b

	local LFGListFrame = LFGListFrame
	LFGListFrame.NothingAvailable.Inset:Hide()

	-- [[ Category selection ]]

	local categorySelection = LFGListFrame.CategorySelection

	B.ReskinButton(categorySelection.FindGroupButton)
	B.ReskinButton(categorySelection.StartGroupButton)
	categorySelection.Inset:Hide()
	categorySelection.CategoryButtons[1]:SetNormalFontObject(GameFontNormal)

	hooksecurefunc("LFGListCategorySelection_AddButton", function(self, btnIndex)
		local bu = self.CategoryButtons[btnIndex]
		if bu and not bu.styled then
			bu.Cover:Hide()
			bu.Icon:SetTexCoord(.01, .99, .01, .99)
			B.CreateBDFrame(bu.Icon, .25, nil, -C.mult)

			bu.styled = true
		end
	end)

	hooksecurefunc("LFGListSearchEntry_Update", function(self)
		local cancelButton = self.CancelButton
		if not cancelButton.styled then
			B.ReskinButton(cancelButton)
			cancelButton.styled = true
		end
	end)

	hooksecurefunc("LFGListSearchEntry_UpdateExpiration", function(self)
		local expirationTime = self.ExpirationTime
		if not expirationTime.fontStyled then
			expirationTime:SetWidth(42)
			expirationTime.fontStyled = true
		end
	end)

	-- [[ Search panel ]]

	local searchPanel = LFGListFrame.SearchPanel

	B.ReskinButton(searchPanel.RefreshButton)
	B.ReskinButton(searchPanel.BackButton)
	B.ReskinButton(searchPanel.BackToGroupButton)
	B.ReskinButton(searchPanel.SignUpButton)
	B.ReskinInput(searchPanel.SearchBox)
	searchPanel.SearchBox:SetHeight(22)
	B.ReskinFilterButton(searchPanel.FilterButton)
	B.ReskinFilterReset(searchPanel.FilterButton.ResetButton)

	searchPanel:HookScript("OnShow", function(self)
		self.FilterButton:SetSize(90, 21) -- needs review, fix blizzard weired size
	end)

	searchPanel.RefreshButton:SetSize(24, 24)
	searchPanel.RefreshButton.Icon:SetPoint("CENTER")
	searchPanel.ResultsInset:Hide()
	B.StripTextures(searchPanel.AutoCompleteFrame)

	local numResults = 1
	hooksecurefunc("LFGListSearchPanel_UpdateAutoComplete", function(self)
		local AutoCompleteFrame = self.AutoCompleteFrame

		for i = numResults, #AutoCompleteFrame.Results do
			local result = AutoCompleteFrame.Results[i]

			if numResults == 1 then
				result:SetPoint("TOPLEFT", AutoCompleteFrame.LeftBorder, "TOPRIGHT", -8, 1)
				result:SetPoint("TOPRIGHT", AutoCompleteFrame.RightBorder, "TOPLEFT", 5, 1)
			else
				result:SetPoint("TOPLEFT", AutoCompleteFrame.Results[i-1], "BOTTOMLEFT", 0, 1)
				result:SetPoint("TOPRIGHT", AutoCompleteFrame.Results[i-1], "BOTTOMRIGHT", 0, 1)
			end

			result:SetNormalTexture(0)
			result:SetPushedTexture(0)
			result:SetHighlightTexture(0)

			local bg = B.CreateBDFrame(result, .25)
			local hl = result:CreateTexture(nil, "BACKGROUND")
			hl:SetInside(bg)
			hl:SetTexture(DB.bdTex)
			hl:SetVertexColor(cr, cg, cb, .25)
			hl:Hide()
			result.hl = hl

			result:HookScript("OnEnter", Highlight_OnEnter)
			result:HookScript("OnLeave", Highlight_OnLeave)

			numResults = numResults + 1
		end
	end)

	local function skinCreateButton(button)
		local child = button:GetChildren()
		if not child.styled and child:IsObjectType("Button") then
			B.ReskinButton(child)
			child.styled = true
		end
	end

	local delayStyled -- otherwise it taints while listing
	hooksecurefunc(searchPanel.ScrollBox, "Update", function(self)
		if not delayStyled then
			B.ReskinButton(self.StartGroupButton)
			B.ReskinScroll(searchPanel.ScrollBar)
			delayStyled = true
		end
		self:ForEachFrame(skinCreateButton)
	end)

	-- [[ Application viewer ]]

	local applicationViewer = LFGListFrame.ApplicationViewer
	applicationViewer.InfoBackground:Hide()
	applicationViewer.Inset:Hide()

	local prevHeader
	for _, headerName in pairs({"NameColumnHeader", "RoleColumnHeader", "ItemLevelColumnHeader", "RatingColumnHeader"}) do
		local header = applicationViewer[headerName]

		B.StripTextures(header)
		B.SetFontSize(header.Label, 14)
		header.Label:SetShadowColor(0, 0, 0, 0)
		header:SetHighlightTexture(0)

		local bg = B.CreateBDFrame(header, .25)
		local hl = header:CreateTexture(nil, "BACKGROUND")
		hl:SetInside(bg)
		hl:SetTexture(DB.bdTex)
		hl:SetVertexColor(cr, cg, cb, .25)
		hl:Hide()
		header.hl = hl

		header:HookScript("OnEnter", Highlight_OnEnter)
		header:HookScript("OnLeave", Highlight_OnLeave)

		if prevHeader then
			header:SetPoint("LEFT", prevHeader, "RIGHT", C.mult, 0)
		end
		prevHeader = header
	end

	B.ReskinButton(applicationViewer.RefreshButton)
	B.ReskinButton(applicationViewer.RemoveEntryButton)
	B.ReskinButton(applicationViewer.EditButton)
	B.ReskinButton(applicationViewer.BrowseGroupsButton)
	B.ReskinCheck(applicationViewer.AutoAcceptButton)
	B.ReskinScroll(applicationViewer.ScrollBar)

	applicationViewer.RefreshButton:SetSize(24, 24)
	applicationViewer.RefreshButton.Icon:SetPoint("CENTER")

	hooksecurefunc("LFGListApplicationViewer_UpdateApplicant", function(button)
		if not button.styled then
			B.ReskinButton(button.DeclineButton)
			B.ReskinButton(button.InviteButton)
			B.ReskinButton(button.InviteButtonSmall)

			button.styled = true
		end
	end)

	-- [[ Entry creation ]]

	local entryCreation = LFGListFrame.EntryCreation
	entryCreation.Inset:Hide()
	B.StripTextures(entryCreation.Description)
	B.ReskinButton(entryCreation.ListGroupButton)
	B.ReskinButton(entryCreation.CancelButton)
	B.ReskinInput(entryCreation.Description)
	B.ReskinInput(entryCreation.Name)
	B.ReskinInput(entryCreation.ItemLevel.EditBox)
	B.ReskinInput(entryCreation.VoiceChat.EditBox)
	B.ReskinDropDown(entryCreation.GroupDropdown)
	B.ReskinDropDown(entryCreation.ActivityDropdown)
	B.ReskinDropDown(entryCreation.PlayStyleDropdown)
	B.ReskinCheck(entryCreation.MythicPlusRating.CheckButton)
	B.ReskinInput(entryCreation.MythicPlusRating.EditBox)
	B.ReskinCheck(entryCreation.PVPRating.CheckButton)
	B.ReskinInput(entryCreation.PVPRating.EditBox)
	if entryCreation.PvpItemLevel then -- I do believe blizz will rename Pvp into PvP in future build
		B.ReskinCheck(entryCreation.PvpItemLevel.CheckButton)
		B.ReskinInput(entryCreation.PvpItemLevel.EditBox)
	end
	B.ReskinCheck(entryCreation.ItemLevel.CheckButton)
	B.ReskinCheck(entryCreation.VoiceChat.CheckButton)
	B.ReskinCheck(entryCreation.PrivateGroup.CheckButton)
	B.ReskinCheck(entryCreation.CrossFactionGroup.CheckButton)

	-- [[ Role count ]]

	hooksecurefunc("LFGListGroupDataDisplayRoleCount_Update", function(self)
		if not self.styled then
			B.ReskinSmallRole(self.TankIcon, "TANK")
			B.ReskinSmallRole(self.HealerIcon, "HEALER")
			B.ReskinSmallRole(self.DamagerIcon, "DPS")
			-- fix for PGFinder
			self.DamagerIcon:ClearAllPoints()
			self.DamagerIcon:SetPoint("RIGHT", -11, 0)

			self.HealerIcon:SetPoint("RIGHT", self.DamagerIcon, "LEFT", -22, 0)
			self.TankIcon:SetPoint("RIGHT", self.HealerIcon, "LEFT", -22, 0)

			HandleRoleAnchor(self, "Tank")
			HandleRoleAnchor(self, "Healer")
			HandleRoleAnchor(self, "Damager")

			self.styled = true
		end
	end)

	hooksecurefunc("LFGListGroupDataDisplayPlayerCount_Update", function(self)
		if not self.styled then
			self.Count:SetWidth(24)

			self.styled = true
		end
	end)

	-- Activity finder

	local activityFinder = entryCreation.ActivityFinder
	activityFinder.Background:SetTexture("")

	local finderDialog = activityFinder.Dialog
	B.StripTextures(finderDialog)
	B.SetBD(finderDialog)
	B.ReskinButton(finderDialog.SelectButton)
	B.ReskinButton(finderDialog.CancelButton)
	B.ReskinInput(finderDialog.EntryBox)
	B.ReskinScroll(finderDialog.ScrollBar)

	-- [[ Application dialog ]]

	local LFGListApplicationDialog = LFGListApplicationDialog

	B.StripTextures(LFGListApplicationDialog)
	B.SetBD(LFGListApplicationDialog)
	B.StripTextures(LFGListApplicationDialog.Description)
	B.CreateBDFrame(LFGListApplicationDialog.Description, .25)
	B.ReskinButton(LFGListApplicationDialog.SignUpButton)
	B.ReskinButton(LFGListApplicationDialog.CancelButton)

	-- [[ Invite dialog ]]

	local LFGListInviteDialog = LFGListInviteDialog

	B.StripTextures(LFGListInviteDialog)
	B.SetBD(LFGListInviteDialog)
	B.ReskinButton(LFGListInviteDialog.AcceptButton)
	B.ReskinButton(LFGListInviteDialog.DeclineButton)
	B.ReskinButton(LFGListInviteDialog.AcknowledgeButton)
end)