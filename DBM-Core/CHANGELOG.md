# DBM - Core

## [12.0.3-10-g664496b](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/664496bb7d90e3153e0afd6346c6d22770fd7419) (2025-11-13)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/12.0.3...664496bb7d90e3153e0afd6346c6d22770fd7419) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- actually at this point this one line is redundant  
- Don't report difficulty on joining delve or follower group  
    Don't report difficulty when joining queued content in general  
    Once again attempt to always report difficulty on joining groups that aren't one of above, but with a better antispam throttle to avoid it being reported twice.  
- final iteration that's best compromise on some of remaining issues.  
- simplify, solving luaLS  
- Make sure message is branded for clarification of source of message  
- improvements to klast  
- Add feature to announce when raid or dungeon difficulty change (while in a group). Raid option on by default and dungeon option off by default.  
    Inspiration for addition is that often. players don't notice the difficulty is set incorrectly when they join a pug group and lose time by zoning into zone before it is set correctly. In addition, they also often don't notice when the difficulty has been changed to correct one either and don't zone in right away. This change is aimed at making those often overlooked chat messages far more prominant with DBMs typical alert style.  
- adjust some message language for TTS on fractillus and soul hunters to be less directive in situations they went against common weak auras  
- Core/Timer: fix count voice when timer is started again before expiring (#1800)  
- bump alpha  
