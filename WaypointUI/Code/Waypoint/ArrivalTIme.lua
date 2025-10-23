local env                 = select(2, ...)
local CallbackRegistry    = env.WPM:Import("wpm_modules/callback-registry")
local WaypointCache       = env.WPM:Import("@/Waypoint/Cache")
local WaypointArrivalTime = env.WPM:New("@/Waypoint/ArrivalTime")



local ALPHA              = 0.2
local MIN_DELTA_TIME     = 0.05
local MIN_SPEED          = 0.5
local MIN_DELTA_DISTANCE = 0.25
local seconds            = -1
local lastDistance
local lastTime
local averageSpeed



-- Calculation
--------------------------------

function WaypointArrivalTime:ResetArrivalTime()
    lastDistance, lastTime, averageSpeed = nil, nil, nil
    seconds = -1
end
CallbackRegistry:Add("Waypoint.ActiveChanged", WaypointArrivalTime.ResetArrivalTime)
CallbackRegistry:Add("Waypoint.SuperTrackingChanged", WaypointArrivalTime.ResetArrivalTime)


function WaypointArrivalTime:CalculateArrivalTime()
    local Distance = WaypointCache:Get("distance")
    if not Distance then return end


    -- Invalid distance or destination reached
    if Distance <= 0 then
        seconds = 0
        lastDistance, lastTime, averageSpeed = nil, nil, nil
        return
    end

    local now = GetTime() or 0
    if not lastDistance or not lastTime then
        lastDistance, lastTime = Distance, now
        return
    end


    -- Check if time delta is greater than min
    local deltaTime = now - lastTime
    if deltaTime < MIN_DELTA_TIME then
        return
    end

    local deltaDistance = lastDistance - Distance
    lastDistance, lastTime = Distance, now


    -- Not approaching target, invalidate ETA
    if deltaDistance <= 0 then
        seconds = -1
        return
    end


    -- Check if distanec delta is greater than min
    if deltaDistance < MIN_DELTA_DISTANCE then
        return
    end


    -- Update speed avg
    local instSpeed = deltaDistance / deltaTime
    if averageSpeed then
        averageSpeed = averageSpeed + ALPHA * (instSpeed - averageSpeed)
    else
        averageSpeed = instSpeed
    end


    -- Update ETA
    if averageSpeed and averageSpeed > MIN_SPEED then
        seconds = math.floor(Distance / averageSpeed + 0.5)
        if seconds > 86400 then -- limit 24h
            seconds = -1
        end
    else
        seconds = -1
    end
end
CallbackRegistry:Add("Waypoint.SecondUpdate", WaypointArrivalTime.CalculateArrivalTime)



-- Get
--------------------------------

function WaypointArrivalTime:GetSeconds()
    return seconds
end


-- Setup
--------------------------------

WaypointArrivalTime:ResetArrivalTime()
