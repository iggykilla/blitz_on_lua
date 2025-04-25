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

    tilesByCoordinates = {} -- define this first so tiles = generateHexGrid can populate
    tiles = HexBoard:generateHexGrid(OFFSET_X, OFFSET_Y) -- ✅ store your tile data

    smallFont = love.graphics.newFont(8)
    mediumFont = love.graphics.newFont(20)
    
    -- Setup Logic
    BoardSetup.setup()
    placedUnits = Helpers.collectPlacedUnits()
  --  debug.log("📦 Collected " .. #placedUnits .. " placed units")

    for i, unit in ipairs(placedUnits) do
     --   debug.log(string.format("  [%d] %s (%s) at %d,%d", i, unit:getName(), unit.team, unit.q, unit.r))
    end

    -- Get all placed units
    removedUnits = {}
    
    -- Select the unit at (2, 0) (center infantry)
    local centerUnit = HexBoard:getTile(2, 0).unit  -- Get the tile at (2, 0) and select its unit
    if centerUnit then
     --   debug.log("call here 1) Selecting unit at (2,0)")
        Helpers.selectUnit(centerUnit)  -- Select that unit
     --   debug.log("🟢 Selecting unit: " .. centerUnit:getName() .. " at (2,0)")
    else
     --   debug.log("⚠️ No unit at (2,0) to select")
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
    

    --[[ Test.lua logic
    local fromTile = getTile(0,1)
    local toTile = getTile(2, 1)

    testCanAttack(fromTile, toTile)]]

    love.keyboard.keysPressed = {}
    love.mouse.keysPressed = {}
end

function love.update(dt)
    -- global input handling
    if love.keyboard.wasPressed("escape") then
        love.event.quit()
    end

    if love.mouse.wasPressed(1) then  -- Left-click
        local q, r = HexMath.screenToHex(
            love.mouse.getX(), love.mouse.getY()
        )
        debug.log(string.format("   → hex coords: (q=%d, r=%d)", q, r))
    
        -- centralized click handling
        Helpers.handleMouseClick(q, r)
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
    love.mouse.keysPressed = {}
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

function love.mousepressed(x, y, button, istouch, presses)
    -- Store the mouse button press in love.mouse.keysPressed
    love.mouse.keysPressed[button] = true
end

function love.mouse.wasPressed(button)
    return love.mouse.keysPressed[button] == true
end