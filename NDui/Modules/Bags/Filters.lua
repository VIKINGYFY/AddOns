local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Bags")

-- Default filter
local function isItemInBag(item)
	return item.bagId >= 0 and item.bagId <= 4
end

local function isItemInBagReagent(item)
	return ContainerFrame_GetContainerNumSlots(5) > 0 and item.bagId == 5
end

local function isItemInBank(item)
	return item.bagId > 5 and item.bagId < 12
end

local function isItemInReagentBank(item)
	return item.bagId == -3
end

local function isItemInAccountBank(item)
	return item.bagId > 11 and item.bagId < 17
end

local function isEmptySlot(item)
	if not C.db["Bags"]["GatherEmpty"] then return end
	return module.initComplete and not item.texture
end

function module:IsSpecialJunk(itemID)
	return C.db["Bags"]["SpecialJunk"] and DB.SpecialJunk[itemID]
end

local function IsEquipmentItem(item)
	return item.link and (DB.EquipmentIDs[item.classID] or (item.id and (C_ArtifactUI.GetRelicInfoByItemID(item.id) or C_Soulbinds.IsItemConduitByItemInfo(item.id))))
end

local function IsOtherItem(item)
	return item.link and (DB.OutmodedIDs[item.classID] and DB.ExcludeIDs[item.subClassID] ~= item.classID)
end

local function isItemOutmoded(item)
	return item.link and IsOtherItem(item) and (item.expansionID and item.expansionID < C.db["Bags"]["iExpToShow"])
end

local function isItemLowerLevel(item)
	return item.link and IsEquipmentItem(item) and (item.ilvl and item.ilvl < C.db["Bags"]["iLvlToShow"])
end

local function isItemCustom(item, index)
	if not C.db["Bags"]["ItemFilter"] then return end
	if not C.db["Bags"]["FilterFavourite"] then return end
	local customIndex = item.id and C.db["Bags"]["CustomItems"][item.id]
	return customIndex and customIndex == index
end

local function isItemJunk(item)
	if not C.db["Bags"]["ItemFilter"] then return end
	if not C.db["Bags"]["FilterJunk"] then return end
	return item.hasPrice and (not module:IsSpecialJunk(item.id)) and ((item.quality and item.quality <= Enum.ItemQuality.Poor) or isItemOutmoded(item) or isItemLowerLevel(item) or NDuiADB["CustomJunkList"][item.id])
end

local function isItemEquipSet(item)
	if not C.db["Bags"]["ItemFilter"] then return end
	if not C.db["Bags"]["FilterEquipSet"] then return end
	return item.link and item.isItemSet
end

local function isItemEquipment(item)
	if not C.db["Bags"]["ItemFilter"] then return end
	if not C.db["Bags"]["FilterEquipment"] then return end
	return item.link and DB.EquipmentIDs[item.classID] or (item.id and (C_ArtifactUI.GetRelicInfoByItemID(item.id) or C_Soulbinds.IsItemConduitByItemInfo(item.id)))
end

local function isItemConsumable(item)
	if not C.db["Bags"]["ItemFilter"] then return end
	if not C.db["Bags"]["FilterConsumable"] then return end
	return item.link and (item.classID ~= Enum.ItemClass.Tradegoods) and ((item.stackCount and item.stackCount > 1) or (item.itemOn and item.itemOn == "openable"))
end

local function isItemLegendary(item)
	if not C.db["Bags"]["ItemFilter"] then return end
	if not C.db["Bags"]["FilterLegendary"] then return end
	return item.link and (item.quality and item.quality >= Enum.ItemQuality.Legendary)
end

local function isItemCollection(item)
	if not C.db["Bags"]["ItemFilter"] then return end
	if not C.db["Bags"]["FilterCollection"] then return end
	return item.link and (DB.MiscellaneousIDs[item.classID] and DB.CollectionIDs[item.subClassID]) or (item.id and C_ToyBox.GetToyInfo(item.id))
end

local function isItemFeature(item)
	if not C.db["Bags"]["ItemFilter"] then return end
	if not C.db["Bags"]["FilterFeature"] then return end
	return item.link and (item.id and DB.PrimordialStone[item.id])
end

local function isItemAuE(item)
	if not C.db["Bags"]["ItemFilter"] then return end
	if not C.db["Bags"]["FilterAuE"] then return end
	return item.link and (item.bindOn and item.bindOn == "accountequip")
end

local function isItemBoN(item)
	if not C.db["Bags"]["ItemFilter"] then return end
	if not C.db["Bags"]["FilterBoN"] then return end
	return item.link and (item.bindType and item.bindType == 0)
end

function module:GetFilters()
	local filters = {}

	filters.onlyBags = function(item) return isItemInBag(item) and not isEmptySlot(item) end
	filters.onlyBank = function(item) return isItemInBank(item) and not isEmptySlot(item) end
	filters.onlyBagReagent = function(item) return isItemInBagReagent(item) and not isEmptySlot(item) end
	filters.onlyReagent = function(item) return isItemInReagentBank(item) and not isEmptySlot(item) end
	filters.accountbank = function(item) return isItemInAccountBank(item) and not isEmptySlot(item) end

	filters.bagAuE = function(item) return isItemInBag(item) and isItemAuE(item) end
	filters.bagBoN = function(item) return isItemInBag(item) and isItemBoN(item) end
	filters.bagCollection = function(item) return isItemInBag(item) and isItemCollection(item) end
	filters.bagConsumable = function(item) return isItemInBag(item) and isItemConsumable(item) end
	filters.bagEquipSet = function(item) return isItemInBag(item) and isItemEquipSet(item) end
	filters.bagEquipment = function(item) return isItemInBag(item) and isItemEquipment(item) end
	filters.bagFeature = function(item) return isItemInBag(item) and isItemFeature(item) end
	filters.bagJunk = function(item) return (isItemInBag(item) or isItemInBagReagent(item)) and isItemJunk(item) end
	filters.bagLegendary = function(item) return isItemInBag(item) and isItemLegendary(item) end

	filters.bankAuE = function(item) return isItemInBank(item) and isItemAuE(item) end
	filters.bankBoN = function(item) return isItemInBank(item) and isItemBoN(item) end
	filters.bankCollection = function(item) return isItemInBank(item) and isItemCollection(item) end
	filters.bankConsumable = function(item) return isItemInBank(item) and isItemConsumable(item) end
	filters.bankEquipSet = function(item) return isItemInBank(item) and isItemEquipSet(item) end
	filters.bankEquipment = function(item) return isItemInBank(item) and isItemEquipment(item) end
	filters.bankFeature = function(item) return isItemInBank(item) and isItemFeature(item) end
	filters.bankJunk = function(item) return (isItemInBank(item) or isItemInReagentBank(item)) and isItemJunk(item) end
	filters.bankLegendary = function(item) return isItemInBank(item) and isItemLegendary(item) end

	filters.accountAuE = function(item) return isItemInAccountBank(item) and isItemAuE(item) end
	filters.accountBoN = function(item) return isItemInAccountBank(item) and isItemBoN(item) end
	filters.accountCollection = function(item) return isItemInAccountBank(item) and isItemCollection(item) end
	filters.accountConsumable = function(item) return isItemInAccountBank(item) and isItemConsumable(item) end
	filters.accountEquipSet = function(item) return isItemInAccountBank(item) and isItemEquipSet(item) end
	filters.accountEquipment = function(item) return isItemInAccountBank(item) and isItemEquipment(item) end
	filters.accountFeature = function(item) return isItemInAccountBank(item) and isItemFeature(item) end
	filters.accountJunk = function(item) return isItemInAccountBank(item) and isItemJunk(item) end
	filters.accountLegendary = function(item) return isItemInAccountBank(item) and isItemLegendary(item) end

	for i = 1, 5 do
		filters["bagCustom"..i] = function(item) return (isItemInBag(item) or isItemInBagReagent(item)) and isItemCustom(item, i) end
		filters["bankCustom"..i] = function(item) return isItemInBank(item) and isItemCustom(item, i) end
		filters["accountCustom"..i] = function(item) return isItemInAccountBank(item) and isItemCustom(item, i) end
	end

	return filters
end