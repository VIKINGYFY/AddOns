local env = select(2, ...)

local select = select
local pairs = pairs

local MixinUtil = env.WPM:New("wpm_modules/mixin-util")

function MixinUtil.Mixin(object, ...)
    for i = 1, select("#", ...) do
        local mixin = select(i, ...)
        for k, v in pairs(mixin) do
            object[k] = v
        end
    end

    return object
end

function MixinUtil.CreateFromMixins(...)
    return MixinUtil.Mixin({}, ...)
end

function MixinUtil.CreateAndInitFromMixin(mixin, ...)
    local object = MixinUtil.Mixin({}, mixin)
    object:Init(...)
    return object
end
