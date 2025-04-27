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

function General:computeValidMoves()
    -- a) run the base move logic
    local raw = Piece.computeValidMoves(self)

    -- b) drop any tile in danger
    local safe = {}
    for _, tile in ipairs(raw) do
        if not Helpers.isTileDangerous(tile.q, tile.r) then
            table.insert(safe, tile)
        end
    end

    return safe
end
