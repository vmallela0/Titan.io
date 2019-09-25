
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local physics = require("physics")
physics.start()
physics.setGravity(0, 0)

-- Image sheet
local sheetOptions = 
{
	frames = 
	{
		{-- rover
		},
		{-- Cargo
			x = 1,
			y = 3,
			width = 87,
			height = 87
		},
		{-- sandstorm
			x = 110,
			y = 19,
			width = 70,
			height = 70
		},
		{-- enemy sandstorms
			x = 190,
			y = 15,
			width = 70,
			height = 70
		},
	},
}

local objectSheet = graphics.newImageSheet("spritesheet2.png", sheetOptions)


local score = 0
local died = false

local rover
local cargo
local sandstorm
local gameLoopTimer
local scoreText

local backGroup
local mainGroup
local uiGroup
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	backGroup = display.newGroup() 
	sceneGroup:insert(backGroup) 

	mainGroup = display.newGroup() 
	sceneGroup:insert(mainGroup)

	local background = display.newImageRect(backGroup, "gamebackground.png", 1400, 800)
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	local cargo = display.newImageRect(mainGroup, objectSheet, 2, 87, 87)
	cargo.x = 500
	cargo.y = 500

	local sandstorm = display.newImageRect(mainGroup, objectSheet, 3, 70, 70)
	sandstorm.x = 600 
	sandstorm.y = 700
	physics.addBody(sandstorm, "dynamic", { radius = 35, bounce = 0.8})
	sandstorm:setLinearVelocity(-30, -30)
	sandstorm:applyTorque(-11)
	
	local enemyStorm = display.newImageRect(mainGroup, objectSheet, 4, 70, 70)
	enemyStorm.x = math.random(200, 1000)
	enemyStorm.y = math.random(100, 300)
	physics.addBody(enemyStorm, "dynamic", { radius = 35, bounce = 0.8})
	enemyStorm:setLinearVelocity(10, 10)
	enemyStorm:applyTorque(11)

	


end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen

	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
