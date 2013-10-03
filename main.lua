-- Air Hockey Game
-- Developed by Carlos Yanez

-- Hide Status Bar

display.setStatusBar(display.HiddenStatusBar)

-- Physics

local physics = require('physics')
physics.start()
physics.setGravity(0, 0)
--physics.setDrawMode('hybrid')

-- Drag Physics Body by Hental (http://www.coronalabs.com/blog/2010/11/01/tutorial-dragging-physics/)
local gameUI = require("gameUI")

-- Graphics

-- [Background]

local bg = display.newImage('bg.png')

-- [Title View]

local titleBg
local playBtn
local creditsBtn
local titleView

-- [Credits]

local creditsView

-- [Game Background]

local gameBg

-- [Walls]

local left
local right
local topLeft
local bottomLeft
local topRight
local bottomRight

-- [Puck]

local puck

-- [Paddles]

local player
local enemy

-- Scores

local playerScore
local enemyScore

-- Sounds

local bell = audio.loadSound('bell.caf')

-- Variables

local lastY
local timerSrc

-- Functions

local Main = {}
local startButtonListeners = {}
local showCredits = {}
local hideCredits = {}
local showGameView = {}
local gameListeners = {}
local moveEnemy = {}
local update = {}

-- Main Function

function Main()
	titleBg = display.newImage('title.png', display.contentCenterX - 143.5, 50)
	playBtn = display.newImage('playBtn.png', display.contentCenterX - 39.5, display.contentCenterY)
	creditsBtn = display.newImage('creditsBtn.png', display.contentCenterX - 40.5, display.contentCenterY + 65)
	titleView = display.newGroup(titleBg, playBtn, creditsBtn)
	
	startButtonListeners('add')
end

function startButtonListeners(action)
	if(action == 'add') then
		playBtn:addEventListener('tap', showGameView)
		creditsBtn:addEventListener('tap', showCredits)
	else
		playBtn:removeEventListener('tap', showGameView)
		creditsBtn:removeEventListener('tap', showCredits)
	end
end

function showCredits:tap(e)
	playBtn.isVisible = false
	creditsBtn.isVisible = false
	creditsView = display.newImage('credits.png', 0, display.contentHeight)
	
	lastY = titleBg.y
	transition.to(titleBg, {time = 300, y = (display.contentHeight * 0.5) - (titleBg.height + 50)})
	transition.to(creditsView, {time = 300, y = (display.contentHeight * 0.5) + 35, onComplete = function() creditsView:addEventListener('tap', hideCredits) end})
end

function hideCredits:tap(e)
	transition.to(creditsView, {time = 300, y = display.contentHeight + 25, onComplete = function() creditsBtn.isVisible = true playBtn.isVisible = true creditsView:removeEventListener('tap', hideCredits) display.remove(creditsView) creditsView = nil end})
	transition.to(titleBg, {time = 300, y = lastY});
end

function showGameView:tap(e)
	transition.to(titleView, {time = 300, x = -titleView.height, onComplete = function() startButtonListeners('rmv') display.remove(titleView) titleView = nil end})
	
	-- [Add GFX]
	
	-- Walls
	
	left = display.newLine(-1, display.contentHeight * 0.5, -1, display.contentHeight * 2)
	right = display.newLine(display.contentWidth+1, display.contentHeight * 0.5, display.contentWidth+1, display.contentHeight * 2)
	topLeft = display.newLine(0, -1, display.contentWidth - 120, -1)
	topRight = display.newLine(display.contentWidth, -1, display.contentWidth * 1.6, -1)
	bottomLeft = display.newLine(0, display.contentHeight, display.contentWidth - 120, display.contentHeight)
	bottomRight = display.newLine(display.contentWidth, display.contentHeight, display.contentWidth * 1.6, display.contentHeight)
	
	-- Game Bg
	
	gameBg = display.newImage('gameBg.png')
	
	-- Player
	
	player = display.newImage('paddle1.png', display.contentCenterX-25, display.contentHeight-100)
	
	-- Enemy
	
	enemy = display.newImage('paddle2.png', display.contentCenterX-25, 10)
	
	-- Scores
	
	enemyScore = display.newText('0', 289, 206, 'Courier-Bold', 20)
	enemyScore:setTextColor(227, 2, 2)
	
	playerScore = display.newText('0', 289, 240, 'Courier-Bold', 20)
	playerScore:setTextColor(227, 2, 2)
	
	-- Puck
	
	puck = display.newImage('puck.png', display.contentCenterX-20, display.contentCenterY-20)
	
	-- Set Physics
	
	physics.addBody(left, 'static')
	physics.addBody(right, 'static')
	physics.addBody(topLeft, 'static')
	physics.addBody(bottomLeft, 'static')
	physics.addBody(topRight, 'static')
	physics.addBody(bottomRight, 'static')
	
	physics.addBody(puck, 'dynamic', {radius = 20, bounce = 0.4})
	puck.isFixedRotation = true
	physics.addBody(player, 'dynamic', {radius = 25})
	physics.addBody(enemy, 'static', {radius = 25})
	
	gameListeners('add')
end

function dragBody(event)
	gameUI.dragBody( event, { maxForce=20000, frequency=10, dampingRatio=0.2, center=true } )
end

function gameListeners(action)
	if(action == 'add') then
		player:addEventListener('touch', dragBody)
		Runtime:addEventListener('enterFrame', update)
		timerSrc = timer.performWithDelay(100, moveEnemy, 0)
	else
		player:removeEventListener('touch', dragBody)
		Runtime:removeEventListener('enterFrame', update)
		timer.cancel(timerSrc)
		timerSrc = nil
	end
end

function moveEnemy(e)
	-- Move Enemy
	
	if(puck.y < display.contentHeight * 0.5) then
		transition.to(enemy, {time = 300, x = puck.x})
	end
end

function update()
	-- Score
	
	if(puck.y > display.contentHeight) then
		enemyScore.text = tostring(tonumber(enemyScore.text) + 1)
	elseif(puck.y < -5) then
		playerScore.text = tostring(tonumber(playerScore.text) + 1)
	end
	
	-- Reset Puck position
	
	if(puck.y > display.contentHeight or puck.y < -5) then
		puck.x = display.contentCenterX
		puck.y = display.contentCenterY
		puck.isAwake = false
		audio.play(bell)
	end
	
	-- Keep paddle on player side
	
	if(player.y < display.contentWidth - 60) then
		player.y = display.contentWidth - 60
	end
end

Main()