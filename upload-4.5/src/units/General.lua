General = Class{__includes = Piece}

function General:init(team, q, r)
    Piece.init(self, "general", team, q, r)
end

function General:getLabel()
    return "G"
end

function General:getName()
    return "General"
end

function General:getValidMoves()
    local neighbors = getNeighbors(self.q, self.r, 1)
    return self:filterAccessibleTiles(neighbors)
end


function General:canAttack(q, r)
    -- Placeholder for Update 5
    return false
end
