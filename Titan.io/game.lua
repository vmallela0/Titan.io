
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
-- Scale elements so that it is proportional to the screen size. for reference look at config
local sheetOptions = 
{
	frames = 
	{
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
		{-- blue robots
			x = 295,
			y = 20,
			width = 69, 
			height = 66
		},
		{-- red robots
			x = 383,
			y = 22,
			width = 67,
			height = 65
		},
		{-- Joystick pad
			x = 513, 
			y = 15,
			width = 125, 
			height = 125
		}
	},
}

--sprite initialization
local objectSheet = graphics.newImageSheet("spritesheet2.png", sheetOptions)


--score and player info init
local score = 0
local died = false
local size = 1

local enemyTable = {}
local scoreTable = {}

local robotTable = {}
local robotSizeTable = {}

--game objects
local rover
local cargo
local sandstorm
local robot

local joystickTop
local joystickLeft
local joystickRight
local joystickBottom
local joystickPad
local background

local fx = 0
local fy = 0
local moveX
local moveY
 

local gameLoopTimer
local spawnTimer
local robotTimer
local scoreText

local backGroup
local mainGroup
local uiGroup


--local enemyCount = 0

-- function randomCargo()
-- 	reuse rand code from enemyScore
-- 	we want 50 cargos generated per minute in game
-- 	spaced out if possible later
-- 	add score here too ==> adding scores after eating a cargo
-- end

local function spawnEnemy()
	-- while enemyCount < 10
	-- do
	-- we will need to add the enemyCount cap because it is finite and the map needs to be regulated
		-- display spawn
	local enemyStorm = display.newImageRect(mainGroup, objectSheet, 3, 70, 70)
	-- moves to back
	enemyStorm:toFront()
	-- enemy table for deletion
	table.insert(enemyTable, enemyStorm)
	--name
	enemyStorm.myName = "enemy"
	-- random score/ size of enemy
	enemyScore = (math.random(1, score + 1))
	-- score table for later
	table.insert(scoreTable, enemyScore)
	enemySize = 1 + math.log(enemyScore)
	-- increase size according to enemyScore
	enemyStorm.xScale = enemySize
	enemyStorm.yScale = enemySize
	-- we need to scale ALL numbers to the screen size. We need to have flexibility in platforms. 
	enemyStorm.x = math.random(0, display.contentWidth + 100)
	enemyStorm.y = math.random(0, display.contentHeight + 100)
	physics.addBody(enemyStorm, "dynamic", { radius = 35, bounce = 2})
	-- random path
	enemyStorm:setLinearVelocity(math.random(-100, 100), math.random(-100, 100))
	-- applies rotation
	enemyStorm:applyTorque(20)
		-- enemyCount=enemyCount+1
	-- end
end

-- local function spawnRobots()
-- 	robotType = math.random(1, 2)
-- 	if robotType == 1 then
-- 		robot = display.newImageRect(background, objectSheet, 4, 69, 66)
-- 	elseif robotType == 2 then
-- 		robot = display.newImageRect(background, objectSheet, 5, 67, 65)
-- 	end
-- 	table.insert(robotTable, robot)
-- 	-- robot:toFront()
-- 	roboSize = math.random(1, 2) / 10
-- 	robotSize = (math.random(1, 2) / 10)
-- 	table.insert(robotSizeTable, roboSize)
-- 	robot.xScale = robotSize
-- 	robot.yScale = robotSize
-- 	robot.x = math.random(-500, display.contentWidth + 500)
-- 	robot.y = math.random(0, display.contentHeight)
-- end

--make sandstorm's radius applicable
--function sandstorm()
	--sandstorm.scale(radius)
	--if ((sandstorm.x + 2 >= enemy.x) or (sandstorm.x - 2 >= enemy.x) and ((sandstorm.y + 2 >= enemy.y) or (sandstorm.y - 2 <= enemy.y))
--end

--following is spawn cargo, idk when to use it:
-- local cargo = display.newImageRect(mainGroup, objectSheet, 1, 87, 87)
-- cargo.x = 500
-- cargo.y = 500

-- updates score text 
local function updateText()
	scoreText.text = "Score: ".. score
end

local function joystickPadForce()
	if joystickPad.x + 62.5 >= -100 then
		-- fx = 100
		moveX = -100
		-- transition.moveBy( container, {x = -100} )

	elseif joystickPad.x + 62.5 < -200 then
		-- fx = -100
		moveX = 100
		-- transition.moveBy( container, {x = 100} )

	end
	if joystickPad.y + 62.5 <= 575 then
		-- fy = -100 
		moveY = 100

	elseif joystickPad.y + 62.5 >= 700 then
		-- fy = 100
		moveY = -100
	end
	if joystickPad.x == -207.5 and joystickPad.y == 580 then
		-- fx = 0
		-- fy = 0
		moveX = 0
		moveY = 0
	end
end

-- local function moveMap()
-- 	if sandstorm.x >= 800 then
-- 		-- transition.to( container, {x = sandstorm.x + 1000} )
-- 		display.contentCenterX = sandstorm.x
-- 		display.contentCenterY = sandstorm.y
-- 	end
-- 	if sandstorm.x <= display.contentCenterX then
-- 		transition.to( container, {x = sandstorm.x - 1000} )
-- 		sandstorm.x = display.contentCenterX 
-- 		sandstorm.y = display.contentCenterY
-- 	end
-- 	if sandstorm.y >= display.contentCenterY then
-- 		transition.to( container, {y = sandstorm.y - 1000} )
-- 		sandstorm.x = display.contentCenterX 
-- 		sandstorm.y = display.contentCenterY
-- 	end
-- 	if sandstorm.y <= display.contentCenterY then
-- 		transition.to( container, {y = sandstorm.y + 1000} )
-- 		sandstorm.x = display.contentCenterX 
-- 		sandstorm.y = display.contentCenterY
-- 	end
-- end


local function stopSelf()
	if sandstorm.x >= display.contentWidth + 300 then
		sandstorm.x = display.contentWidth + 300
	end
	if sandstorm.x <= -350 then
		sandstorm.x = -350
	end
	if sandstorm.y <= 50 then
		sandstorm.y = 50
	end
	if sandstorm.y >= 800 then
		sandstorm.y = 800
	end
end


local function stopPad()
	if joystickPad.x >= -125 then
		joystickPad.x = -125
	end
	if joystickPad.x <= -300 then
		joystickPad.x = -300
	end
	if joystickPad.y <= 475 then 
		joystickPad.y = 475
	end
	if joystickPad.y >= 675 then
		joystickPad.y = 675
	end
end



local function joystickPadMove(event)
	local joystickPad = event.target
	local phase = event.phase

	if("began" == phase) then
		display.currentStage:setFocus(joystickPad)
		joystickOffsetX = event.x - joystickPad.x
		joystickOffsetY = event.y - joystickPad.y

	elseif ("moved" == phase) then
		joystickPad.x = event.x - joystickOffsetX
		joystickPad.y = event.y - joystickOffsetY
		stopPad()
		stopSelf()
		sandstorm:setLinearVelocity(fx, fy, sandstorm.x, sandstorm.y)
	elseif("ended" == phase or "cancelled" == phase) then
		display.currentStage:setFocus(nil)
		joystickPad.x = -207.5
		joystickPad.y = 580
		fx = 0 
		fy = 0
		sandstorm:setLinearVelocity(0, 0, sandstorm.x, sandstorm.y)

	end
	return true
end

local function endGame()
	composer.setVariable("finalScore", score)
	composer.setVariable("gameScore", score)

	composer.gotoScene("gameover", {time = 1000, effect = "crossFade"})
end

local function crackHeadFunc()
	
	for s = #enemyTable, 1, -1 do
		local sandstormChaos = enemyTable[s]
		sandstormChaos:setLinearVelocity(math.random(-420, 420), math.random(-420, 420))
	end
end


-- -----------------------------------------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------------------------------------

-- create()-----------------------------------------------------------------------------------------------------------------
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	physics.pause()
	-- display groups
	backGroup = display.newGroup() 
	sceneGroup:insert(backGroup) 

	mainGroup = display.newGroup() 
	sceneGroup:insert(mainGroup)

	uiGroup = display.newGroup()
	sceneGroup:insert(uiGroup)

	-- 
	-- container = display.newContainer(backGroup, display.actualContentWidth, display.actualContentHeight)

	background = display.newImageRect(backGroup, "gamebackground.png", 1400, 800)
	background:translate(display.contentWidth / 2, display.contentHeight / 2)
	transition.to( background, { rotation = 360, transition = easing.inOutExpo} )
	background.xScale = 5
	background.yScale = 5
	
	-- spawns joysticks
	joystickTop = display.newImageRect(uiGroup, "joystick.png", 400, 400)
	physics.addBody( joystickTop, {bounce = 0, isSensor = true} )
	joystickTop.x = -75
	joystickTop.y = 600
	joystickTop.alpha = .6

	joystickLeft = display.newImageRect(uiGroup, "joystick.png", 400, 400)
	physics.addBody( joystickLeft, {bounce = 0, isSensor = true} )
	joystickLeft.x = -175
	joystickLeft.y = 700
	joystickLeft.alpha = .6


	joystickRight = display.newImageRect(uiGroup, "joystick.png", 400, 400)
	physics.addBody( joystickRight, {bounce = 0, isSensor = true} )
	joystickRight.x = 25
	joystickRight.y = 700
	joystickRight.alpha = .6


	joystickBottom = display.newImageRect(uiGroup, "joystick.png", 400, 400)
	physics.addBody( joystickBottom, {bounce = 0, isSensor = true} )
	joystickBottom.x = -75
	joystickBottom.y = 800
	joystickBottom.alpha = .6


	joystickPad = display.newImageRect(uiGroup, objectSheet, 6, 125, 125)
	physics.addBody( joystickPad, { bounce = 0, isSensor = true } )
	joystickPad.xScale = .75
	joystickPad.yScale = .75
	joystickPad.x = -207.5
	joystickPad.y = 580
	joystickPad.alpha = .98

	-- score Text 
	scoreText = display.newText(uiGroup, "Score "..score, display.contentCenterX, 50, native.systemFont, 36)
	scoreText:setFillColor(0, 0, 0)

	-- spawn self
	sandstorm = display.newImageRect(mainGroup, objectSheet, 2, 70, 70)
	sandstorm.x = display.contentCenterX 
	sandstorm.y = display.contentCenterY
	physics.addBody(sandstorm, "dynamic", { radius = 35, bounce = 0, isSensor = true})
	sandstorm:applyTorque(-15)

	local function spawnSelf()
		sandstorm.isBodyActive = false
		sandstorm.x = display.contentCenterX
		sandstorm.y = display.contentCenterY

		-- fade in sandstorm when spawned
		transition.to(sandstorm, {alpha=1, time=5000,
			onComplete = function()
				sandstorm.isBodyActive = true
			end
		} )	
	end

	

	-- Sensor type the sandstorm
	-- physics.addBody(sandstorm, {radius = 30, isSensor = true})
	sandstorm.myName = "self"


	-- Event listener for dragSelf func
	joystickPad:addEventListener("touch", joystickPadMove)
end


-- show event -----------------------------------------------------------------------------------------------------------------
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase
	-- grow func
	local function grow()
		sandstorm.xScale = size 
		sandstorm.yScale = size 
	end

	-- local function boundaries()
	-- 	if sandstorm.x >= background.x + (background.width / 2 )then
	-- 		sandstorm.x = background.x + (background.width / 2)
	-- 	end
	-- 	if sandstorm.x <= background.x then
	-- 		sandstorm.x = background.x
	-- 	end
	-- 	if sandstorm.y >= background.y + (background.height / 2) then
	-- 		sandstorm.y = background.y + (background.height / 2)
	-- 	end
	-- 	if sandstorm.y >= background.y then
	-- 		sandstorm.y = background.y
	-- 	end
	-- end
	
	-- gameLoop -- deletes enemy too
	local function gameLoop()
		joystickPadForce()
		crackHeadFunc()
		-- boundaries()
		transition.moveBy( background, {x = moveX, y = moveY} )
		-- moveMap()
		for i = #enemyTable, 1, -1 do
			local enemyS = scoreTable[i]
			local deleteEnemy = enemyTable[i]
			local enemyRealSize = 1 + math.log(enemyS)

			-- if 
			-- 	deleteEnemy.x < -500 or deleteEnemy.x > display.viewableContentWidth + 500 or
			-- 	deleteEnemy.y < -500 or
			-- 	--deleteEnemy.y > display.viewableContentHeight + 500
			-- then 
			-- 	deleteEnemy:removeSelf()
				
			-- 	-- display.remove(deleteEnemy)
			-- 	table.remove(enemyTable, i)
			-- 	table.remove(scoreTable, i)
			-- else
			if
			sandstorm.x -(30 * size) <= deleteEnemy.x and sandstorm.x + (40 * size) >= deleteEnemy.x and 
			sandstorm.y -(30 * size) <= deleteEnemy.y and sandstorm.y + (40 * size) >= deleteEnemy.y and
			1 + math.log(enemyS) <= size  
			then 
				-- delete enemy
				deleteEnemy:removeSelf()

				-- display.remove(deleteEnemy) -- deletes enemy
				table.remove(enemyTable, i) 
				table.remove(scoreTable, i)
				-- updates score and size

				score = score + enemyS
				size = (size + (math.log(score) / 5))
				updateText()
				grow()
			
			elseif
				-- touches but size bigger (enemy eat)
				deleteEnemy.x -(35 * (enemyRealSize)) <= sandstorm.x and deleteEnemy.x + (35 * enemyRealSize) >= sandstorm.x and 
				deleteEnemy.y -(35 * (enemyRealSize)) <= sandstorm.y and deleteEnemy.y + (35 * enemyRealSize) >= sandstorm.y and
				1 + math.log(enemyS) > size 
			then 
				-- turns blank
				sandstorm.alpha = 0
				sandstorm.isBodyActive = false
				timer.performWithDelay(1000, endGame)


			elseif
				sandstorm.x >= 1400 or sandstorm.x <= 0 or 
				sandstorm.y >= 800 or sandstorm.y <= 0   
			then 
				-- turns blank
				sandstorm.alpha = 0
				sandstorm.isBodyActive = false
				timer.performWithDelay(1000, endGame)
			end	
		end
	end


	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)
	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		physics.start()
		-- game timer
		gameLoopTimer = timer.performWithDelay(100, gameLoop, 0)
		-- spawn timer
		spawnTimer = timer.performWithDelay(2000, spawnEnemy, 0)
		-- robotTimer = timer.performWithDelay(500, spawnRobots, 0)
	end
end


-- hide() event -----------------------------------------------------------------------------------------------------------------
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
		timer.cancel(gameLoopTimer)
		timer.cancel(spawnTimer)
		-- timer.cancel(robotTimer)

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