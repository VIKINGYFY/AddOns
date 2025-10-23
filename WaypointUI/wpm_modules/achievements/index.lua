local env                        = select(2, ...)

local GetStatisticsCategoryList  = GetStatisticsCategoryList
local GetCategoryNumAchievements = GetCategoryNumAchievements
local GetAchievementInfo         = GetAchievementInfo
local GetComparisonStatistic     = GetComparisonStatistic
local GetStatistic               = GetStatistic
local tostring                   = tostring

local Achievements               = env.WPM:New("wpm_modules/achievements")

-- Returns the statistic ID for the specified statistic name. Can be used for GetStatistic(id) or GetComparisonStatistic(id).
function Achievements:GetStatisticID(name)
    for _, categoryId in pairs(GetStatisticsCategoryList()) do
        for i = 1, GetCategoryNumAchievements(categoryId) do
            local _id, _name = GetAchievementInfo(categoryId, i)

            if tostring(_name) == tostring(name) then
                return _id, _name
            end
        end
    end
    return -1
end

-- Gets the value for the specified statistic ID.
---@param unit UnitToken
---@param id number
function Achievements:GetStatistic(unit, id)
    if unit ~= "player" then
        return GetComparisonStatistic(id)
    else
        return GetStatistic(id)
    end
end
