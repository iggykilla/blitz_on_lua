Infantry = Class{__includes = Piece}

local radius = INFANTRY_MOVE_RADIUS

function Infantry:init(team, q, r)
    Piece.init(self, "infantry", team, q, r)
end

function Infantry:getLabel()
    return "I"
end

function Infantry:getName()
    return "Infantry"
end

function Infantry:moveDirections()
    if self.team == "blue" then
        return { {0, -1}, {-1, 0}, {-1, 1} }
    else
        return { {0, 1}, {1, 0}, {1, -1} }
    end
end

function Infantry:computeValidMoves()
    local forwardDirs = self:moveDirections()
    local raw = HexBoard:getNeighbors(self.q, self.r, radius, true, forwardDirs)
    return self:filterAccessibleTiles(raw)
end

function Infantry:computeValidAttacks()
    local forwardDirs = self:moveDirections()
    local raw = HexBoard:getNeighbors(self.q, self.r, radius, true, forwardDirs)
    return self:filterAttackableTiles(raw)
end