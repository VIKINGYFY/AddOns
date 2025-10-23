local env             = select(2, ...)
local MixinUtil       = env.WPM:Import("wpm_modules/mixin-util")

local Mixin           = MixinUtil.Mixin

local LazyTimer       = env.WPM:New("wpm_modules/lazy-timer")


local dummyFrame = CreateFrame("Frame"); dummyFrame:Hide()
local SET_SCRIPT_FUNC = getmetatable(dummyFrame).__index.SetScript


local TimerMixin = {}

function TimerMixin:OnLoad()
    self.elapsed = 0
    self.action = nil
    self.delay = 0
end

function TimerMixin.SetAction(self, action)
    self.action = action
end

local function handleOnUpdate(self, elapsed)
    self.elapsed = self.elapsed + elapsed
    if self.elapsed >= self.delay then
        self.elapsed = 0

        SET_SCRIPT_FUNC(self, "OnUpdate", nil)
        self.action(self)
    end
end

function TimerMixin.Start(self, delay)
    self.delay = delay
    SET_SCRIPT_FUNC(self, "OnUpdate", handleOnUpdate)
end


function LazyTimer:New()
    local timer = CreateFrame("Frame")
    Mixin(timer, TimerMixin)
    timer:OnLoad()

    return timer
end
