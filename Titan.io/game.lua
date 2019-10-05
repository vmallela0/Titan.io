
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

local fx = 0
local fy = 0
 

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
	enemyStorm:toBack()
	-- enemy table for deletion
	table.insert(enemyTable, enemyStorm)
	--name
	enemyStorm.myName = "enemy"
	-- random score/ size of enemy
	enemyScore = math.random(1, 5)
	-- score table for later
	table.insert(scoreTable, enemyScore)
	enemySize = 1 + math.log(enemyScore)
	-- increase size according to enemyScore
	enemyStorm.xScale = enemySize
	enemyStorm.yScale = enemySize
	-- we need to scale ALL numbers to the screen size. We need to have flexibility in platforms. 
	enemyStorm.x = math.random(0, display.contentWidth + 100)
	enemyStorm.y = math.random(0, display.contentHeight + 100)
	physics.addBody(enemyStorm, "dynamic", { radius = 35, bounce = 0.8})
	-- random path
	enemyStorm:setLinearVelocity(math.random(-50, 50), math.random(-50, 50))
	-- applies rotation
	enemyStorm:applyTorque(10)
		-- enemyCount=enemyCount+1
	-- end
end

local function spawnRobots()
	robotType = math.random(1, 2)
	if robotType == 1 then
		robot = display.newImageRect(mainGroup, objectSheet, 4, 69, 66)
	elseif robotType == 2 then
		robot = display.newImageRect(mainGroup, objectSheet, 5, 67, 65)
	end
	table.insert(robotTable, robot)
	robot:toBack()
	robot.myName = "robot"
	roboSize = math.random(1, 3)
	robotSize = (math.random(1, 3) / 3)
	table.insert(robotSizeTable, roboSize)
	robot.xScale = robotSize
	robot.yScale = robotSize
	robot.x = math.random(-500, display.contentWidth + 500)
	robot.y = math.random(0, display.contentHeight)
end

local function spawnJoystick()
	
end
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

-- movement func, for now just draggin
-- change to joystick controls 
local function dragSelf(event)
	local sandstorm = event.target
	local phase = event.phase

	if("began" == phase) then 
		display.currentStage:setFocus(sandstorm)
		sandstorm.touchOffsetX = event.x - sandstorm.x
		sandstorm.touchOffsetY = event.y - sandstorm.y
	elseif("moved" == phase) then
		-- timer.performWithDelay(200, function () 

		--Please don't change this -->>
		sandstorm.x = event.x - sandstorm.touchOffsetX
		sandstorm.y = event.y - sandstorm.touchOffsetY
		-- Force applyer, doesnt work well
		-- local fx = event.x - sandstorm.x
		-- local fy = event.y - sandstorm.y
		-- local fm = math.sqrt(fx * fx + fy * fy)
		-- if fm > 0 then 
		-- 	fx = fx / fm
		-- 	fy = fy / fm
		-- end
		-- loc = .1
		-- sandstorm:applyForce(fx, fy, sandstorm.x, sandstorm.y)
	elseif("ended" == phase or "cancelled" == phase) then 
		display.currentStage:setFocus(nil)
	end
	return true
end

local function joystickPadForce()
	if joystickPad.x + 62.5 >= -100 then
		fx = 100
	elseif joystickPad.x + 62.5 < -200 then
		fx = -100
	end
	if joystickPad.y + 62.5 <= 575 then
		fy = -100
	elseif joystickPad.y + 62.5 >= 700 then
		fy = 100
	end
	if joystickPad.x == -207.5 and joystickPad.y == 580 then
		fx = 0
		fy = 0
	end
end

local function stopSelf()
	if sandstorm.x >= display.contentWidth + 400 then
		sandstorm.x = display.contentWidth + 400
	end
	if sandstorm.x <= -300 then
		sandstorm.x = -300
	end
	if sandstorm.y <= 0 then
		sandstorm.y = 0
	end
	if sandstorm.y >= 900 then
		sandstorm.y = 900
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
		joystickPadForce()
		sandstorm:setLinearVelocity(fx, fy, sandstorm.x, sandstorm.y)
		stopSelf()
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
	composer.gotoScene("menu", {time = 1000, effect = "crossFade"})
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

	-- background
	local background = display.newImageRect(backGroup, "gamebackground.png", 1400, 800)
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	-- spawns joysticks
	joystickTop = display.newImageRect(uiGroup, "joystick.png", 400, 400)
	physics.addBody( joystickTop, {bounce = 0, isSensor = true} )
	joystickTop.x = -75
	joystickTop.y = 600

	joystickLeft = display.newImageRect(uiGroup, "joystick.png", 400, 400)
	physics.addBody( joystickLeft, {bounce = 0, isSensor = true} )
	joystickLeft.x = -175
	joystickLeft.y = 700

	joystickRight = display.newImageRect(uiGroup, "joystick.png", 400, 400)
	physics.addBody( joystickRight, {bounce = 0, isSensor = true} )
	joystickRight.x = 25
	joystickRight.y = 700

	joystickBottom = display.newImageRect(uiGroup, "joystick.png", 400, 400)
	physics.addBody( joystickBottom, {bounce = 0, isSensor = true} )
	joystickBottom.x = -75
	joystickBottom.y = 800

	joystickPad = display.newImageRect(uiGroup, objectSheet, 6, 125, 125)
	physics.addBody( joystickPad, { bounce = 0, isSensor = true } )
	joystickPad.xScale = .75
	joystickPad.yScale = .75
	joystickPad.x = -207.5
	joystickPad.y = 580

	-- score Text 
	scoreText = display.newText(uiGroup, "Score "..score, 500, 80, native.systemFont, 36)
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
		transition.to(sandstorm, {alpha=1, time=3000,
			onComplete = function()
				sandstorm.isBodyActive = true
			end
		} )	
	
	end

	-- Sensor type the sandstorm
	-- physics.addBody(sandstorm, {radius = 30, isSensor = true})
	sandstorm.myName = "self"


	-- Event listener for dragSelf func
	sandstorm:addEventListener("touch", dragSelf)
	-- Runtime:addEventListener("collision", joystickTopMove)
	-- Runtime:addEventListener("collision", joystickLeftMove)
	-- Runtime:addEventListener("collision", joystickRightMove)
	-- Runtime:addEventListener("collision", joystickBottomMove)

	joystickPad:addEventListener("touch", joystickPadMove)
	-- joystickPad:addEventListener("collision", joystickCollision)
	
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
	-- gameLoop -- deletes enemy too
	local function gameLoop()
		for i = #enemyTable, 1, -1 do
			local enemyS = scoreTable[i]
			local deleteEnemy = enemyTable[i]
			local enemyRealSize = 1 + math.log(enemyS)
				
			if 
				deleteEnemy.x < -500 or deleteEnemy.x > display.contentWidth + 500 or
				deleteEnemy.y < -100 or
				deleteEnemy.y > display.contentHeight + 100
			then 
				display.remove(deleteEnemy)
				table.remove(enemyTable, i)
				table.remove(scoreTable, i)
			elseif
				sandstorm.x -(30 * size) <= deleteEnemy.x and sandstorm.x + (40 * size) >= deleteEnemy.x and 
				sandstorm.y -(30 * size) <= deleteEnemy.y and sandstorm.y + (40 * size) >= deleteEnemy.y and
				1 + math.log(enemyS) <= size 
			then 
				-- delete enemy
				display.remove(deleteEnemy) -- deletes enemy
				table.remove(enemyTable, i) 
				table.remove(scoreTable, i)
				-- updates score and size
				score = score + (enemyS * 2)
				size = (1 + (math.log(score) / 2))
				updateText()
				grow()
				-- print("test")
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
			end
		end
		for n = #robotTable, 1, -1 do
			local deleteRobot = robotTable[n]
			local robotS = robotSizeTable[n]

			if 
				sandstorm.x - (30 * size) <= deleteRobot.x and sandstorm.x + (30 * size) >= deleteRobot.x and
				sandstorm.y - (30 * size) <= deleteRobot.y and sandstorm.y + (30 * size) >= deleteRobot.y
			then
				display.remove(deleteRobot)
				table.remove(robotTable, n)
				table.remove(robotSizeTable, n)
				score = score + robotS
				size = (1 + (math.log(score) / 2))
				updateText()
				grow()
			end
		end
	end


	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)
		-- timer.resume(gameLoopTimer)
		-- timer.resume(spawnTimer)
		-- timer.resume(robotTimer)
	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		physics.start()
		-- game timer
		gameLoopTimer = timer.performWithDelay(100, gameLoop, 0)
		-- spawn timer
		spawnTimer = timer.performWithDelay(500, spawnEnemy, 0)
		robotTimer = timer.performWithDelay(500, spawnRobots, 0)
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
		timer.cancel(robotTimer)

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
