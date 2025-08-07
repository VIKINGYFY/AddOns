---@class ns
local addon = select(2, ...)

-- BetterBags namespace
-----------------------------------------------------------
---@class BetterBags: AceAddon
local BetterBags = LibStub('AceAddon-3.0'):GetAddon("BetterBags")

---@class Categories: AceModule
---@field GetCategoryByName fun(self: Categories, name: string): CustomCategoryFilter|nil
---@field RemoveItemFromCategory fun(self: Categories, itemID: number): nil
---@field RegisterCategoryFunction fun(self: Categories, name: string, fn: fun(data: ItemData): string|nil): nil
---@field ephemeralCategories table<string, CustomCategoryFilter> -- private
---@field ephemeralCategoryByItemID table<number, CustomCategoryFilter>
local Categories = BetterBags:GetModule('Categories')

---@class Events: AceModule
local Events = BetterBags:GetModule('Events')

---@class Database: AceModule
---@field GetItemCategoryByItemID fun(self: Database, itemID: number): CustomCategoryFilter|nil
local Database = BetterBags:GetModule('Database')

-- Use the L:G() function to get the localized string.
---@class Localization: AceModule
local L = BetterBags:GetModule('Localization')

-- Lua API
-----------------------------------------------------------
local string_find = string.find

---@param inputString string
---@param patterns string[]
---@return string[]|nil
local function string_findm(inputString, patterns)
	local results = {}
	local keys    = {}

	for i = 1, #patterns do
		local patternToMatch = patterns[i]
		local start, endd = string_find(inputString, patternToMatch)
		if start ~= nil then
			results[patternToMatch] = { start, endd }
			table.insert(keys, start)
		end
	end

	if #keys == 0 then return nil end

	table.sort(keys)
	local finalArray = {}
	for i = 1, #keys do
		table.insert(finalArray, results[keys[i]])
	end
	return finalArray
end

-- WoW API
-----------------------------------------------------------
local CreateFrame = CreateFrame
local C_TooltipInfo_GetBagItem = C_TooltipInfo and C_TooltipInfo.GetBagItem
local C_Item_IsEquippableItem = C_Item and C_Item.IsEquippableItem

-----------------------------------------------------------
-- Filter Setup
-----------------------------------------------------------
local BOP_STRINGS = { ITEM_SOULBOUND, ITEM_BIND_ON_PICKUP }
local BOA_STRINGS = { ITEM_ACCOUNTBOUND, ITEM_BNETACCOUNTBOUND, ITEM_BIND_TO_ACCOUNT, ITEM_BIND_TO_BNETACCOUNT }
local WUE_STRINGS = { ITEM_ACCOUNTBOUND_UNTIL_EQUIP, ITEM_BIND_TO_ACCOUNT_UNTIL_EQUIP }

-- Tooltip used for scanning.
local _SCANNER = "AVY_ScannerTooltip"

--- Get the category of an item.
---@param bagIndex number
---@param slotIndex number
---@param itemInfo ExpandedItemInfo|nil
---@return string|nil
function addon:GetItemCategory(bagIndex, slotIndex, itemInfo)
	local category = nil

	--- Whether we have C_TooltipInfo APIs available
	if (addon.IsRetail) then
		local tooltipInfo = C_TooltipInfo_GetBagItem(bagIndex, slotIndex)
		if not tooltipInfo then return end
		for i = 2, 6 do
			local line = tooltipInfo.lines[i]
			if (not line) then
				break
			end
			local bind = self:GetBindString(line.leftText)
			if (bind) then
				category = bind
				break
			end
		end
	else
		if itemInfo == nil then return end
		if (itemInfo.bindType == 2 or itemInfo.bindType == 3) then
			local Scanner = CreateFrame("GameTooltip", _SCANNER .. itemInfo.itemGUID, nil, "SharedTooltipTemplate")
			Scanner:SetOwner(WorldFrame, "ANCHOR_NONE")
			Scanner:ClearLines()
			if bagIndex == BANK_CONTAINER then
				Scanner:SetInventoryItem("player", BankButtonIDToInvSlotID(slotIndex, nil))
			else
				Scanner:SetBagItem(bagIndex, slotIndex)
			end
			local lines = self:GetTooltipLines(Scanner)
			for _, line in ipairs(lines) do
				if (line == '') then
					break
				end
				local bind = self:GetBindString(line)
				if (bind) then
					category = bind
					break
				end
			end
			Scanner:Hide()
		end
	end
	return category
end

---@param msg string
---@return string|nil
function addon:GetBindString(msg)
	if (msg) then
		if (string_find(msg, ITEM_BIND_ON_EQUIP)) then
			return addon.S_BOE
		elseif (string_findm(msg, BOP_STRINGS)) then
			return addon.S_BOP
		elseif (string_findm(msg, WUE_STRINGS)) then
			return addon.S_WUE
		elseif (string_findm(msg, BOA_STRINGS)) then
			return addon.S_BOA
		end
	end
end

---@param tooltip GameTooltip
function addon:GetTooltipLines(tooltip)
	local textLines = {}
	local regions = { tooltip:GetRegions() }
	for _, r in ipairs(regions) do
		if r:IsObjectType("FontString") then
			table.insert(textLines, r:GetText())
		end
	end
	return textLines
end

---@param category string|nil
---@return boolean
function addon:CategoryEnabled(category)
	if (category == addon.S_BOA) then
		return addon.db.enableBoa
	elseif (category == addon.S_BOE) then
		return addon.db.enableBoe
	elseif (category == addon.S_WUE) then
		return addon.db.enableWue
	elseif (category == addon.S_BOP) then
		return addon.db.enableBop
	end
	return false
end

---@param data ItemData
function addon:CategoryFilter(data)
	local quality = data.itemInfo.itemQuality
	local bindType = data.itemInfo.bindType
	local equippable = C_Item_IsEquippableItem(data.itemInfo.itemID)
	if (addon.db.onlyEquippable and not equippable) then return nil end

	-- Only parse items that are Common (1) and above, and are of type BoP, BoE, BoU, BoA, BoW
	local junk = quality ~= nil and quality == 0
	if (not junk or (bindType ~= nil and bindType > 0 and (bindType < 4 or bindType > 6))) then
		local category = addon:GetItemCategory(data.bagid, data.slotid, data.itemInfo)
		if (category ~= nil and addon:CategoryEnabled(category)) then
			return L:G(category)
		end
	end

	return nil
end

local function GetCategory(itemID)
	local category = Database:GetItemCategoryByItemID(itemID)
	if (category and category.name) then return category.name end
	-- this might break due to using internals of the Categories module
	category = Categories.ephemeralCategoryByItemID[itemID]
	if (category and category.name) then return category.name end
	return nil
end

---@param slot number
function addon:RemoveBindConfirmFromCategory(slot)
	if addon.bindConfirm == nil then return end
	if not addon.IsRetail then return end

	local id = addon.bindConfirm.id
	local itemID = C_Item.GetItemID({ equipmentSlotIndex = slot })

	local category = addon.bindConfirm.category
	local categoryName = GetCategory(itemID)

	-- ensure we're deleting an item from the correct category
	if (itemID ~= id or category ~= categoryName) then return end

	if (category == L:G(addon.S_BOE) or category == L:G(addon.S_WUE)) then
		Categories:RemoveItemFromCategory(itemID)
		addon.bindConfirm = nil -- Clear the bind confirm
	end
end

-- Check if the priority addon is available
local BetterBagsPriority = LibStub('AceAddon-3.0'):GetAddon("BetterBags_Priority", true)
local priorityEnabled = BetterBagsPriority ~= nil or false

if (priorityEnabled) then
	---@class PriorityCategories: AceModule
	---@field RegisterCategoryFunction fun(self: PriorityCategories, name: string, filterName: string, fn: fun(data: ItemData): string|nil): nil
	local PriorityCategories = BetterBagsPriority:GetModule('Categories')
	-- this is required because we have multiple categories and can't really register a single function for all of them
	local cat = Categories:GetCategoryByName(L:G("Bound"))
	if not cat then
		Categories:CreateCategory(addon.context:New("Bound_Create_UmbrellaCat"), {
			name = L:G("Bound"),
			itemList = {},
		})
	end

	-- If the priority addon is available, we register the custom category as an empty filter with BetterBags to keep the
	-- "enable system" working. The actual filtering will be done by the priority addon
	Categories:RegisterCategoryFunction("BoEBoAItemsCategoryFilter", function(data)
		return nil
	end)

	-- categoriesWithPriority:RegisterCategoryFunction("YOUR_ADDON_TITLE", "YOUR_FILTER_NAME_HERE", fn)
	PriorityCategories:RegisterCategoryFunction(L:G("Bound"), "BoEBoAItemsCategoryFilter", function(data)
		return addon:CategoryFilter(data)
	end)
else
	-- Use this API to register a function that will be called for every item in the player's bags.
	-- The function you provide will be given an ItemData table, which contains all properties of an item
	-- loaded from the Blizzard API. From here, you can call any custom code you want to analyze the item.
	-- Your function must return a string, which is the category name that the item should be placed in.
	-- If your function returns nil, the item will not be placed in any category.
	-- Results of this function, including nil, are cached, so you do not need to worry about performance
	-- after the first scan.
	-- Your current code goes here to maintain the current behaviour if the priority addon isn't enabled
	Categories:RegisterCategoryFunction("BoEBoAItemsCategoryFilter", function(data)
		return addon:CategoryFilter(data)
	end)
end
