local env                = select(2, ...)

local WUISettingFrame    = WUISettingFrame
local SettingsCanvas     = SettingsPanel.Container.SettingsCanvas
local IsAddonLoaded      = C_AddOns.IsAddOnLoaded

local CallbackRegistry   = env.WPM:Import("wpm_modules/callback-registry")
local SavedVariables     = env.WPM:Import("wpm_modules/saved-variables")
local SettingConstructor = env.WPM:Await("@/Setting/Constructor")
local SettingSchema      = env.WPM:Await("@/Setting/Schema")
local SettingLogic       = env.WPM:New("@/Setting/Logic")




-- Shared
--------------------------------

local isElvUILoaded = false




-- Tab
--------------------------------

local selectedTabIndex = nil
local categoryId = nil


local function getSelectedTabFrame()
    if not selectedTabIndex then return end
    return SettingConstructor.Tabs[selectedTabIndex]
end

function SettingLogic:OpenTabByIndex(index)
    selectedTabIndex = index

    for i = 1, #SettingConstructor.Tabs do
        local tab = SettingConstructor.Tabs[i]
        local tabButton = SettingConstructor.TabButtons[i]
        local isSelected = i == index


        if isSelected and not tab:IsShown() then tab:PlayIntro() end
        tab:SetShown(isSelected)
        tabButton:SetSelected(isSelected)


        -- Dynamic rendering, only render elements when tab is selected
        if isSelected and not tab.hasRendered then
            tab:_Render()
            tab.hasRendered = true
        end


        -- Refresh widgets
        SettingConstructor:Refresh(true)
    end
end


-- Setup
--------------------------------

WUISettingFrameAnchor = CreateFrame("Frame", "WUISettingFrameAnchor", UIParent)
local INSET = 8
local isSetup = false



function SettingLogic.OpenSettingUI()
    if not categoryId then return end
    Settings.OpenToCategory(categoryId)
end



local function setupSettingUI()
    SettingConstructor:SetBuildTargetFrame(WUISettingFrame.Content.Container)
    SettingConstructor:Build(SettingSchema.SCHEMA)

    WUISettingFrame:SetParent(WUISettingFrameAnchor)
    WUISettingFrame:SetPoint("CENTER", WUISettingFrameAnchor)
    WUISettingFrame:SetSize(WUISettingFrameAnchor:GetSize())
    WUISettingFrame:_Render()

    SettingLogic:OpenTabByIndex(1)
end





local function OnShow(self)
    if not isElvUILoaded then isElvUILoaded = IsAddonLoaded("ElvUI") end
    


    WUISettingFrameAnchor:ClearAllPoints()
    
    if isElvUILoaded then
        WUISettingFrameAnchor:SetAllPoints(SettingsCanvas)
    else
        WUISettingFrameAnchor:SetPoint("CENTER", SettingsCanvas, -INSET, INSET)
        WUISettingFrameAnchor:SetSize(math.ceil(SettingsCanvas:GetWidth() + INSET * 2), math.ceil(SettingsCanvas:GetHeight() + INSET / 2))
    end

    WUISettingFrame:Show()


    
    if not isSetup then
        setupSettingUI()
        isSetup = true
    end
end

local function OnHide(self)
    WUISettingFrame:Hide()
end

local function RenderUI()
    if WUISettingFrame:IsShown() and isSetup then
        WUISettingFrame:_Render()

        for i = 1, #SettingConstructor.Tabs do
            SettingConstructor.Tabs[i].hasRendered = false
        end

        local currentTab = getSelectedTabFrame()
        if currentTab then
            currentTab.hasRendered = true
            currentTab:_Render()
        end
    end
end




WUISettingFrameAnchor:HookScript("OnShow", OnShow)
WUISettingFrameAnchor:HookScript("OnHide", OnHide)
WUISettingFrameAnchor:SetScript("OnEvent", RenderUI)
CallbackRegistry:Add("WoWClient.OnUIScaleChanged", RenderUI)
SavedVariables.OnChange("WaypointDB_Global", "PrefFont", RenderUI, 10)





local function OnAddonLoaded()
    -- Hide frame
    WUISettingFrameAnchor:Hide()
    WUISettingFrame:Hide()

    -- Add to Blizzard in-game add-on setting page
    local category = Settings.RegisterCanvasLayoutCategory(WUISettingFrameAnchor, env.NAME)
    Settings.RegisterAddOnCategory(category)

    categoryId = category:GetID()
end
CallbackRegistry:Add("Preload.AddonReady", OnAddonLoaded)
