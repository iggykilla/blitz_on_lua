local debugger = {}

DEBUG_MODE = true -- set to false in production

function logDebbug(msg)
    if DEBUG_MODE then
        print("[DEBUG] " .. msg)
    end
end

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

        -- Ordered fields
        local fields = { "q", "r", "x", "y", "occupied", "selected", "highlightType" }

        for _, key in ipairs(fields) do
            debugger.log("  " .. key .. ": " .. tostring(tile[key]))
        end

        -- Unit info (if present)
        if tile.unit then
            local unit = tile.unit
            local label = unit:getLabel()
            local name = unit:getName()
            debugger.log(string.format("  unit: %s (%s) [%s]", name, unit.team, label))
        end

        debugger.log("---")
    end
    debugger.log("=== End of Tile State ===")
end

return debugger
