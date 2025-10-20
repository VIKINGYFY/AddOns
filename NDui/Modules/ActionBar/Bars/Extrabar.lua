local _, ns = ...
local B, C, L, DB = unpack(ns)
local Bar = B:GetModule("Actionbar")

local function UpdateAbilityFrame(fame, newFrame)
	fame:SetParent(newFrame)
	fame:EnableMouse(false)
	fame:ClearAllPoints()
	fame:SetPoint("CENTER", newFrame)
	fame.ignoreInLayout = true
	fame:SetIgnoreParentScale(true)
	fame:SetScale(UIParent:GetScale())

	if fame.Style then fame.Style:Hide() end
end

function Bar:CreateExtrabar()
	local buttonList = {}
	local size = 52

	ExtraAbilityContainer:SetScript("OnShow", nil)
	ExtraAbilityContainer:SetScript("OnUpdate", nil)
	ExtraAbilityContainer.OnUpdate = nil -- remove BaseLayoutMixin.OnUpdate
	ExtraAbilityContainer.IsLayoutFrame = nil -- dont let it get readded
	ExtraAbilityContainer:KillEditMode()

	-- ExtraActionButton
	local extraFrame = CreateFrame("Frame", "NDui_ActionBarExtra", UIParent, "SecureHandlerStateTemplate")
	extraFrame:SetSize(size, size)
	extraFrame.mover = B.Mover(extraFrame, L["Extrabar"], "Extrabar", {"LEFT", _G.NDui_ActionBar3Button12, "TOPRIGHT", DB.margin, 0})
	extraFrame:ClearAllPoints()
	extraFrame:SetPoint("CENTER", extraFrame.mover, "CENTER")

	UpdateAbilityFrame(ExtraActionBarFrame, extraFrame)

	local button = ExtraActionButton1
	table.insert(buttonList, button)
	table.insert(Bar.buttons, button)
	button:SetSize(size, size)

	extraFrame.frameVisibility = "[extrabar] show; hide"
	RegisterStateDriver(extraFrame, "visibility", extraFrame.frameVisibility)

	-- ZoneAbility
	local zoneFrame = CreateFrame("Frame", "NDui_ActionBarZone", UIParent, "SecureHandlerStateTemplate")
	zoneFrame:SetSize(size, size)
	zoneFrame.mover = B.Mover(zoneFrame, L["Zone Ability"], "ZoneAbility", {"RIGHT", _G.NDui_ActionBar3Button1, "TOPLEFT", -DB.margin, 0})
	zoneFrame:ClearAllPoints()
	zoneFrame:SetPoint("CENTER", zoneFrame.mover, "CENTER")

	UpdateAbilityFrame(ZoneAbilityFrame, zoneFrame)

	hooksecurefunc(ZoneAbilityFrame, "UpdateDisplayedZoneAbilities", function(self)
		for spellButton in self.SpellButtonContainer:EnumerateActive() do
			if spellButton and not spellButton.styled then
				B.CleanTextures(spellButton)

				local bubg = B.CreateBG(spellButton, -1)
				B.ReskinHLTex(spellButton, bubg)
				B.ReskinCPTex(spellButton, bubg)
				B.UpdateButton(spellButton, bubg)

				spellButton.styled = true
			end
		end
	end)

	-- Extra button range, needs review
	hooksecurefunc("ActionButton_UpdateRangeIndicator", function(self, checksRange, inRange)
		if not self.action then return end

		if checksRange and not inRange then
			self.icon:SetVertexColor(1, .1, .1)
		else
			local isUsable, notEnoughMana = IsUsableAction(self.action)
			if isUsable then
				self.icon:SetVertexColor(1, 1, 1)
			elseif notEnoughMana then
				self.icon:SetVertexColor(.5, .5, 1)
			else
				self.icon:SetVertexColor(.5, .5, .5)
			end
		end
	end)
end