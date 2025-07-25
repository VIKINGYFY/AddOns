local _, ns = ...
local B, C, L, DB = unpack(ns)
local TT = B:GetModule("Tooltip")

local tipList, powerList, powerCache, tierCache = {}, {}, {}, {}

local function getIconString(icon, known)
	if known then
		return format("|T%s:16:24:0:0:64:64:5:59:16:48:255:255:255|t", icon)
	else
		return format("|T%s:16:24:0:0:64:64:5:59:16:48:128:128:128|t", icon)
	end
end

function TT:Azerite_ScanTooltip()
	table.wipe(tipList)
	table.wipe(powerList)

	for i = 9, self:NumLines() do
		local line = _G[self:GetName().."TextLeft"..i]
		local text = line:GetText()
		local powerName = text and string.match(text, "%- (.+)")
		if powerName then
			table.insert(tipList, i)
			powerList[i] = powerName
		end
	end
end

function TT:Azerite_PowerToSpell(id)
	local spellID = powerCache[id]
	if not spellID then
		local powerInfo = C_AzeriteEmpoweredItem.GetPowerInfo(id)
		if powerInfo and powerInfo.spellID then
			spellID = powerInfo.spellID
			powerCache[id] = spellID
		end
	end
	return spellID
end

function TT:Azerite_UpdateTier(link)
	if not C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID(link) then return end
	local allTierInfo = tierCache[link]
	if not allTierInfo then
		allTierInfo = C_AzeriteEmpoweredItem.GetAllTierInfoByItemID(link)
		tierCache[link] = allTierInfo
	end

	return allTierInfo
end

function TT:Azerite_UpdateItem()
	local data = self:GetTooltipData()
	local guid = data and data.guid
	local link = guid and C_Item.GetItemLinkByGUID(guid)
	if not link then return end

	local allTierInfo = TT:Azerite_UpdateTier(link)
	if not allTierInfo then return end

	TT.Azerite_ScanTooltip(self)
	if #tipList == 0 then return end

	local index = 1
	for i = 1, #allTierInfo do
		local powerIDs = allTierInfo[i].azeritePowerIDs
		if powerIDs[1] == 13 then break end

		local lineIndex = tipList[index]
		if not lineIndex then break end

		local tooltipText = ""
		for _, id in ipairs(powerIDs) do
			local spellID = TT:Azerite_PowerToSpell(id)
			if not spellID then break end

			local name, icon = C_Spell.GetSpellName(spellID), C_Spell.GetSpellTexture(spellID)
			local found = name == powerList[lineIndex]
			if found then
				tooltipText = tooltipText.." "..getIconString(icon, true)
			else
				tooltipText = tooltipText.." "..getIconString(icon)
			end
		end

		if tooltipText ~= "" then
			local line = _G[self:GetName().."TextLeft"..lineIndex]
			if C.db["Tooltip"]["OnlyArmorIcons"] then
				line:SetText(tooltipText)
				_G[self:GetName().."TextLeft"..lineIndex+1]:SetText("")
			else
				line:SetText(line:GetText().."\n "..tooltipText)
			end
		end

		index = index + 1
	end
end

function TT:AzeriteArmor()
	if not C.db["Tooltip"]["AzeriteArmor"] then return end
	if C_AddOns.IsAddOnLoaded("AzeriteTooltip") then return end

	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, TT.Azerite_UpdateItem)
end