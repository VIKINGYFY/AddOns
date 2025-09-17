# CompactVendor

## [v11.2.0.250916](https://github.com/Vladinator/wow-addon-compactvendor/tree/v11.2.0.250916) (2025-09-16)
[Full Changelog](https://github.com/Vladinator/wow-addon-compactvendor/commits/v11.2.0.250916) [Previous Releases](https://github.com/Vladinator/wow-addon-compactvendor/releases)

- Updated `GetSanitizedHyperlinkForQuery` to support any link offered from merchants, not just items.  
    This should properly fix the issue with merchants selling currency "items" as mentioned in #34 and #35.  
    TOC bump for update.  
- TOC bump.  
- Separated `ns.Search.Matches` into additional functions, per item type. If the link isn't supported, it will be silently ignored.  
- Version bump.  
- Merge pull request #36 from Korbrawr/master  
    Prevent calling heirloom/toy API for entries that aren't items  
- Prevent calling heirloom/toy API for entries that aren't items  
- TOC bump  
- Updated non-refundable warning code for static popup to work with patch 11.2  
- Vendoring an item (causing an update) won't reset the filters back to their default state with yesterdays change.  
    Running a new release with that minor adjustment and testing since yesterday.  
- Do not reset the filters when the merchant updates.  
    This would cause some odd behavior when we sold/bought items.  
    The downside is that when you change filter category using the Blizzard filters. It will remember your filter options in the addon, but that might also be desired sometimes.  
- Temporarily disabled tooltip scanning in classic clients due to missing infrastructure, and my implementation wasn't robust enough. (This won't be noticeable, only affects tooltip scanning functionality.)  
- Version bump.  
- Improved search logic and accuracy.  
    Updated the search help text to match supported syntax.  
- Implemented merchant tooltip scanning, but the issue is additional async delays with the special requirement text. Not to mention the localization issue, most those texts have no globalstrings to use to pattern match.  
    The hyperlink scan approach is still the active one, though the code supports to swap the logic to the merchant style when we get it to a usable state.  
    Small improvements to the requirements filter and the renown presentation (from my tests, but there are probably many other kind of requirements).  
- Version bump  
- The stat filter can miss some stat names due the global space not containing the localization as expected.  
    Created a simple mapping table to redirect the key findings to an existing localized stat name.  
    This needs to be checked on classic era and mist clients, but for mainline it works well.  
    The `ReMapStatTable` func was implemented to override duplicate entries that appeared for some reason, into one filter value to avoid duplication.  
    This was specific to the resistances, so I used the `statTextMap` to find the keys and map them to the values like with the translations.  
    This fixed the filter and deduped the dropdown options.  
- The merchant index also has a `hasIndex` boolean for easy checking.  
    Most places where the index was used, also now check if it's valid. This only applies to situations where the merchant is still loading data.  
    The rows that display this rare loading state won't appear like items, it will hide all other behavior, and simply show "Loading..." until the data is available for it to display itself.  
- Version bump  
- Tooltip scanning will store callbacks and re-use existing ongoing requests, instead of making new duplicates. This way we simply respond to all callbacks interested in the same item hyperlink when it's ready.  
- Split up the `tooltipData` into additional props to track state and data and the unique scanner ID (for response tracking).  
    Moved the response handling and callbacks to their own methods `RefreshTooltipData` and `OnTooltipScanResponse` which are called when appropriate.  
    This simplified the code in the `Refresh` routine to simply use the `tooltipData` when available, otherwise start a scan task and assign the relevant fields and provide the callbacks needed to update the correct item once the response returns.  
    The `TooltipScanner` is now specifically containing the relevant methods we need for its purpose.  
- TOC bump.  
- The merchant item has awareness on which button is using it.  
    Moved the cleanup of button code in a view factory resetter handler.  
    The tooltip scan will ensure the results still match the expected merchant item ID, and abort if not. (This could happen if a response is delayed and the frame reused for another item in the meantime.)  
    When the view assigns a button it also assigns that buttons merchant item object, and the parentButton on said object. (And during resetting this is cleaned up.)  
    The update merchant routine will, when possible, call the `UpdateMerchantItemButton` method as data is refreshed so the visuals match the backend state.  
    Previously this only occured when the button is displayed, or when specific events related to bags occured. This would sometimes lead to state missmatch, but hopefully not anymore.  
- Tooltip scanning can be delayed, and when it is, we need to call the `UpdateMerchantItemByID` method. We only wish to do that when there is a delay, meaning there was no tail-call that instantly resolved `tooltipData`.  
- Multiple requirements on the same item should yield results if one of them is checked.  
    This way the list fills up with appropriate checked results, even if just partial.  
- Removed the old tooltip scanning code, and replaced it with the new one.  
    Added polyfill for the pre 10 clients by implementing a local `C_TooltipInfo` for our purpose.  
    Can consider implementing the `ScanMerchantItem` equivalent, considering some tooltips contain requirements specific to that way of rendering tooltips.  
- Fixed minor filter refreshing behavior issues. Setting filters and changing the merchant filters, should properly reset them as intended.  
    Added new tooltip scanning code and trying it out by overloading the `TooltipScanner.ScanHyperlink` method.  
    The new method will simply replace the old loading system, the new one should be better. After enough testing, I will remove the old code that is no longer needed if this is the case in practice.  
    Setting `MerchantItem:IsRequirementScannable()` to `true` while doing these tests, so as many tooltips get scanned so I can inspect stability and accuracy.  
- - TOC bump  
    - Fixed the item stats filter  
- If it wasn't for the tooltip scanning delay the requirements filter dropdown itself functions as expected.  
    But there is some wonky behavior when swapping the filter between "All" and "All Specializations" which cause some wonky loading behavior, the provider doesn't always fully return all items, some pending once might get locked waiting, etc.  
    This appears to be caused due to tooltip scanning of too many things at once adds more delay and potential failure, so need to re-think the tooltip scanning code and making it more robust to avoid this from happening.  
    Need to revisit the events called from the bottom up, so we properly subscribe to callbacks relevant to each step, so that the filter button on top properly refreshes when it has to.  
    After some cleaning up it is better, but not good enough to simply enable the full tooltip scanning behavior on all items, so keeping it on recipes and pets for now.  
- Renamed the old `CanLean` method to a universal `HasRequirements` method which will scan and extract the various requirements, the old method did the same logic just worse and used an older naming convention which is now corrected.  
    Requirements are scanned from the bottom up, and will stop scanning as soon a non-requirement is encountered after any requirements that were found.  
    This is to avoid embed issues, where the tooltip contained data from an embeded item, but we couldn't know where it ends and the regular tooltip continues.  
    Updated the stats filter and the requirements filter, it had to be adjusted to consider the checked options/values, so only those were taken into account when deciding if to show or hide the item in question.  
    There are still some oddities with the requirements, will need to do more testing.  
- Marked all items as scannable, since we don't know in advance if an item has or doesn't have any requirement lines in its tooltip.  
    This flags all items for tooltip scanning, thus allowing the `CanLearn` method to extract all sort of requirements, not only for recipes, pets, cosmetics, etc.  
    Need to profile performance on large vendors, like renown quartermasters and other quartermasters with a lot of items.  
- Fixed a bit of docs and a bit of filter code. Added a TODO on the requirements filter, right now it won't work to toggle the filters, they are properly detected, but we need to change the filter dropdown to reflect the contents of the actual requirements.  
- Created `MerchantItem:CanAfford()` and using it where suitable instead of the prop directly.  
    Created `MerchantItem:GetLearnRequirements(predicate?)` and `MerchantItem:GetLearnRequirementsForRedProfessions()` methods and using these instead of a loop and logic in the `UpdateMerchantItemButton` function.  
    This way it's a bit more clear what the purpose is, and reusable if I need similar checks elsewhere.  
- No need to try to purchase something we can't afford. This avoids the confirmation popup for items we can't buy either way.  
- Fixed tooltip scanning issues around profession scanning of requirements.  
    An item can have multiple requirements, and we mostly care about the profession one for coloring, and the dropdown filters care for all of them combined.  
    There is more work to be done to confirm the other kind of requirements: level, rating, achievement, guild, reputation, specialization, renown, and check for other kinds that we should add to the filter and scanning code.  
- The merchant filter event is too costly, so we do like the default UI does it, just queue a full update to occur later once the events settle.  
    This primarily affects merchants with a lot of items, like renown quartermasters, timewalking vendor, etc. And it only occurs the first time the merchant frame is opened, as the client caches the data until you properly logout and back in again.  
- TOC bump  
- Merchant filter needs to track the updatesd on a per-item basis and not just as "the last one gets updated" like it previously was.  
    This wasn't really noticeable as long a full update was performed, which often happens once filter events settle, but still it could lead to some oddities.  
    Added a loading spinner when the frame shows until it is done loading data. Would only affect the frame when initially shown as the server needs a bit of time to send data to the client.  
    Added status text when the vendor has no items to sell, or is filtered by the filter system, so the user knows it's empty and not that it's waiting to load data (though the spinner now helps cover the loading aspect).  
- TOC updates  
- Minor doc updates.  
    Updated the stat filter to accumulate multiple checks so that all items matching all the checked boxes appear in the list.  
- Version bump.  
- Placed the refresh and update merchant button behavior into `RefreshAndUpdateMerchantItemButton` for convenience.  
    We call this when the merchant item button is being shown, or when an even fires, to ensure an up-to-date visual state.  
- Merchant buttons listen for currency or bag item updates to refresh and update themselves.  
    The refresh merchant item code might not be ideal there, so need to think about where to place it. The button update event on the other hand is fine as it related to the button visuals.  
    Created a safer FrameUtil in case some event isn't available in the other client flavor. Might want to do specific research and cover those cases manually so everything keeps working as intended.  
- Version bump.  
- Cleaned up `CreateMerchantItemButton` since it always receives the widget button reference, didn't need the old code, except the update call.  
    The merchant item refresh method had the quality and qualityColor assignment updated to always reflect the itemLink quality and to update both at the same time, to avoid odd de-sync behaviors that could previously occur.  
- TOC bump  
- Updated logic when merchant frame shows and loads items.  
    The end result should be a smoother and more stable experience when opening a merchant that has items that the game has to load for the first time.  
    Once ready the filters will also update themselves to ensure nothing is being incorrectly filtered.  
- TOC bump  
- Added support for the new color in hyperlinks.  
- TOC bump.  
- Transmog API are unstable on Classic so added an override to avoid that situation as a fix for the addon.  
- Changes to GetMerchantItemInfo had to have a method implemented to migrate between the old style and the new table return value.  
    Some minor docs changes.  
