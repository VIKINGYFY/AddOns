local env = select(2, ...)

local Utils_Formatting = env.WPM:New("wpm_modules/utils/formatting")

-- Returns x amount coverted to gold, silver and copper.
---@param x number
---@return number: gold
---@return number: silver
---@return number: copper
function Utils_Formatting:FormatMoney(x)
    local gold = math.floor(x / 10000)
    local silver = math.floor((x % 10000) / 100)
    local copperAmount = x % 100

    return gold, silver, copperAmount
end

-- Returns hr, min, sec from seconds.
---@param seconds number
---@return number rawHr
---@return number rawMin
---@return number rawSec
---@return string strHr
---@return string strMin
---@return string strSec
function Utils_Formatting:FormatTime(seconds)
    local rawHr = math.floor(seconds / 3600)
    local rawMin = math.floor((seconds % 3600) / 60)
    local rawSec = seconds % 60
    local strHr = rawHr > 0 and rawHr .. "h " or ""
    local strMin = rawMin > 0 and rawMin .. "m " or ""
    local strSec = rawSec > 0 and rawSec .. "s" or ""

    return rawHr, rawMin, rawSec, strHr, strMin, strSec
end
