local env                          = select(2, ...)

local CreateFrame                  = CreateFrame
local abs                          = math.abs

local UIAnim_Processor             = env.WPM:Import("wpm_modules/ui-anim/processor")
local UIAnim_Enum                  = env.WPM:Import("wpm_modules/ui-anim/enum")
local UIAnim_Engine                = env.WPM:New("wpm_modules/ui-anim/engine")

local MIN_TICK                     = 1 / 60
local VALUE_EPSILON                = 0
local LOOP_YOYO                    = UIAnim_Enum.Looping and UIAnim_Enum.Looping.Yoyo

local MP_Apply                     = UIAnim_Processor.Apply
local MP_Read                      = UIAnim_Processor.Read
local MP_GetEasing                 = UIAnim_Processor.GetEasing
local MP_Prepare                   = UIAnim_Processor.PrepareApply
local MP_Resolve                   = UIAnim_Processor.ResolveTarget
local LINEAR_EASE                  = MP_GetEasing(UIAnim_Enum.Easing.Linear)

local STATE_WAIT                   = 0
local STATE_PLAY                   = 1
local STATE_LOOP_DELAY             = 2

local activeInstances              = {}
local activeInstanceCount          = 0
local instancePool                 = {}
local instancePoolCount            = 0
local wrapperRegistry              = setmetatable({}, { __mode = "k" })
local currentWrapper               = nil
local currentRunId                 = 0
local lastPlayedWrapperForOnFinish = nil
local updateFrame                  = CreateFrame("Frame")
local isUpdateLoopRunning          = false
local nextDefinitionId             = 0

local notifyFinish                 = nil
local fastApply                    = nil




-- Internal
--------------------------------

local function ensureEngine()
    if activeInstanceCount > 0 and not isUpdateLoopRunning then
        updateFrame:SetScript("OnUpdate", UIAnim_Engine.OnUpdate)
        isUpdateLoopRunning = true
    elseif activeInstanceCount == 0 and isUpdateLoopRunning then
        updateFrame:SetScript("OnUpdate", nil)
        isUpdateLoopRunning = false
    end
end


local function isTargetHidden(target)
    return target and ((target.IsShown and not target:IsShown()) or (target.IsVisible and not target:IsVisible())) or false
end

local function pushActive(instance)
    activeInstanceCount = activeInstanceCount + 1
    activeInstances[activeInstanceCount] = instance
    ensureEngine()
end

local function removeActive(index)
    local last = activeInstanceCount
    local instance = activeInstances[index]
    if not instance then return end

    if index ~= last then
        activeInstances[index] = activeInstances[last]
    end
    activeInstances[last] = nil
    activeInstanceCount = last - 1

    local wrapperInfo = instance.wrapperInfo
    if wrapperInfo then
        local count = wrapperInfo.pendingCount or 0
        if count > 0 then
            count = count - 1
            wrapperInfo.pendingCount = count
            if count == 0 then
                notifyFinish(wrapperInfo)
            end
        end
    end

    if instancePoolCount < 100 then
        instancePoolCount = instancePoolCount + 1
        instancePool[instancePoolCount] = instance
    end

    if activeInstanceCount == 0 and isUpdateLoopRunning then
        updateFrame:SetScript("OnUpdate", nil)
        isUpdateLoopRunning = false
    end
end

notifyFinish = function(wrapperInfo)
    if not wrapperInfo then return end
    local count = (wrapperInfo.pendingCount or 0) - 1
    wrapperInfo.pendingCount = count > 0 and count or 0
    if count <= 0 and wrapperInfo.finishCallback then
        local cb = wrapperInfo.finishCallback
        wrapperInfo.finishCallback = nil
        cb()
    end
end

fastApply = function(instance, currentValue)
    local applyKind = instance.applyKind
    if applyKind == "method" then
        local applyMethod = instance.applyMethod
        if applyMethod then applyMethod(instance.target, currentValue) end
    elseif applyKind == "x" or applyKind == "y" then
        local setPoint = instance.applyMethod
        if not setPoint then return end
        local target = instance.target
        local anchorP, anchorRelTo, anchorRelP = instance.anchorP, instance.anchorRelTo, instance.anchorRelP

        -- Only recheck anchor if it might have changed
        if target.GetPoint then
            local _p, _relTo, _relP, x, y = target:GetPoint()
            if _p and _p ~= anchorP then
                anchorP, anchorRelTo, anchorRelP = _p, _relTo or UIParent, _relP or _p
                instance.anchorP, instance.anchorRelTo, instance.anchorRelP = anchorP, anchorRelTo, anchorRelP
            end
            x, y = x or 0, y or 0
            if applyKind == "x" then
                setPoint(target, anchorP, anchorRelTo, anchorRelP, currentValue, y)
            else
                setPoint(target, anchorP, anchorRelTo, anchorRelP, x, currentValue)
            end
        end
    else
        MP_Apply(instance.target, instance.property, currentValue)
    end
end


local function triggerStart(instance)
    local info = instance.wrapperInfo
    if not info or info.startNotified then return end
    info.startNotified = true
    local scb = info.startCallback
    if scb then
        info.startCallback = nil
        scb()
    end
end


local function finalizeInstance(instance)
    if not instance or instance.loopType then return end

    local finalValue = instance.dir == 1 and instance.to or instance.from
    if finalValue ~= nil then
        fastApply(instance, finalValue)
        instance.lastValue = finalValue
    end
end




-- Definition Prototype
--------------------------------

local DefProto = {}
DefProto.__index = DefProto

local function resetDef(def)
    def.__property, def.__duration, def.__from, def.__to, def.__loopType = nil, nil, nil, nil, nil
    def.__easing, def.__hasFrom = "Linear", false
    def.__loopDelayStart, def.__loopDelayEnd, def.__waitStart = 0, 0, 0
    return def
end

local function allocateDefinition()
    local def = resetDef({})
    nextDefinitionId = nextDefinitionId + 1
    def.__id = nextDefinitionId
    return setmetatable(def, DefProto)
end

function DefProto:wait(seconds)
    self.__waitStart = (seconds or 0); return self
end
function DefProto:property(prop)
    self.__property = prop; return self
end
function DefProto:duration(seconds)
    self.__duration = seconds; return self
end
function DefProto:easing(ease)
    self.__easing = ease; return self
end
function DefProto:from(value)
    self.__from = value; self.__hasFrom = true; return self
end
function DefProto:to(value)
    self.__to = value; return self
end
function DefProto:loop(loopType)
    self.__loopType = loopType; return self
end
function DefProto:loopDelayStart(seconds)
    self.__loopDelayStart = (seconds or 0); return self
end
function DefProto:loopDelayEnd(seconds)
    self.__loopDelayEnd = (seconds or 0); return self
end

local function createInstance(def, target)
    local instance
    if instancePoolCount > 0 then
        instance = instancePool[instancePoolCount]
        instancePool[instancePoolCount] = nil
        instancePoolCount = instancePoolCount - 1
    else
        instance = {}
    end

    local loopType = def.__loopType
    local duration = def.__duration or 0
    local wrapperInfo = currentWrapper and wrapperRegistry[currentWrapper] or nil

    instance.target = target
    instance.property = def.__property
    instance.duration = duration
    instance.easing = MP_GetEasing(def.__easing)
    instance.from = def.__hasFrom and def.__from or nil
    instance.to = def.__to
    instance.loopType = loopType
    instance.loopDelayS = def.__loopDelayStart or 0
    instance.loopDelayE = def.__loopDelayEnd or 0
    instance.state = STATE_PLAY
    instance.dir = 1
    instance.t = 0
    instance.timer = 0
    instance.wrapper = currentWrapper
    instance.wrapperInfo = wrapperInfo
    instance.runId = currentRunId
    instance.stateName = wrapperInfo and wrapperInfo.activeStateName or nil
    instance.defId = def.__id
    instance.hasBeenVisible = not isTargetHidden(target)
    instance.invDuration = duration > 0 and (1 / duration) or 0

    -- Prepare fast apply path (cached method/anchors)
    if target then
        local kind, method, anchorP, anchorRelTo, anchorRelP = MP_Prepare(target, def.__property)
        instance.applyKind = kind
        instance.applyMethod = method
        instance.anchorP = anchorP
        instance.anchorRelTo = anchorRelTo
        instance.anchorRelP = anchorRelP
    end

    -- Apply initial delay logic
    local startDelay = (def.__waitStart or 0) + (loopType and (def.__loopDelayStart or 0) or 0)
    if startDelay > 0 then
        instance.state = STATE_WAIT
        instance.timer = startDelay
    else
        instance.state = STATE_PLAY
        instance.t = 0
        instance.timer = 0
        triggerStart(instance)
    end

    -- Resolve starting value if not provided
    if not instance.from then
        instance.from = MP_Read(target, def.__property)
    end

    -- Precompute delta for cheaper interpolation
    instance.delta = (instance.to or 0) - (instance.from or 0)
    instance.accum = 0
    instance.lastValue = instance.from

    return instance
end

local function stopExistingDefInstance(wrapper, defId, target)
    if not (wrapper and defId) then return end

    local index = 1
    while index <= activeInstanceCount do
        local existing = activeInstances[index]
        if existing and existing.wrapper == wrapper and existing.defId == defId then
            if (not target) or existing.target == target then
                finalizeInstance(existing)
                removeActive(index)
                return
            end
        end
        index = index + 1
    end
end

function DefProto:Play(target)
    -- Validate minimal requirements
    local prop, dur, to = self.__property, self.__duration, self.__to
    if not (prop and dur and to ~= nil) then
        return self
    end

    if target == nil then
        error("UIAnim.Animate:Play requires a target.", 2)
    end

    local resolvedTarget = MP_Resolve(target)
    if not resolvedTarget then
        return self
    end

    if currentWrapper and self.__id then
        stopExistingDefInstance(currentWrapper, self.__id, resolvedTarget)
    end

    local isLooping = self.__loopType ~= nil
    local wrapperInfo = currentWrapper and wrapperRegistry[currentWrapper]

    -- Count towards finish if non-looping and in a wrapper context
    if not isLooping and wrapperInfo then
        wrapperInfo.pendingCount = wrapperInfo.pendingCount + 1
    end

    -- Immediate apply path without creating an instance
    if dur <= 0 then
        MP_Apply(resolvedTarget, prop, to)
        if not isLooping and wrapperInfo then notifyFinish(wrapperInfo) end
        return self
    end

    -- Always use CPU update loop to avoid native allocations
    local instance = createInstance(self, resolvedTarget)
    if not instance.target then
        if not isLooping and wrapperInfo then notifyFinish(wrapperInfo) end
        return self
    end
    pushActive(instance)
    return self
end




-- Wrapper Prototype
--------------------------------

local WrapperProto = {}
WrapperProto.__index = WrapperProto

function WrapperProto:State(name, fn)
    if not name or type(fn) ~= "function" then return self end
    local wrapperInfo = wrapperRegistry[self]
    if not wrapperInfo then return self end
    wrapperInfo.states[name] = fn
    return self
end

function WrapperProto:Play(target, name)
    local wrapperInfo = wrapperRegistry[self]
    if not wrapperInfo then return self end

    local stateTarget, stateName
    if name == nil and type(target) == "string" then
        stateTarget, stateName = nil, target
    else
        stateTarget, stateName = target, name
    end

    if not stateName then return self end

    -- Stop previous and new run
    self:Stop()
    wrapperInfo.runId = wrapperInfo.runId + 1
    wrapperInfo.pendingCount = 0
    wrapperInfo.finishCallback = nil
    wrapperInfo.startCallback = nil
    wrapperInfo.startNotified = false

    -- Run state callback with play context
    local stateFunction = wrapperInfo.states[stateName]
    if stateFunction then
        currentWrapper = self
        currentRunId = wrapperInfo.runId
        wrapperInfo.activeStateName = stateName
        local definitionCache = wrapperInfo.defCache[stateName]
        if not definitionCache then
            definitionCache = { defs = {}, index = 0 }
            wrapperInfo.defCache[stateName] = definitionCache
        else
            definitionCache.index = 0
        end
        stateFunction(stateTarget)
        currentWrapper = nil
        currentRunId = 0
        wrapperInfo.activeStateName = nil
        lastPlayedWrapperForOnFinish = self
    end
    return self
end

function WrapperProto:IsPlaying(target, name)
    local wrapperInfo = wrapperRegistry[self]
    if not wrapperInfo then return false end

    local queryTarget, queryState
    if name == nil and type(target) == "string" then
        queryTarget, queryState = nil, target
    else
        queryTarget, queryState = target, name
    end

    local resolvedTarget = queryTarget and MP_Resolve(queryTarget) or nil

    for index = 1, activeInstanceCount do
        local instance = activeInstances[index]
        if instance and instance.wrapper == self then
            if instance.runId == (wrapperInfo.runId or 0) then
                if (not queryState or instance.stateName == queryState) and (not resolvedTarget or instance.target == resolvedTarget) then
                    return true
                end
            end
        end
    end

    return false
end

function WrapperProto.onFinish(cb)
    local wrapper = lastPlayedWrapperForOnFinish
    if not wrapper then return WrapperProto end
    local info = wrapperRegistry[wrapper]
    if not info then
        lastPlayedWrapperForOnFinish = nil; return WrapperProto
    end
    if cb then
        if (info.pendingCount or 0) == 0 then
            cb()
        else
            info.finishCallback = cb
        end
    end
    lastPlayedWrapperForOnFinish = nil
    return wrapper
end

function WrapperProto.onStart(cb)
    local wrapper = lastPlayedWrapperForOnFinish
    if not wrapper then return WrapperProto end
    local info = wrapperRegistry[wrapper]
    if not info then
        lastPlayedWrapperForOnFinish = nil; return WrapperProto
    end
    if cb then
        if info.startNotified then
            cb()
        else
            info.startCallback = cb
        end
    end
    return wrapper
end

function WrapperProto:Stop()
    local wrapperInfo = wrapperRegistry[self]
    if not wrapperInfo then return self end

    -- Invalidate all current instances by bumping runId
    wrapperInfo.runId = wrapperInfo.runId + 1
    wrapperInfo.pendingCount = 0
    wrapperInfo.finishCallback = nil
    wrapperInfo.startCallback = nil
    wrapperInfo.startNotified = false

    -- Proactively purge matching instances
    local instanceIndex = 1
    while instanceIndex <= activeInstanceCount do
        local animationInstance = activeInstances[instanceIndex]
        if animationInstance and animationInstance.wrapper == self then
            finalizeInstance(animationInstance)
            removeActive(instanceIndex)
        else
            instanceIndex = instanceIndex + 1
        end
    end

    return self
end



-- Engine Update
--------------------------------

local function stepInstance(instance, elapsed)
    -- Stale instance: wrapper changed state
    local wrapperInfo = instance.wrapperInfo
    if wrapperInfo then
        if instance.runId ~= wrapperInfo.runId then
            return true
        end
    elseif instance.wrapper then
        wrapperInfo = wrapperRegistry[instance.wrapper]
        if not wrapperInfo or instance.runId ~= wrapperInfo.runId then
            return true
        end
        instance.wrapperInfo = wrapperInfo
    end

    -- Accumulate time and throttle updates
    local accumulatedTime = instance.accum + elapsed
    if accumulatedTime < MIN_TICK then
        instance.accum = accumulatedTime
        return false
    end
    local timeToProcess = accumulatedTime
    instance.accum = 0

    -- Consume elapsed across state transitions to remain time-accurate under variable FPS
    local remaining = timeToProcess
    while remaining > 0 do
        local state = instance.state

        if state == STATE_WAIT then
            local t = instance.timer
            if remaining < t then
                instance.timer = t - remaining
                remaining = 0
                return false
            else
                remaining = remaining - t
                instance.state = STATE_PLAY
                instance.t = 0
                instance.timer = 0
                triggerStart(instance)
                -- continue loop with leftover time
            end

        elseif state == STATE_PLAY then
            local duration = instance.duration
            local t = instance.t
            local timeLeft = duration - t

            if remaining < timeLeft then
                t = t + remaining
                instance.t = t
                remaining = 0
            else
                t = duration
                instance.t = t
                remaining = remaining - timeLeft
            end

            local normalizedTime = t * instance.invDuration
            local easing = instance.easing
            local easedValue = easing == LINEAR_EASE and normalizedTime or easing(normalizedTime)
            local from, to, delta, dir = instance.from, instance.to, instance.delta, instance.dir
            local currentValue = dir == 1 and (from + delta * easedValue) or (to - delta * easedValue)
            local lastValue = instance.lastValue
            if VALUE_EPSILON <= 0 or not lastValue or abs(lastValue - currentValue) >= VALUE_EPSILON then
                fastApply(instance, currentValue)
                instance.lastValue = currentValue
            end

            local target = instance.target
            local targetHidden = isTargetHidden(target)
            if targetHidden then
                if instance.hasBeenVisible and not instance.loopType then
                    local finalValue = to
                    if finalValue ~= nil then
                        fastApply(instance, finalValue)
                        instance.lastValue = finalValue
                    end
                    if wrapperInfo then notifyFinish(wrapperInfo) end
                    return true
                elseif instance.hasBeenVisible then
                    return true
                end
            else
                instance.hasBeenVisible = true
            end

            -- Finished the play segment
            if t >= duration then
                local loopType = instance.loopType
                if not loopType then
                    -- Final apply to ensure exact target value
                    local finalValue = dir == 1 and to or from
                    fastApply(instance, finalValue)
                    instance.lastValue = finalValue
                    if wrapperInfo then notifyFinish(wrapperInfo) end
                    return true
                end

                -- Looping behaviour
                if loopType == LOOP_YOYO then
                    instance.dir = -dir
                end

                local loopDelayE = instance.loopDelayE
                if loopDelayE > 0 then
                    instance.state = STATE_LOOP_DELAY
                    instance.timer = loopDelayE
                else
                    instance.state = STATE_PLAY
                    instance.t = 0
                    instance.timer = 0
                    triggerStart(instance)
                    local loopDelayS = instance.loopDelayS
                    if loopDelayS > 0 then
                        instance.state = STATE_WAIT
                        instance.timer = loopDelayS
                    end
                end
            else
                return false
            end

        elseif state == STATE_LOOP_DELAY then
            local t = instance.timer
            if remaining < t then
                instance.timer = t - remaining
                remaining = 0
                return false
            else
                remaining = remaining - t
                instance.state = STATE_PLAY
                instance.t = 0
                instance.timer = 0
                triggerStart(instance)
                if instance.loopDelayS > 0 then
                    instance.state = STATE_WAIT
                    instance.timer = instance.loopDelayS
                end
                -- continue with leftover time
            end
        else
            return true
        end
    end

    return false
end

function UIAnim_Engine.OnUpdate(self, elapsed)
    if activeInstanceCount == 0 or (not elapsed) or elapsed <= 0 then return end
    local instanceIndex = 1
    while instanceIndex <= activeInstanceCount do
        local instance = activeInstances[instanceIndex]
        if not instance or stepInstance(instance, elapsed) then
            removeActive(instanceIndex)
        else
            instanceIndex = instanceIndex + 1
        end
    end
end



-- Public API
--------------------------------

function UIAnim_Engine.New()
    local wrapper = {}
    wrapperRegistry[wrapper] = {
        states        = {},
        runId         = 0,
        pendingCount  = 0,
        defCache      = {},
        startNotified = false
    }
    return setmetatable(wrapper, WrapperProto)
end

function UIAnim_Engine.Animate()
    -- If called within a wrapper's state play, reuse cached definitions to avoid allocations
    if currentWrapper then
        local info = wrapperRegistry[currentWrapper]
        if info then
            local stateName = info.activeStateName
            if stateName then
                local defCache = info.defCache
                local stateCache = defCache[stateName]
                if not stateCache then
                    stateCache = {}
                    defCache[stateName] = stateCache
                    stateCache.idx = 0
                end
                local idx = stateCache.idx + 1
                stateCache.idx = idx
                local def = stateCache[idx]
                if def then
                    return resetDef(def)
                else
                    local newDef = allocateDefinition()
                    stateCache[idx] = newDef
                    return newDef
                end
            end
        end
    end

    -- Fallback: create a one-off definition (outside of wrapper state playback)
    return allocateDefinition()
end
