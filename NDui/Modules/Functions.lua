local _, ns = ...
local B, C, L, DB = unpack(ns)
local oUF = ns.oUF
local cr, cg, cb = DB.r, DB.g, DB.b

-- 自定义
do
	-- Item Slot
	local iSlotDB = {}
	function B.GetItemSlot(itemLink, bagID, slotID)
		local itemID, itemType, itemSubType, itemEquipLoc, itemIcon, itemClassID, itemSubClassID = C_Item.GetItemInfoInstant(itemLink)
		if not itemID then return end
		if iSlotDB[itemID] then return iSlotDB[itemID] end

		local itemSolt
		if DB.EquipIDs[itemClassID] then
			itemSolt = DB.EquipTypes[itemEquipLoc] or _G[itemEquipLoc]
		end

		local itemDate
		if bagID and slotID then
			itemDate = C_TooltipInfo.GetBagItem(bagID, slotID)
		else
			itemDate = C_TooltipInfo.GetHyperlink(itemLink, nil, nil, true)
		end
		if itemDate then
			for i = 2, 8 do
				local lineData = itemDate.lines[i]
				if not lineData then break end

				local lineText = lineData.leftText
				if DB.ConduitTypes[lineText] then
					itemSolt = DB.ConduitTypes[lineText]
					break
				elseif DB.BindTypes[lineText] then
					itemSolt = DB.BindTypes[lineText]
					break
				end
			end
		end

		local _, spellID = C_Item.GetItemSpell(itemID)
		if DB.AncientMana[spellID] then
			itemSolt = "魔力"
		elseif DB.DeliverRelic[spellID] then
			itemSolt = "研究"
		elseif DB.Experience[spellID] then
			itemSolt = "经验"
		end

		if itemClassID == Enum.ItemClass.Container then
			itemSolt = DB.ContainerTypes[itemSubClassID]
		elseif itemClassID == Enum.ItemClass.ItemEnhancement then
			itemSolt = DB.EnchantTypes[itemSubClassID]
		elseif itemClassID == Enum.ItemClass.Recipe then
			itemSolt = DB.RecipeTypes[itemSubClassID]
		elseif itemClassID == Enum.ItemClass.Key then
			itemSolt = DB.KeyTypes[itemSubClassID]
		elseif itemClassID == Enum.ItemClass.Miscellaneous then
			itemSolt = DB.MiscTypes[itemSubClassID]
		elseif itemClassID == Enum.ItemClass.Profession then
			itemSolt = DB.ProfessionTypes[itemSubClassID]
		end

		if C_ArtifactUI.GetRelicInfoByItemID(itemID) then
			itemSolt = RELICSLOT
		elseif C_Item.IsAnimaItemByID(itemID) then
			itemSolt = POWER_TYPE_ANIMA
		elseif C_ToyBox.GetToyInfo(itemID) then
			itemSolt = TOY
		end

		--itemSolt = itemClassID.." "..itemSubClassID

		iSlotDB[itemID] = itemSolt
		return iSlotDB[itemID]
	end

	-- Item Extra
	function B.GetItemExtra(item)
		local itemEx = ""
		local stats = C_Item.GetItemStats(item)

		if stats then
			for stat, count in pairs(stats) do
				if DB.ItemStats[stat] then
					itemEx = itemEx.."-".._G[stat]
				end
				if string.find(stat, "EMPTY_SOCKET_") then
					itemEx = itemEx.."-"..L["Socket"]
				end
			end
		end

		return itemEx
	end

	local rtgColor = {1, 0, 0, 1, 1, 0, 0, 1, 0}
	local gtrColor = {0, 1, 0, 1, 1, 0, 1, 0, 0}
	function B.Color(cur, max, fullRed)
		local r, g, b = oUF:RGBColorGradient(cur, max, unpack(fullRed and gtrColor or rtgColor))
		return r, g, b
	end

	function B.Perc(value, fullRed)
		local per = format("%.1f%%", value)
		local r, g, b = B.Color(value, 100, fullRed)
		return B.HexRGB(r, g, b, per)
	end
end

do
	-- 频道选择
	function B.GetMSGChannel()
		return ((IsPartyLFG() or C_PartyInfo.IsPartyWalkIn()) and "INSTANCE_CHAT") or (IsInRaid() and "RAID") or "PARTY"
	end
end