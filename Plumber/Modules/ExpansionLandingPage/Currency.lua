local _, addon = ...
local API = addon.API;
local L = addon.L;
local CallbackRegistry = addon.CallbackRegistry;
local LandingPageUtil = addon.LandingPageUtil;


local ipairs = ipairs;
local pairs = pairs;
local GetCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo;
local GetItemIconByID = C_Item.GetItemIconByID;
local GetItemCount = C_Item.GetItemCount;
local GetItemNameByID = C_Item.GetItemNameByID;
local BreakUpLargeNumbers = BreakUpLargeNumbers;


local BUTTON_WIDTH, BUTTON_HEIGHT = 240, 24;


local DefaultResources = {
    {itemID = 244465, shownInDelves = true},

    {currencyID = 3028},    --Restored Coffer Key
    {itemID = 236096, isMinor = false},   --Coffer Key Shard
    {itemID = 235897},      --Radiant Echo

    {currencyID = 1602, shownIfOwned = true},    --Conquest
    {currencyID = 1792, shownIfOwned = true},    --Honor

    {currencyID = 3149, shownIfOwned = true},    --Displaced Corrupted Mementos
    {currencyID = 2815},    --Resonance Crystals
    {currencyID = 3218},    --Empty Kaja'Cola Can
    {currencyID = 3226, shownIfOwned = true},    --Market Research
    {currencyID = 3090, shownIfOwned = true},    --Flame-Blessed Iron
    {currencyID = 3056},    --Kej
    --{currencyID = 3055},      --Mereldar Derby Mark
    {currencyID = 2803},    --Undercoin

    ---{isHeader = true, name = PVP},
    {currencyID = 2123, shownIfOwned = true},    --Bloody Tokens
    {currencyID = 2797, shownIfOwned = true},    --Trophy of Strife
};

local function GetResourcesQuantity(data)
    if data.currencyID then
        local info = GetCurrencyInfo(data.currencyID);
        return info and info.quantity or 0
    elseif data.itemID then
        return GetItemCount(data.itemID, true, false, true, true);
    end

    return 0
end

local CurrencyButtonMixin = {};
do
    function CurrencyButtonMixin:SetCurrency(currencyID, isMinor)
        self.currencyID = currencyID;
        self.itemID = nil;
        self.buttonDitry = true;
        self:Refresh();
        self:SetShownAsMinor(isMinor);
    end

    function CurrencyButtonMixin:SetItem(itemID, isMinor)
        self.currencyID = nil;
        self.itemID = itemID;
        self.buttonDitry = true;
        self:Refresh();
        self:SetShownAsMinor(isMinor);
    end

    function CurrencyButtonMixin:Refresh()
        local quantity;
        local isOverflow;

        if self.currencyID then
            local info = GetCurrencyInfo(self.currencyID);
            if info then
                quantity = info.quantity;
                local totalEarned = info.totalEarned or 0;
                local maxQuantity = info.maxQuantity or 0;
                isOverflow = quantity > 0 and maxQuantity > 0 and (((maxQuantity - totalEarned) == 0) or (quantity >= maxQuantity))
                if self.buttonDitry then
                    self.buttonDitry = nil;
                    self.Name:SetText(info.name);
                    self.Icon:SetTexture(info.iconFileID);
                end
            else
                return false
            end
        elseif self.itemID then
            quantity = GetItemCount(self.itemID, true, false, true, true);
            if self.buttonDitry then
                self.buttonDitry = nil;
                self.Icon:SetTexture(GetItemIconByID(self.itemID));
                local itemName = GetItemNameByID(self.itemID);
                if itemName then
                    self.Name:SetText(itemName);
                else
                    CallbackRegistry:LoadItem(self.itemID, function(itemID)
                        if self.itemID == itemID then
                            self.Name:SetText(GetItemNameByID(self.itemID));
                            self.Icon:SetTexture(GetItemIconByID(self.itemID));
                        end
                    end);
                end
            end
        else
            return false
        end

        if quantity then
            if quantity > 0 then
                self.anyOwned = true;
                self.Name:SetTextColor(0.922, 0.871, 0.761);
                self.Count:SetText(BreakUpLargeNumbers(quantity));
                if isOverflow then
                    self.Count:SetTextColor(0.098, 1.000, 0.098);
                else
                    self.Count:SetTextColor(0.88, 0.88, 0.88);
                end
            else
                self.anyOwned = false;
                self.Name:SetTextColor(0.5, 0.5, 0.5);
                self.Count:SetTextColor(0.5, 0.5, 0.5);
                self.Count:SetText(0);
            end
            return true
        else
            self.anyOwned = false;
            return false
        end
    end

    function CurrencyButtonMixin:SetShownAsMinor(isMinor)
        self.Name:SetPoint("LEFT", self, "LEFT", (isMinor and 22) or 8, 0);
    end

    function CurrencyButtonMixin:OnEnter()
        self:UpdateVisual();
        local tooltip = GameTooltip;
        tooltip:SetOwner(self.Icon, "ANCHOR_RIGHT", 0, 0);
        if self.currencyID then
            tooltip:SetCurrencyByID(self.currencyID);
        elseif self.itemID then
            tooltip:SetItemByID(self.itemID);
        end
    end

    function CurrencyButtonMixin:OnLeave()
        self:UpdateVisual();
        GameTooltip:Hide();
    end

    function CurrencyButtonMixin:OnClick()
        API.ToggleBlizzardTokenUIIfWarbandCurrency(self.currencyID);
    end

    function CurrencyButtonMixin:UpdateVisual()
        if self:IsMouseMotionFocus() then
            self.Name:SetTextColor(1, 1, 1);
        else
            if self.anyOwned then
                self.Name:SetTextColor(0.922, 0.871, 0.761);
            else
                self.Name:SetTextColor(0.5, 0.5, 0.5);
            end
        end
    end
end

local function CreateButton(parent)
    local f = CreateFrame("Button", nil, parent);
    f:SetSize(BUTTON_WIDTH, BUTTON_HEIGHT);
    API.Mixin(f, CurrencyButtonMixin);

    f.Icon = f:CreateTexture(nil, "OVERLAY");
    f.Icon:SetSize(20, 20);
    f.Icon:SetPoint("RIGHT", f, "RIGHT", -8, 0);

    f.Count = f:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    f.Count:SetPoint("RIGHT", f, "RIGHT", -32, 0);
    f.Count:SetJustifyH("RIGHT");
    f.Count:SetTextColor(1, 1, 1);
    f.Count:SetText("0");

    f.Name = f:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    f.Name:SetPoint("LEFT", f, "LEFT", 8, 0);
    f.Name:SetPoint("RIGHT", f.Count, "LEFT", -20, 0);
    f.Name:SetJustifyH("LEFT");
    f.Name:SetTextColor(1, 1, 1);
    f.Name:SetText("0/0");
    f.Name:SetMaxLines(1);

    f.Background = f:CreateTexture(nil, "BACKGROUND");
    f.Background:SetAllPoints(true);

    f:SetScript("OnEnter", f.OnEnter);
    f:SetScript("OnLeave", f.OnLeave);
    f:SetScript("OnClick", f.OnClick);

    return f
end


local CurrencyListMixin = {};
do
    function CurrencyListMixin:Refresh()
        --Called once when frame is created
        self:OnSizeChanged();
        self:FullUpdate();
    end

    function CurrencyListMixin:OnShow()
        self:FullUpdate();
    end

    function CurrencyListMixin:OnHide()
        self:UnregisterEvent("CURRENCY_DISPLAY_UPDATE");
        self:UnregisterEvent("BAG_UPDATE_DELAYED");
        self.anyCurrency = nil;
        self.anyItem = nil;
    end

    function CurrencyListMixin:OnEvent(event, ...)
        if event == "CURRENCY_DISPLAY_UPDATE" then
            if not self.anyCurrency then return end;
            local currencyID = ...

            if self.currencyXButton[currencyID] then
                self.currencyXButton[currencyID]:Refresh();
                return
            end

            local processFunc = function(obj)
                if obj.currencyID == currencyID then
                    obj:Refresh();
                    return true
                end
            end
            self.ScrollView:ProcessActiveObjects("CurrencyButton", processFunc);
        elseif event == "BAG_UPDATE_DELAYED" then
            if not self.anyItem then return end;
            local processFunc = function(obj)
                if obj.itemID then
                    obj:Refresh();
                end
            end
            self.ScrollView:ProcessActiveObjects("CurrencyButton", processFunc);
        end
    end

    function CurrencyListMixin:FullUpdate()
        self.anyCurrency = nil;
        self.anyItem = nil;

        local n = 0;
        local content = {};
        local offsetY = 0;
        local offsetX = -0.5 * BUTTON_WIDTH;
        local gap = 0;
        local top, bottom;
        local objectHeight;
        local valid;

        for _, v in ipairs(DefaultResources) do
            valid = true;
            if v.shownInDelves then
                valid = API.IsInDelves();
            elseif v.shownIfOwned then
                valid = GetResourcesQuantity(v) > 0;
            end

            if valid then
                n = n + 1;
                top = offsetY;
                if v.isHeader then
                    objectHeight = 16;
                    bottom = offsetY + objectHeight + gap;
                    content[n] = {
                        templateKey = "HeaderTitle",
                        setupFunc = function(obj)
                            obj:SetText(v.name);
                        end,
                        top = top,
                        bottom = bottom,
                        point = "TOPLEFT",
                        offsetX = offsetX,
                    };
                else
                    objectHeight = BUTTON_HEIGHT;
                    bottom = offsetY + objectHeight + gap;
                    content[n] = {
                        templateKey = "CurrencyButton",
                        top = top,
                        bottom = bottom,
                        point = "TOPLEFT",
                        offsetX = offsetX,
                    };
                    if v.currencyID then
                        self.anyCurrency = true;
                        content[n].setupFunc = function(obj)
                            obj:SetCurrency(v.currencyID, v.isMinor);
                        end;
                    elseif v.itemID then
                        self.anyItem = true;
                        content[n].setupFunc = function(obj)
                            obj:SetItem(v.itemID, v.isMinor);
                        end;
                    end
                end
                offsetY = bottom;
            end
        end

        local retainPosition = true;
        self.ScrollView:Show();
        self.ScrollView:SetContent(content, retainPosition);


        self.currencyXButton = {};
        local itemUpgradeButtons = LandingPageUtil.GetItemUpgradeButtons();
        if itemUpgradeButtons then
            self.anyCurrency = true;
            for _, button in ipairs(itemUpgradeButtons) do
                self.currencyXButton[button.currencyID] = button;
                button:Refresh();
            end
        end

        if self.anyCurrency then
            self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
        else
            self:UnregisterEvent("CURRENCY_DISPLAY_UPDATE");
        end

        if self.anyItem then
            self:RegisterEvent("BAG_UPDATE_DELAYED");
        else
            self:UnregisterEvent("BAG_UPDATE_DELAYED");
        end
    end

    function CurrencyListMixin:UpdateScrollViewContent()
        if self.ScrollView then
            self.ScrollView:CallObjectMethod("CurrencyButton", "Refresh");
        end
    end

    function CurrencyListMixin:OnSizeChanged()
        if self.ScrollView then
            self.ScrollView:OnSizeChanged();
        end
    end
end


function LandingPageUtil.CreateCurrencyList(parent)
    local f = CreateFrame("Frame", nil, parent);
    API.Mixin(f, CurrencyListMixin);

    local height = 7 * BUTTON_HEIGHT;
    f:SetSize(BUTTON_WIDTH, height);


    local ScrollView = LandingPageUtil.CreateScrollViewForTab(f);
    f.ScrollView = ScrollView;
    ScrollView:Hide();
    ScrollView:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0);
    ScrollView:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 0);
    ScrollView:OnSizeChanged();
    ScrollView:SetAlwaysShowScrollBar(false);
    ScrollView:SetSmartClipsChildren(true);
    ScrollView:SetStepSize(2.5 * BUTTON_HEIGHT);
    ScrollView:SetBottomOvershoot(BUTTON_HEIGHT);
    ScrollView:ResetScrollBarPosition();
    ScrollView:UseBoundaryGradient(true);
    ScrollView:SetBoundaryGradientSize(BUTTON_HEIGHT);

    local function CurrencyButton_Create()
        return CreateButton(ScrollView)
    end

    local function CurrencyButton_OnAcquired(button)
        if ScrollView:IsScrollable() then
            button:SetWidth(BUTTON_WIDTH - 20);
        else
            button:SetWidth(BUTTON_WIDTH);
        end
    end

    local function CurrencyButton_OnRemoved(button)
        button.currencyID = nil;
        button.itemID = nil;
    end

    ScrollView:AddTemplate("CurrencyButton", CurrencyButton_Create, CurrencyButton_OnAcquired, CurrencyButton_OnRemoved);


    local function HeaderTitle_Create()
        local fs = ScrollView:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        fs:SetSize(208, 16);
        fs:SetTextColor(0.8, 0.8, 0.8);
        return fs
    end

    ScrollView:AddTemplate("HeaderTitle", HeaderTitle_Create);

    f:SetScript("OnShow", f.OnShow);
    f:SetScript("OnHide", f.OnHide);
    f:SetScript("OnEvent", f.OnEvent);

    return f, height
end