local _, ns = ...
local B, C, L, DB = unpack(ns)
local oUF = ns.oUF
local UF = B:GetModule("UnitFrames")

UF.RaidDebuffsBlack = {}
function UF:UpdateRaidDebuffsBlack()
	table.wipe(UF.RaidDebuffsBlack)

	for spellID in pairs(C.RaidDebuffsBlack) do
		local name = C_Spell.GetSpellName(spellID)
		if name then
			if NDuiADB["RaidDebuffsBlack"][spellID] == nil then
				UF.RaidDebuffsBlack[spellID] = true
			end
		end
	end

	for spellID, value in pairs(NDuiADB["RaidDebuffsBlack"]) do
		if value then
			UF.RaidDebuffsBlack[spellID] = true
		end
	end
end

function UF:CreateDebuffsIndicator(self)
	local debuffFrame = CreateFrame("Frame", nil, self)
	debuffFrame:SetSize(1, 1)
	debuffFrame:SetPoint("BOTTOMLEFT", self.Health, "BOTTOMLEFT")

	debuffFrame.buttons = {}
	local prevDebuff
	for i = 1, 3 do
		local button = CreateFrame("Frame", nil, debuffFrame)
		B.AuraIcon(button)
		button:SetScript("OnEnter", UF.AuraButton_OnEnter)
		button:SetScript("OnLeave", B.HideTooltip)
		button:Hide()

		button.count = B.CreateFS(button, 12, "", false, "BOTTOMRIGHT", 6, -3)
		button.CD:SetHideCountdownNumbers(true)

		if not prevDebuff then
			button:SetPoint("BOTTOMLEFT", self.Health, "BOTTOMLEFT")
		else
			button:SetPoint("LEFT", prevDebuff, "RIGHT")
		end
		prevDebuff = button
		debuffFrame.buttons[i] = button
	end

	self.DebuffsIndicator = debuffFrame

	UF.DebuffsIndicator_UpdateOptions(self)
end

function UF:DebuffsIndicator_UpdateButton(debuffIndex, aura)
	local button = self.DebuffsIndicator.buttons[debuffIndex]
	if not button then return end

	button.unit, button.index, button.filter = aura.unit, aura.index, aura.filter
	if button.CD then
		if aura.duration and aura.duration > 0 then
			button.CD:SetCooldown(aura.expiration - aura.duration, aura.duration)
			button.CD:Show()
		else
			button.CD:Hide()
		end
	end

	if button.bg then
		if aura.isDebuff then
			local color = oUF.colors.debuff[aura.debuffType] or oUF.colors.debuff.none
			button.bg:SetBackdropBorderColor(color[1], color[2], color[3])
		else
			B.SetBorderColor(button.bg)
		end
	end

	if button.Icon then button.Icon:SetTexture(aura.texture) end
	if button.count then button.count:SetText(aura.count > 1 and aura.count or "") end

	button:Show()
end

function UF:DebuffsIndicator_HideButtons(from, to)
	for i = from, to do
		local button = self.DebuffsIndicator.buttons[i]
		if button then
			button:Hide()
		end
	end
end

function UF.DebuffsIndicator_Filter(raidAuras, aura)
	local spellID = aura.spellID
	if UF.RaidDebuffsBlack[spellID] then
		return false
	elseif aura.isBossAura or SpellIsPriorityAura(spellID) then
		return true
	else
		local hasCustom, alwaysShowMine, showForMySpec = SpellGetVisibilityInfo(spellID, raidAuras.isInCombat and "RAID_INCOMBAT" or "RAID_OUTOFCOMBAT")
		if hasCustom then
			return showForMySpec or (alwaysShowMine and aura.isPlayerAura)
		else
			return true
		end
	end
end

function UF:DebuffsIndicator_UpdateOptions()
	local debuffs = self.DebuffsIndicator
	if not debuffs then return end

	debuffs.enable = C.db["UFs"]["ShowRaidDebuff"]
	local size = C.db["UFs"]["RaidDebuffSize"]
	local disableMouse = C.db["UFs"]["DebuffClickThru"]

	for i = 1, 3 do
		local button = debuffs.buttons[i]
		if button then
			button:SetSize(size, size)
			button:EnableMouse(not disableMouse)
		end
	end
end