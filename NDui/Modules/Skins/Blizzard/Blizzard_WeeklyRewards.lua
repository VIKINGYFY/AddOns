local _, ns = ...
local B, C, L, DB = unpack(ns)

local r, g, b = C_Item.GetItemQualityColor(4)
local function Reskin_SetRewards(self)
	if not self.styled then
		self:DisableDrawLayer("BORDER")
		self.Icon:SetPoint("LEFT", 6, 0)

		local icbg = B.ReskinIcon(self.Icon)
		icbg:SetBackdropBorderColor(r, g, b)

		local bubg = B.ReskinNameFrame(self, icbg)
		bubg:SetBackdropBorderColor(r, g, b)

		self.styled = true
	end
end

local function Update_SelectionState(self)
	if not self.bg then return end

	if self.SelectedTexture:IsShown() then
		self.bg:SetBackdropBorderColor(1, 1, 0)
	else
		B.SetBorderColor(self.bg)
	end
end

local function Update_DisplayedItem(self)
	if self.displayedItemDBID then
		local hyperlink = C_WeeklyRewards.GetItemHyperlink(self.displayedItemDBID)
		if hyperlink then
			local level = B.GetItemLevel(hyperlink)
			local slot = B.GetItemType(hyperlink)
			self:GetParent():SetProgressText(slot.." "..level)
		end
	end
end

local function Reskin_ActivityFrame(self, isObject)
	self.bg = B.CreateBDFrame(self, .25)

	if self.Background then
		self.Background:SetTexCoord(.02, .98, .02, .98)
		self.Background:SetInside(self.bg)
	end

	if self.UnselectedFrame then
		B.StripTextures(self.UnselectedFrame)
	end

	if self.SelectionGlow then
		B.StripTextures(self.SelectionGlow.EdgeGlow, 99)
		B.StripTextures(self.SelectionGlow.SideGlows, 99)
	end

	if self.Border and isObject then
		B.StripTextures(self)
		hooksecurefunc(self, "SetSelectionState", Update_SelectionState)
		hooksecurefunc(self.ItemFrame, "SetRewards", Reskin_SetRewards)
		hooksecurefunc(self.ItemFrame, "SetDisplayedItem", Update_DisplayedItem)
	end
end

local function Reskin_Reward(self)
	if self.bg then return end

	self.bg = B.ReskinIcon(self.Icon)
	B.ReskinBorder(self.IconBorder, true)
end

local function Reskin_SelectReward(self)
	local confirmFrame = self.confirmSelectionFrame
	if confirmFrame then
		if not confirmFrame.styled then
			WeeklyRewardsFrameNameFrame:Hide()
			Reskin_Reward(confirmFrame.ItemFrame)

			confirmFrame.styled = true
		end

		local alsoItemsFrame = confirmFrame.AlsoItemsFrame
		if alsoItemsFrame and alsoItemsFrame.pool then
			for frame in alsoItemsFrame.pool:EnumerateActive() do
				Reskin_Reward(frame)
			end
		end
	end
end

C.OnLoadThemes["Blizzard_WeeklyRewards"] = function()
	B.ReskinFrame(WeeklyRewardsFrame)

	local HeaderFrame = WeeklyRewardsFrame.HeaderFrame
	B.StripTextures(HeaderFrame)
	B.ReskinText(HeaderFrame.Text, 1, .8, 0, 1, SystemFont_Huge1)

	local SelectRewardButton = WeeklyRewardsFrame.SelectRewardButton
	B.StripTextures(SelectRewardButton)
	B.ReskinButton(SelectRewardButton)

	local ConcessionFrame = WeeklyRewardsFrame.ConcessionFrame
	B.StripTextures(ConcessionFrame)
	hooksecurefunc(ConcessionFrame, "SetSelectionState", Update_SelectionState)

	Reskin_ActivityFrame(WeeklyRewardsFrame.RaidFrame)
	Reskin_ActivityFrame(WeeklyRewardsFrame.MythicFrame)
	Reskin_ActivityFrame(WeeklyRewardsFrame.PVPFrame)
	Reskin_ActivityFrame(WeeklyRewardsFrame.WorldFrame)

	for _, frame in pairs(WeeklyRewardsFrame.Activities) do
		Reskin_ActivityFrame(frame, true)
	end

	hooksecurefunc(WeeklyRewardsFrame, "SelectReward", Reskin_SelectReward)

	local dialog = WeeklyRewardExpirationWarningDialog
	if dialog then B.ReskinFrame(dialog) end
end