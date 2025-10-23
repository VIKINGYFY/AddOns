local env = select(2, ...)

local Utils_Conversion = env.WPM:New("wpm_modules/utils/conversion")

---@param yds number
function Utils_Conversion:ConvertYardsToMetric(yds)
    local km = 0
    local m = 0

    local meters = yds * 0.9144
    km = meters / 1000
    m = meters % 1000

    return km, m
end
