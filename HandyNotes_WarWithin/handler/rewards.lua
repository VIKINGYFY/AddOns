local myname, ns = ...

local COSMETIC_COLOR = CreateColor(1, 0.5, 1)
local ATLAS_CHECK, ATLAS_CROSS = "common-icon-checkmark", "common-icon-redx"

local formatif = function(value, format, fallback)
    if not value then return fallback or "" end
    return string.format(format, value)
end

ns.rewards = {}
-- _G.REWARDS = ns.rewards

-- Base reward specification, which should never really be used:
ns.rewards.Reward = ns.Class{
    __classname = "Reward",
    note = false,
    requires = false,
    -- todo: consolidate these somehow?
    quest = false,
    questComplete = false,
    warband = false,
    Initialize = function(self, id, extra)
        self.id = id
        if extra then
            for k, v in pairs(extra) do
                if self[k] == false then
                    self[k] = v
                end
            end
        end
    end,
    Name = function(self, color) return UNKNOWN end,
    Icon = function(self) return 134400 end, -- question mark
    Obtained = function(self, for_tooltip)
        local result
        if self.quest then
            if C_QuestLog.IsQuestFlaggedCompleted(self.quest) or C_QuestLog.IsOnQuest(self.quest) then
                return true
            end
            if self.warband and C_QuestLog.IsQuestFlaggedCompletedOnAccount(self.quest) then
                return true
            end
            if for_tooltip or ns.db.quest_notable then
                result = false
            end
        end
        if self.questComplete then
            if C_QuestLog.IsQuestFlaggedCompleted(self.questComplete) then
                return true
            end
            if for_tooltip or ns.db.quest_notable then
                result = false
            end
        end
        return result
    end,
    Notable = function(self)
        -- Is it knowable and not obtained?
        return self:MightDrop() and (self:Obtained() == false)
    end,
    Available = function(self)
        if self.requires and not ns.conditions.check(self.requires) then
            return false
        end
        -- TODO: profession recipes?
        return true
    end,
    MightDrop = function(self) return self:Available() end,
    SetTooltip = function(self, tooltip) return false end,
    AddToTooltip = function(self, tooltip)
        local r, g, b = self:TooltipNameColor()
        local lr, lg, lb = self:TooltipLabelColor()
        tooltip:AddDoubleLine(
            self:TooltipLabel(),
            self:TooltipName(),
            lr, lg, lb,
            r, g, b
        )
    end,
    TooltipName = function(self)
        local name = self:Name(true)
        local icon = self:Icon()
        if not name then
            name = SEARCH_LOADING_TEXT
        end
        if self.requires then
            name = TEXT_MODE_A_STRING_VALUE_TYPE:format(name, ns.conditions.summarize(self.requires, true))
        end
        if self.note then
            name = TEXT_MODE_A_STRING_VALUE_TYPE:format(name, self.note)
        end
        return ("%s%s%s"):format(
            (icon and (ns.quick_texture_markup(icon) .. " ") or ""),
            ns.render_string(name),
            self:ObtainedTag() or ""
        )
    end,
    TooltipNameColor = function(self)
        if not self:Name() then
            return 0, 1, 1
        end
        return NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b
    end,
    TooltipLabel = function(self) return UNKNOWN end,
    TooltipLabelColor = function(self)
        if ns.db.show_npcs_emphasizeNotable and self:Notable() then
            return 1, 0, 1
        end
        return NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b
    end,
    ObtainedTag = function(self)
        local known = self:Obtained(true) -- for_tooltip
        if known == nil then return end
        return " " .. CreateAtlasMarkup(known and ATLAS_CHECK or ATLAS_CROSS)
    end,
    Cache = function(self) end,
}

ns.rewards.Item = ns.Class{
    __classname = "Item",
    __parent = ns.rewards.Reward,
    spell = false,
    Name = function(self, color)
        local name, link = C_Item.GetItemInfo(self.id)
        if link then
            return color and link:gsub("[%[%]]", "") or name
        end
    end,
    TooltipLabel = function(self)
        local _, itemType, itemSubtype, equipLoc, icon, classID, subclassID = C_Item.GetItemInfoInstant(self.id)
        local _, link = C_Item.GetItemInfo(self.id)
        local label = ENCOUNTER_JOURNAL_ITEM
        if classID == Enum.ItemClass.Armor and subclassID ~= Enum.ItemArmorSubclass.Shield then
            label = _G[equipLoc] or label
        else
            label = itemSubtype
        end
        if label and ns.IsCosmeticItem(self.id) then
            label = TEXT_MODE_A_STRING_VALUE_TYPE:format(label, COSMETIC_COLOR:WrapTextInColorCode(ITEM_COSMETIC))
        end
        return label
    end,
    Icon = function(self) return (select(5, C_Item.GetItemInfoInstant(self.id))) end,
    Obtained = function(self, for_tooltip)
        local result = self:super("Obtained", for_tooltip)
        if self.spell then
            -- can't use the tradeskill functions + the recipe-spell because that data's only available after the tradeskill window has been opened...
            local info = C_TooltipInfo.GetItemByID(self.id)
            if info then
                for _, line in ipairs(info.lines) do
                    if line.leftText and string.match(line.leftText, _G.ITEM_SPELL_KNOWN) then
                        return true
                    end
                end
            end
            result = false
        end
        if ns.CLASSIC then return result and GetItemCount(self.id, true) > 0 end
        if (for_tooltip or ns.db.transmog_notable) and ns.CanLearnAppearance(self.id) then
            return ns.HasAppearance(self.id, ns.db.transmog_specific)
        end
        return result
    end,
    -- Notable = function(self)
    --     -- notable if: it might drop, its obtainability is knowable, and it hasn't been obtained
    --     -- (close override of the parent, to add the transmog preference)
    --     return self:super("Notable") or
    --         (self:MightDrop() and self:Obtained() == false)
    -- end,
    MightDrop = function(self)
        -- We think an item might drop if it either has no spec information, or
        -- returns any spec information at all (because the game will only give
        -- specs for the current character)
        -- can't pass in a reusable table for the second argument because it changes the no-data case
        local specTable = C_Item.GetItemSpecInfo(self.id)
        -- Some cosmetic items seem to be flagged as not dropping for any spec. I
        -- could only confirm this for some cosmetic back items but let's play it
        -- safe and say that any cosmetic item can drop regardless of what the
        -- spec info says...
        if specTable and #specTable == 0 and not ns.IsCosmeticItem(self.id) then
            return false
        end
        -- parent catches covenants / classes / etc
        return self:super("MightDrop")
    end,
    SetTooltip = function(self, tooltip)
        tooltip:SetItemByID(self.id)
    end,
    Cache = function(self)
        C_Item.RequestLoadItemDataByID(self.id)
    end,
}
ns.rewards.Toy = ns.Class{
    __classname = "Toy",
    __parent = ns.rewards.Item,
    TooltipLabel = function(self) return TOY end,
    Obtained = function(self, ...)
        if ns.CLASSIC then return GetItemCount(self.id, true) > 0 end
        return self:super("Obtained", ...) ~= false and PlayerHasToy(self.id)
    end,
    Notable = function(self, ...) return ns.db.toy_notable and self:super("Notable", ...) end,
}
ns.rewards.Mount = ns.Class{
    __classname = "Mount",
    __parent = ns.rewards.Item,
    Initialize = function(self, id, mountid, ...)
        self:super("Initialize", id, ...)
        self.mountid = mountid
    end,
    TooltipLabel = function(self) return MOUNT end,
    Obtained = function(self, ...)
        if self:super("Obtained", ...) == false then return false end
        if ns.CLASSIC then return GetItemCount(self.id, true) > 0 end
        if not _G.C_MountJournal then return false end
        if not self.mountid then
            self.mountid = C_MountJournal.GetMountFromItem and C_MountJournal.GetMountFromItem(self.id)
        end
        return self.mountid and (select(11, C_MountJournal.GetMountInfoByID(self.mountid)))
    end,
    Notable = function(self, ...) return ns.db.mount_notable and self:super("Notable", ...) end,
}
ns.rewards.Pet = ns.Class{
    __classname = "Pet",
    __parent = ns.rewards.Item,
    Initialize = function(self, id, petid, ...)
        self:super("Initialize", id, ...)
        self.petid = petid
    end,
    TooltipLabel = function(self) return TOOLTIP_BATTLE_PET end,
    Obtained = function(self, ...)
        if self:super("Obtained", ...) == false then return false end
        if ns.CLASSIC then return GetItemCount(self.id, true) > 0 end
        if not self.petid then
            self.petid = select(13, C_PetJournal.GetPetInfoByItemID(self.id))
        end
        return self.petid and C_PetJournal.GetNumCollectedInfo(self.petid) > 0
    end,
    Notable = function(self, ...) return ns.db.pet_notable and self:super("Notable", ...) end,
}
ns.rewards.Set = ns.Class{
    __classname = "Set",
    __parent = ns.rewards.Item,
    Initialize = function(self, id, setid, ...)
        self:super("Initialize", id, ...)
        self.setid = setid
    end,
    Name = function(self)
        local info = C_TransmogSets.GetSetInfo(self.setid)
        if info then
            return info.name
        end
        return self:Super("Name")
    end,
    TooltipLabel = function(self) return WARDROBE_SETS end,
    Obtained = function(self, ...)
        if not self:super("Obtained", ...) then return false end
        if ns.CLASSIC then return GetItemCount(self.id, true) > 0 end
        local info = C_TransmogSets.GetSetInfo(self.setid)
        if info then
            if info.collected then return true end
            -- we want to fall through and return nil for sets the current class can't learn:
            if info.classMask and bit.band(info.classMask, ns.playerClassMask) == ns.playerClassMask then return false end
        end
    end,
    ObtainedTag = function(self)
        local info = C_TransmogSets.GetSetInfo(self.setid)
        if not info then return end
        if not info.collected then
            local sources = C_TransmogSets.GetSetPrimaryAppearances(self.setid)
            if sources and #sources > 0 then
                local numKnown = 0
                for _, source in pairs(sources) do
                    if source.collected then
                        numKnown = numKnown + 1
                    end
                end
                return RED_FONT_COLOR:WrapTextInColorCode(GENERIC_FRACTION_STRING:format(numKnown, #sources))
            end
        end
        return self:super("ObtainedTag")
    end,
}

ns.rewards.Currency = ns.Class{
    __classname = "Currency",
    __parent = ns.rewards.Reward,
    Initialize = function(self, id, amount, ...)
        self:super("Initialize", id, ...)
        self.amount = amount
        self.faction = C_CurrencyInfo.GetFactionGrantedByCurrency(id)
        -- This effect is a little specialized around the rep drops from rares
        -- in War Within; will need to revisit it if there's future warband
        -- currency rewards that are character-gated not account-gated...
        self.warband = self.faction and C_Reputation.IsAccountWideReputation(self.faction)
    end,
    Name = function(self, color)
        local info = C_CurrencyInfo.GetBasicCurrencyInfo(self.id, self.amount)
        if info and info.name then
            local name = color and ITEM_QUALITY_COLORS[info.quality].color:WrapTextInColorCode(info.name) or info.name
            return (self.amount and self.amount > 1) and
                ("%s x %d"):format(name, self.amount) or
                name
        end
        return self:Super("Name", color)
    end,
    Icon = function(self)
        local info = C_CurrencyInfo.GetBasicCurrencyInfo(self.id)
        if info and info.icon then
            return info.icon
        end
    end,
    TooltipLabel = function(self)
        return self.faction and REPUTATION or CURRENCY
    end,
}
