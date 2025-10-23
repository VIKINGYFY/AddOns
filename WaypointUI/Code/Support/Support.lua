local env           = select(2, ...)

local IsAddOnLoaded = C_AddOns.IsAddOnLoaded
local ipairs        = ipairs
local tinsert       = table.insert

local Support       = env.WPM:New("@/Support")
local list          = {}



function Support:Add(addonName, loadFunc)
    tinsert(list, {
        name     = addonName,
        loadFunc = loadFunc
    })
end



local EL = CreateFrame("Frame")
EL:RegisterEvent("PLAYER_ENTERING_WORLD")
EL:SetScript("OnEvent", function()
    EL:UnregisterAllEvents()
    EL:SetScript("OnEvent", nil)

    for _, addon in ipairs(list) do
        if IsAddOnLoaded(addon.name) then
            addon.loadFunc()
        end
    end
end)
