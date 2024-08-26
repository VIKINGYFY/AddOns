# CompactVendor

## [v11.0.0.240805](https://github.com/Vladinator/wow-addon-compactvendor/tree/v11.0.0.240805) (2024-08-05)
[Full Changelog](https://github.com/Vladinator/wow-addon-compactvendor/commits/v11.0.0.240805) [Previous Releases](https://github.com/Vladinator/wow-addon-compactvendor/releases)

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
- - Moved the filter IsCollected into the core addon as IsTransmogCollected.  
    - Added more states for items like transmog and toys instead of tooltip scanning.  
    - The merchant list and filters rely on this new infomation from the core itself.  
- TOC bump  
- - We tooltip scan cosmetics and otherwise tooltips with information to extract.  
    - Merged collected/known into a learnable filter for better control of what to display. Fixed issue with heirlooms and cosmetics not being properly handled and scanned.  
- TOC bump  
- When applying font size we also need to apply it to the cost font strings and autoresize them again.  
- Adding the ability to set a shape onto the icon template. Need to duplicate the exact look of the current Round implementation, then add the additional types.  
- TOC bump  
- Using the new Settings cause taint. Replaced with more basic widget template.  
- Set the default size to 13 and force apply shadows if not using the default font object.  
- Enforcing shadow on the font if a size is used that doesn't have one as part of it.  
- Adding merchant scanning as that contains more information.  
- Removed module CF isn't aware of existing yet.  
- Merge pull request #11 from Vladinator/feature/df  
    Dragonflight and v2 rewrite  
- Adjusted visibility handling, to hide button or list when the tab is not the correct one.  
- Updated for 10.0.0  
