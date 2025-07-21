local CompactVendorFilterDropDownTemplate = CompactVendorFilterDropDownTemplate ---@type CompactVendorFilterDropDownTemplate

---@alias StatTablePolyfill table<string, number?>

---@type StatTablePolyfill
local statTable = {}

---@param itemLink string
---@return StatTablePolyfill? statTable
local function UpdateItemStatTable(itemLink)
    if C_Item.GetItemStats then
        statTable = C_Item.GetItemStats(itemLink)
        return statTable
    end
    local GetItemStats = GetItemStats ---@diagnostic disable-line: undefined-global
    if GetItemStats then
        if statTable then
            table.wipe(statTable)
        end
        statTable = GetItemStats(itemLink, statTable)
    end
    return statTable
end

---@alias CompactVendorFilterDropDownStatsOptionValue string

---@class CompactVendorFilterDropDownStatsOption : CompactVendorFilterDropDownTemplateOption
---@field public value CompactVendorFilterDropDownStatsOptionValue

---@param options CompactVendorFilterDropDownStatsOption[]
---@param itemValue StatTablePolyfill
---@return StatTablePolyfill statTable
local function FilterItemValue(options, itemValue)
    local temp = {} ---@type StatTablePolyfill
    for _, option in ipairs(options) do
        if option.show and option.checked then
            local key = option.value
            local value = itemValue[key]
            temp[key] = value
        end
    end
    return temp
end

local filter = CompactVendorFilterDropDownTemplate:New(
    "Stats", {},
    "itemLink", {},
    function(self)
        local items = self.parent:GetMerchantItems()
        local itemDataKey = self.itemDataKey
        local values = self.values ---@type table<CompactVendorFilterDropDownStatsOptionValue, boolean?>
        table.wipe(values)
        for _, itemData in ipairs(items) do
            local itemLink = itemData[itemDataKey] ---@type string
            if UpdateItemStatTable(itemLink) then
                for statKey, _ in pairs(statTable) do
                    values[statKey] = true
                end
            end
        end
        for value, _ in pairs(values) do
            ---@type CompactVendorFilterDropDownStatsOption
            local option = self:GetOption(value, true) ---@diagnostic disable-line: assign-type-mismatch
            option.value = value
            option.text = tostring(_G[value])
            option.show = true
        end
    end,
    function(self, itemLink)
        local itemValue = UpdateItemStatTable(itemLink)
        if not itemValue then
            return
        end
        return FilterItemValue(self.options, itemValue)
    end,
    ---@param value? CompactVendorFilterDropDownStatsOptionValue
    ---@param itemValue? StatTablePolyfill?
    function(_, value, itemValue)
        if not value or not itemValue then
            return
        end
        local statValue = itemValue[value]
        return statValue == nil
    end,
    true
)

filter:Publish()
