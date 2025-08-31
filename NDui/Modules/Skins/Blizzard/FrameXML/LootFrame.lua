local _, ns = ...
local B, C, L, DB = unpack(ns)

C.OnLoginThemes["LootFrame"] = function()
	B.ReskinClose(LootFrame.ClosePanelButton)
	B.StripTextures(LootFrame)
	B.CreateBG(LootFrame)
	B.ReskinScroll(LootFrame.ScrollBar)

	local function updateHighlight(self)
		local button = self.__owner
		if button.HighlightNameFrame:IsShown() then
			button.bg:SetBackdropColor(1, 1, 1, .25)
		else
			button.bg:SetBackdropColor(0, 0, 0, .25)
		end
	end

	local function updatePushed(self)
		local button = self.__owner
		if button.PushedNameFrame:IsShown() then
			button.bg:SetBackdropBorderColor(1, 1, 0)
		else
			B.SetBorderColor(button.bg)
		end
	end

	local function onHide(self)
		B.SetBorderColor(self.__owner.bg)
	end

	hooksecurefunc(LootFrame.ScrollBox, "Update", function(self)
		for i = 1, self.ScrollTarget:GetNumChildren() do
			local button = select(i, self.ScrollTarget:GetChildren())
			local item = button.Item
			local questTexture = button.IconQuestTexture
			local pushedFrame = button.PushedNameFrame
			if item and not button.styled then
				B.StripTextures(item, 1)
				item.bg = B.ReskinIcon(item.icon)
				B.ReskinBorder(item.IconBorder, true)

				pushedFrame:SetAlpha(0)
				questTexture:SetAlpha(0)
				button.NameFrame:SetAlpha(0)
				button.BorderFrame:SetAlpha(0)
				button.HighlightNameFrame:SetAlpha(0)
				button.bg = B.CreateBDFrame(button.HighlightNameFrame, .25)
				button.bg:SetAllPoints()
				item.__owner = button
				item:HookScript("OnMouseUp", updatePushed)
				item:HookScript("OnMouseDown", updatePushed)
				item:HookScript("OnEnter", updateHighlight)
				item:HookScript("OnLeave", updateHighlight)
				item:HookScript("OnHide", onHide)

				button.styled = true
			end

			local itemBG = item and item.bg
			if itemBG and questTexture:IsShown() then
				itemBG:SetBackdropBorderColor(1, 1, 0)
			end
		end
	end)

	-- Bonus roll
	B.ReskinFrame(BonusRollFrame, 4)

	local PromptFrame = BonusRollFrame.PromptFrame
	B.ReskinIcon(PromptFrame.Icon)

	local Timer = PromptFrame.Timer
	Timer.Bar:SetTexture(DB.normTex)
	Timer.Bar:SetVertexColor(DB.r, DB.g, DB.b)
	B.CreateBDFrame(Timer, .25, nil, -1)

	local SpecIcon = BonusRollFrame.SpecIcon
	B.UpdatePoint(SpecIcon, "RIGHT", PromptFrame.InfoFrame, "RIGHT", -5, 0)

	local icbg = B.ReskinIcon(SpecIcon)
	hooksecurefunc("BonusRollFrame_StartBonusRoll", function()
		icbg:SetShown(SpecIcon:IsShown())
	end)

	local from, to = "|T.+|t", "|T%%s:14:14:0:0:64:64:5:59:5:59|t"
	BONUS_ROLL_COST = gsub(BONUS_ROLL_COST, from, to)
	BONUS_ROLL_CURRENT_COUNT = gsub(BONUS_ROLL_CURRENT_COUNT, from, to)

	-- Loot Roll Frame
	local NUM_GROUP_LOOT_FRAMES = 4

	hooksecurefunc("GroupLootContainer_OpenNewFrame", function()
		for i = 1, NUM_GROUP_LOOT_FRAMES do
			local frame = _G["GroupLootFrame"..i]
			if not frame.styled then
				frame.Background:SetAlpha(0)
				frame.bg = B.CreateBG(frame)
				B.ReskinBorder(frame.Border, true)

				frame.Timer.Bar:SetTexture(DB.bdTex)
				frame.Timer.Bar:SetVertexColor(1, 1, 0)
				frame.Timer.Background:SetAlpha(0)
				B.CreateBDFrame(frame.Timer, .25)

				frame.IconFrame.Border:SetAlpha(0)
				B.ReskinIcon(frame.IconFrame.Icon)

				local bg = B.CreateBDFrame(frame, .25)
				bg:SetPoint("TOPLEFT", frame.IconFrame.Icon, "TOPRIGHT", 0, 1)
				bg:SetPoint("BOTTOMRIGHT", frame.IconFrame.Icon, "BOTTOMRIGHT", 150, -1)

				frame.styled = true
			end
		end
	end)

	-- Bossbanner
	hooksecurefunc("BossBanner_ConfigureLootFrame", function(lootFrame)
		local iconHitBox = lootFrame.IconHitBox
		if not iconHitBox.bg then
			iconHitBox.bg = B.ReskinIcon(lootFrame.Icon)
			B.ReskinBorder(iconHitBox.IconBorder, true)
		end

		iconHitBox.IconBorder:SetTexture(nil)
	end)
end