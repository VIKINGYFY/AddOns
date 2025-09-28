# BagSync

## [v19.74](https://github.com/Xruptor/BagSync/tree/v19.74) (2025-09-27)
[Full Changelog](https://github.com/Xruptor/BagSync/compare/v19.73...v19.74) [Previous Releases](https://github.com/Xruptor/BagSync/releases)

- Classic and Anniversary Server Bank Fix  
    * Fixed an issue on the classic and anniversary servers where the first bank slot was not correctly being counted.  This is due to Blizzard having incorrect variables stored within the client versus the retail server.  In fact the first bank slot is actually the ReagentBag number on classic servers.  Way to go Blizzard!  
    * Adjusted the bank slots to compensate for this mess.  (Fixes #421)  
    *  Special thanks to Schlapstick on the Classic Anniversary server for helping a poor tauren out to buy a bank slot.  You rock! :)  
- Merge pull request #422 from nanjuekaien1/patch-87  
    Update zhCN.lua  
- Update zhCN.lua  