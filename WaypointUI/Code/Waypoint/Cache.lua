local env = select(2, ...)
local WaypointCache = env.WPM:New("@/Waypoint/Cache")

local Cache = {}

function WaypointCache:Set(k, v)
    Cache[k] = v
end

function WaypointCache:Get(k)
    return Cache[k]
end

function WaypointCache:Clear()
    for k, _ in pairs(Cache) do
        Cache[k] = nil
    end
end
