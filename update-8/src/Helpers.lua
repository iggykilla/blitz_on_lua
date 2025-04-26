Helpers = {}

function Helpers.collectPlacedUnits()
    local list = {}
    for _, tile in ipairs(tiles) do
        if tile.unit then
            table.insert(list, tile.unit)
        end
    end
    return list
end

function Helpers.selectUnit(unit)
    if not unit then
        -- Deselection path
        selectedUnit = nil
        selectedQ, selectedR = nil, nil

        -- Clear all tile markings
        for _, tile in ipairs(tiles) do
            tile.selected    = false
            tile.highlighted = false
            tile.attackable  = false
        end

        -- Log and refresh visuals
        debug.log("[selectUnit] ⚪️ Deselected unit")
        Visuals.refreshHighlights(nil)
        return
    end

    -- If they clicked the same unit, do nothing
    if selectedUnit == unit then
        debug.log("[selectUnit] ⚠️ Already selected: "
            .. unit:getName()
            .. " at (" .. unit.q .. "," .. unit.r .. ")"
        )
        return
    end

    -- Selection path
    selectedUnit = unit
    selectedQ, selectedR = unit.q, unit.r

    -- Clear old tile markings
    for _, tile in ipairs(tiles) do
        tile.selected    = false
        tile.highlighted = false
        tile.attackable  = false
    end

    -- Mark the new tile
    local tile = HexBoard:getTile(selectedQ, selectedR)
    if tile then tile.selected = true end

    debug.log("[selectUnit] ✅ Selected: "
        .. unit:getName()
        .. " at (" .. unit.q .. "," .. unit.r .. ")"
    )

    -- Refresh move/attack highlights for the newly selected unit
    Visuals.refreshHighlights(unit)
end

function Helpers.rawSelect(unit)
    selectedUnit = unit
    selectedQ = unit.q
    selectedR = unit.r
end

function Helpers.removeUnit(unit)
    -- record the unit
    table.insert(removedUnits, unit)

    -- remove from placedUnits
    for i, u in ipairs(placedUnits) do
        if u == unit then
            table.remove(placedUnits, i)
            break
        end
    end

    -- clear unit from tile
    Helpers.clearTile(unit.q, unit.r)
end

function Helpers.resolveAttack(attacker, targetQ, targetR)
    debug.log(string.format(
    "[resolveAttack] ▶️ ENTRY attacker=%s target=(%d,%d)",
    attacker.type or tostring(attacker),
    targetQ, targetR
    ))
    
    -- 1) Validate that the target is in range/attackable
    local attackableTiles = attacker:computeValidAttacks()
    local validTarget = false
    for _, tile in ipairs(attackableTiles) do
        if tile.q == targetQ and tile.r == targetR then
            validTarget = true
            break
        end
    end
    if not validTarget then
        debug.log("[resolveAttack] ❌ Target not attackable")
        return false
    end

    -- 2) Ensure there’s actually a unit to hit
    local targetTile = HexBoard:getTile(targetQ, targetR)
    if not targetTile or not targetTile.unit then
        debug.log("[resolveAttack] ❌ No unit at target")
        return false
    end
    local target = targetTile.unit

    -- 3) Deal damage
    local dmg = attacker.attack or 1
    target.hp = target.hp - dmg

    -- 4) Handle death vs. survival
    if target.hp <= 0 then
        Helpers.removeUnit(target)
        debug.log(string.format(
            "[resolveAttack] 💥 %s (%s) destroyed %s at (%d,%d)",
            attacker.type, attacker.team, target.type, targetQ, targetR
        ))

        if attacker:shouldAdvanceAfterAttack(targetQ, targetR) then
            if attacker.canMoveTo and attacker:canMoveTo(targetQ, targetR) then
                HexBoard:moveUnit(attacker.q, attacker.r, targetQ, targetR)
                debug.log(string.format(
                    "[resolveAttack] 🚶 %s advanced to (%d,%d)",
                    attacker.type, targetQ, targetR
                ))
            else
                debug.log(string.format(
                    "[resolveAttack] ❌ %s cannot advance to (%d,%d)",
                    attacker.type, targetQ, targetR
                ))
            end
        end
    else
        debug.log(string.format(
            "[resolveAttack] ⚔️ %s survived with %d HP",
            target.type, target.hp
        ))
    end

    debug.log(string.format("[resolveAttack] ⏹ EXIT target=(%d,%d)", targetQ, targetR))
    return true
end

function Helpers.clearTile(q, r)
    local tile = HexBoard:getTile(q, r)
    if tile then
        tile.unit = nil
        tile.occupied = false
        debug.log(string.format("[clearTile] Cleared tile at (%d,%d)", q, r))
    end
end

--- Central click handler: select, move, attack, then advance the turn.
function Helpers.handleMouseClick(q, r)
    local u     = selectedUnit
    local other = HexBoard:getUnitAt(q, r)

    -- 0) Nothing selected? Pick up or bail
    if not u then
        if other then
            Helpers.selectUnit(other)
            return "selected"
        end
        return nil
    end

    -- 1) Click on an ENEMY unit → attempt attack
    if other and other.team ~= u.team then
        for _, tile in ipairs(u:getValidAttacks()) do
            if tile.q == q and tile.r == r then
                Helpers.resolveAttack(u, q, r)
                Helpers.selectUnit(nil)
                return "attacked"
            end
        end
        -- clicked an out‐of‐range enemy: do _not_ deselect
        debug.log(string.format(
          "[handleMouseClick] ⚠️ Enemy at (%d,%d) is out of range", q, r
        ))
        return nil
    end

    -- 2) Click on a FRIENDLY unit → switch selection
    if other and other.team == u.team then
        Helpers.selectUnit(other)
        return "selected"
    end

    -- 3) Try to move
    for _, tile in ipairs(u:getValidMoves()) do
        if tile.q == q and tile.r == r then
            HexBoard:moveUnit(u.q, u.r, q, r)
            Helpers.selectUnit(nil)
            return "moved"
        end
    end

    -- 4) Clicked empty or invalid spot → deselect
    Helpers.selectUnit(nil)
    return nil
end

return Helpers
