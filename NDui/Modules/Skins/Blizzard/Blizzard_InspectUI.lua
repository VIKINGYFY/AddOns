local _, ns = ...
local B, C, L, DB = unpack(ns)

C.OnLoadThemes["Blizzard_InspectUI"] = function()
	B.StripTextures(InspectModelFrame, true)
	InspectGuildFrameBG:Hide()
	B.ReskinButton(InspectPaperDollFrame.ViewButton)
	InspectPaperDollFrame.ViewButton:ClearAllPoints()
	InspectPaperDollFrame.ViewButton:SetPoint("TOP", InspectFrame, 0, -45)
	InspectPVPFrame.BG:Hide()
	B.ReskinButton(InspectPaperDollItemsFrame.InspectTalents)

	-- Character
	local slots = {
		"Head", "Neck", "Shoulder", "Shirt", "Chest", "Waist", "Legs", "Feet", "Wrist",
		"Hands", "Finger0", "Finger1", "Trinket0", "Trinket1", "Back", "MainHand",
		"SecondaryHand", "Tabard",
	}

	for i = 1, #slots do
		local slot = _G["Inspect"..slots[i].."Slot"]
		B.StripTextures(slot)

		slot.bg = B.ReskinIcon(slot.icon)
		slot.IconOverlay:SetAtlas("CosmeticIconFrame")
		slot.IconOverlay:SetInside(slot.bg)

		B.ReskinBorder(slot.IconBorder)
		B.ReskinHLTex(slot, slot.bg)
	end

	local function UpdateCosmetic(self)
		local unit = InspectFrame.unit
		local itemLink = unit and GetInventoryItemLink(unit, self:GetID())
		self.IconOverlay:SetShown(itemLink and C_Item.IsCosmeticItem(itemLink))
	end

	hooksecurefunc("InspectPaperDollItemSlotButton_Update", function(button)
		button.icon:SetShown(button.hasItem)
		UpdateCosmetic(button)
	end)

	B.ReskinFrame(InspectFrame)
	B.ReskinFrameTab(InspectFrame, 4)

	-- Talents
	--[=[ currently disabled in 10.0
	B.StripTextures(InspectTalentFrame)

	local inspectSpec = InspectTalentFrame.InspectSpec
	inspectSpec.ring:Hide()
	B.ReskinIcon(inspectSpec.specIcon)

	for i = 1, 7 do
		local row = InspectTalentFrame.InspectTalents["tier"..i]
		for j = 1, 3 do
			local bu = row["talent"..j]
			bu.Slot:Hide()
			bu.border:SetTexture("")
			B.ReskinIcon(bu.icon)
		end
	end

	local function updateIcon(self)
		local spec = nil
		if INSPECTED_UNIT ~= nil then
			spec = GetInspectSpecialization(INSPECTED_UNIT)
		end
		if spec ~= nil and spec > 0 then
			local role1 = GetSpecializationRoleByID(spec)
			if role1 ~= nil then
				local _, _, _, icon = GetSpecializationInfoByID(spec)
				self.specIcon:SetTexture(icon)
			end
		end
	end

	inspectSpec:HookScript("OnShow", updateIcon)
	InspectTalentFrame:HookScript("OnEvent", function(self, event, unit)
		if not InspectFrame:IsShown() then return end
		if event == "INSPECT_READY" and InspectFrame.unit and UnitGUID(InspectFrame.unit) == unit then
			updateIcon(self.InspectSpec)
		end
	end)
	]=]
end