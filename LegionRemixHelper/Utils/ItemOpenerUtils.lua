---@class AddonPrivate
local Private = select(2, ...)

local const = Private.constants

---@class ItemOpenerUtils
local itemOpenerUtils = {
    ---@type table<any, string>
    L = nil,
    ---@type ItemUtils
    itemUtils = nil
}
Private.ItemOpenerUtils = itemOpenerUtils

function itemOpenerUtils:CreateSettings()
    local settingsUtils = Private.SettingsUtils
    local settingsCategory = settingsUtils:GetCategory()
    local settingsPrefix = self.L["ItemOpenerUtils.SettingsCategoryPrefix"]

    settingsUtils:CreateHeader(settingsCategory, settingsPrefix, self.L["ItemOpenerUtils.SettingsCategoryTooltip"],
        { settingsPrefix })
    settingsUtils:CreateCheckbox(settingsCategory, "AUTO_ITEM_OPEN", "BOOLEAN", self.L["ItemOpenerUtils.AutoItemOpen"],
        self.L["ItemOpenerUtils.AutoItemOpenTooltip"], true,
        settingsUtils:GetDBFunc("GETTERSETTER", "itemOpener.autoItemOpen"))

    local openItemTooltip = self.L["ItemOpenerUtils.AutoOpenItemEntryTooltip"]
    for _, itemEntry in ipairs(const.ITEM_OPENER.ITEMS) do
        local id = itemEntry.ITEM_ID
        local item = Item:CreateFromItemID(id)
        item:ContinueOnItemLoad(function()
            local link = item:GetItemLink()
            settingsUtils:CreateCheckbox(settingsCategory, "AUTO_ITEM_OPEN_"..id, "BOOLEAN", link,
                openItemTooltip:format(link), true,
                settingsUtils:GetDBFunc("GETTERSETTER", "itemOpener.items."..id))
        end)
    end
end

---@param itemLoc ItemLocationMixin
---@return boolean isAutoItem
function itemOpenerUtils:IsAutoItem(itemLoc)
    for _, itemEntry in ipairs(const.ITEM_OPENER.ITEMS) do
        if itemLoc and itemLoc:IsValid() then
            local itemID = C_Item.GetItemID(itemLoc)
            if itemID == itemEntry.ITEM_ID then
                return true
            end
            if itemEntry.ITEM_NAME then
                local itemName = C_Item.GetItemName(itemLoc)
                if itemName == itemEntry.ITEM_NAME then
                    return true
                end
            end
        end
    end
    return false
end

function itemOpenerUtils:OpenBagItems()
    if not Private.Addon:GetDatabaseValue("itemOpener.autoItemOpen", true) then
        return
    end
    for itemLoc in self.itemUtils:ForEachBagItem() do
        if self:IsAutoItem(itemLoc) then
            C_Container.UseContainerItem(itemLoc:GetBagAndSlot())
        end
    end
end

function itemOpenerUtils:Init()
    self.L = Private.L
    local addon = Private.Addon
    self.itemUtils = Private.ItemUtils

    addon:RegisterEvent("BAG_UPDATE_DELAYED", "ItemOpenerUtils_OnBagUpdateDelayed", function()
        self:OpenBagItems()
    end)
end

rasuL = itemOpenerUtils