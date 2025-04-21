Helpers = {}

function Helpers.selectUnit(unit)
    selectedUnit = unit
    selectedQ = unit.q
    selectedR = unit.r

    for _, tile in ipairs(tiles) do
        tile.selected = false
        tile.highlighted = false
        tile.attackable = false
    end

    local tile = getTile(selectedQ, selectedR)
    if tile then
        tile.selected = true
    end

    Visuals.refreshHighlights(unit)
end