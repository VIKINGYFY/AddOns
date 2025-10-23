local env                                 = select(2, ...)
local Config                              = env.Config

local SetSuperTrackedUserWaypoint         = C_SuperTrack.SetSuperTrackedUserWaypoint
local IsSuperTrackingAnything             = C_SuperTrack.IsSuperTrackingAnything
local ClearAllSuperTracked                = C_SuperTrack.ClearAllSuperTracked
local GetHighestPrioritySuperTrackingType = C_SuperTrack.GetHighestPrioritySuperTrackingType
local CanSetUserWaypointOnMap             = C_Map.CanSetUserWaypointOnMap
local SetUserWaypoint                     = C_Map.SetUserWaypoint
local ClearUserWaypoint                   = C_Map.ClearUserWaypoint
local HasUserWaypoint                     = C_Map.HasUserWaypoint
local CreateFrame                         = CreateFrame
local hooksecurefunc                      = hooksecurefunc
local tostring                            = tostring

local Sound                               = env.WPM:Import("wpm_modules/sound")
local CallbackRegistry                    = env.WPM:Import("wpm_modules/callback-registry")
local LazyTimer                           = env.WPM:Import("wpm_modules/lazy-timer")
local MapPin                              = env.WPM:New("@/MapPin")



local session = {
    ["name"]  = nil,
    ["mapID"] = nil,
    ["x"]     = nil,
    ["y"]     = nil
}



-- Helper
--------------------------------

local function getUserWaypointPosition()
    local userWaypoint = C_Map.GetUserWaypoint()
    if not userWaypoint then return nil end

    return {
        mapID = userWaypoint.uiMapID,
        pos   = userWaypoint.position
    }
end



-- Audio
--------------------------------

local function playUserNavigationAudio()
    local Setting_CustomAudio = Config.DBGlobal:GetVariable("AudioCustom")
    local soundID = env.Enum.Sound.NewUserNavigation

    if Setting_CustomAudio then
        if tonumber(soundID) then
            soundID = Config.DBGlobal:GetVariable("AudioCustomNewUserNavigation")
        end
    end

    Sound:PlaySound("Main", soundID)
end



-- User Navigation (/way)
--------------------------------

function MapPin.ClearUserNavigation()
    if MapPin.IsUserNavigation() then ClearUserWaypoint() end
    MapPin.SetUserNavigation()
end

function MapPin.ClearDestination()
    if MapPin.IsUserNavigation() then
        MapPin.ClearUserNavigation()
    end

    if IsSuperTrackingAnything() then
        ClearAllSuperTracked()
    end
end

function MapPin.SetUserNavigation(name, mapID, x, y)
    session = {
        name  = name,
        mapID = mapID,
        x     = x,
        y     = y
    }

    Config.DBLocal:SetVariable("slashWayCache", session)
end

function MapPin.GetUserNavigation()
    local savedWay = Config.DBLocal:GetVariable("slashWayCache")

    if not savedWay then
        session = {
            name  = nil,
            mapID = nil,
            x     = nil,
            y     = nil
        }

        Config.DBLocal:SetVariable("slashWayCache", session)
    else
        session = savedWay
    end

    return session
end

local NewWayTimer = LazyTimer:New()
NewWayTimer:SetAction(function()
    CallbackRegistry:Trigger("MapPin.NewUserNavigation")
end)

function MapPin.NewUserNavigation(name, mapID, x, y)
    if not CanSetUserWaypointOnMap(mapID) then return end

    local pos = CreateVector2D(x / 100, y / 100)
    local mapPoint = UiMapPoint.CreateFromVector2D(mapID, pos)

    MapPin.SetUserNavigation(name, mapID, pos.x, pos.y)
    SetUserWaypoint(mapPoint)
    SetSuperTrackedUserWaypoint(true)

    NewWayTimer:Start(0) -- Delay to make sure the game has tracked the new target

    playUserNavigationAudio()
end

function MapPin.IsUserNavigation()
    if not HasUserWaypoint() then return false end

    local pinTracked                = GetHighestPrioritySuperTrackingType() == Enum.SuperTrackingType.UserWaypoint
    local userWaypoint              = getUserWaypointPosition()
    local currentUserNavigationInfo = MapPin.GetUserNavigation()

    if not userWaypoint or not currentUserNavigationInfo or not currentUserNavigationInfo.mapID or not currentUserNavigationInfo.x or not currentUserNavigationInfo.y then return false end

    local mapIDMatch = tostring(userWaypoint.mapID) == tostring(currentUserNavigationInfo.mapID)
    local xMatch     = string.format("%.1f", userWaypoint.pos.x * 100) == string.format("%.1f", currentUserNavigationInfo.x * 100)
    local yMatch     = string.format("%.1f", userWaypoint.pos.y * 100) == string.format("%.1f", currentUserNavigationInfo.y * 100)

    return (pinTracked and mapIDMatch and xMatch and yMatch)
end

-- Additional Features
--------------------------------

do -- Automatically track user waypoint when placed
    local DelayTimer = LazyTimer:New()
    DelayTimer:SetAction(function()
        SetSuperTrackedUserWaypoint(true)
    end)

    local EL = CreateFrame("Frame")
    EL:RegisterEvent("USER_WAYPOINT_UPDATED")
    EL:SetScript("OnEvent", function(_, event, ...)
        if event == "USER_WAYPOINT_UPDATED" then
            DelayTimer:Start(0)
        end
    end)
end

do -- Automatically place and track user waypoint when clicking on map pin link
    hooksecurefunc("SetItemRef", function(link, text, button, chatFrame)
        local prefix, mapID, x, y = link:match("^(%a+):(%d+):(%d+):(%d+)$")
        if prefix ~= "worldmap" then return end

        x = x / 100
        y = y / 100

        local pos = CreateVector2D(x / 100, y / 100)
        local mapPoint = UiMapPoint.CreateFromVector2D(mapID, pos)

        SetUserWaypoint(mapPoint)
        SetSuperTrackedUserWaypoint(true)
    end)
end




-- Setup
--------------------------------

local function OnAddonLoad()
    MapPin.GetUserNavigation()
    CallbackRegistry:Trigger("MapPin.Ready")
end

CallbackRegistry:Add("Preload.AddonReady", OnAddonLoad)
