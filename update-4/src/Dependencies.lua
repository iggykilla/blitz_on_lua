-- push is a library that will allow us to draw our game at a virtual
-- resolution, instead of however large our window is; used to provide
-- a more retro aesthetic
--
-- https://github.com/Ulydev/push
push = require 'lib/push'

-- the "Class" library we're using will allow us to represent anything in
-- our game as code, rather than keeping track of many disparate variables and
-- methods
--
-- https://github.com/vrld/hump/blob/master/class.lua
Class = require 'lib/class'

-- a few global constants, centralized
require 'src/constants'

-- Board - Tiles Logic
require 'src/HexBoard'

require 'src/Piece'
-- Factory (uses above units)
UnitFactory = require 'src/UnitFactory'

-- ui logic
Visuals = require 'src/ui/Visuals'

-- Unit Files
require 'src/units/Infantry'
require 'src/units/Tank'
require 'src/units/Horse'
require 'src/units/Commander'
require 'src/units/General'

-- requires logic to print debug files
debug = require("debugger")
debug.log("Hello again!")
