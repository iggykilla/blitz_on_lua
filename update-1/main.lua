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

    tiles = generateHexGrid(offsetX, offsetY) -- ✅ store your tile data

    smallFont = love.graphics.newFont(12)

end

function love.update(dt)

end

function love.draw()
    push:start()

    love.graphics.setFont(smallFont)

    -- draw hexes here
    for _, tile in ipairs(tiles) do
        drawHex(tile.x, tile.y, HEX_RADIUS)
    
        local label = string.format("%d,%d", tile.q, tile.r)
    
        -- center the text in the tile
        local textWidth = smallFont:getWidth(label)
        local textHeight = smallFont:getHeight()
        love.graphics.print(label, tile.x - textWidth / 2, tile.y - textHeight / 2)
    end

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