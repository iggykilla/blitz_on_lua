Helpers = {}

Helpers.dangerZones = {}
Helpers.placedUnits = {}
Helpers.winner = nil
Helpers.promotionRequest = nil

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
    table.insert(removedUnits, unit)        
    for i,u in ipairs(Helpers.placedUnits) do
      if u == unit then
        table.remove(Helpers.placedUnits, i)
        break
      end
    end
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

        -- **NEW: check for game over right after removal**
        if Helpers.isGameOver() then
            return true
        end

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

    -- after removal/advance…
    for _, u in ipairs(Helpers.placedUnits) do
        u:invalidateMoves()
        u:invalidateAttacks()
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

function Helpers.findUnitByType(team, unitType)
    for _, u in ipairs(Helpers.placedUnits) do
        if u.team == team and u.type == unitType then
            return u
      end
    end
    return nil
end

function Helpers.checkGameResult(activeTeam)
    -- find the remaining Generals
    local blueGen = Helpers.findUnitByType("blue",  "general")
    local redGen  = Helpers.findUnitByType("red",   "general")

    -- 1) Standard victory if a General is gone
    if not blueGen then
        Helpers.winner = "red"
        return "red"
    end
    if not redGen then
        Helpers.winner = "blue"
        return "blue"
    end

    -- 2) Insufficient material: both sides only have their General
    local blueCount, redCount = 0, 0
    for _, u in ipairs(Helpers.placedUnits) do
        if     u.team == "blue" then blueCount = blueCount + 1
        elseif u.team == "red"  then redCount  = redCount  + 1
        end
    end
    if blueCount == 1 and redCount == 1 then
        Helpers.winner = "tie"
        return "tie"
    end

    -- 3) Stalemate for the active team:
    --    only its General remains *and* it has no moves or attacks
    local ownUnits = {}
    for _, u in ipairs(Helpers.placedUnits) do
        if u.team == activeTeam then
            table.insert(ownUnits, u)
        end
    end
    if #ownUnits == 1 and ownUnits[1].type == "general" then
        local gen     = ownUnits[1]
        local moves   = gen:computeValidMoves()
        local attacks = gen:computeValidAttacks()
        if #moves == 0 and #attacks == 0 then
            Helpers.winner = "tie"
            return "tie"
        end
    end

    -- no result yet
    return nil
end

function Helpers.isGameOver(activeTeam)
    return Helpers.checkGameResult(activeTeam) ~= nil
end

function Helpers.updateDangerZones(activeTeam)
    -- Reset danger zones map
    Helpers.dangerZones = {}

    -- Log entry info
    debug.log("=== updateDangerZones, activeTeam = " .. tostring(activeTeam))
    debug.log("placedUnits count = " .. tostring(#Helpers.placedUnits))

    -- Iterate over all placed units
    for i, u in ipairs(Helpers.placedUnits) do
        debug.log(string.format("unit #%d: type=%s team=%s", i, u.type or "?", u.team))

        -- Only consider enemy units
        if u.team ~= activeTeam then
            local maxRange = u:maxAttackRange()
            local rawRange

            -- Choose raw range source based on unit type
            if maxRange > 1 then
                -- Ranged units: all hexes within maxRange
                rawRange = HexBoard:getNeighbors(u.q, u.r, maxRange, u.flagRadius, u:moveDirections())
                debug.log("  rawRange (ranged) count = " .. tostring(#rawRange))
            else
                -- Melee units: all reachable tiles, including blocked
                rawRange = HexBoard:getReachableTiles(u.q, u.r, u:getMaxMoveCost(), u, true)
                debug.log("  rawRange (melee) count = " .. tostring(#rawRange))
            end

            local maxCost = u:maxAttackCost()

            for j, tile in ipairs(rawRange) do
                local dist = HexMath.hexDistance(u.q, u.r, tile.q, tile.r)
                local cost = u:attackCost(dist)
                -- Check only range and cost
                if dist <= maxRange and cost <= maxCost then
                    local key = tile.q .. "," .. tile.r
                    Helpers.dangerZones[key] = true
                    debug.log(string.format("  -> zone #%d: q=%d r=%d key=%q", j, tile.q, tile.r, key))
                else
                    debug.log(string.format("  -- skip #%d: q=%d r=%d dist=%d cost=%d", 
                        j, tile.q, tile.r, dist, cost))
                end
            end
        end
    end

    -- Log resulting danger zone coordinates
    debug.log("dangerZones keys:")
    for coord in pairs(Helpers.dangerZones) do
        debug.log("  " .. coord)
    end
end

function Helpers.isTileDangerous(q, r)
    return Helpers.dangerZones[q .. "," .. r] == true
end

-- Define where infantry promote (opponent’s general start)
local promotionZone = {
    blue = { q = -4, r =  0 },
    red  = { q =  4, r =  0 }
  }
  
-- 1) Called from moveUnit when an infantry lands on the zone
function Helpers.requestPromotion(unit, options)
    -- options = {"tank","horse","commander"}
    Helpers.promotionRequest = { unit = unit, options = options }
end
  
  -- 2) User clicked one of the options
function Helpers.processPromotionChoice(choice)
    local pr = Helpers.promotionRequest
    if not pr then return end
    Helpers.promoteUnit(pr.unit, choice)
    Helpers.promotionRequest = nil
    gStateMachine:change('enemy-turn', { team = 'red' })
end
  
-- 3) Swap out the infantry for its promoted form
function Helpers.promoteUnit(unit, newType)
    local team, q, r = unit.team, unit.q, unit.r
    Helpers.removeUnit(unit)
    HexBoard:placeUnit(q, r, newType, team)
    debug.log(string.format(
    "[Promote] Infantry at (%d,%d) became %s",
    q, r, newType
    ))
end
  
-- 4) Quick check for promotion‐tile membership
function Helpers.isInPromotionZone(unit)
    if unit.type ~= "infantry" then return false end
    local z = promotionZone[unit.team]
    return unit.q == z.q and unit.r == z.r
end 

return Helpers
