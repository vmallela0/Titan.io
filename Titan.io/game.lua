
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
			width = 65,
			height = 65
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

local sandstorm

local enemyScore = 0
local score = 0
local died = false

local enemyTable = {}

local rover
local cargo
local sandstorm
local gameLoopTimer
local scoreText

local backGroup
local mainGroup
local uiGroup

--import log
--local radius = math.log(score) + 15
--Make randomization function here
--function randomEnemy()
-- SPAWN ENEMIES AT SLOW RATE 
-- WE WANT 10 ENEMIES AT ALL TIMES IN EVERY ROOM
-- 
--end

-- function randomCargo()
-- 	reuse rand code from enemyScore
-- 	we want 50 cargos generated per minute in game
-- 	spaced out if possible later
-- 	add score here too ==> adding scores after eating a cargo
-- end

local function spawnEnemy()
	local enemyStorm = display.newImageRect(mainGroup, objectSheet, 4, 70, 70)
	table.insert(enemyTable, enemyStorm)
	enemyStorm.myName = "enemy"
	enemyStorm.x = math.random(300, 800)
	enemyStorm.y = math.random(100, 300)
	physics.addBody(enemyStorm, "dynamic", { radius = 35, bounce = 0.8})
	enemyStorm:setLinearVelocity(math.random(-100, 100), math.random(-100, 100))
	enemyStorm:applyTorque(11)
end

--local radius = math.log(score) + 15


--make sandstorm's radius applicable
--function sandstorm()
	--sandstorm.scale(radius)
	--if ((sandstorm.x + 2 >= enemy.x) or (sandstorm.x - 2 >= enemy.x) and ((sandstorm.y + 2 >= enemy.y) or (sandstorm.y - 2 <= enemy.y))
--end

--following is spawn cargo, idk when to use it:
-- local cargo = display.newImageRect(mainGroup, objectSheet, 2, 87, 87)
-- cargo.x = 500
-- cargo.y = 500

local function updateText()
	scoreText.text = "Score: ".. score
end

local function dragSelf(event)
	local sandstorm = event.target
	local phase = event.phase

	if("began" == phase) then 
		display.currentStage:setFocus(sandstorm)
		sandstorm.touchOffsetX = event.x - sandstorm.x
		sandstorm.touchOffsetY = event.y - sandstorm.y
	elseif("moved" == phase) then
		timer.performWithDelay(200, function () sandstorm.x = event.x - sandstorm.touchOffsetX
		sandstorm.y = event.y - sandstorm.touchOffsetY end)
	elseif("ended" == phase or "cancelled" == phase) then 
		display.currentStage:setFocus(nil)
	end
	return true
end

-- -----------------------------------------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------------------------------------

-- create()-----------------------------------------------------------------------------------------------------------------
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	physics.pause()

	backGroup = display.newGroup() 
	sceneGroup:insert(backGroup) 

	mainGroup = display.newGroup() 
	sceneGroup:insert(mainGroup)

	uiGroup = display.newGroup()
	sceneGroup:insert(uiGroup)

	local background = display.newImageRect(backGroup, "gamebackground.png", 1400, 800)
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	-- score Text 
	scoreText = display.newText(uiGroup, "Score "..score, 500, 80, native.systemFont, 36)
	scoreText:setFillColor(0, 0, 0)


	-- spawn self
	sandstorm = display.newImageRect(mainGroup, objectSheet, 3, 70, 70)
	sandstorm.x = 500 
	sandstorm.y = 500
	physics.addBody(sandstorm, "dynamic", { radius = 35, bounce = 0, isSensor = true})
	sandstorm:applyTorque(-15)
	sandstorm.fill.scaleX = 1
	sandstorm.fill.scaleY = 1

	-- Sensor type the sandstorm
	-- physics.addBody(sandstorm, {radius = 30, isSensor = true})
	sandstorm.myName = "self"


	
	-- Event listener
	sandstorm:addEventListener("touch", dragSelf)
	
end


-- show event -----------------------------------------------------------------------------------------------------------------
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase
	local function gameLoop()
		spawnEnemy()
		for i = #enemyTable, 1, -1 do
			local deleteEnemy = enemyTable[i]
	
			if(
				-- deleteEnemy.x < -100 or deleteEnemy.x > display.contentWidth + 100 or
				-- deleteEnemy.y < -100 or
				-- deleteEnemy.y > display.contentHeight + 100 
				-- or 
				deleteEnemy.x -40 <= sandstorm.x and deleteEnemy.x + 40 >= sandstorm.x and 
				deleteEnemy.y -40 <= sandstorm.y and deleteEnemy.y + 40 >= sandstorm.y)
				
			then 
				display.remove(deleteEnemy) 
				table.remove(enemyTable, i)
				print("test")
			end
		end
	end


	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		physics.start()

		gameLoopTimer = timer.performWithDelay(500, gameLoop, 0)
		
	end
end


-- hide() event -----------------------------------------------------------------------------------------------------------------
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		physics.pause()
		composer.removeScene("game")
	end
end


-- destroy() -----------------------------------------------------------------------------------------------------------------
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
