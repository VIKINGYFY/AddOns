local env = select(2, ...)
local struct = env.WPM:Import("wpm_modules/struct").New
local SettingDefine = env.WPM:New("@/Setting/Define")

SettingDefine.TitleInfo = struct{
    imagePath = nil,
    text      = nil,
    subtext   = nil
}

SettingDefine.Descriptor = struct{
    imageType   = nil,
    imagePath   = nil,
    description = nil
}
