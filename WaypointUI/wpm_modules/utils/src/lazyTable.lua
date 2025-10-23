local env = select(2, ...)
local Utils_LazyTable = env.WPM:New("wpm_modules/utils/lazy-table")

--[[
        local parent = {}
        parent["LT_name"] = 0
        parent["LT_name_value1"] = ...
        parent["LT_name_value2"] = ...
]]





-- Instantiates a new lazy table with the provided name under the parent table.
---@param parent table
---@param name string
function Utils_LazyTable.New(parent, name)
    parent["LT_" .. name] = 0
end

-- Returns the length of the lazy table with the provided name under the parent table.
---@param parent table
---@param name string
function Utils_LazyTable.Length(parent, name)
    return parent["LT_" .. name]
end





-- Inserts a value into the lazy table with the provided name under the parent table.
---@param parent table
---@param name string
---@param value any
function Utils_LazyTable.Insert(parent, name, value)
    if not parent["LT_" .. name] then
        Utils_LazyTable.New(parent, name)
    end
    parent["LT_" .. name] = parent["LT_" .. name] + 1
    parent["LT_" .. name .. Utils_LazyTable.Length(parent, name)] = value
end

-- Sets a value in the lazy table with the provided name under the parent table.
---@param parent table
---@param name string
---@param index number
---@param value any
function Utils_LazyTable.Set(parent, name, index, value)
    parent["LT_" .. name .. index] = value
end

-- Removes a value from the lazy table with the provided name under the parent table.
---@param parent table
---@param name string
---@param index number
function Utils_LazyTable.Remove(parent, name, index)
    parent["LT_" .. name .. index] = nil
    parent["LT_" .. name] = parent["LT_" .. name] - 1
end






-- Retrieves a value from the lazy table with the provided name under the parent table.
---@param parent table
---@param name string
---@param index number
function Utils_LazyTable.Get(parent, name, index)
    return parent["LT_" .. name .. index]
end
