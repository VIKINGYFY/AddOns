local env = select(2, ...)
local SettingEnum = env.WPM:New("@/Setting/Enum")

SettingEnum.WidgetType = {
    Tab           = 1,
    Title         = 2,
    Container     = 3,
    Text          = 4,
    Range         = 5,
    Button        = 6,
    Checkbox      = 7,
    SelectionMenu = 8,
    ColorInput    = 9,
    Input         = 10
}

SettingEnum.ImageType = {
    Large = 1,
    Small = 2
}
