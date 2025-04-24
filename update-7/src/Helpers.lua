Helpers = {}

function Helpers.selectUnit(unit)
    if not unit then
        debug.log("[selectUnit] ❌ Tried to select a nil unit")
        return
    end

    selectedUnit = unit
    selectedQ = unit.q
    selectedR = unit.r

    for _, tile in ipairs(tiles) do
        tile.selected = false
        tile.highlighted = false
        tile.attackable = false
    end

    local tile = getTile(selectedQ, selectedR)
    if tile then
        tile.selected = true
    end

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

    local targetTile = getTile(targetQ, targetR)
    if not targetTile or not targetTile.unit then return false end

    local target = targetTile.unit
    target.hp = target.hp - (attacker.attack or 1)

    if target.hp <= 0 then
        Helpers.removeUnit(target)

        if attacker:shouldAdvanceAfterAttack(targetQ, targetR) then
            moveUnit(attacker.q, attacker.r, targetQ, targetR)
        end

        debug.log(string.format("[resolveAttack] 💥 %s (%s) destroyed %s at (%d,%d)",
            attacker.type, attacker.team, target.type, targetQ, targetR))
    else
        debug.log(string.format("[resolveAttack] ⚔️ %s survived with %d HP", target.type, target.hp))
    end

    return true
end

function Helpers.clearTile(q, r)
    local tile = getTile(q, r)
    if tile then
        tile.unit = nil
        tile.occupied = false
    end
end
