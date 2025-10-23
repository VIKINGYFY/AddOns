local env                       = select(2, ...)

local wipe                      = table.wipe

local LazyTimer                 = env.WPM:Import("wpm_modules/lazy-timer")
local Processor                 = env.WPM:Import("wpm_modules/ui-kit/renderer/processor")
local UIKit_Renderer_Cleaner = env.WPM:New("wpm_modules/ui-kit/renderer/cleaner")




-- Variables
--------------------------------

UIKit_Renderer_Cleaner.onCooldown = false


local dirty = {}
local dirtyCount = 0
local actionTablePool = {}
local poolSize = 0
local waitingForWash = false


local FIELD_ACTION = "__cleaner_actions"
local FIELD_DIRTY  = "__cleaner_isDirty"


local VALID_ACTIONS = {
    SizeStatic     = true,
    SizeFit        = true,
    SizeFill       = true,
    PositionOffset = true,
    Anchor         = true,
    Point          = true,
    Layout         = true,
    ScrollBar      = true
}


local Processor_SizeStatic = Processor.SizeStatic
local Processor_SizeFit = Processor.SizeFit
local Processor_SizeFill = Processor.SizeFill
local Processor_PositionOffset = Processor.PositionOffset
local Processor_Anchor = Processor.Anchor
local Processor_Point = Processor.Point
local Processor_Layout = Processor.Layout
local Processor_ScrollBar = Processor.ScrollBar


local function getActionTable()
    if poolSize > 0 then
        local tbl = actionTablePool[poolSize]
        actionTablePool[poolSize] = nil
        poolSize = poolSize - 1
        return tbl
    end
    return {}
end

local function returnActionTable(tbl)
    wipe(tbl)
    poolSize = poolSize + 1
    actionTablePool[poolSize] = tbl
end


-- Timers
--------------------------------

local washTimer = LazyTimer:New()
local cooldownTimer = LazyTimer:New()
washTimer:SetAction(function() UIKit_Renderer_Cleaner.Wash() end)
cooldownTimer:SetAction(function() UIKit_Renderer_Cleaner.onCooldown = false end)


-- API
--------------------------------

function UIKit_Renderer_Cleaner:AddDirty(action, frame)
    if not VALID_ACTIONS[action] then return end

    local actions = frame[FIELD_ACTION]
    if not actions then
        actions = getActionTable()
        frame[FIELD_ACTION] = actions
        frame[FIELD_DIRTY] = true
        dirtyCount = dirtyCount + 1
        dirty[dirtyCount] = frame
    end

    actions[action] = true

    if not waitingForWash then
        waitingForWash = true
        washTimer:Start(0)
    end
end

local function processForwardPass(frame, actions)
    if actions.SizeStatic then Processor_SizeStatic(frame) end
    if actions.SizeFill then Processor_SizeFill(frame) end
    if actions.PositionOffset then Processor_PositionOffset(frame) end
    if actions.Anchor then Processor_Anchor(frame) end
    if actions.Point then Processor_Point(frame) end
end

local function processBackwardPass(frame, actions)
    if actions.SizeFit then Processor_SizeFit(frame) end
    if actions.Layout then Processor_Layout(frame) end
end

local function cleanupFrame(frame)
    local actions = frame[FIELD_ACTION]
    returnActionTable(actions)
    frame[FIELD_ACTION] = nil
    frame[FIELD_DIRTY] = nil
end


function UIKit_Renderer_Cleaner.Wash()
    if UIKit_Renderer_Cleaner.onCooldown or dirtyCount == 0 then return end

    UIKit_Renderer_Cleaner.onCooldown = true
    cooldownTimer:Start(0)
    waitingForWash = false

    -- PASS 1: Initial layout resolution
    -- Forward: Apply parent-dependent properties (top-down)
    for i = 1, dirtyCount do
        local frame = dirty[i]
        processForwardPass(frame, frame[FIELD_ACTION])
    end

    -- Backward: Apply child-dependent properties (bottom-up)
    for i = dirtyCount, 1, -1 do
        local frame = dirty[i]
        processBackwardPass(frame, frame[FIELD_ACTION])
    end

    -- PASS 2: Dependency resolution
    -- Re-apply to resolve interdependencies from first pass
    -- Forward: Reapply parent-dependent properties
    for i = 1, dirtyCount do
        local frame = dirty[i]
        processForwardPass(frame, frame[FIELD_ACTION])
    end

    -- Backward: Reapply child-dependent properties
    for i = dirtyCount, 1, -1 do
        local frame = dirty[i]
        processBackwardPass(frame, frame[FIELD_ACTION])
    end

    -- FINAL PASS: ScrollBar updates and cleanup
    for i = 1, dirtyCount do
        local frame = dirty[i]
        local actions = frame[FIELD_ACTION]

        if actions.ScrollBar then
            Processor_ScrollBar(frame)
        end

        cleanupFrame(frame)
        dirty[i] = nil
    end

    dirtyCount = 0
end
