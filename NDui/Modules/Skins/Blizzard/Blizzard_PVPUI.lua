local _, ns = ...
local B, C, L, DB = unpack(ns)

local function ReskinPvPFrame(frame)
	frame:DisableDrawLayer("BACKGROUND")
	frame:DisableDrawLayer("BORDER")
	B.ReskinRole(frame.TankIcon, "TANK")
	B.ReskinRole(frame.HealerIcon, "HEALER")
	B.ReskinRole(frame.DPSIcon, "DPS")

	local bar = frame.ConquestBar
	B.ReskinStatusBar(bar)

	local reward = bar.Reward
	reward.Ring:Hide()
	reward.CircleMask:Hide()
	B.ReskinIcon(reward.Icon)
	if reward.CheckMark then
		reward.CheckMark:SetAtlas("checkmark-minimal")
	end
end

local function ConquestFrameButton_OnEnter(self)
	ConquestTooltip:ClearAllPoints()
	ConquestTooltip:SetPoint("TOPLEFT", self, "TOPRIGHT", 1, 0)
end

C.OnLoadThemes["Blizzard_PVPUI"] = function()
	local cr, cg, cb = DB.r, DB.g, DB.b

	local PVPQueueFrame = PVPQueueFrame
	local HonorFrame = HonorFrame
	local ConquestFrame = ConquestFrame

	-- Category buttons

	local iconSize = 60-2*C.mult
	for i = 1, 4 do
		local bu = PVPQueueFrame["CategoryButton"..i]
		if bu then
			local icon = bu.Icon
			local cu = bu.CurrencyDisplay

			bu.Ring:Hide()
			B.ReskinButton(bu)
			bu.Background:SetInside(bu.__bg)
			bu.Background:SetColorTexture(cr, cg, cb, .25)
			bu.Background:SetAlpha(1)

			icon:SetPoint("LEFT", bu, "LEFT")
			icon:SetSize(iconSize, iconSize)
			B.ReskinIcon(icon)

			if cu then
				local ic = cu.Icon

				ic:SetSize(16, 16)
				ic:SetPoint("TOPLEFT", bu.Name, "BOTTOMLEFT", 0, -8)
				cu.Amount:SetPoint("LEFT", ic, "RIGHT", 4, 0)
				B.ReskinIcon(ic)
			end
		end
	end

	PVPQueueFrame.CategoryButton1.Icon:SetTexture("Interface\\Icons\\achievement_bg_winwsg")
	PVPQueueFrame.CategoryButton2.Icon:SetTexture("Interface\\Icons\\achievement_bg_killxenemies_generalsroom")
	PVPQueueFrame.CategoryButton3.Icon:SetTexture("Interface\\Icons\\ability_warrior_offensivestance")

	hooksecurefunc("PVPQueueFrame_SelectButton", function(index)
		for i = 1, 3 do
			local bu = PVPQueueFrame["CategoryButton"..i]
			if i == index then
				bu.Background:Show()
			else
				bu.Background:Hide()
			end
		end
	end)

	PVPQueueFrame.CategoryButton1.Background:SetAlpha(1)
	B.StripTextures(PVPQueueFrame.HonorInset)
	PVPQueueFrame.HonorInset.Background:Hide()

	local popup = PVPQueueFrame.NewSeasonPopup
	B.ReskinButton(popup.Leave)
	popup.NewSeason:SetTextColor(1, .8, 0)
	popup.SeasonRewardText:SetTextColor(1, .8, 0)
	popup.SeasonDescriptionHeader:SetTextColor(1, 1, 1)

	popup:HookScript("OnShow", function(self)
		for _, description in pairs(self.SeasonDescriptions) do
			description:SetTextColor(1, 1, 1)
		end
	end)

	local SeasonRewardFrame = popup.SeasonRewardFrame
	SeasonRewardFrame.CircleMask:Hide()
	SeasonRewardFrame.Ring:Hide()
	local bg = B.ReskinIcon(SeasonRewardFrame.Icon)
	bg:SetFrameLevel(4)

	local seasonReward = PVPQueueFrame.HonorInset.RatedPanel.SeasonRewardFrame
	seasonReward.Ring:Hide()
	seasonReward.CircleMask:Hide()
	B.ReskinIcon(seasonReward.Icon)

	-- Honor frame

	HonorFrame.Inset:Hide()
	ReskinPvPFrame(HonorFrame)
	B.ReskinButton(HonorFrame.QueueButton)
	B.ReskinDropDown(HonorFrameTypeDropdown)
	B.ReskinScroll(HonorFrame.SpecificScrollBar)

	hooksecurefunc(HonorFrame.SpecificScrollBox, "Update", function(self)
		for i = 1, self.ScrollTarget:GetNumChildren() do
			local button = select(i, self.ScrollTarget:GetChildren())
			if not button.styled then
				button.Bg:Hide()
				button.Border:Hide()
				button:SetNormalTexture(0)
				button:SetHighlightTexture(0)

				local bg = B.CreateBDFrame(button, .25)
				bg:SetPoint("TOPLEFT", 2, 0)
				bg:SetPoint("BOTTOMRIGHT", -1, 2)

				button.SelectedTexture:SetDrawLayer("BACKGROUND")
				button.SelectedTexture:SetColorTexture(cr, cg, cb, .25)
				button.SelectedTexture:SetInside(bg)

				B.ReskinIcon(button.Icon)
				button.Icon:SetPoint("TOPLEFT", 5, -3)

				button.styled = true
			end
		end
	end)

	local bonusFrame = HonorFrame.BonusFrame
	bonusFrame.WorldBattlesTexture:Hide()
	bonusFrame.ShadowOverlay:Hide()

	for _, bonusButton in pairs({"RandomBGButton", "RandomEpicBGButton", "Arena1Button", "BrawlButton", "BrawlButton2"}) do
		local bu = bonusFrame[bonusButton]
		B.ReskinButton(bu)
		bu.SelectedTexture:SetDrawLayer("BACKGROUND")
		bu.SelectedTexture:SetColorTexture(cr, cg, cb, .25)
		bu.SelectedTexture:SetInside(bu.__bg)

		local reward = bu.Reward
		if reward then
			reward.Border:Hide()
			reward.CircleMask:Hide()
			reward.Icon.bg = B.ReskinIcon(reward.Icon)
		end
	end

	-- Conquest Frame

	ReskinPvPFrame(ConquestFrame)
	ConquestFrame.Inset:Hide()
	ConquestFrame.RatedBGTexture:Hide()
	ConquestFrame.ShadowOverlay:Hide()
	ConquestFrame.Arena2v2:HookScript("OnEnter", ConquestFrameButton_OnEnter)
	ConquestFrame.Arena3v3:HookScript("OnEnter", ConquestFrameButton_OnEnter)
	ConquestFrame.RatedBG:HookScript("OnEnter", ConquestFrameButton_OnEnter)
	B.ReskinButton(ConquestFrame.JoinButton)

	local names = {"RatedSoloShuffle", "RatedBGBlitz", "Arena2v2", "Arena3v3", "RatedBG"}
	for _, name in pairs(names) do
		local bu = ConquestFrame[name]
		if bu then
			B.ReskinButton(bu)
			local reward = bu.Reward
			if reward then
				reward.Border:Hide()
				reward.CircleMask:Hide()
				reward.Icon.bg = B.ReskinIcon(reward.Icon)
			end

			bu.SelectedTexture:SetDrawLayer("BACKGROUND")
			bu.SelectedTexture:SetColorTexture(cr, cg, cb, .25)
			bu.SelectedTexture:SetInside(bu.__bg)
		end
	end

	-- Item Borders for HonorFrame & ConquestFrame

	hooksecurefunc("PVPUIFrame_ConfigureRewardFrame", function(rewardFrame, _, _, itemRewards, currencyRewards)
		local rewardTexture, rewardQuaility = nil, 1

		if currencyRewards then
			for _, reward in ipairs(currencyRewards) do
				local info = C_CurrencyInfo.GetCurrencyInfo(reward.id)
				local name, texture, quality = info.name, info.iconFileID, info.quality
				if quality == _G.Enum.ItemQuality.Artifact then
					_, rewardTexture, _, rewardQuaility = CurrencyContainerUtil.GetCurrencyContainerInfo(reward.id, reward.quantity, name, texture, quality)
				end
			end
		end

		if not rewardTexture and itemRewards then
			local reward = itemRewards[1]
			if reward then
				_, _, rewardQuaility, _, _, _, _, _, _, rewardTexture = C_Item.GetItemInfo(reward.id)
			end
		end

		if rewardTexture then
			local icon = rewardFrame.Icon
			icon:SetTexture(rewardTexture)
			if icon.bg then
				local r, g, b = C_Item.GetItemQualityColor(rewardQuaility)
				icon.bg:SetBackdropBorderColor(r, g, b)
			end
		end
	end)

	-- PlunderstormFrame
	if PlunderstormFrame then
		PlunderstormFrame.Inset:Hide()
		B.ReskinButton(PlunderstormFrame.StartQueue)

		local panel = PVPQueueFrame.HonorInset.PlunderstormPanel
		if panel then
			B.ReskinButton(panel.PlunderstoreButton)
			B.ReplaceIconString(panel.PlunderDisplay)
			hooksecurefunc(panel.PlunderDisplay, "SetText", B.ReplaceIconString)
		end

		local popup = PlunderstormFramePopup
		if popup then
			B.StripTextures(popup)
			B.SetBD(popup)
			B.ReskinButton(popup.AcceptButton)
			B.ReskinButton(popup.DeclineButton)
		end
	end
end