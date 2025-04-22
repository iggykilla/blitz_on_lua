_G.love = require 'love'
---@diagnostic disable-next-line: lowercase-global

-- all the libraries are store here
require 'src/Dependencies'

function love.load()
    debug.log("Game started")
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- seed the RNG so that calls to random are always random
    math.randomseed(os.time())

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,    -- or true if you want fullscreen
        resizable = true,      -- true if you want dynamic resizing
        vsync = true,          -- smooth frames
        canvas = false         -- false = better for sharp lines
    })

    local offsetX = VIRTUAL_WIDTH / 2
    local offsetY = VIRTUAL_HEIGHT / 2

    tilesByCoordinates = {} -- define this first so tiles = generateHexGrid can populate
    tiles = generateHexGrid(offsetX, offsetY) -- ✅ store your tile data
    
    -- safe setup of test unit

    -- blue back row
    placeUnit(0, 1, "tank", "blue")
    placeUnit(4, 0, "general", "blue")
    placeUnit(3, 0, "commander", "blue")
    placeUnit(2, 2, "horse", "blue")

    -- blue infantry
    local blue_infantry_placement = {{2,-1}, {2,0}, {0,0}, {-1,1}}
    for _, pos in ipairs(blue_infantry_placement) do
        placeUnit(pos[1], pos[2], "infantry", "blue")
    end

    -- red infantry
    placeUnit(1, 1, "infantry", "red")
    placeUnit(1, 0, "infantry", "red")
    placeUnit(3, -1, "infantry", "red")
    placeUnit(0, -1, "infantry", "red")
    placeUnit(0, 2, "infantry", "red")

    smallFont = love.graphics.newFont(8)
    mediumFont = love.graphics.newFont(20)
    
    -- Get all placed units
    placedUnits = {}

    for _, tile in ipairs(tiles) do
        if tile.unit then
            table.insert(placedUnits, tile.unit)
        end
    end

    unitIndex = 1
    if #placedUnits > 0 then
        unitIndex = 1
        Helpers.rawSelect(placedUnits[unitIndex])
    end

--[[
    -- tracks tile state 
    debug.logAllTiles(tiles)
        
    -- test tilesByCoordinates
    local test = getTile(4, 0)
    if test then
        debug.log("Test getTile(4,0): unit = " .. (test.unit and test.unit.type or "none"))
    else
        debug.log("Test getTile(4,0): tile not found")
    end]]
    gStateMachine = StateMachine{
        ["player-turn"] = function() return PlayerTurnState() end,
        ["enemy-turn"] = function() return EnemyTurnState() end
    }
    gStateMachine:change("player-turn", {team = "blue"})
    
    love.keyboard.keysPressed = {}
end

function love.update(dt)
    -- global input handling
    if love.keyboard.wasPressed("escape") then
        love.event.quit()
    end

    gStateMachine:update(dt)

    for _, tile in pairs(tiles) do
        if tile.flashTimer and tile.flashTimer > 0 then
            tile.flashTimer = tile.flashTimer - dt * 2 -- adjust speed if needed
            if tile.flashTimer < 0 then tile.flashTimer = 0 end
        end
    end

    for _, tile in pairs(tiles) do
        if tile.flashTimer > 0.01 and not tile.loggedFlash then
            debug.log(string.format("⚠️ tile at %d,%d started with flashTimer = %.2f", tile.q, tile.r, tile.flashTimer))
            tile.loggedFlash = true
        end
        
        -- Reset logged flag after flash ends
        if tile.flashTimer == 0 then
            tile.loggedFlash = false
        end
    end
    -- reset keys pressed
    love.keyboard.keysPressed = {}
end

function love.draw()
    push:start()
    love.graphics.setFont(smallFont)

    -- draw all hexes
    for _, tile in ipairs(tiles) do
        Visuals.drawTile(tile, smallFont, mediumFont)
    end

    -- Draw selected unit info
    if selectedUnit then
        local label = string.format("Selected: %s (%s)", selectedUnit:getName(), selectedUnit.team)
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(mediumFont)
        love.graphics.print(label, 10, VIRTUAL_HEIGHT - 30)
    end
    -- use the state machine to defer rendering to the current state we're in
    gStateMachine:render()

    push:finish()
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    -- add to our table of keys pressed this frame
    love.keyboard.keysPressed[key] = true
end

function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end