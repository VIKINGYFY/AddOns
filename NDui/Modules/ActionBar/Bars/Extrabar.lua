local _, ns = ...
local B, C, L, DB = unpack(ns)
local Bar = B:GetModule("Actionbar")

function Bar:CreateExtrabar()
	local buttonList = {}
	local size = 52
	local framSize = size + 2*DB.margin

	-- ExtraActionButton
	local frame = CreateFrame("Frame", "NDui_ActionBarExtra", UIParent, "SecureHandlerStateTemplate")
	frame:SetSize(framSize, framSize)
	frame.mover = B.Mover(frame, L["Extrabar"], "Extrabar", {"LEFT", _G.NDui_ActionBar3Button12, "TOPRIGHT", 0, 0})

	ExtraAbilityContainer:SetScript("OnShow", nil)
	ExtraAbilityContainer:SetScript("OnUpdate", nil)
	ExtraAbilityContainer.OnUpdate = nil -- remove BaseLayoutMixin.OnUpdate
	ExtraAbilityContainer.IsLayoutFrame = nil -- dont let it get readded
	ExtraAbilityContainer:KillEditMode()

	ExtraActionBarFrame:EnableMouse(false)
	ExtraActionBarFrame:ClearAllPoints()
	ExtraActionBarFrame:SetPoint("CENTER", frame)
	ExtraActionBarFrame.ignoreInLayout = true
	ExtraActionBarFrame:SetIgnoreParentScale(true)
	ExtraActionBarFrame:SetScale(UIParent:GetScale())

	local button = ExtraActionButton1
	table.insert(buttonList, button)
	table.insert(Bar.buttons, button)
	button:SetSize(size, size)

	frame.frameVisibility = "[extrabar] show; hide"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)

	-- ZoneAbility
	local zoneFrame = CreateFrame("Frame", "NDui_ActionBarZone", UIParent)
	frame:SetSize(framSize, framSize)
	zoneFrame.mover = B.Mover(zoneFrame, L["Zone Ability"], "ZoneAbility", {"RIGHT", _G.NDui_ActionBar3Button1, "TOPLEFT", 0, 0})

	ZoneAbilityFrame:SetParent(zoneFrame)
	ZoneAbilityFrame:ClearAllPoints()
	ZoneAbilityFrame:SetPoint("CENTER", zoneFrame)
	ZoneAbilityFrame.ignoreInLayout = true
	ZoneAbilityFrame.Style:SetAlpha(0)

	hooksecurefunc(ZoneAbilityFrame, "UpdateDisplayedZoneAbilities", function(self)
		for spellButton in self.SpellButtonContainer:EnumerateActive() do
			if spellButton and not spellButton.styled then
				B.CleanTextures(spellButton)

				local bubg = B.CreateBDFrame(spellButton, .25)
				B.ReskinHLTex(spellButton, bubg)
				B.ReskinCPTex(spellButton, bubg)
				B.UpdateButton(spellButton, bubg)

				spellButton.styled = true
			end
		end
	end)

	-- Fix button visibility
	hooksecurefunc(ZoneAbilityFrame, "SetParent", function(self, parent)
		if parent == ExtraAbilityContainer then
			self:SetParent(zoneFrame)
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