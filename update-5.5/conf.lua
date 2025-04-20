--[[
    conf.lua is run before anything else (even before require works like normal)
    use raw values, can't use constants
]]

function love.conf(t)
    t.window.title = "Blitz"
end