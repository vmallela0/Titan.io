
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

--game objects
local rover
local cargo
local sandstorm
local gameLoopTimer
local spawnTimer
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
	local enemyStorm = display.newImageRect(mainGroup, objectSheet, 4, 70, 70)
	-- moves to back
	enemyStorm:toBack()
	-- enemy table for deletion
	table.insert(enemyTable, enemyStorm)
	--name
	enemyStorm.myName = "enemy"
	-- random score/ size of enemy
	enemyScore = math.random(1, 15)
	-- score table for later
	table.insert(scoreTable, enemyScore)
	enemySize = 1 + math.log(enemyScore)
	-- increase size according to enemyScore
	enemyStorm.xScale = enemySize
	enemyStorm.yScale = enemySize
	-- we need to scale ALL numbers to the screen size. We need to have flexibility in platforms. 
	enemyStorm.x = math.random(0, display.contentWidth)
	enemyStorm.y = math.random(0, display.contentHeight)
	physics.addBody(enemyStorm, "dynamic", { radius = 35, bounce = 0.8})
	-- random path
	enemyStorm:setLinearVelocity(math.random(-200, 200), math.random(-200, 200))
	-- applies rotation
	enemyStorm:applyTorque(10)
		-- enemyCount=enemyCount+1
	-- end
end

--make sandstorm's radius applicable
--function sandstorm()
	--sandstorm.scale(radius)
	--if ((sandstorm.x + 2 >= enemy.x) or (sandstorm.x - 2 >= enemy.x) and ((sandstorm.y + 2 >= enemy.y) or (sandstorm.y - 2 <= enemy.y))
--end

--following is spawn cargo, idk when to use it:
-- local cargo = display.newImageRect(mainGroup, objectSheet, 2, 87, 87)
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
		-- local forceScale = .1
		-- sandstorm:applyForce(fx * forceScale, fy * forceScale, sandstorm.x, sandstorm.y)
	elseif("ended" == phase or "cancelled" == phase) then 
		display.currentStage:setFocus(nil)
	end
	return true
end

local function endGame()
	composer.gotoScene("menu")
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
	local joystick = display.newImageRect(uiGroup, "joystick.png", 500, 500)
	joystick.x = -150
	joystick.y = 800

	-- score Text 
	scoreText = display.newText(uiGroup, "Score "..score, 500, 80, native.systemFont, 36)
	scoreText:setFillColor(0, 0, 0)

	-- spawn self
	sandstorm = display.newImageRect(mainGroup, objectSheet, 3, 70, 70)
	sandstorm.x = display.contentCenterX 
	sandstorm.y = display.contentCenterY
	physics.addBody(sandstorm, "dynamic", { radius = 35, bounce = 0, isSensor = true})
	sandstorm:applyTorque(-15)

	local function spawnSelf()
		sandstorm.isBodyActive = false
		sandstorm.x = display.contentCenterX
		sandstorm.y = display.contentCenterY

		-- fade in ship when spawned
		transition.to(sandstorm, {alpha=1, time=3000,
			onComplete = function()
				sandstorm.isBodyActive = true
				endGame = false
			end
		} )	
	end

	-- Sensor type the sandstorm
	-- physics.addBody(sandstorm, {radius = 30, isSensor = true})
	sandstorm.myName = "self"


	-- Event listener for dragSelf func
	sandstorm:addEventListener("touch", dragSelf)
	
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
				
			if 
				deleteEnemy.x < -100 or deleteEnemy.x > display.contentWidth + 100 or
				deleteEnemy.y < -100 or
				deleteEnemy.y > display.contentHeight + 100
			then 
				display.remove(deleteEnemy)
				table.remove(enemyTable, i)
				table.remove(scoreTable, i)
			elseif
				deleteEnemy.x -(40 * size) <= sandstorm.x and deleteEnemy.x + (40 * size) >= sandstorm.x and 
				deleteEnemy.y -(40 * size) <= sandstorm.y and deleteEnemy.y + (40 * size) >= sandstorm.y and
				1 + math.log(enemyS) <= size 
			then 
				-- delete enemy
				display.remove(deleteEnemy) -- deletes enemy
				table.remove(enemyTable, i) 
				table.remove(scoreTable, i)
				-- updates score and size
				score = score + enemyS
				size = (1 + (math.log(score) / 2))
				updateText()
				grow()
				-- print("test")
			elseif
				-- touches but size bigger (enemy eat)
				deleteEnemy.x -(40 * size) <= sandstorm.x and deleteEnemy.x + (40 * size) >= sandstorm.x and 
				deleteEnemy.y -(40 * size) <= sandstorm.y and deleteEnemy.y + (40 * size) >= sandstorm.y and
				1 + math.log(enemyS) > size 
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
		spawnTimer = timer.performWithDelay(500, spawnEnemy, 0)
	end
end


-- hide() event -----------------------------------------------------------------------------------------------------------------
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
		timer.pause(gameLoopTimer)
		timer.pause(spawnTimer)
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
