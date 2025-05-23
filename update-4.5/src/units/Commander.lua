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

function Commander:getValidMoves()
    local raw = getReachableTiles(self.q, self.r, self:getMaxMoveCost(), self)
    return self:filterAccessibleTiles(raw)
end

function Commander:canAttack(q, r)
    -- Placeholder for Update 5
    return false
end

function Commander:getMaxMoveCost()
    return 3
end
