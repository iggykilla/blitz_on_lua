
--[[
    Piece:init(unitType, team, q, r)
    Piece:getLabel()
    Piece:getColor()
    Piece:render(x, y, font)
    Piece:setPosition(q, r)
    Piece:canMoveTo(q, r)
]]

Piece = Class{}

function Piece:init(unitType, team, q, r)
    self.type = unitType                -- e.g., "infantry", "tank"
    self.team = team                    -- "red" or "blue"
    self.label = self:getLabel()        -- I, T, G, C
    self.q = q or nil
    self.r = r or nil
    self.flagRadius = false
    self.hp = 1                         -- Blitz rule: all units have 1 HP
end

function Piece:getLabel()
    return self.type:sub(1, 1):upper()
end

function Piece:getColor()
    if self.team == "red" then return {1, 0, 0}
    else return {0, 0.4, 1} end
end

function Piece:render(x, y, font)
    local r, g, b = self:getColor()
    love.graphics.setColor(r, g, b)
    love.graphics.setFont(font)
    love.graphics.print(self.label, x, y)
    love.graphics.setColor(1, 1, 1)
end

function Piece:setPosition(q, r)
    self.q = q
    self.r = r
end

function Piece:canMoveTo(q, r)
    for _, tile in ipairs(self:getValidMoves()) do
        if tile.q == q and tile.r == r and not tile.occupied then
            return true
        end
    end
    return false
end

function Piece:getMaxMoveCost()
    return 1 -- default move range (e.g., for Infantry)
end

function Piece:moveDirections()
    return nil
end

function Piece:getValidMoves()
    if self.cachedMoves then
        return self.cachedMoves
    end

    local computed = self:computeValidMoves()
    
    --[[if DEBUG_MODE then
        if type(computed) ~= "table" then
            if not self._warnedInvalid then
                debug.log(string.format("[getValidMoves] ERROR: computeValidMoves() returned %s for %s", type(computed), self.type))
                self._warnedInvalid = true
            end
            return {}
        end
    end]]

    self.cachedMoves = computed
    return self.cachedMoves
end

function Piece:invalidateMoves()
    self.cachedMoves = nil
end

-- Default fallback
function Piece:computeValidMoves()
    local raw = HexBoard:getNeighbors(self.q, self.r, 1)
    return self:filterAccessibleTiles(raw)
end

function Piece:isTileAccessible(tile)
    return not tile.occupied or tile.unit.team ~= self.team
end

function Piece:filterAccessibleTiles(tiles)
    local result = {}
    for _, tile in ipairs(tiles) do
        local accessible = self:isTileAccessible(tile)

        --[[if DEBUG_MODE then
            debug.log(string.format(
                "[%s (%s)] filterAccessibleTiles → (%d,%d) occupied=%s by %s → %s",
                self.type,
                self.team,
                tile.q, tile.r,
                tostring(tile.occupied),
                tile.unit and tile.unit.team or "none",
                accessible and "✅ allowed" or "❌ blocked"
            ))
        end]]

        if accessible then
            table.insert(result, tile)
        end
    end
    return result
end

function Piece:modifyMoveCost(tile)
    if tile and tile.moveCost then
        return tile.moveCost
    end
    return 1 -- default fallback cost
end

function Piece:markAttackableTiles(tile)
    return tile.occupied and tile.unit.team ~= self.team 
 end
 
function Piece:filterAttackableTiles(tiles)
    local result = {}
    for _, tile in ipairs(tiles) do
        local attackable = self:markAttackableTiles(tile)

        if attackable then
            -- ✅ No need to set tile.attackable here
            table.insert(result, tile)
       --   debug.log(string.format("[markAttackableTiles] Tile (%d,%d) marked as ✅ attackable (enemy unit)", tile.q, tile.r))
        else
       --   debug.log(string.format("[markAttackableTiles] Tile (%d,%d) marked as ❌ not attackable", tile.q, tile.r))
        end
    end
    return result
end
 
function Piece:computeValidAttacks()
    -- Get raw tiles to consider (could be special pattern)
    local raw = HexBoard:getNeighbors(self.q, self.r, self:maxAttackRange())
    -- Optional final filter (if needed for terrain, visibility, etc.)
    return self:filterAttackableTiles(raw)
end

-- For visuals
function Piece:getValidAttacks()
    if self.cachedAttacks then
        return self.cachedAttacks
    end

    local computed = self:computeValidAttacks()
    
 --[[ if DEBUG_MODE then
        if type(computed) ~= "table" then
            if not self._warnedInvalid then
                debug.log(string.format("[getValidAttacks] ERROR: computeValidAttacks () returned %s for %s", type(computed), self.type))
                self._warnedInvalid = true
            end
            return {}
        end
    end]]

    self.cachedAttacks = computed
    return self.cachedAttacks
end

function Piece:invalidateAttacks()
    self.cachedAttacks = nil
end

function Piece:attackCost() return 1 end
function Piece:maxAttackCost() return 1 end
function Piece:maxAttackRange() return 1 end

function Piece:canAttack(q, r)
    local tile = HexBoard:getTile(q, r)
    if not tile or not self:markAttackableTiles(tile) then
        return false
    end

    return HexBoard:hasLineOfSight(self, HexBoard:getTile(self.q, self.r), tile)
end

function Piece:shouldAdvanceAfterAttack(targetQ, targetR)
    return true -- default: all basic units advance
end