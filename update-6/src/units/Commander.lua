Commander = Class{__includes = Piece}

function Commander:init(team, q, r)
    Piece.init(self, "commander", team, q, r)
end

function Commander:getLabel()
    return "K"
end

function Commander:getName()
    return "Commander"
end

function Commander:computeValidMoves()
    local reachableTiles = getReachableTiles(self.q, self.r, self:getMaxMoveCost(), self)
    return self:filterAccessibleTiles(reachableTiles)
end

function Commander:getMaxMoveCost()
    return 3
end

function Commander:computeValidAttacks()
    local reachableWithEnemies = getAttackableTilesMelee(self.q, self.r, self)
    return self:filterAttackableTiles(reachableWithEnemies)
end
