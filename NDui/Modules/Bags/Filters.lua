local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Bags")

-- Default filter
local function isItemInBag(item)
	return item.bagId >= 0 and item.bagId <= 4
end

local function isItemInBagReagent(item)
	return item.bagId == 5
end

local function isItemInBank(item)
	return item.bagId == -1 or (item.bagId > 5 and item.bagId < 13)
end

local emptyBags = {[0] = true, [11] = true}
local function isEmptySlot(item)
	if not C.db["Bags"]["GatherEmpty"] then return end
	return module.initComplete and not item.texture and emptyBags[module.BagsType[item.bagId]]
end

function module:IsPetTrashCurrency(itemID)
	return C.db["Bags"]["PetTrash"] and DB.PetTrashCurrenies[itemID]
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
	return ((item.quality and item.quality == Enum.ItemQuality.Poor) or NDuiADB["CustomJunkList"][item.id]) and item.hasPrice and not module:IsPetTrashCurrency(item.id)
end

local function isItemEquipSet(item)
	if not C.db["Bags"]["ItemFilter"] then return end
	if not C.db["Bags"]["FilterEquipSet"] then return end
	return item.isItemSet
end

local function isItemEquipment(item)
	if not C.db["Bags"]["ItemFilter"] then return end
	if not C.db["Bags"]["FilterEquipment"] then return end
	return DB.EquipIDs[item.classID] or (item.id and (C_ArtifactUI.GetRelicInfoByItemID(item.id) or C_Soulbinds.IsItemConduitByItemInfo(item.id)))
end

local function isItemConsumable(item)
	if not C.db["Bags"]["ItemFilter"] then return end
	if not C.db["Bags"]["FilterConsumable"] then return end
	return item.stackCount and item.stackCount > 1 and not DB.ExcludeIDs[item.classID]
end

local function isItemLegendary(item)
	if not C.db["Bags"]["ItemFilter"] then return end
	if not C.db["Bags"]["FilterLegendary"] then return end
	return item.quality and item.quality >= Enum.ItemQuality.Legendary
end

local function isItemCollection(item)
	if not C.db["Bags"]["ItemFilter"] then return end
	if not C.db["Bags"]["FilterCollection"] then return end
	return (DB.MiscIDs[item.classID] and DB.CollectionIDs[item.subClassID]) or (item.id and C_ToyBox.GetToyInfo(item.id))
end

local function isItemFeature(item)
	if not C.db["Bags"]["ItemFilter"] then return end
	if not C.db["Bags"]["FilterFeature"] then return end
	return item.id and DB.PrimordialStone[item.id]
end

local function isItemAoE(item)
	if not C.db["Bags"]["ItemFilter"] then return end
	if not C.db["Bags"]["FilterAoE"] then return end
	return item.bindOn and item.bindOn == "accountequip"
end

local function isItemBoN(item)
	if not C.db["Bags"]["ItemFilter"] then return end
	if not C.db["Bags"]["FilterBoN"] then return end
	return item.bindType and item.bindType == 0
end

local accountBankIDs = {
	[Enum.BagIndex.AccountBankTab_1 or 13] = true,
	[Enum.BagIndex.AccountBankTab_2 or 14] = true,
	[Enum.BagIndex.AccountBankTab_3 or 15] = true,
	[Enum.BagIndex.AccountBankTab_4 or 16] = true,
	[Enum.BagIndex.AccountBankTab_5 or 17] = true
}

function module:GetFilters()
	local filters = {}

	filters.onlyBags = function(item) return isItemInBag(item) and not isEmptySlot(item) end
	filters.onlyBank = function(item) return isItemInBank(item) and not isEmptySlot(item) end
	filters.onlyBagReagent = function(item) return isItemInBagReagent(item) and not isEmptySlot(item) end
	filters.onlyReagent = function(item) return item.bagId == -3 and not isEmptySlot(item) end
	filters.accountbank = function(item) return accountBankIDs[item.bagId] and not isEmptySlot(item) end

	filters.bagEquipment = function(item) return isItemInBag(item) and isItemEquipment(item) end
	filters.bankEquipment = function(item) return isItemInBank(item) and isItemEquipment(item) end

	filters.bagEquipSet = function(item) return isItemInBag(item) and isItemEquipSet(item) end
	filters.bankEquipSet = function(item) return isItemInBank(item) and isItemEquipSet(item) end

	filters.bagAoE = function(item) return isItemInBag(item) and isItemAoE(item) end
	filters.bankAoE = function(item) return isItemInBank(item) and isItemAoE(item) end

	filters.bagCollection = function(item) return isItemInBag(item) and isItemCollection(item) end
	filters.bankCollection = function(item) return isItemInBank(item) and isItemCollection(item) end

	filters.bagConsumable = function(item) return isItemInBag(item) and isItemConsumable(item) end
	filters.bankConsumable = function(item) return isItemInBank(item) and isItemConsumable(item) end

	filters.bagFeature = function(item) return isItemInBag(item) and isItemFeature(item) end
	filters.bankFeature = function(item) return isItemInBank(item) and isItemFeature(item) end

	filters.bagBoN = function(item) return isItemInBag(item) and isItemBoN(item) end
	filters.bankBoN = function(item) return isItemInBank(item) and isItemBoN(item) end

	filters.bagJunk = function(item) return isItemInBag(item) and isItemJunk(item) end
	filters.bankJunk = function(item) return isItemInBank(item) and isItemJunk(item) end

	filters.bagLegendary = function(item) return isItemInBag(item) and isItemLegendary(item) end
	filters.bankLegendary = function(item) return isItemInBank(item) and isItemLegendary(item) end

	for i = 1, 5 do
		filters["bagCustom"..i] = function(item) return isItemInBag(item) and isItemCustom(item, i) end
		filters["bankCustom"..i] = function(item) return isItemInBank(item) and isItemCustom(item, i) end
	end

	return filters
end