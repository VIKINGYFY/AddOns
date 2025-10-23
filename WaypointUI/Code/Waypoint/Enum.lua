local env = select(2, ...)
local WaypointEnum = env.WPM:New("@/Waypoint/Enum")




-- General
--------------------------------

WaypointEnum.NavigationMode = {
    Hidden    = -1,
    Waypoint  = 1,
    Pinpoint  = 2,
    Navigator = 3
}

WaypointEnum.TrackingType = {
    QuestCompleteRecurring = 1,
    QuestCompleteImportant = 2,
    QuestComplete          = 3,
    QuestIncomplete        = 4,
    Corpse                 = 5,
    Other                  = 6
}

WaypointEnum.State = {
    Invalid        = 0,
    InvalidRange   = 1,
    QuestProximity = 2,
    QuestArea      = 3,
    Proximity      = 4,
    Area           = 5
}




-- Setting
--------------------------------

WaypointEnum.WaypointSystemType = {
    All      = 1,
    Waypoint = 2,
    Pinpoint = 3
}

WaypointEnum.WaypointDistanceTextType = {
    All         = 1,
    Distance    = 2,
    ArrivalTime = 3,
    None        = 4
}
