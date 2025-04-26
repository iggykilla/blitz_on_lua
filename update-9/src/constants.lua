
--[[
    Figuring out window sizes

    🧮 Hex Width Math
    Each pointy-topped hex has:

    radius = 40
    width = √3 × radius ≈ 1.732 × 40 ≈ 69.28

    But adjacent columns don’t sit next to each other fully.
    They shift over by ¾ of the hex width.

    Horizontal step = hex_width × 0.75 ≈ 69.28 × 0.75 ≈ 51.96
    First column starts at x = 0

    Next 8 columns step by 51.96
    Width ≈ 69.28 + 8 × 51.96 ≈ 69.28 + 415.68 ≈ ~485px
    That’s total grid width

    ✅ Final Dimensions
    Let’s round up for padding:

    hex_radius = 40
    hex_width ≈ 69
    hex_height = 80

    So let’s lock in:

    Virtual Width: 550
    Virtual Height: 420

]]

-- size of our actual window
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- size we're trying to emulate with push
VIRTUAL_WIDTH = 550
VIRTUAL_HEIGHT = 360

-- tile radius (changed to 20 from 40 to better fit the screen)
HEX_RADIUS = 20

SQRT3 = math.sqrt(3)

OFFSET_X = VIRTUAL_WIDTH / 2
OFFSET_Y = VIRTUAL_HEIGHT / 2

-- Movement Ranges
INFANTRY_MOVE_RADIUS    = 1
HORSE_JUMP_RADIUS       = 2
TANK_SHORT_RADIUS       = 1
TANK_LONG_RADIUS        = 2 -- asterisk jump radius
COMMANDER_MOVE_RADIUS   = 3
GENERAL_MOVE_RADIUS     = 1
