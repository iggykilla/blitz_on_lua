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
HexMath = require 'src.HexMath'

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

-- a basic StateMachine class which will allow us to transition to and from
-- game states smoothly and avoid monolithic code in one file
require 'src/StateMachine'

require 'src/Helpers'

-- each of the individual states our game can be in at once; each state has
-- its own update and render methods that can be called by our state machine
-- each frame, to avoid bulky code in main.lua
require 'src/states/PlayerTurnState'
require 'src/states/EnemyTurnState'

-- For testing and debugging
require 'src/Test'