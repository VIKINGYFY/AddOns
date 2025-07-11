local _, ns = ...
local B, C, L, DB = unpack(ns)
local cr, cg, cb = DB.r, DB.g, DB.b

C.OnLoadThemes["Blizzard_AzeriteUI"] = function()
	B.ReskinFrame(AzeriteEmpoweredItemUI)
	AzeriteEmpoweredItemUIBg:Hide()
	AzeriteEmpoweredItemUI.ClipFrame.BackgroundFrame.Bg:Hide()
end

local function updateEssenceButton(button)
	if not button.bg then
		local bg = B.CreateBDFrame(button, .25)
		bg:SetPoint("TOPLEFT", 1, 0)
		bg:SetPoint("BOTTOMRIGHT", 0, 2)

		if button.Icon then
			B.ReskinIcon(button.Icon)
			B.ReskinHLTex(button, bg, true)

			button.PendingGlow:SetTexture("")
			button.Background:SetAlpha(0)
		end

		if button.ExpandedIcon then
			button:DisableDrawLayer("BACKGROUND")
			button:DisableDrawLayer("BORDER")
		end

		button.bg = bg
	end

	if button:IsShown() then
		if button.PendingGlow and button.PendingGlow:IsShown() then
			button.bg:SetBackdropBorderColor(1, 1, 0)
		else
			B.SetBorderColor(button.bg)
		end
	end
end

C.OnLoadThemes["Blizzard_AzeriteEssenceUI"] = function()
	B.ReskinFrame(AzeriteEssenceUI)
	B.StripTextures(AzeriteEssenceUI.PowerLevelBadgeFrame)
	B.ReskinScroll(AzeriteEssenceUI.EssenceList.ScrollBar)

	for _, milestoneFrame in pairs(AzeriteEssenceUI.Milestones) do
		if milestoneFrame.LockedState then
			milestoneFrame.LockedState.UnlockLevelText:SetTextColor(0, 1, 1)
			milestoneFrame.LockedState.UnlockLevelText.SetTextColor = B.Dummy
		end
	end

	hooksecurefunc(AzeriteEssenceUI.EssenceList.ScrollBox, "Update", function(self)
		self:ForEachFrame(updateEssenceButton)
	end)
end

local function reskinReforgeUI(frame)
	B.StripTextures(frame, 0)
	B.SetBD(frame)
	B.ReskinClose(frame.CloseButton)
	B.ReskinIcon(frame.ItemSlot.Icon)

	local buttonFrame = frame.ButtonFrame
	B.StripTextures(buttonFrame)
	buttonFrame.MoneyFrameEdge:SetAlpha(0)
	local bg = B.CreateBDFrame(buttonFrame, .25)
	bg:SetPoint("TOPLEFT", buttonFrame.MoneyFrameEdge, 3, 0)
	bg:SetPoint("BOTTOMRIGHT", buttonFrame.MoneyFrameEdge, 0, 2)
	if buttonFrame.AzeriteRespecButton then B.ReskinButton(buttonFrame.AzeriteRespecButton) end
	if buttonFrame.ActionButton then B.ReskinButton(buttonFrame.ActionButton) end
	if buttonFrame.Currency then B.ReskinIcon(buttonFrame.Currency.Icon) end

	if frame.DescriptionCurrencies then
		hooksecurefunc(frame.DescriptionCurrencies, "SetCurrencies", B.SetCurrenciesHook)
	end
end

C.OnLoadThemes["Blizzard_AzeriteRespecUI"] = function()
	reskinReforgeUI(AzeriteRespecFrame)
end

C.OnLoadThemes["Blizzard_ItemInteractionUI"] = function()
	reskinReforgeUI(ItemInteractionFrame)
end