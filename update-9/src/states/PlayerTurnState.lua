PlayerTurnState = Class{}

function PlayerTurnState:init() end

function PlayerTurnState:enter(params)
    self.team = params.team  -- "blue" or "red"
    self.unitIndex = 1
    self.teamUnits = {}

    -- Cache all units belonging to this team
    for _, unit in ipairs(Helpers.placedUnits) do
        if unit.team == self.team then
            table.insert(self.teamUnits, unit)
        end
    end

    Helpers.updateDangerZones(self.team)

    -- Try selecting the default unit at (2,0)
    local centerTile = HexBoard:getTile(2, 0)
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
    local mx, my = love.mouse.getX(), love.mouse.getY()
    local hoverQ, hoverR = HexMath.screenToHex(mx, my)

    if love.mouse.wasPressed(1) then
        local q, r   = HexMath.screenToHex(love.mouse.getX(), love.mouse.getY())
        local action = Helpers.handleMouseClick(q, r)
    
        if action == "moved" or action == "attacked" then
            gStateMachine:change('enemy-turn', { team = 'red' })
        end
    end

    if love.keyboard.wasPressed("tab") then
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

    if hoverQ ~= currentHoverQ or hoverR ~= currentHoverR then
        currentHoverQ, currentHoverR = hoverQ, hoverR
        Visuals.highlightHover(hoverQ, hoverR)
    end
end

function PlayerTurnState:render()
    love.graphics.print(self.team .. "'s Turn", 10, 10)
end

function PlayerTurnState:exit() end