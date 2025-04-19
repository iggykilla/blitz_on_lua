



 --[[ function Piece:markAttackableTiles(tiles)
    debug.log("[markAttackableTiles] Called")  -- Verify if the function is being triggered
    
    for _, tile in ipairs(tiles) do
        if tile.occupied and tile.unit.team ~= self.team then
            tile.attackable = true
            debug.log(string.format("[markAttackableTiles] Tile (%d,%d) marked as ✅ attackable (enemy unit)", tile.q, tile.r))
        else
            tile.attackable = false
            debug.log(string.format("[markAttackableTiles] Tile (%d,%d) marked as ❌ not attackable", tile.q, tile.r))
        end
    end
end

function Piece:getValidAttacks()
    local raw = getNeighbors(self.q, self.r, 1)

    -- Always mark, even if cached
    self:markAttackableTiles(raw)

    self.markedAttacks = true

    debug.log("[computedValidAttacks] Attackable tiles:")
    for _, tile in ipairs(raw) do
        if tile.attackable then
            debug.log(string.format("[getValidAttacks] Tile (%d,%d) is attackable", tile.q, tile.r))
        end
    end

    return raw
end]]