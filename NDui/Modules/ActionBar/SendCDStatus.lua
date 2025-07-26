local _, ns = ...
local B, C, L, DB = unpack(ns)
local Bar = B:GetModule("Actionbar")

-- Send cooldown status
local function GetRemainTime(second)
	if second > 60 then
		return format("%.1d:%.2d", second/60, second%60)
	else
		return format("%ds", second)
	end
end

local lastCDSend = 0
function Bar:SendCurrentSpell(thisTime, spellID)
	local spellLink = C_Spell.GetSpellLink(spellID)
	local chargeInfo = C_Spell.GetSpellCharges(spellID)
	local charges = chargeInfo and chargeInfo.currentCharges
	local maxCharges = chargeInfo and chargeInfo.maxCharges
	local chargeStart = chargeInfo and chargeInfo.cooldownStartTime
	local chargeDuration = chargeInfo and chargeInfo.cooldownDuration

	if charges and maxCharges then
		if charges ~= maxCharges then
			local remain = chargeStart + chargeDuration - thisTime
			SendChatMessage(format(L["ChargesRemaining"], spellLink, charges, maxCharges, GetRemainTime(remain)), B.GetCurrentChannel())
		else
			SendChatMessage(format(L["ChargesCompleted"], spellLink, charges, maxCharges), B.GetCurrentChannel())
		end
	else
		local cooldownInfo = C_Spell.GetSpellCooldown(spellID)
		local start = cooldownInfo and cooldownInfo.startTime
		local duration = cooldownInfo and cooldownInfo.duration

		if start and duration > 0 then
			local remain = start + duration - thisTime
			SendChatMessage(format(L["CooldownRemaining"], spellLink, GetRemainTime(remain)), B.GetCurrentChannel())
		else
			SendChatMessage(format(L["CooldownCompleted"], spellLink), B.GetCurrentChannel())
		end
	end
end

function Bar:SendCurrentItem(thisTime, itemID, itemLink, itemCount)
	local start, duration = C_Item.GetItemCooldown(itemID)
	if start and duration > 0 then
		local remain = start + duration - thisTime
		SendChatMessage(format(L["CooldownRemaining"], itemLink.." x"..itemCount, GetRemainTime(remain)), B.GetCurrentChannel())
	else
		SendChatMessage(format(L["CooldownCompleted"], itemLink.." x"..itemCount), B.GetCurrentChannel())
	end
end

function Bar:AnalyzeButtonCooldown()
	if not self._state_action or not IsInGroup() then return end

	local thisTime = GetTime()
	if thisTime - lastCDSend < 1.5 then return end
	lastCDSend = thisTime

	local spellType, id, subType = GetActionInfo(self._state_action)
	local itemCount = GetActionCount(self._state_action)
	if spellType == "spell" then
		Bar:SendCurrentSpell(thisTime, id)
	elseif spellType == "item" then
		local itemName, itemLink = C_Item.GetItemInfo(id)
		Bar:SendCurrentItem(thisTime, id, itemLink or itemName, itemCount)
	elseif spellType == "macro" then
		local spellID = subType == "spell" and id or GetMacroSpell(id)
		local _, itemLink = GetMacroItem(id)
		local itemID = itemLink and GetItemInfoFromHyperlink(itemLink)
		if spellID then
			Bar:SendCurrentSpell(thisTime, spellID)
		elseif itemID then
			Bar:SendCurrentItem(thisTime, itemID, itemLink, itemCount)
		end
	end
end

function Bar:SendCDStatus()
	if not C.db["Actionbar"]["SendActionCD"] then return end

	for _, button in pairs(Bar.buttons) do
		button:HookScript("OnMouseWheel", Bar.AnalyzeButtonCooldown)
	end
end