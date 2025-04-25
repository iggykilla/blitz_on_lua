PlayerTurnState = Class{}

function PlayerTurnState:init() end

function PlayerTurnState:enter(params)
    self.team = params.team  -- "blue" or "red"
    self.unitIndex = 1
    self.teamUnits = {}

    -- Cache all units belonging to this team
    for _, unit in ipairs(placedUnits) do
        if unit.team == self.team then
            table.insert(self.teamUnits, unit)
        end
    end

    -- Try selecting the default unit at (2,0)
    local centerTile = getTile(2, 0)
    if centerTile and centerTile.unit and centerTile.unit.team == self.team then
        Helpers.selectUnit(centerTile.unit)
    --    debug.log("🟢 Selecting unit: " .. centerTile.unit:getName() .. " at (2,0)")
    else
        -- Fallback: pick first alive unit
        for _, unit in ipairs(self.teamUnits) do
            if not unit.dead then
                Helpers.selectUnit(unit)
          --      debug.log("🟢 Fallback select: " .. unit:getName())
                break
            end
        end
    end
end

function PlayerTurnState:update(dt)
    if love.keyboard.wasPressed("m") then
        -- Example: try to move 1 tile northeast
        local q, r = selectedQ, selectedR
        local dq, dr = -1, 0
        if moveUnit(q, r, q + dq, r + dr) then
            gStateMachine:change('enemy-turn', { team = 'red' })
        end

    elseif love.keyboard.wasPressed("n") then
        -- Example: try to move 1 tile northeast
        local q, r = selectedQ, selectedR
        local dq, dr = -2, 0
        if moveUnit(q, r, q + dq, r + dr) then
            gStateMachine:change('enemy-turn', { team = 'red' })
        end

    elseif love.keyboard.wasPressed("a") then
        -- Example: melee attack north
        local q, r = selectedQ, selectedR
        local dq, dr = -1, 0
        if Helpers.resolveAttack(selectedUnit, q + dq, r + dr) then
            gStateMachine:change('enemy-turn', { team = 'red' })
        end

    elseif love.keyboard.wasPressed("r") then
        -- Example: ranged attack east
        local q, r = selectedQ, selectedR
        local dq, dr = 2, 0
        if Helpers.resolveAttack(selectedUnit, q + dq, r + dr) then
            gStateMachine:change('enemy-turn', { team = 'red' })
        end

    elseif love.keyboard.wasPressed("tab") then
        self.unitIndex = self.unitIndex + 1
        if self.unitIndex > #self.teamUnits then
            self.unitIndex = 1
        end
    
        local nextUnit = self.teamUnits[self.unitIndex]
        -- Skip dead units
        while nextUnit and nextUnit.hp <= 0 do
            self.unitIndex = self.unitIndex + 1
            if self.unitIndex > #self.teamUnits then
                self.unitIndex = 1
            end
            nextUnit = self.teamUnits[self.unitIndex]
        end
    
        if nextUnit then
            debug.log("🔁 Tab → selecting: " .. nextUnit:getName())
            debug.log("🟢 Selecting unit at " .. selectedQ .. "," .. selectedR)
            Helpers.selectUnit(nextUnit)
        else
            debug.log("❌ Tab tried to select a nil unit")
        end    

    elseif love.keyboard.wasPressed("e") then
        gStateMachine:change('enemy-turn', { team = 'red' })
    end
end

function PlayerTurnState:render()
    love.graphics.print(self.team .. "'s Turn", 10, 10)
end

function PlayerTurnState:exit() end