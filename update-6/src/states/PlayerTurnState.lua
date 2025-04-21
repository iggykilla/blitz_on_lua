PlayerTurnState = Class{}

function PlayerTurnState:init() end

function PlayerTurnState:enter(params)
    self.team = params.team
    -- maybe highlight that team's units
end

function PlayerTurnState:update(dt)
    if love.keyboard.wasPressed("m") then
        moveUnit(2, 0, 2, -1)
    elseif love.keyboard.wasPressed("n") then
        moveUnit(2, 0, 1, 0)
    elseif love.keyboard.wasPressed("tab") then
        unitIndex = unitIndex + 1
        if unitIndex > #placedUnits then
            unitIndex = 1
        end
        selectedUnit = placedUnits[unitIndex]
        selectedQ = selectedUnit.q
        selectedR = selectedUnit.r

        for _, tile in ipairs(tiles) do
            tile.selected = false
            tile.highlighted = false
            tile.attackable = false
        end

        local tile = getTile(selectedUnit.q, selectedUnit.r)
        if tile then
            tile.selected = true
        end

        Visuals.refreshHighlights(selectedUnit)
    end
end

function PlayerTurnState:render()
    love.graphics.print(self.team .. "'s Turn", 10, 10)
end

function PlayerTurnState:exit() end