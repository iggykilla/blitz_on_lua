Infantry = Class{__includes = Piece}

function Infantry:init(team, q, r)
    Piece.init(self, "infantry", team, q, r)
end

function Infantry:getLabel()
    return "I"
end

function Infantry:getName()
    return "Infantry"
end

function Infantry:computeValidMoves()
    local radius = INFANTRY_MOVE_RADIUS
    local forwardDirs = self.team == "blue"
        and { {0, -1}, {-1, 0}, {-1, 1} }
        or  { {0, 1}, {1, 0}, {1, -1} }

    -- Get raw neighbors (without recalculating them later)
    local raw = getNeighbors(self.q, self.r, radius, true, forwardDirs)

    -- Pass the raw neighbors to getReachableTiles
    local reachableTiles = getReachableTiles(self.q, self.r, raw, self:getMaxMoveCost(), self) 

    --[[if DEBUG_MODE then
        debug.log("[Infantry:getValidMoves] Reachable tiles: " .. #reachableTiles)

        debug.log("[Infantry:getValidMoves] Raw neighbors:")
        for _, tile in ipairs(raw) do
            debug.log(string.format(" - (%d, %d)", tile.q, tile.r))
        end
    end]]
    
    -- Filter the reachable tiles based on accessibility
    return self:filterAccessibleTiles(reachableTiles)
end

function Infantry:canAttack(q, r)
    -- Placeholder for Update 5: attack logic
    return false
end