# BagSync

## [v19.71](https://github.com/Xruptor/BagSync/tree/v19.71) (2025-08-09)
[Full Changelog](https://github.com/Xruptor/BagSync/compare/v19.70...v19.71) [Previous Releases](https://github.com/Xruptor/BagSync/releases)

- Fixed issues for patch 11.2  
    * Fixed a number of errors associated with the new Bank Tabs system in 11.2 (Fixes #415)  
    * Added checks to remove orphaned database entries for reagents and void storage due to patch 11.2 and the new bank tabs.  (Fixes #415)  
    * Updated compatibility for Classic, Cata, WOTLK and MOP. (Fixes #415)  
    * Removed the tracking options for reagent and void storage from the config if the server has Bank Tabs enabled.  (Fixes #415)  
    * Added checks to remove any saved equipped bags for the bank if Bank Tabs is enabled. (Fixes #415)  
