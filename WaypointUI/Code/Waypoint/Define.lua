local env            = select(2, ...)
local struct         = env.WPM:Import("wpm_modules/struct").New
local WaypointDefine = env.WPM:New("@/Waypoint/Define")


WaypointDefine.ContextIconTexture = struct{
    requestRecolor = false,
    type           = nil,
    path           = nil
}

WaypointDefine.ObjectiveInfo = struct{
    objectives       = nil,
    isMultiObjective = nil
}

WaypointDefine.RedirectInfo = struct{
    valid = nil,
    x     = nil,
    y     = nil,
    text  = nil
}
