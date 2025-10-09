---@class AddonPrivate
local Private = select(2, ...)

---@class ScrappableItem
---@field bagID number
---@field slotID number
---@field level number
---@field icon number
---@field invType Enum.InventoryType
---@field quality Enum.ItemQuality
---@field link string
---@field location ItemLocation

---@class ScrappingUtils
---@field ui ScrappingUI
local scrappingUtils = {
    ui = nil,
    cachedMappedPendingItems = nil,
}
Private.ScrappingUtils = scrappingUtils

local const = Private.constants

function scrappingUtils:Init()
    self.ui = Private.ScrappingUI

    local addon = Private.Addon
    addon:RegisterEvent("ADDON_LOADED", "scrappingUtils_AddonLoaded", function(_, _, loadedAddonName)
        if loadedAddonName == "Blizzard_ScrappingMachineUI" then
            addon:UnregisterEventCallback("ADDON_LOADED", "scrappingUtils_AddonLoaded")
            self.ui:Init()
        end
    end)

    addon:RegisterEvent("SCRAPPING_MACHINE_PENDING_ITEM_CHANGED", "scrappingUtils_ScrappingMachinePendingItemChanged",
        function()
            self.cachedMappedPendingItems = self:GetMappedPendingScrappableItems()
            self:AutoScrap()
        end)
end

---@param bagID number
---@param slotID number
---@return boolean success
function scrappingUtils:ScrapItemFromBag(bagID, slotID)
    C_Container.PickupContainerItem(bagID, slotID)
    local slots = { ScrappingMachineFrame.ItemSlots:GetChildren() }
    for scrappingMachineIndex = 1, const.SCRAPPING_MACHINE.MAX_SLOTS do
        if not C_ScrappingMachineUI.GetCurrentPendingScrapItemLocationByIndex(scrappingMachineIndex - 1) then
            slots[scrappingMachineIndex]:Click()
            return true
        end
    end
    ClearCursor()
    return false
end

---@return string[]
function scrappingUtils:GetMappedPendingScrappableItems()
    local pendingItemsMap = {}
    for _, itemLoc in ipairs(self:GetPendingScrappableItems()) do
        pendingItemsMap[table.concat({ itemLoc:GetBagAndSlot() }, "-")] = true
    end
    return pendingItemsMap
end

---@return ItemLocation[]
function scrappingUtils:GetPendingScrappableItems()
    local pendingItems = {}
    for i = 1, const.SCRAPPING_MACHINE.MAX_SLOTS do
        local itemLoc = C_ScrappingMachineUI.GetCurrentPendingScrapItemLocationByIndex(i - 1)
        if itemLoc then
            tinsert(pendingItems, itemLoc)
        end
    end
    return pendingItems
end

---@param itemLoc ItemLocation
---@return boolean isPending
function scrappingUtils:IsItemLocationPendingScrap(itemLoc)
    if not itemLoc or not itemLoc:IsValid() then
        return false
    end
    if not self.cachedMappedPendingItems then
        self.cachedMappedPendingItems = self:GetMappedPendingScrappableItems()
    end
    return self.cachedMappedPendingItems[table.concat({ itemLoc:GetBagAndSlot() }, "-")] or false
end

---@return ScrappableItem[]
function scrappingUtils:GetScrappableItems()
    local scrappableItems = {}
    for bagID = BACKPACK_CONTAINER, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
        for slotID = 1, C_Container.GetContainerNumSlots(bagID) do
            local itemLoc = ItemLocation:CreateFromBagAndSlot(bagID, slotID)
            if itemLoc:IsValid() and C_Item.CanScrapItem(itemLoc) then
                tinsert(scrappableItems, {
                    bagID = bagID,
                    slotID = slotID,
                    level = C_Item.GetCurrentItemLevel(itemLoc),
                    icon = C_Item.GetItemIcon(itemLoc),
                    invType = C_Item.GetItemInventoryType(itemLoc),
                    quality = C_Item.GetItemQuality(itemLoc),
                    link = C_Item.GetItemLink(itemLoc),
                    location = itemLoc,
                })
            end
        end
    end
    return scrappableItems
end

---@param capReturn number|nil
---@return ScrappableItem[]
function scrappingUtils:GetFilteredScrappableItems(capReturn)
    local minLevelDiff = self:GetMinimumLevelDifference() or 0
    local maxQuality = self:GetMaxScrappingQuality() or Enum.ItemQuality.Rare

    local scrappableItems = self:GetScrappableItems()
    local filteredItems = {}
    for _, item in ipairs(scrappableItems) do
        local equippedItemLevel = Private.ItemUtils:GetMinLevelForInvType(item.invType)
        if equippedItemLevel and equippedItemLevel - item.level >= minLevelDiff and item.quality <= maxQuality then
            tinsert(filteredItems, item)

            if capReturn and #filteredItems >= capReturn then
                break
            end
        end
    end
    return filteredItems
end

function scrappingUtils:GetNumActiveScrap(max)
    local count = 0
    if C_ScrappingMachineUI.HasScrappableItems() then
        for i = 1, max do
            if C_ScrappingMachineUI.GetCurrentPendingScrapItemLocationByIndex(i - 1) then
                count = count + 1
            end
        end
    end

    return count
end

function scrappingUtils:AutoScrapBatch()
    local itemsToScrap = self:GetFilteredScrappableItems(const.SCRAPPING_MACHINE.MAX_SLOTS)
    if #itemsToScrap < const.SCRAPPING_MACHINE.MAX_SLOTS then
        if self:GetNumActiveScrap(const.SCRAPPING_MACHINE.MAX_SLOTS) >= #itemsToScrap then
            return
        end
    end
    if C_ScrappingMachineUI.HasScrappableItems() then
        return
    end
    C_ScrappingMachineUI.RemoveAllScrapItems()
    for _, item in ipairs(itemsToScrap) do
        self:ScrapItemFromBag(item.bagID, item.slotID)
    end
end

function scrappingUtils:AutoScrap()
    if not self.ui.scrappingMachine:IsShown() then return end
    if not self:GetAutoScrap() then return end
    if C_ScrappingMachineUI.HasScrappableItems() then return end
    RunNextFrame(function()
        self:AutoScrapBatch()
    end)
end

---@return Enum.ItemQuality
function scrappingUtils:GetMaxScrappingQuality()
    return Private.Addon:GetDatabaseValue("scrapping.maxQuality")
end

---@param value Enum.ItemQuality
function scrappingUtils:SetMaxScrappingQuality(value)
    Private.Addon:SetDatabaseValue("scrapping.maxQuality", value)
end

---@return number
function scrappingUtils:GetMinimumLevelDifference()
    return Private.Addon:GetDatabaseValue("scrapping.minLevelDiff")
end

---@param value number
function scrappingUtils:SetMinimumLevelDifference(value)
    Private.Addon:SetDatabaseValue("scrapping.minLevelDiff", value)
end

---@return boolean
function scrappingUtils:GetAutoScrap()
    return Private.Addon:GetDatabaseValue("scrapping.autoScrap")
end

---@param value boolean
function scrappingUtils:SetAutoScrap(value)
    Private.Addon:SetDatabaseValue("scrapping.autoScrap", value)
end
