function testGetLine(fromTile, toTile)
    if not fromTile or not toTile then
        debug.log("❌ Invalid tiles in testGetLine")
        return
    end

    debug.log(string.format("Testing line from (%d,%d) to (%d,%d):", fromTile.q, fromTile.r, toTile.q, toTile.r))

    local line = HexMath.getLine(fromTile.q, fromTile.r, toTile.q, toTile.r, true, true)

    for i, tile in ipairs(line) do
        if tile then
            debug.log(string.format("Step %d: (%d,%d)", i, tile.q, tile.r))
            tile.debugColor = {1, 0, 1} -- pink for visual debug
        else
            debug.log(string.format("Step %d: ❌ tile is nil", i))
        end
    end
end

function testLineOfSight(fromTile, toTile)
    if not fromTile then
        debug.log("❌ fromTile is nil")
        return
    end

    if not toTile then
        debug.log("❌ toTile is nil")
        return
    end

    if not fromTile.unit then
        debug.log("❌ No unit on fromTile")
        return
    end

    local unit = fromTile.unit

    debug.log(string.format("🔍 Testing LoS from (%d,%d) to (%d,%d)", fromTile.q, fromTile.r, toTile.q, toTile.r))

    local line = HexMath.getLine(fromTile.q, fromTile.r, toTile.q, toTile.r, false, false)

    for _, tile in ipairs(line) do
        if tile then
            tile.debugColor = {1, 1, 0} -- yellow
        end
    end

    if hasLineOfSight(unit, fromTile, toTile) then
        toTile.debugColor = {0, 1, 0}
        debug.log("✅ Line of Sight is CLEAR")
    else
        toTile.debugColor = {1, 0, 0}
        debug.log("❌ Line of Sight is BLOCKED")
    end
end

function testCanAttack(fromTile, toTile)
    if not fromTile or not toTile then
        debug.log("❌ Invalid tiles in testCanAttack")
        return
    end

    local unit = fromTile.unit
    if not unit then
        debug.log("❌ No unit on fromTile")
        return
    end

    debug.log(string.format("🎯 Testing canAttack from (%d,%d) to (%d,%d)", fromTile.q, fromTile.r, toTile.q, toTile.r))

    if unit:canAttack(toTile.q, toTile.r) then
        toTile.debugColor = {0, 1, 0}
        debug.log("✅ Unit CAN attack target")
    else
        toTile.debugColor = {1, 0, 0}
        debug.log("❌ Unit CANNOT attack target")
    end
end

function testGetTile(tile)
    if tile then
        debug.log(string.format("[getTile] Tile at (0,0): q = %d, r = %d, unit = %s", tile.q, tile.r, tile.unit and tile.unit.type or "none"))
    else
        debug.log("[getTile] Tile at (0,0) is nil")
    end
end

function testHandleMouseClick(q, r)
    -- 1) Nothing selected yet? Try to pick up a unit
    if not selectedUnit then
        selectUnitAt(q, r)
        if selectedUnit then
            return "selected"
        else
            return nil
        end
    end

    local u = selectedUnit
    local startQ, startR = u.q, u.r

    -- 2) Can we move there?
    for _, tile in ipairs(u:getValidMoves()) do
        if tile.q == q and tile.r == r then
            HexBoard:moveUnit(startQ, startR, q, r)
            -- deselect after move:
            Helpers.selectUnit(nil)
            return "moved"
        end
    end

    -- 3) Can we attack there?
    for _, tile in ipairs(u:getValidAttacks()) do
        if tile.q == q and tile.r == r then
            Helpers.resolveAttack(u, q, r)
            -- deselect after attack:
            Helpers.selectUnit(nil)
            return "attacked"
        end
    end

    -- 4) Nothing valid here
    debug.log(string.format(
      "Invalid click at (%d,%d): not a move or attack target", q, r
    ))
    return nil
end
