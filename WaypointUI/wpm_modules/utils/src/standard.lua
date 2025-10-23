local env = select(2, ...)
local Utils_Standard = env.WPM:New("wpm_modules/utils/standard")

-- Returns the length of a table.
---@param tbl table
---@return number length
function Utils_Standard.GetTableLength(tbl)
    local length = 0
    for _ in pairs(tbl) do
        length = length + 1
    end
    return length
end

-- Reverses a table.
---@param tbl table
---@return table table
function Utils_Standard.ReverseTable(tbl)
    local reversed = {}
    local len = #tbl
    for i = len, 1, -1 do
        reversed[len - i + 1] = tbl[i]
    end
    return reversed
end

-- Generates a random id.
---@return number id
function Utils_Standard.GenerateRandomID()
    return math.random(1, 99999999)
end
