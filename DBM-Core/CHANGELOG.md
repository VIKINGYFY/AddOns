# DBM - Core

## [12.0.6-12-g66c9101](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/66c9101adfafdeace34fd080b8180c5be9889563) (2025-11-22)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/12.0.6...66c9101adfafdeace34fd080b8180c5be9889563) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- fully disable DBM offline  
- Add localization for a future setting  
- add midnight timer testing tool  
- cleanup unused  
- remove 15 bar cap, it breaks bar tracking in midnight with way blizzard queues timers. an actual system for hiding bars beyond x time or x count will be added in near future but this should fix missing bars in midnight testing  
- tbc ptr is broken and returning WOW\_PROJECT\_CLASSIC instead of WOW\_PROJECT\_BURNING\_CRUSADE\_CLASSIC so we have to work around bug for now  
- what a nitpick luacheck. why are you even still around?  
- restrip some things out since they were edit mode only features  
- Fix lua error sending pull timer in midnight  
- wipe respawn data form midnight mods  
- blizzard includes respawn timer in timeline so no need to start our own  
- bump alpha  
