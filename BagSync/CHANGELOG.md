# BagSync

## [v19.69](https://github.com/Xruptor/BagSync/tree/v19.69) (2025-07-21)
[Full Changelog](https://github.com/Xruptor/BagSync/compare/v19.68...v19.69) [Previous Releases](https://github.com/Xruptor/BagSync/releases)

- Fixed Blizzards stupid code inconsistencies  
    * MOP Classic apparently doesn't have C\_TooltipInfo implemented like ALL the other servers.  Seriously Blizzard?!?! (Fixes #413)  
    * Had to add checks for BattlePet cages in Mailbox and Guild Bank for MOP Classic.  Reverted to older code just to make it work. (Fixes #413)  
    * Fixes a nil error when checking the mailbox or guildbank in MOP Classic.  
