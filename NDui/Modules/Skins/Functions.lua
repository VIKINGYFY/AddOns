local _, ns = ...
local B, C, L, DB = unpack(ns)
local S = B:RegisterModule("Skins")

do
	function S:GetToggleDirection()
		local direc = C.db["Skins"]["ToggleDirection"]
		if direc == 1 then
			return ">", "<", "RIGHT", "LEFT", -DB.margin, 0, 20, 80
		elseif direc == 2 then
			return "<", ">", "LEFT", "RIGHT", DB.margin, 0, 20, 80
		elseif direc == 3 then
			return "∨", "∧", "BOTTOM", "TOP", 0, DB.margin, 80, 20
		else
			return "∧", "∨", "TOP", "BOTTOM", 0, -DB.margin, 80, 20
		end
	end

	local toggleFrames = {}

	local function CreateToggleButton(parent)
		local bu = CreateFrame("Button", nil, parent)
		bu:SetSize(20, 80)
		bu.text = B.CreateFS(bu, 18, nil, true)
		B.ReskinMenuButton(bu)

		return bu
	end

	function S:CreateToggle(frame)
		local close = CreateToggleButton(frame)
		frame.closeButton = close

		local open = CreateToggleButton(UIParent)
		open:Hide()
		frame.openButton = open

		open:SetScript("OnClick", function()
			open:Hide()
		end)
		close:SetScript("OnClick", function()
			open:Show()
		end)

		S:SetToggleDirection(frame)
		table.insert(toggleFrames, frame)

		return open, close
	end

	function S:SetToggleDirection(frame)
		local str1, str2, rel1, rel2, x, y, width, height = S:GetToggleDirection()
		local parent = frame.bg
		local close = frame.closeButton
		local open = frame.openButton
		close:ClearAllPoints()
		close:SetPoint(rel1, parent, rel2, x, y)
		close:SetSize(width, height)
		open:ClearAllPoints()
		open:SetPoint(rel1, parent, rel1, -x, -y)
		open:SetSize(width, height)

		if C.db["Skins"]["ToggleDirection"] == 5 then
			close:SetScale(.001)
			close:SetAlpha(0)
			open:SetScale(.001)
			open:SetAlpha(0)
			close.text:SetText("")
			open.text:SetText("")
		else
			close:SetScale(1)
			close:SetAlpha(1)
			open:SetScale(1)
			open:SetAlpha(1)
			close.text:SetText(str1)
			open.text:SetText(str2)
		end
	end

	function S:RefreshToggleDirection()
		for _, frame in pairs(toggleFrames) do
			S:SetToggleDirection(frame)
		end
	end

	function B:ReskinIconSelector()
		B.StripTextures(self)
		B.CreateBG(self):SetInside()
		B.StripTextures(self.BorderBox)
		B.StripTextures(self.BorderBox.IconSelectorEditBox, 2)
		B.ReskinInput(self.BorderBox.IconSelectorEditBox)
		B.StripTextures(self.BorderBox.SelectedIconArea.SelectedIconButton)
		B.ReskinIcon(self.BorderBox.SelectedIconArea.SelectedIconButton.Icon)
		B.ReskinButton(self.BorderBox.OkayButton)
		B.ReskinButton(self.BorderBox.CancelButton)
		B.ReskinDropDown(self.BorderBox.IconTypeDropdown)
		B.ReskinScroll(self.IconSelector.ScrollBar)

		hooksecurefunc(self.IconSelector.ScrollBox, "Update", function(self)
			for i = 1, self.ScrollTarget:GetNumChildren() do
				local child = select(i, self.ScrollTarget:GetChildren())
				if child.Icon and not child.styled then
					child:DisableDrawLayer("BACKGROUND")
					child.SelectedTexture:SetColorTexture(1, 1, 0, .5)
					child.SelectedTexture:SetAllPoints(child.Icon)
					local hl = child:GetHighlightTexture()
					hl:SetColorTexture(1, 1, 1, .25)
					hl:SetAllPoints(child.Icon)
					B.ReskinIcon(child.Icon)

					child.styled = true
				end
			end
		end)
	end

	function B:ReskinModelControl()
		for i = 1, 5 do
			local button = select(i, self.ControlFrame:GetChildren())
			if button.NormalTexture then
				button.NormalTexture:SetAlpha(0)
				button.PushedTexture:SetAlpha(0)
			end
		end
	end

	function B:ReplaceIconString(text)
		if not text then text = self:GetText() end
		if not text or text == "" then return end

		local newText, count = string.gsub(text, "|T([^:]-):[%d+:]+|t", "|T%1:14:14:0:0:64:64:5:59:5:59|t")
		if count > 0 then self:SetFormattedText("%s", newText) end
	end

	local flyoutFrame

	local function reskinFlyoutButton(button)
		if not button.styled then
			button.bg = B.ReskinIcon(button.icon)
			button:SetNormalTexture(0)
			button:SetPushedTexture(0)
			button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
			B.ReskinBorder(button.IconBorder, true)

			button.styled = true
		end
	end

	local function refreshFlyoutButtons(self)
		for i = 1, self.ScrollTarget:GetNumChildren() do
			local button = select(i, self.ScrollTarget:GetChildren())
			if button.IconBorder then
				reskinFlyoutButton(button)
			end
		end
	end

	local function resetFrameStrata(frame)
		frame.bg:SetFrameStrata("LOW")
	end

	function B:ReskinProfessionsFlyout(parent)
		if flyoutFrame then return end

		for i = 1, parent:GetNumChildren() do
			local child = select(i, parent:GetChildren())
			local checkbox = child.HideUnownedCheckbox
			if checkbox then
				flyoutFrame = child

				B.StripTextures(flyoutFrame)
				flyoutFrame.bg = B.CreateBG(flyoutFrame)
				hooksecurefunc(flyoutFrame, "SetParent", resetFrameStrata)
				B.ReskinCheck(checkbox)
				checkbox.bg:SetInside(nil, 6, 6)
				B.ReskinScroll(flyoutFrame.ScrollBar)
				reskinFlyoutButton(flyoutFrame.UndoItem)
				hooksecurefunc(flyoutFrame.ScrollBox, "Update", refreshFlyoutButtons)

				break
			end
		end
	end

	function B:ReskinGarrisonTooltip()
		if self.Icon then B.ReskinIcon(self.Icon) end
		if self.CloseButton then B.ReskinClose(self.CloseButton) end
	end

	local ReplacedRoleTex = {
		["Adventures-Tank"] = "Soulbinds_Tree_Conduit_Icon_Protect",
		["Adventures-Healer"] = "ui_adv_health",
		["Adventures-DPS"] = "ui_adv_atk",
		["Adventures-DPS-Ranged"] = "Soulbinds_Tree_Conduit_Icon_Utility",
	}
	local function replaceFollowerRole(roleIcon, atlas)
		local newAtlas = ReplacedRoleTex[atlas]
		if newAtlas then
			roleIcon:SetAtlas(newAtlas)
		end
	end

	function B:ReskinGarrisonPortrait()
		local level = self.Level or self.LevelText
		if level then
			level:ClearAllPoints()
			level:SetPoint("BOTTOM", self, 0, 15)
			if self.LevelCircle then self.LevelCircle:Hide() end
			if self.LevelBorder then self.LevelBorder:SetScale(.0001) end
		end

		if self.LevelDisplayFrame then
			self.LevelDisplayFrame.LevelCircle:Hide()
		end

		self.squareBG = B.CreateBDFrame(self.Portrait, 1)

		if self.PortraitRing then
			self.PortraitRing:Hide()
			self.PortraitRingQuality:SetTexture(nil)
			self.PortraitRingCover:SetColorTexture(0, 0, 0)
			self.PortraitRingCover:SetAllPoints(self.squareBG)
		end

		if self.Empty then
			self.Empty:SetColorTexture(0, 0, 0)
			self.Empty:SetAllPoints(self.Portrait)
		end
		if self.Highlight then self.Highlight:Hide() end
		if self.PuckBorder then self.PuckBorder:SetAlpha(0) end
		if self.TroopStackBorder1 then self.TroopStackBorder1:SetAlpha(0) end
		if self.TroopStackBorder2 then self.TroopStackBorder2:SetAlpha(0) end

		if self.HealthBar then
			self.HealthBar.Border:Hide()

			local roleIcon = self.HealthBar.RoleIcon
			roleIcon:ClearAllPoints()
			roleIcon:SetPoint("CENTER", self.squareBG, "TOPRIGHT", -2, -2)
			replaceFollowerRole(roleIcon, roleIcon:GetAtlas())
			hooksecurefunc(roleIcon, "SetAtlas", replaceFollowerRole)

			local background = self.HealthBar.Background
			background:SetAlpha(0)
			background:ClearAllPoints()
			background:SetPoint("TOPLEFT", self.squareBG, "BOTTOMLEFT", C.mult, 6)
			background:SetPoint("BOTTOMRIGHT", self.squareBG, "BOTTOMRIGHT", -C.mult, C.mult)
			self.HealthBar.Health:SetTexture(DB.normTex)
		end
	end
end