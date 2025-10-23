local env                 = select(2, ...)
local Utils_LazyTable     = env.WPM:Import("wpm_modules/utils/lazy-table")

local UIKit_FrameCache = env.WPM:New("wpm_modules/ui-kit/frame-cache")
local cache               = {}




function UIKit_FrameCache:Add(id, frame)
    cache[id] = frame
end

function UIKit_FrameCache:Remove(id)
    cache[id] = nil
end

function UIKit_FrameCache:Get(id)
    return cache[id]
end

function UIKit_FrameCache:GetFramesInLazyTable(frame, name)
    -- Check whether frame has children
    local numChildren = Utils_LazyTable.Length(frame, name)
    if not numChildren then return end

    -- Store children results in a temporary Lazy table to prevent creating new tables per call
    frame.__frameCache = frame.__frameCache or {}

    local result = frame.__frameCache
    for i = 1, numChildren do
        -- Parse each children and add to results
        local currentFrame = Utils_LazyTable.Get(frame, name, i)
        result[i] = UIKit_FrameCache:Get(currentFrame)
    end

    -- Return cached children
    return result
end
