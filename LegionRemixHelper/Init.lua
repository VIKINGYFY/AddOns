---@class AddonPrivate
local Private = select(2, ...)
local const = Private.constants

local defaultDatabase = {
    scrapping = {
        maxQuality = Enum.ItemQuality.Rare,
        minLevelDiff = 0,
        autoScrap = false,
    },
    collectionsTab = {
        selected = 1,
    },
    artifactTraits = {
        autoActive = {},
        autoBuy = false,
    },
    quickActionBar = {
        actions = nil,
    },
    quest = {
        autoAccept = false,
        autoTurnIn = false,
        suppressShift = false,
        ignoreEternus = true,
    },
    toast = {
        activate = false,
        bronze = false,
        artifact = false,
        upgrade = false,
        trait = false,
        sound = false,
    },
    tooltip = {
        activate = false,
        threads = false,
        power = false,
    },
    itemOpener = {
        autoItemOpen = false,
    },
    merchant = {
        hideCollectedItems = false,
    },
    editMode = {
        ToastUI = {
            point = "TOP",
            relativePoint = "TOP",
            relativeTo = "UIParent",
            xOfs = 0,
            yOfs = -50,
        }
    },
    version = nil
}

---@class LegionRH : RasuAddonBase
local addon = LibStub("RasuAddon"):CreateAddon(
    const.ADDON_NAME,
    "LegionRemixHelperDB",
    defaultDatabase
)

Private.Addon = addon

local localeObj = LibStub("RasuLocale"):CreateLocale(const.ADDON_NAME)
localeObj:AddFullTranslationTbl(Private.Locales)
localeObj:SetLocale(GetLocale())

Private.L = localeObj:GetTranslationObj()