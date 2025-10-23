local env           = select(2, ...)
local UIAnim_Engine = env.WPM:Import("wpm_modules/ui-anim/engine")
local UIAnim_Enum   = env.WPM:Import("wpm_modules/ui-anim/enum")
local UIAnim        = env.WPM:New("wpm_modules/ui-anim")


UIAnim.Enum = UIAnim_Enum
UIAnim.New = UIAnim_Engine.New
UIAnim.Animate = UIAnim_Engine.Animate
UIAnim.Configure = UIAnim_Engine.Configure
UIAnim.SetTickRate = UIAnim_Engine.SetTickRate
UIAnim.SetMinTick = UIAnim_Engine.SetMinTick
UIAnim.SetEpsilon = UIAnim_Engine.SetEpsilon
