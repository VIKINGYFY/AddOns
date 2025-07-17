# CompactVendor

## [v11.1.7.250717](https://github.com/Vladinator/wow-addon-compactvendor/tree/v11.1.7.250717) (2025-07-17)
[Full Changelog](https://github.com/Vladinator/wow-addon-compactvendor/commits/v11.1.7.250717) [Previous Releases](https://github.com/Vladinator/wow-addon-compactvendor/releases)

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
- Fixed colorblind mode detection, in addition to the legacy or deprecated global, I also check the cvar itself just like the latest UI code does it when handling rendering money strings.  
- Fixed issue on Classic SOD when talking to Pix Xizzix (and other vendors with Relics).  
- Add support for CanIMogIt so when it's available we use it to detect the status of appearance collection.  
- TOC bump  
- Track the event for merchant show/closed by setting the `merchantOpen` boolean accordingly.  
    Reply on this new boolean in `UpdateMerchantInfo` so that if we're not on a merchant we ensure to cleanup and answer properly, we can't be on a merchant if the event said we closed the interface.  
    Added BuyEmAll support, if the addon is loaded, it will be used for stack purchase instead of the built-in standard frame.  
    The new Open/Close/IsOpen methods on the quantity button widget will use the API for BuyEmAll when available, otherwise fallback to default behavior.  
- The wow token price check should only happen on mainline, as classic era and other flavors might not be properly handling the token pricing, as it can cause lua errors on those clients.  
- Updated GetItemCount to properly include reagent bank and the warbank when checking if you can afford something.  
- TOC bump.  
- Use Yes/No instead of the collected texts.  
- Adjusted item appearance collection status logic. Will display `Appearance` with Yes/No, and `Appearance: Collected` if we have collected the appearance or not, given that the first filter is properly set to show collectable items.  
- TOC bump  
- Fixed minor issue with `Learnable: Collected` detection and classification.  
- TOC bump.  
- Minor layout adjustments for 11.  
- Minor 11 changes.  
- TOC bump  
- The "Learnable: Collected" filter was changed to be more than just Yes/No, it will now also support "Some" for cosmetic bundles that contain many items.  
    This way you can differentiate between "Yes" (fully collected), "Some" (partially collected) and "No".  
    The gray color indicates that you have all the unique slots collected, so this filter helps further differentiate between Yes and Some.  
- Adjusted collection bundle filter and "collected" detection.  
    TOC bump.  
- TOC bump  
- Added support for checking learnable collection bundles.  
    These kind of items are considered "learnable" and collectable, like battle pets, toys, etc. Collections contain a set of multiple items, and if all are collected, the collection is considered complete and the item grayed out as "Already known" to make it easier to filter and see in the list.  
    The "Learnable" and "Learnable: Collected" filters will consider these kind of bundles.  
- TOC bump  
- Lightweight search system until the external library gets updated. Sorry for the inconvenience.  
- Merge pull request #20 from bloerwald/2024-02-update\_libs  
    Update libraries to newest available version.  
- libs: ItemSearch-1.3: update to 881f914  
- libs: C\_Everywhere: update to 907e535  
- libs: CustomSearch-1.0: update to 98167ba  
- libs: update Unfit-1.0 to d7531db  
- Update release.yml  
- Slug changed and broke workflow.  
- - Fixed a stats filter bug with a deprecated (soon to be) API.  
    - TOC bump.  
- Added crafting quality stars to items where its relevant.  
    TooltipUtil.SurfaceArgs will be removed in 11.0 so preparing for that ever so slowly.  
    Free items are properly assigned the appropriate CostType.  
- Patch 11.0 preparations.  
- Fixed a minor bug with undefined API usage.  
    TOC bump and re-release.  
- Using the "retrieving item info" text when the item data is pending.  
- Even with no tooltip scanning we can still show the data, even in Classic. Need to implement scanning for proper filtering support.  
- Added TOC files for the other clients.  
- Added classic era fixes. Tooltip scanning is currently not functional.  
