local _, ns = ...
local B, C, L, DB = unpack(ns)
local S = B:GetModule("Skins")

function S:PGFSkin()
	if not C_AddOns.IsAddOnLoaded("PremadeGroupsFilter") then return end
	if not C.db["Skins"]["BlizzardSkins"] then return end

	local PGFDialog = _G.PremadeGroupsFilterDialog
	if not PGFDialog then return end

	local ArenaPanel = _G.PremadeGroupsFilterArenaPanel
	local DelvePanel = _G.PremadeGroupsFilterDelvePanel
	local DungeonPanel = _G.PremadeGroupsFilterDungeonPanel
	local MiniPanel = _G.PremadeGroupsFilterMiniPanel
	local RBGPanel = _G.PremadeGroupsFilterRBGPanel
	local RaidPanel = _G.PremadeGroupsFilterRaidPanel
	local RolePanel = _G.PremadeGroupsFilterRolePanel

	local function handleDropdown(drop)
		B.StripTextures(drop)

		local bg = B.CreateBDFrame(drop, 0, true)
		B.UpdateSize(bg, 16, -4, -18, 8)

		local down = drop.Button
		B.UpdatePoint(down, "RIGHT", bg, "RIGHT", -3, 0)
		B.StripTextures(down)
		B.SetupTexture(down, "down")
	end

	local names = {"BLFit", "BRFit", "Defeated", "DelveTier", "Difficulty", "DPS", "Heals", "MPRating", "MatchingId", "Members", "NeedsBL", "NotDeclined", "Partyfit", "PvPRating", "Tanks"}
	local function handleGroup(panel)
		for _, name in pairs(names) do
			local frame = panel.Group[name]
			if frame then
				local check = frame.Act
				if check then
					check:SetSize(26, 26)
					check:SetPoint("TOPLEFT", 5, 2)
					B.ReskinCheck(check)
				end
				if frame.Min and frame.Max then
					B.ReskinInput(frame.Min)
					B.ReskinInput(frame.Max)
				end
				if frame.DropDown then
					handleDropdown(frame.DropDown)
				end
			end
		end

		B.ReskinInput(panel.Advanced.Expression)
	end

	local selects = {"SelectNone", "SelectAll", "SelectBountiful"}
	local function handlePanel(panel, subPanel)
		local prevButton
		for _, name in pairs(selects) do
			local button = panel[name]
			if button then
				button:SetSize(18, 18)
				B.ReskinButton(button)

				if prevButton then
					B.UpdatePoint(button, "RIGHT", prevButton, "LEFT", -3, 0)
				else
					B.UpdatePoint(button, "RIGHT", PGFDialog.MaxMinButtonFrame.MinimizeButton, "LEFT", -3, 0)
				end

				prevButton = button
			end
		end

		for i = 1, 15 do
			local frame = panel[subPanel..i]
			local check = frame and frame.Act
			if check then
				check:SetSize(26, 26)
				check:SetPoint("TOPLEFT", 5, 2)
				B.ReskinCheck(check)
			end
		end
	end

	local styled
	hooksecurefunc(PGFDialog, "Show", function(self)
		if styled then return end
		styled = true

		B.ReskinFrame(self)
		B.ReskinButton(self.ResetButton)
		B.ReskinButton(self.RefreshButton)

		B.ReskinInput(MiniPanel.Advanced.Expression)
		B.ReskinInput(MiniPanel.Sorting.Expression)

		local button = self.MaxMinButtonFrame
		if button.MinimizeButton then
			B.ReskinArrow(button.MinimizeButton, "min")
			B.UpdatePoint(button.MinimizeButton, "RIGHT", self.CloseButton, "LEFT", -3, 0)

			B.ReskinArrow(button.MaximizeButton, "max")
			B.UpdatePoint(button.MaximizeButton, "RIGHT", self.CloseButton, "LEFT", -3, 0)
		end

		handleGroup(ArenaPanel)
		handleGroup(DelvePanel)
		handleGroup(DungeonPanel)
		handleGroup(RBGPanel)
		handleGroup(RaidPanel)
		handleGroup(RolePanel)

		handlePanel(DelvePanel.Delves, "Delve")
		handlePanel(DungeonPanel.Dungeons, "Dungeon")
	end)

	hooksecurefunc(PGFDialog, "ResetPosition", function(self)
		B.UpdatePoint(self, "TOPLEFT", PVEFrame, "TOPRIGHT", 3, 0)
	end)
--[[
	local PGFDialog = _G.PremadeGroupsFilterDialog

	local tipStyled
	hooksecurefunc(PremadeGroupsFilter.Debug, "PopupMenu_Initialize", function()
		if tipStyled then return end
		for i = 1, PGFDialog:GetNumChildren() do
			local child = select(i, PGFDialog:GetChildren())
			if child and child.Shadow then
				B.ReskinTooltip(child)
				tipStyled = true
				break
			end
		end
	end)
]]
	local button = UsePGFButton
	if button then
		B.ReskinCheck(button)
		button.text:SetWidth(35)
	end

	local popup = PremadeGroupsFilterStaticPopup
	if popup then
		B.StripTextures(popup)
		B.CreateBG(popup)
		B.ReskinInput(popup.EditBox)
		B.ReskinButton(popup.Button1)
		B.ReskinButton(popup.Button2)
	end
end