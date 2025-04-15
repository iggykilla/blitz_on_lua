local debugger = {}

function debugger.log(str)
    local file = io.open("debug_log.txt", "a")
    if file then
        file:write(os.date("[%H:%M:%S] ") .. tostring(str) .. "\n")
        file:close()
    end
end


-- testing that tile-state changes after placing units
function debugger.logAllTiles(tiles)
    debugger.log("=== Full Tile State ===")
    for _, tile in ipairs(tiles) do
        debugger.log("Tile at " .. tile.q .. "," .. tile.r)

        -- Manually ordered fields
        local fields = { "q", "r", "x", "y", "unit", "occupied", "selected", "highlighted" }

        for _, key in ipairs(fields) do
            local v = tile[key]
            if key == "unit" and v ~= nil then
                debugger.log("  unit: " .. v.type .. " (" .. v.team .. ")")
            else
                debugger.log("  " .. key .. ": " .. tostring(v))
            end
        end

        debugger.log("---")
    end
    debugger.log("=== End of Tile State ===")
end

return debugger
