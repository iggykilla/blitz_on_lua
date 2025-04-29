EnemyTurnState = Class{}

function EnemyTurnState:init() end

function EnemyTurnState:enter(params)
    self.team = params.team  -- Ensure the correct team ("blue" or "red") is passed
    self.unitIndex = 1
    self.teamUnits = {}

    -- Filter and collect only the enemy team's units
    for _, unit in ipairs(Helpers.placedUnits) do
        if unit.team == self.team then
            table.insert(self.teamUnits, unit)
        end
    end

    Helpers.updateDangerZones(self.team)
    
    self.timer = 0
    self.actionDelay = 0.5

    -- Log to ensure the correct units are being selected
    debug.log(self.team .. " AI has " .. #self.teamUnits .. " units.")

    -- Select first enemy unit
    if #self.teamUnits > 0 then
        Helpers.selectUnit(self.teamUnits[self.unitIndex])
    end
end

function EnemyTurnState:update(dt)
    self.timer = self.timer + dt
    if self.timer < self.actionDelay then return end
    self.timer = 0

    while self.unitIndex <= #self.teamUnits do
        local unit = self.teamUnits[self.unitIndex]

        if not unit or unit.dead then
            self.unitIndex = self.unitIndex + 1
            goto continue
        end

        Helpers.selectUnit(unit)

        -- Try attacks first
        local validAttacks = unit:computeValidAttacks()
        if #validAttacks > 0 then
            local melee, ranged = {}, {}
            for _, t in ipairs(validAttacks) do
                local d = HexMath.hexDistance(unit.q, unit.r, t.q, t.r)
                if d == 1 then table.insert(melee, t)
                elseif unit.isRanged and d > 1 then table.insert(ranged, t) end
            end

            local choice = melee[1] or ranged[1]
            if choice and Helpers.resolveAttack(unit, choice.q, choice.r) then
                gStateMachine:change('player-turn', { team = 'blue' })
                return
            end
        end

        -- Try moving
        local validMoves = unit:getValidMoves()
        if #validMoves > 0 then
            local moveTo = validMoves[1]
            if HexBoard:moveUnit(unit.q, unit.r, moveTo.q, moveTo.r) then
                if not Helpers.promotionRequest then
                    gStateMachine:change('player-turn', { team = 'blue' })
                return
                end
            end
        end

        self.unitIndex = self.unitIndex + 1
        ::continue::
    end

    -- End turn if nothing left to do
    gStateMachine:change('player-turn', { team = 'blue' })
end

function EnemyTurnState:render()
    love.graphics.print(self.team .. "'s Turn (AI)", 10, 10)
end

function EnemyTurnState:exit() end
