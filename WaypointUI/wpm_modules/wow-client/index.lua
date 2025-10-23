local env = select(2, ...)
local WoWClient_Events = env.WPM:Import("wpm_modules/wow-client/events")
local WoWClient_Versioning = env.WPM:Import("wpm_modules/wow-client/versioning")
local WoWClient = env.WPM:New("wpm_modules/wow-client")

WoWClient.IS_RETAIL = WoWClient_Versioning.IS_RETAIL
WoWClient.IS_CLASSIC_PROGRESSION = WoWClient_Versioning.IS_CLASSIC_PROGRESSION
WoWClient.IS_CLASSIC_ERA = WoWClient_Versioning.IS_CLASSIC_ERA
WoWClient.IS_CLASSIC_ALL = WoWClient_Versioning.IS_CLASSIC_ALL
