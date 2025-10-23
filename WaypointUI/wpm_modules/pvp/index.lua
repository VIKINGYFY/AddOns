local env = select(2, ...)
local GetPvpTierInfo = C_PvP.GetPvpTierInfo
local PvP = env.WPM:New("wpm_modules/pvp")

local TIER_MAP = {
    Elite       = GetPvpTierInfo(6),
    Duelist     = GetPvpTierInfo(5),
    Rival2      = GetPvpTierInfo(208),
    Rival1      = GetPvpTierInfo(4),
    Challenger2 = GetPvpTierInfo(207),
    Challenger1 = GetPvpTierInfo(3),
    Combatant2  = GetPvpTierInfo(206),
    Combatant1  = GetPvpTierInfo(2),
    Unranked    = GetPvpTierInfo(1)
}

function PvP:GetRatedPVPTierFromRating(rating)
    local rank = {
        name        = nil,
        pvpTierInfo = nil
    }

    if not rating or rating <= 0 then
        rank.name = "Unranked"
        rank.pvpTierInfo = TIER_MAP.Unranked
    else
        if rating >= TIER_MAP.Duelist.ascendRating then
            rank.name = "Elite"
            rank.pvpTierInfo = TIER_MAP.Elite
        elseif rating >= TIER_MAP.Rival2.ascendRating then
            rank.name = "Duelist"
            rank.pvpTierInfo = TIER_MAP.Duelist
        elseif rating >= TIER_MAP.Rival1.ascendRating then
            rank.name = "Rival II"
            rank.pvpTierInfo = TIER_MAP.Rival2
        elseif rating >= TIER_MAP.Challenger2.ascendRating then
            rank.name = "Rival I"
            rank.pvpTierInfo = TIER_MAP.Rival1
        elseif rating >= TIER_MAP.Challenger1.ascendRating then
            rank.name = "Challenger II"
            rank.pvpTierInfo = TIER_MAP.Challenger2
        elseif rating >= TIER_MAP.Combatant2.ascendRating then
            rank.name = "Challenger I"
            rank.pvpTierInfo = TIER_MAP.Challenger1
        elseif rating >= TIER_MAP.Combatant1.ascendRating then
            rank.name = "Combatant II"
            rank.pvpTierInfo = TIER_MAP.Combatant2
        elseif rating >= TIER_MAP.Unranked.ascendRating then
            rank.name = "Combatant I"
            rank.pvpTierInfo = TIER_MAP.Combatant1
        else
            rank.name = "Unranked"
            rank.pvpTierInfo = TIER_MAP.Unranked
        end
    end

    return rank
end
