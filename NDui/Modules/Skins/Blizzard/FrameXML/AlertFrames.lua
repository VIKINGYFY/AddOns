local _, ns = ...
local B, C, L, DB = unpack(ns)

-- Fix Alertframe bg
local function fixBg(frame)
	if frame:IsObjectType("AnimationGroup") then
		frame = frame:GetParent()
	end
	if frame.bg then
		frame.bg:SetBackdropColor(0, 0, 0, C.db["Skins"]["SkinAlpha"])
		if frame.bg.__shadow then
			frame.bg.__shadow:SetBackdropBorderColor(0, 0, 0, .5)
		end
	end
end

local function fixParentbg(anim)
	local frame = anim.__owner
	if frame.bg then
		frame.bg:SetBackdropColor(0, 0, 0, C.db["Skins"]["SkinAlpha"])
		if frame.bg.__shadow then
			frame.bg.__shadow:SetBackdropBorderColor(0, 0, 0, .5)
		end
	end
end

local function fixAnim(frame)
	if frame.hooked then return end

	frame:HookScript("OnEnter", fixBg)
	frame:HookScript("OnShow", fixBg)
	frame.animIn:HookScript("OnFinished", fixBg)
	if frame.animArrows then
		frame.animArrows:HookScript("OnPlay", fixBg)
		frame.animArrows:HookScript("OnFinished", fixBg)
	end
	if frame.Arrows and frame.Arrows.ArrowsAnim then
		frame.Arrows.ArrowsAnim.__owner = frame
		frame.Arrows.ArrowsAnim:HookScript("OnPlay", fixParentbg)
		frame.Arrows.ArrowsAnim:HookScript("OnFinished", fixParentbg)
	end

	frame.hookded = true
end

C.OnLoginThemes["AlertFrames"] = function()
	-- AlertFrames
	hooksecurefunc("AlertFrame_PauseOutAnimation", fixBg)

	local AlertTemplateFunc = {
		[AchievementAlertSystem] = function(frame)
			if not frame.bg then
				frame.bg = B.CreateBG(frame)
				frame.Unlocked:SetTextColor(1, .8, 0)
				frame.Unlocked:SetFontObject(NumberFont_GameNormal)
				frame.GuildName:ClearAllPoints()
				frame.GuildName:SetPoint("TOPLEFT", 50, -14)
				frame.GuildName:SetPoint("TOPRIGHT", -50, -14)
				B.ReskinIcon(frame.Icon.Texture)

				frame.GuildBanner:SetTexture(nil)
				frame.GuildBorder:SetTexture(nil)
				frame.Icon.Bling:SetTexture(nil)
			end
			frame.glow:SetTexture(nil)
			frame.Background:SetTexture(nil)
			frame.Icon.Overlay:SetTexture(nil)
			if frame.GuildBanner:IsShown() then
				frame.bg:SetPoint("TOPLEFT", 2, -29)
				frame.bg:SetPoint("BOTTOMRIGHT", -2, 4)
			else
				frame.bg:SetPoint("TOPLEFT", frame, -2, -17)
				frame.bg:SetPoint("BOTTOMRIGHT", 2, 12)
			end
		end,
		[CriteriaAlertSystem] = function(frame)
			if not frame.bg then
				frame.bg = B.CreateBG(frame)
				frame.bg:SetPoint("TOPLEFT", frame, 5, -7)
				frame.bg:SetPoint("BOTTOMRIGHT", frame, 18, 10)

				frame.Unlocked:SetTextColor(1, .8, 0)
				frame.Unlocked:SetFontObject(NumberFont_GameNormal)
				B.ReskinIcon(frame.Icon.Texture)
				frame.Background:SetTexture(nil)
				frame.Icon.Bling:SetTexture(nil)
				frame.Icon.Overlay:SetTexture(nil)
				frame.glow:SetTexture(nil)
				frame.shine:SetTexture(nil)
			end
		end,
		[LootAlertSystem] = function(frame)
			local lootItem = frame.lootItem
			if not frame.bg then
				frame.bg = B.CreateBG(frame)
				frame.bg:SetPoint("TOPLEFT", frame, 13, -15)
				frame.bg:SetPoint("BOTTOMRIGHT", frame, -13, 13)

				B.ReskinIcon(lootItem.Icon)
				lootItem.Icon:SetInside()
				lootItem.IconOverlay:SetInside()
				lootItem.IconOverlay2:SetInside()
				lootItem.SpecRing:SetTexture(nil)
				lootItem.SpecIcon:SetPoint("TOPLEFT", lootItem.Icon, -5, 5)
				lootItem.SpecIcon.bg = B.ReskinIcon(lootItem.SpecIcon)
			end
			frame.glow:SetTexture(nil)
			frame.shine:SetTexture(nil)
			frame.Background:SetTexture(nil)
			frame.PvPBackground:SetTexture(nil)
			frame.BGAtlas:SetTexture(nil)
			lootItem.IconBorder:SetTexture(nil)
			lootItem.SpecIcon.bg:SetShown(lootItem.SpecIcon:IsShown() and lootItem.SpecIcon:GetTexture() ~= nil)
		end,
		[LootUpgradeAlertSystem] = function(frame)
			if not frame.bg then
				frame.bg = B.CreateBG(frame)
				frame.bg:SetPoint("TOPLEFT", 10, -14)
				frame.bg:SetPoint("BOTTOMRIGHT", -10, 12)

				B.ReskinIcon(frame.Icon)
				frame.Icon:ClearAllPoints()
				frame.Icon:SetPoint("CENTER", frame.BaseQualityBorder)

				frame.BaseQualityBorder:SetSize(52, 52)
				frame.BaseQualityBorder:SetTexture(DB.bdTex)
				frame.UpgradeQualityBorder:SetTexture(DB.bdTex)
				frame.UpgradeQualityBorder:SetSize(52, 52)
				frame.Background:SetTexture(nil)
				frame.Sheen:SetTexture(nil)
				frame.BorderGlow:SetTexture(nil)
			end
			frame.BaseQualityBorder:SetTexture(nil)
			frame.UpgradeQualityBorder:SetTexture(nil)
		end,
		[MoneyWonAlertSystem] = function(frame)
			if not frame.bg then
				frame.bg = B.CreateBG(frame)
				frame.bg:SetInside(frame, 7, 7)

				B.ReskinIcon(frame.Icon)
				frame.Background:SetTexture(nil)
				frame.IconBorder:SetTexture(nil)
			end
		end,
		[NewRecipeLearnedAlertSystem] = function(frame)
			if not frame.bg then
				frame.bg = B.CreateBG(frame)
				frame.bg:SetPoint("TOPLEFT", 10, -5)
				frame.bg:SetPoint("BOTTOMRIGHT", -10, 5)

				frame:GetRegions():SetTexture(nil)
				B.CreateBDFrame(frame.Icon, .25, nil, -1)
				frame.glow:SetTexture(nil)
				frame.shine:SetTexture(nil)
			end
			frame.Icon:SetMask("")
			frame.Icon:SetTexCoord(unpack(DB.TexCoord))
		end,
		[WorldQuestCompleteAlertSystem] = function(frame)
			if not frame.bg then
				frame.bg = B.CreateBG(frame)
				frame.bg:SetPoint("TOPLEFT", 4, -7)
				frame.bg:SetPoint("BOTTOMRIGHT", -4, 8)

				B.ReskinIcon(frame.QuestTexture)
				frame.shine:SetTexture(nil)
				frame:DisableDrawLayer("BORDER")
				frame.ToastText:SetFontObject(NumberFont_GameNormal)
			end
		end,
		[GarrisonTalentAlertSystem] = function(frame)
			if not frame.bg then
				frame.bg = B.CreateBG(frame)
				frame.bg:SetPoint("TOPLEFT", 10, -10)
				frame.bg:SetPoint("BOTTOMRIGHT", -10, 13)

				B.ReskinIcon(frame.Icon)
				frame:GetRegions():Hide()
				frame.glow:SetTexture(nil)
				frame.shine:SetTexture(nil)
			end
		end,
		[GarrisonFollowerAlertSystem] = function(frame)
			if not frame.bg then
				frame.bg = B.CreateBG(frame)
				frame.bg:SetPoint("TOPLEFT", 16, -3)
				frame.bg:SetPoint("BOTTOMRIGHT", -16, 16)

				frame:GetRegions():Hide()
				select(5, frame:GetRegions()):Hide()
				B.ReskinGarrisonPortrait(frame.PortraitFrame)
				frame.PortraitFrame:ClearAllPoints()
				frame.PortraitFrame:SetPoint("TOPLEFT", 22, -8)

				frame.glow:SetTexture(nil)
				frame.shine:SetTexture(nil)
			end
			frame.FollowerBG:SetTexture(nil)
		end,
		[GarrisonMissionAlertSystem] = function(frame)
			if not frame.bg then
				frame.bg = B.CreateBG(frame)
				frame.bg:SetPoint("TOPLEFT", 8, -8)
				frame.bg:SetPoint("BOTTOMRIGHT", -8, 10)

				if frame.Blank then frame.Blank:Hide() end
				if frame.IconBG then frame.IconBG:Hide() end
				frame.Background:Hide()
				frame.glow:SetTexture(nil)
				frame.shine:SetTexture(nil)
			end

			-- Anchor fix in 8.2
			if frame.Level then
				local showItemLevel = frame.ItemLevel:IsShown()
				local isRareMission = frame.Rare:IsShown()

				if showItemLevel and isRareMission then
					frame.Level:SetPoint("TOP", frame, "TOP", -115, -14)
					frame.ItemLevel:SetPoint("TOP", frame, "TOP", -115, -37)
					frame.Rare:SetPoint("TOP", frame, "TOP", -115, -48)
				elseif isRareMission then
					frame.Level:SetPoint("TOP", frame, "TOP", -115, -19)
					frame.Rare:SetPoint("TOP", frame, "TOP", -115, -45)
				elseif showItemLevel then
					frame.Level:SetPoint("TOP", frame, "TOP", -115, -19)
					frame.ItemLevel:SetPoint("TOP", frame, "TOP", -115, -45)
				else
					frame.Level:SetPoint("TOP", frame, "TOP", -115, -28)
				end
			end
		end,
		[DigsiteCompleteAlertSystem] = function(frame)
			if not frame.bg then
				frame.bg = B.CreateBG(frame)
				frame.bg:SetInside(frame, 8, 8)

				frame:GetRegions():Hide()
				frame.glow:SetTexture(nil)
				frame.shine:SetTexture(nil)
			end
		end,
		[GuildChallengeAlertSystem] = function(frame)
			if not frame.bg then
				frame.bg = B.CreateBG(frame)
				frame.bg:SetPoint("TOPLEFT", 8, -13)
				frame.bg:SetPoint("BOTTOMRIGHT", -8, 13)

				select(2, frame:GetRegions()):SetTexture(nil)
				frame.glow:SetTexture(nil)
				frame.shine:SetTexture(nil)
			end
		end,
		[DungeonCompletionAlertSystem] = function(frame)
			if not frame.bg then
				frame.bg = B.CreateBG(frame)
				frame.bg:SetPoint("TOPLEFT", 3, -8)
				frame.bg:SetPoint("BOTTOMRIGHT", -3, 8)

				B.ReskinIcon(frame.dungeonTexture)
				frame:DisableDrawLayer("Border")
				frame.heroicIcon:SetTexture(nil)
				frame.glowFrame.glow:SetTexture(nil)
				frame.shine:SetTexture(nil)
			end
		end,
		[ScenarioAlertSystem] = function(frame)
			if not frame.bg then
				frame.bg = B.CreateBG(frame)
				frame.bg:SetInside(frame, 5, 5)

				B.ReskinIcon(frame.dungeonTexture)
				frame:GetRegions():Hide()
				select(3, frame:GetRegions()):Hide()
				frame.glowFrame.glow:SetTexture(nil)
				frame.shine:SetTexture(nil)
			end
		end,
		[LegendaryItemAlertSystem] = function(frame)
			if not frame.bg then
				frame.bg = B.CreateBG(frame)
				frame.bg:SetPoint("TOPLEFT", 25, -22)
				frame.bg:SetPoint("BOTTOMRIGHT", -25, 24)
				frame:HookScript("OnUpdate", fixBg)

				B.ReskinIcon(frame.Icon)
				frame.Icon:ClearAllPoints()
				frame.Icon:SetPoint("TOPLEFT", frame.bg, 10, -10)

				frame.Background:SetTexture(nil)
				frame.Background2:SetTexture(nil)
				frame.Background3:SetTexture(nil)
				frame.glow:SetTexture(nil)
			end
		end,
		[NewPetAlertSystem] = function(frame)
			if not frame.bg then
				frame.bg = B.CreateBG(frame)
				frame.bg:SetPoint("TOPLEFT", 12, -13)
				frame.bg:SetPoint("BOTTOMRIGHT", -12, 10)

				B.ReskinIcon(frame.Icon)
				frame.IconBorder:Hide()
				frame.Background:SetTexture(nil)
				frame.shine:SetTexture(nil)
			end
		end,
		[InvasionAlertSystem] = function(frame)
			if not frame.bg then
				frame.bg = B.CreateBG(frame)
				frame.bg:SetInside(frame, 5, 5)

				local bg, icon = frame:GetRegions()
				bg:Hide()
				B.ReskinIcon(icon)
			end
		end,
		[EntitlementDeliveredAlertSystem] = function(frame)
			if not frame.bg then
				frame.bg = B.CreateBG(frame)
				frame.bg:SetInside(frame, 12, 12)

				B.ReskinIcon(frame.Icon)
				frame.Title:SetTextColor(0, 1, 1)
				frame.Background:Hide()
			end
		end,
		[RafRewardDeliveredAlertSystem] = function(frame)
			if not frame.bg then
				frame.bg = B.CreateBG(frame)
				frame.bg:SetPoint("TOPLEFT", 24, -14)
				frame.bg:SetPoint("BOTTOMRIGHT", -24, 8)

				B.ReskinIcon(frame.Icon)
				frame.StandardBackground:SetTexture(nil)
			end
		end,
	}

	AlertTemplateFunc[HonorAwardedAlertSystem] = AlertTemplateFunc[MoneyWonAlertSystem]
	AlertTemplateFunc[MonthlyActivityAlertSystem] = AlertTemplateFunc[CriteriaAlertSystem]
	AlertTemplateFunc[GarrisonBuildingAlertSystem] = AlertTemplateFunc[GarrisonTalentAlertSystem]
	AlertTemplateFunc[SkillLineSpecsUnlockedAlertSystem] = AlertTemplateFunc[NewRecipeLearnedAlertSystem]

	AlertTemplateFunc[GarrisonShipMissionAlertSystem] = AlertTemplateFunc[GarrisonMissionAlertSystem]
	AlertTemplateFunc[GarrisonShipFollowerAlertSystem] = AlertTemplateFunc[GarrisonMissionAlertSystem]
	AlertTemplateFunc[GarrisonRandomMissionAlertSystem] = AlertTemplateFunc[GarrisonMissionAlertSystem]

	AlertTemplateFunc[NewToyAlertSystem] = AlertTemplateFunc[NewPetAlertSystem]
	AlertTemplateFunc[NewMountAlertSystem] = AlertTemplateFunc[NewPetAlertSystem]
	AlertTemplateFunc[NewRuneforgePowerAlertSystem] = AlertTemplateFunc[NewPetAlertSystem]
	AlertTemplateFunc[NewCosmeticAlertFrameSystem] = AlertTemplateFunc[NewPetAlertSystem]
	AlertTemplateFunc[NewWarbandSceneAlertSystem] = AlertTemplateFunc[NewPetAlertSystem]

	hooksecurefunc(AlertFrame, "AddAlertFrame", function(_, frame)
		local func = AlertTemplateFunc[frame.queue]
		if func then
			func(frame)
			fixAnim(frame)
		end
	end)

	-- Reward Icons
	hooksecurefunc("StandardRewardAlertFrame_AdjustRewardAnchors", function(frame)
		if frame.RewardFrames then
			for i = 1, frame.numUsedRewardFrames do
				local reward = frame.RewardFrames[i]
				if not reward.bg then
					select(2, reward:GetRegions()):SetTexture(nil)
					reward.texture:ClearAllPoints()
					reward.texture:SetInside(reward, 6, 6)
					reward.bg = B.ReskinIcon(reward.texture)
				end
			end
		end
	end)

	-- BonusRollLootWonFrame
	hooksecurefunc("LootWonAlertFrame_SetUp", function(frame)
		local lootItem = frame.lootItem
		if not frame.bg then
			frame.bg = B.CreateBG(frame)
			frame.bg:SetInside(frame, 10, 10)
			fixAnim(frame)

			frame.shine:SetTexture(nil)
			B.ReskinIcon(lootItem.Icon)

			lootItem.SpecRing:SetTexture(nil)
			lootItem.SpecIcon:SetPoint("TOPLEFT", lootItem.Icon, -5, 5)
			lootItem.SpecIcon.bg = B.ReskinIcon(lootItem.SpecIcon)
		end

		frame.glow:SetTexture(nil)
		frame.Background:SetTexture(nil)
		frame.PvPBackground:SetTexture(nil)
		frame.BGAtlas:SetAlpha(0)
		lootItem.IconBorder:SetTexture(nil)
		lootItem.SpecIcon.bg:SetShown(lootItem.SpecIcon:IsShown() and lootItem.SpecIcon:GetTexture() ~= nil)
	end)

	-- BonusRollMoneyWonFrame
	hooksecurefunc("MoneyWonAlertFrame_SetUp", function(frame)
		if not frame.bg then
			frame.bg = B.CreateBG(frame)
			frame.bg:SetInside(frame, 5, 5)
			fixAnim(frame)

			frame.Background:SetTexture(nil)
			B.ReskinIcon(frame.Icon)
			frame.IconBorder:SetTexture(nil)
		end
	end)

	--[=[ Event toast, seems unnecessary

	hooksecurefunc(EventToastManagerFrame, "DisplayToast", function(self)
		local toast = self.currentDisplayingToast
		if not toast then return end

		local icon = toast.Icon
		local border = toast.IconBorder
		if icon and not toast.bg then
			toast.bg = B.ReskinIcon(icon)
			if border then
				border:SetTexture(nil)
				B.ReskinBorder(border, true)
			end
		end

		if toast.bg then
			toast.bg:SetShown(icon and icon:IsShown() and icon:GetTexture() ~= nil)
		end
	end)
	]=]
end