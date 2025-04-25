Horse = Class{__includes = Piece}

function Horse:init(team, q, r)
    Piece.init(self, "horse", team, q, r)
end

function Horse:getLabel()
    return "C"
end

function Horse:getName()
    return "Cavalry"
end

function Horse:computeValidMoves()
    local raw = HexBoard:getNeighbors(self.q, self.r, HORSE_JUMP_RADIUS, true)
    return self:filterAccessibleTiles(raw)
end

function Horse:getMaxMoveCost()
    return 2 -- or whatever value you want
end

function Horse:computeValidAttacks()
    local raw = HexBoard:getNeighbors(self.q, self.r, HORSE_JUMP_RADIUS, true)
    return self:filterAttackableTiles(raw)
end