---@class AddonPrivate
local Private = select(2, ...)

---@class QuestUtils
---@field addon LegionRH
local questUtils = {
    addon = nil,
    ---@type table<any, string>
    L = nil,
}
Private.QuestUtils = questUtils

function questUtils:Init()
    self.L = Private.L
    local addon = Private.Addon
    self.addon = addon

    addon:RegisterEvent("GOSSIP_SHOW", "QuestUtils_GossipShow", function()
        self:OnGossipShow()
    end)

    addon:RegisterEvent("QUEST_GREETING", "QuestUtils_QuestGreeting", function()
        self:OnQuestGreeting()
    end)

    addon:RegisterEvent("QUEST_COMPLETE", "QuestUtils_QuestComplete", function()
        self:OnQuestComplete()
    end)

    addon:RegisterEvent("QUEST_DETAIL", "QuestUtils_QuestDetail", function()
        self:OnQuestDetail()
    end)

    addon:RegisterEvent("QUEST_PROGRESS", "QuestUtils_QuestProgress", function()
        self:OnQuestProgress()
    end)
end

function questUtils:CreateSettings()
    local settingsUtils = Private.SettingsUtils
    local settingsCategory = settingsUtils:GetCategory()
    local settingsPrefix = self.L["QuestUtils.SettingsCategoryPrefix"]

    settingsUtils:CreateHeader(settingsCategory, settingsPrefix, self.L["QuestUtils.SettingsCategoryTooltip"],
        { settingsPrefix })
    settingsUtils:CreateCheckbox(settingsCategory, "AUTO_QUEST_TURN_IN", "BOOLEAN", self.L["QuestUtils.AutoTurnIn"],
        self.L["QuestUtils.AutoTurnInTooltip"], true,
        settingsUtils:GetDBFunc("GETTERSETTER", "quest.autoTurnIn"))
    settingsUtils:CreateCheckbox(settingsCategory, "AUTO_QUEST_ACCEPT", "BOOLEAN", self.L["QuestUtils.AutoAccept"],
        self.L["QuestUtils.AutoAcceptTooltip"], true,
        settingsUtils:GetDBFunc("GETTERSETTER", "quest.autoAccept"))
end

---@param functionType "autoAccept" | "autoTurnIn"
---@return boolean
function questUtils:IsActive(functionType)
    return self.addon:GetDatabaseValue("quest." .. functionType)
end

function questUtils:OnGossipShow()
    if self:IsActive("autoTurnIn") then
        local activeQuests = C_GossipInfo.GetActiveQuests()
        if activeQuests then
            for _, questInfo in ipairs(activeQuests) do
                if questInfo.isComplete then
                    C_GossipInfo.SelectActiveQuest(questInfo.questID)
                    break
                end
            end
        end
    end
    if self:IsActive("autoAccept") then
        local availableQuests = C_GossipInfo.GetAvailableQuests()
        if availableQuests then
            for _, questInfo in ipairs(availableQuests) do
                C_GossipInfo.SelectAvailableQuest(questInfo.questID)
                break
            end
        end
    end
end

function questUtils:OnQuestGreeting()
    if self:IsActive("autoTurnIn") then
        local numActive = GetNumActiveQuests()
        for i = 1, numActive do
            local activeID = GetActiveQuestID(i)
            if activeID then
                local isComplete = C_QuestLog.IsComplete(activeID)
                if isComplete then
                    ---@diagnostic disable-next-line: redundant-parameter
                    SelectActiveQuest(i)
                end
            end
        end
    end
    if self:IsActive("autoAccept") and GetNumAvailableQuests() > 0 then
        ---@diagnostic disable-next-line: redundant-parameter
        SelectAvailableQuest(1)
    end
end

function questUtils:OnQuestComplete()
    if self:IsActive("autoTurnIn") then
        pcall(function()  -- Only complete with no selection
            ---@diagnostic disable-next-line: param-type-mismatch
            GetQuestReward(nil)
        end)
    end
end

function questUtils:OnQuestDetail()
    if self:IsActive("autoAccept") then
        AcceptQuest()
    end
end

function questUtils:OnQuestProgress()
    if self:IsActive("autoTurnIn") and IsQuestCompletable() then
        CompleteQuest()
    end
end
