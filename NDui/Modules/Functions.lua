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

		if not typeCache[itemInfo] then
			local itemType, itemDate

			if DB.EquipmentIDs[itemClassID] then
				itemType = DB.EquipmentTypes[itemEquipLoc] or _G[itemEquipLoc]
			elseif C_ArtifactUI.GetRelicInfoByItemID(itemID) then
				itemType = RELICSLOT
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

			if bagID and slotID then
				itemDate = C_TooltipInfo.GetBagItem(bagID, slotID)
			else
				itemDate = C_TooltipInfo.GetHyperlink(itemInfo, nil, nil, true)
			end
			if itemDate then
				for i = 2, #itemDate.lines do
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
			elseif DB.Studying[spellID] then
				itemType = "知识"
			end

			if DB.SpecialJunk[itemID] then
				itemType = SPECIAL
			end

			--itemType = itemClassID.." "..itemSubClassID

			typeCache[itemInfo] = itemType
		end

		return typeCache[itemInfo]
	end

	-- Item Stat
	local statCache = {}
	function B.GetItemStat(itemInfo)
		if not statCache[itemInfo] then
			local itemStat = ""
			local stats = C_Item.GetItemStats(itemInfo)
			if stats then
				for stat, count in pairs(stats) do
					if DB.ItemStats[stat] then
						itemStat = itemStat.."-".._G[stat]
					end
					if string.find(stat, "EMPTY_SOCKET_") then
						itemStat = itemStat.."-".."插槽"
						break
					end
				end
			end

			statCache[itemInfo] = itemStat
		end

		return statCache[itemInfo]
	end

	-- Item Extra
	local miscList = {[TOY] = true, [PETS] = true, [MOUNTS] = true}
	local extraCache = {}
	function B.GetItemExtra(itemInfo)
		if not extraCache[itemInfo] then
			local itemType = B.GetItemType(itemInfo)
			local itemStat = B.GetItemStat(itemInfo)
			local itemLevel = B.GetItemLevel(itemInfo)

			local itemExtra = ""
			if itemLevel and itemType then
				itemExtra = "<"..itemLevel.."-"..itemType..itemStat..">"
			elseif itemLevel then
				itemExtra = "<"..itemLevel..itemStat..">"
			elseif itemType then
				itemExtra = "<"..itemType..itemStat..">"
			end

			local hasStat = (itemStat and itemStat ~= "")
			local hasMisc = (itemType and miscList[itemType])

			extraCache[itemInfo] = {
				itemExtra = itemExtra,
				hasStat = hasStat,
				hasMisc = hasMisc,
			}
		end

		return extraCache[itemInfo].itemExtra, extraCache[itemInfo].hasStat, extraCache[itemInfo].hasMisc
	end

	local rtgColor = {1,0,0, 1,1,0, 0,1,0}
	local gtrColor = {0,1,0, 1,1,0, 1,0,0}
	function B.SmoothColor(cur, max, fullGreen)
		local r, g, b = oUF:RGBColorGradient(cur, max, unpack(fullGreen and rtgColor or gtrColor))
		return r, g, b
	end

	function B.ColorPerc(per, fullGreen, max)
		local var = format("%.1f%%", per)
		local r, g, b = B.SmoothColor(math.abs(per), max or 100, fullGreen)
		return B.HexRGB(r, g, b, var)
	end

	function B.ColorNumb(cur, max, fullGreen)
		local num = B.Numb(cur)
		local r, g, b = B.SmoothColor(math.abs(cur), max, fullGreen)
		return B.HexRGB(r, g, b, num)
	end
end

do
	-- 频道选择
	function B.GetCurrentChannel()
		return ((IsPartyLFG() or C_PartyInfo.IsPartyWalkIn()) and "INSTANCE_CHAT") or (IsInRaid() and "RAID") or "PARTY"
	end

	function B.GetGroupUnit(index, isInRaid)
		return isInRaid and "raid"..index or "party"..index
	end
end