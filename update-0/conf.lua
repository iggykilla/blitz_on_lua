--[[
    conf.lua is run before anything else (even before require works like normal)
    use raw values, can't use constants
]] 

function love.conf(t)
    t.window.title = "Blitz"
    t.window.width = 1280
    t.window.height = 720
    t.window.resizable = true
    t.window.vsync = true
    t.window.fullscreen = true
end