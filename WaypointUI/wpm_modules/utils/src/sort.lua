local env = select(2, ...)

local pairs = pairs
local tostring = tostring
local tonumber = tonumber
local table_sort = table.sort
local string_lower = string.lower
local string_find = string.find

local Utils_Sort = env.WPM:New("wpm_modules/utils/sort")

local decoratedPool = {}

local function extractSubVariable(list, subVariableList, len)
    if len == 0 then
        return list
    end

    local cur = list
    for i = 1, len do
        if cur == nil then return nil end
        cur = cur[subVariableList[i]]
    end
    return cur
end

local function find_string(hay, needle)
    if Utils_Sort.FindString then
        return Utils_Sort:FindString(hay, needle)
    end
    return string_find(hay, needle, 1, true) ~= nil
end

-- Finds the position of a specified key in a table (keeps original semantics of using pairs order).
---@param tbl table
---@param indexValue any
---@return any index
function Utils_Sort:FindKeyPositionInTable(tbl, indexValue)
    if tbl == nil then return nil end
    local idx = 0
    for k in pairs(tbl) do
        idx = idx + 1
        if k == indexValue then return idx end
    end
    return nil
end

-- Finds the position of a specified value in a table (keeps original semantics of using pairs order).
---@param tbl table
---@param indexValue any
---@return any index
function Utils_Sort:FindValuePositionInTable(tbl, indexValue)
    if tbl == nil then return nil end
    local idx = 0
    for _, v in pairs(tbl) do
        idx = idx + 1
        if v == indexValue then return idx end
    end
    return nil
end

-- Returns a sub variable from a list (fast path and safe when subVariableList is nil/empty).
---@param list table
---@param subVariableList table
---@return any
function Utils_Sort:GetSubVariableFromList(list, subVariableList)
    local len = (subVariableList and #subVariableList) or 0
    return extractSubVariable(list, subVariableList, len)
end

-- Finds the position of a variable value in a table (array-style).
---@param tbl table
---@param subVariableList table
---@param value any
function Utils_Sort:FindVariableValuePositionInTable(tbl, subVariableList, value)
    if tbl == nil then return nil end
    local len = (subVariableList and #subVariableList) or 0
    for i = 1, #tbl do
        local sub = extractSubVariable(tbl[i], subVariableList, len)
        if sub == value then return i end
    end
    return nil
end

-- Internal decorator-based sorter (reduces repeated GetSubVariableFromList calls).
local function decorate_sort_and_unwrap(list, subVariableList, comparator)
    if list == nil then return list end
    local n = #list
    if n <= 1 then return list end

    local indices = subVariableList
    local len = (indices and #indices) or 0
    local decorated = decoratedPool

    for i = 1, n do
        local entry = decorated[i]
        local value = list[i]
        local key = extractSubVariable(value, indices, len)
        if entry then
            entry.key = key
            entry.val = value
        else
            decorated[i] = { key = key, val = value }
        end
    end

    for i = n + 1, #decorated do
        decorated[i] = nil
    end

    table_sort(decorated, function(a, b)
        return comparator(a.key, b.key)
    end)

    for i = 1, n do
        list[i] = decorated[i].val
    end

    return list
end

-- Sorts a list by numbers.
---@param list table
---@param subVariableList table
---@param ascending? boolean: use ascending order
---@return table
function Utils_Sort:SortListByNumber(list, subVariableList, ascending)
    local function compareDescending(a, b)
        if a == nil and b == nil then return false end
        if a == nil then return false end
        if b == nil then return true end
        local na, nb = tonumber(a) or a, tonumber(b) or b
        return na < nb
    end

    local function compareAscending(a, b)
        if a == nil and b == nil then return false end
        if a == nil then return false end
        if b == nil then return true end
        local na, nb = tonumber(a) or a, tonumber(b) or b
        return na > nb
    end

    local comp = ascending and compareAscending or compareDescending

    return decorate_sort_and_unwrap(list, subVariableList, comp)
end

-- Sorts a list by alphabetical order.
---@param list table
---@param subVariableList table
---@param descending? boolean: use descending order (Z-A)
---@return table
function Utils_Sort:SortListByAlphabeticalOrder(list, subVariableList, descending)
    local function compareDescending(a, b)
        a = (a == nil) and "" or tostring(a)
        b = (b == nil) and "" or tostring(b)
        return string_lower(a) > string_lower(b)
    end

    local function compareAscending(a, b)
        a = (a == nil) and "" or tostring(a)
        b = (b == nil) and "" or tostring(b)
        return string_lower(a) < string_lower(b)
    end

    local comp = descending and compareDescending or compareAscending

    return decorate_sort_and_unwrap(list, subVariableList, comp)
end

-- Filters a list by a variable.
---@param list table
---@param subVariableList table
---@param value any: value to filter
---@param roughMatch? boolean: use rough matching
---@param caseSensitive? boolean: use case-sensitive matching (default: true)
---@param customCheck? function
---@return table
function Utils_Sort:FilterListByVariable(list, subVariableList, value, roughMatch, caseSensitive, customCheck)
    if not list then return {} end
    local out = {}
    local outSize = 0
    local cs = (caseSensitive == nil) and true or caseSensitive
    local rough = not not roughMatch
    local indices = subVariableList
    local len = (indices and #indices) or 0

    local needle = value
    if not cs and value ~= nil then
        needle = string_lower(tostring(value))
    end
    local needleString = tostring(needle)

    for i = 1, #list do
        local entry = list[i]
        if customCheck then
            if customCheck(entry) then
                outSize = outSize + 1
                out[outSize] = entry
            end
        else
            local sv = extractSubVariable(entry, indices, len)
            if sv ~= nil then
                if rough then
                    local hay = tostring(sv)
                    if not cs then hay = string_lower(hay) end
                    if find_string(hay, needleString) then
                        outSize = outSize + 1
                        out[outSize] = entry
                    end
                else
                    if cs then
                        if sv == needle then
                            outSize = outSize + 1
                            out[outSize] = entry
                        end
                    else
                        if string_lower(tostring(sv)) == needleString then
                            outSize = outSize + 1
                            out[outSize] = entry
                        end
                    end
                end
            end
        end
    end

    return out
end
