local _, ns = ...
local B, C, L, DB = unpack(ns)
local oUF = ns.oUF
local cr, cg, cb = DB.r, DB.g, DB.b

-- 自定义
do
	-- Item Slot
	local typeCache = {}
	function B.GetItemType(itemInfo, bagID, slotID)
		local itemID, _, _, itemEquipLoc, _, itemClassID, itemSubClassID = C_Item.GetItemInfoInstant(itemInfo)
		if not itemID then return end
		if typeCache[itemInfo] then return typeCache[itemInfo] end

		local itemType, itemDate
		if DB.EquipmentIDs[itemClassID] or C_ArtifactUI.GetRelicInfoByItemID(itemID) then
			itemType = DB.EquipmentTypes[itemEquipLoc] or _G[itemEquipLoc]

			if C_ArtifactUI.GetRelicInfoByItemID(itemID) then
				itemType = RELICSLOT
			end
		end

		if itemClassID == Enum.ItemClass.Container then
			itemType = DB.ContainerTypes[itemSubClassID]
		elseif itemClassID == Enum.ItemClass.ItemEnhancement then
			itemType = DB.ItemEnhancementTypes[itemSubClassID]
		elseif itemClassID == Enum.ItemClass.Recipe then
			itemType = DB.RecipeTypes[itemSubClassID]
		elseif itemClassID == Enum.ItemClass.Key then
			itemType = DB.KeyTypes[itemSubClassID]
		elseif itemClassID == Enum.ItemClass.Miscellaneous then
			itemType = DB.MiscellaneousTypes[itemSubClassID]
		elseif itemClassID == Enum.ItemClass.Profession then
			itemType = DB.ProfessionTypes[itemSubClassID]
		end

		local itemDate
		if bagID and slotID then
			itemDate = C_TooltipInfo.GetBagItem(bagID, slotID)
		else
			itemDate = C_TooltipInfo.GetHyperlink(itemInfo, nil, nil, true)
		end
		if itemDate then
			for i = 2, 8 do
				local lineData = itemDate.lines[i]
				if not lineData then break end

				local lineText = lineData.leftText
				if DB.ConduitTypes[lineText] then
					itemType = DB.ConduitTypes[lineText]
					break
				elseif DB.CurioTypes[lineText] then
					itemType = DB.CurioTypes[lineText]
					break
				elseif DB.BindTypes[lineText] then
					itemType = DB.BindTypes[lineText]
					break
				end
			end
		end

		if C_Item.IsAnimaItemByID(itemID) then
			itemType = POWER_TYPE_ANIMA
		elseif C_ToyBox.GetToyInfo(itemID) then
			itemType = TOY
		end

		local _, spellID = C_Item.GetItemSpell(itemID)
		if DB.AncientMana[spellID] then
			itemType = "魔力"
		elseif DB.DeliverRelic[spellID] then
			itemType = "研究"
		elseif DB.Experience[spellID] then
			itemType = "经验"
		end

		--itemType = itemClassID.." "..itemSubClassID

		typeCache[itemInfo] = itemType
		return itemType
	end

	-- Item Stat
	local statCache = {}
	function B.GetItemStat(itemInfo)
		if statCache[itemInfo] then return statCache[itemInfo] end

		local itemStat = ""
		local stats = C_Item.GetItemStats(itemInfo)
		if stats then
			for stat, count in pairs(stats) do
				if DB.ItemStats[stat] then
					itemStat = itemStat.."-".._G[stat]
				end
				if string.find(stat, "EMPTY_SOCKET_") then
					itemStat = itemStat.."-"..L["Socket"]
				end
			end
		end

		statCache[itemInfo] = itemStat
		return itemStat
	end

	-- Item Extra
	local extraCache = {}
	function B.GetItemExtra(itemInfo)
		if extraCache[itemInfo] then return extraCache[itemInfo] end

		local itemExtra, hasStat
		local itemType = B.GetItemType(itemInfo)
		local itemStat = B.GetItemStat(itemInfo)
		local itemLevel = B.GetItemLevel(itemInfo)

		if itemLevel and itemType then
			itemExtra = "<"..itemLevel.."-"..itemType..itemStat..">"
		elseif itemLevel then
			itemExtra = "<"..itemLevel..itemStat..">"
		elseif itemType then
			itemExtra = "<"..itemType..itemStat..">"
		end

		if itemStat ~= "" then
			hasStat = true
		end

		extraCache[itemInfo] = itemExtra
		return itemExtra, hasStat
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