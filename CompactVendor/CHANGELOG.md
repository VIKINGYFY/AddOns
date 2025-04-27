# CompactVendor

## [v11.1.0.250423](https://github.com/Vladinator/wow-addon-compactvendor/tree/v11.1.0.250423) (2025-04-23)
[Full Changelog](https://github.com/Vladinator/wow-addon-compactvendor/commits/v11.1.0.250423) [Previous Releases](https://github.com/Vladinator/wow-addon-compactvendor/releases)

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
- TOC bump  
- Added 10.1 adjustments.  
- TOC bump and small fix for 10.1  
- TOC bump  
- - Added option slider for icon shape. Default is round.  
    - The GET\_ITEM\_INFO\_RECEIVED event does make sense, as once it fires we need to update a previously pending entry as done loading.  
- Ensure that we only process tooltip data relevant to the merchant item itself.  
- TOC bump  
- - Clarified the state of the tooltip scanner return values. Booleans signify a pending request or not, in the events there is no direct item returned.  
    - Adjusted code to reflect this change, and ensured to avoid requesting additional scans on pending scans.  
    - The item refresh method will respect the pending scan and avoid duplicate scan requests. Once done, the callback will finalize the item and mark it as loaded.  
    - Added UpdateMerchantThrottled as a lot of items on a vendor will cause multiple update events along with item loaded events to occur, we only need to track the merchant update event, and to update once at the end, not for every unique item.  
    - Commented out the GET\_ITEM\_INFO\_RECEIVED and ITEM\_DATA\_LOAD\_RESULT events as the MERCHANT\_UPDATE appears to also fire regardless, and it's good enough with the throttle method used to avoid too frequent updates.  
- TOC bump  
- Replaced old transmog collected code with a faster way to check if an appearance is collected or not.  
- TOC bump  
- - Added custom colors to support Spell related items in the merchant, like in Torghast. The quality filter will use the internal quality table when creating the dropdown options.  
    - Merchant update event will refresh items with limited availability, in case we purchased any of those.  
