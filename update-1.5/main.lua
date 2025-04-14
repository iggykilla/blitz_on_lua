_G.love = require 'love'
---@diagnostic disable-next-line: lowercase-global


-- all the libraries are store here
require 'src/Dependencies'

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- seed the RNG so that calls to random are always random
    math.randomseed(os.time())

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,    -- or true if you want fullscreen
        resizable = true,     -- true if you want dynamic resizing
        vsync = true,          -- smooth frames
        canvas = false         -- false = better for sharp lines
    })

    local offsetX = VIRTUAL_WIDTH / 2
    local offsetY = VIRTUAL_HEIGHT / 2

    tilesByCoordinates = {} -- define this first so tiles = generateHexGrid can populate
    tiles = generateHexGrid(offsetX, offsetY) -- ✅ store your tile data
    -- safe setup of test unit
    local tile = getTile(0, 0)
    if tile then
        tile.unit = "TestUnit"
    end

    local tile2 = getTile(2, 2)
    if tile2 then
        tile2.unit = "TestUnit"
    end

    smallFont = love.graphics.newFont(12)
end

function love.update(dt)

end

function love.draw()
    push:start()
    love.graphics.setFont(smallFont)

    -- draw all hexes
    for _, tile in ipairs(tiles) do
        drawHex(tile.x, tile.y, HEX_RADIUS)

        local label = string.format("%d,%d", tile.q, tile.r)
        local textWidth = smallFont:getWidth(label)
        local textHeight = smallFont:getHeight()
        love.graphics.print(label, tile.x - textWidth / 2, tile.y - textHeight / 2)
    end

    -- highlight center
    local t = getTile(0, 0)
    
    if t then
        love.graphics.setColor(1, 1, 0)
        drawHex(t.x, t.y, HEX_RADIUS)

    -- highlight neighbors
    local neighbors = getNeighbors(1, 1)
    for _, n in ipairs(neighbors) do
        love.graphics.setColor(0, 1, 0)
        drawHex(n.x, n.y, HEX_RADIUS)
    end

    local checkTile = getTile(0, 1)
        if checkTile then
            if isTileEmpty(0, 1) then
                love.graphics.setColor(0, 0, 1) -- blue if empty
            else
                love.graphics.setColor(1, 0, 0) -- red if occupied
            end
            drawHex(checkTile.x, checkTile.y, HEX_RADIUS)
        end
    end

    -- test tile at (2, 2)
    local checkTile2 = getTile(2, 2)
    if checkTile2 then
        if isTileEmpty(2, 2) then
            love.graphics.setColor(0, 0, 1) -- blue if empty
        else
            love.graphics.setColor(1, 0, 0) -- red if occupied
        end
        drawHex(checkTile2.x, checkTile2.y, HEX_RADIUS)
    end

 

    love.graphics.setColor(1, 1, 1)
    push:finish()
end


function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    -- keys can be accessed by string name
    if key == 'escape' then
        -- function LÖVE gives us to terminate application
        love.event.quit()
    end
end