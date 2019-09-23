-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

local composer = require("composer")

display.setStatusBar(display.HiddenStatusBar)

math.randomseed(os.time())

audio.reserveChannels(1)

composer.gotoScene("menu")