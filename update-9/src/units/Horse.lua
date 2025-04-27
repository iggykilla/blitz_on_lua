Horse = Class{__includes = Piece}

function Horse:init(team, q, r)
    Piece.init(self, "horse", team, q, r)
    self.flagRadius = true
end

function Horse:getLabel()
    return "C"
end

function Horse:getName()
    return "Cavalry"
end

function Horse:computeValidMoves()
    local raw = HexBoard:getNeighbors(self.q, self.r, HORSE_JUMP_RADIUS, self.flagRadius)
    return self:filterAccessibleTiles(raw)
end

function Horse:getMaxMoveCost()
    return 2 -- or whatever value you want
end

function Horse:computeValidAttacks()
    local raw = HexBoard:getNeighbors(self.q, self.r, HORSE_JUMP_RADIUS, self.flagRadius)
    return self:filterAttackableTiles(raw)
end

function Horse:maxAttackCost() return 2 end
function Horse:maxAttackRange() return 2 end

function Horse:attackCost(distance)
    return distance or 1 -- 1 for melee, 2 for ranged, or customize
end