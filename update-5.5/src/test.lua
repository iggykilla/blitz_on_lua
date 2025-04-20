--[[      Update 5.5 – Finalized Attack System with Line of Sight

- Added getAttackableTiles(startQ, startR, unit) for full-range tactical scans
- Introduced unit:attackCost(), maxAttackCost(), and maxAttackRange()
- Refactored Piece:canAttack(q, r) to include Line of Sight (LoS) check
- Created hasLineOfSight(unit, fromTile, toTile) using cube-based hex raycasting
- Added canAttackThrough(unit, tile) with terrain + unit blocking rules
- Centralized movement and attack passability in isTileBlocked(tile, unit, mode)
- Moved hex math (getLine, cubeLerp, rounding) to src/HexMath.lua
- Maintained filterAttackableTiles() and markAttackableTiles(tile) for local checks

Update getReachableTiles to support blocked tiles; refactor melee attack detection

- Added `includeBlocked` flag to `getReachableTiles` to include non-walkable tiles (e.g. enemies) in results
- Updated `getAttackableTilesMelee` to use `getReachableTiles` with `includeBlocked = true`
- Now correctly detects enemy units adjacent to reachable tiles, even if blocked
- Added debug logs to visualize reachable tiles and confirm attackable enemies
- Maintained separation of concerns: filtering logic stays in `filterAttackableTiles`
]]