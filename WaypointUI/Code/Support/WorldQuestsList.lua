local env             = select(2, ...)
local SlashCommand    = env.WPM:Import("wpm_modules/slash-command")
local Support         = env.WPM:Import("@/Support")
local WorldQuestsList = env.WPM:New("@/Support/WorldQuestsList")



local function removeWQLSlashCmd()
    SlashCommand:RemoveSlashCommand("WQLSlashWay")
end



local function OnAddonLoad()
    C_Timer.After(10, function()
        removeWQLSlashCmd()
    end)
end
Support:Add("WorldQuestsList", OnAddonLoad)
