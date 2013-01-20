-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local group = nil

-- include Corona's "widget" library
local widget = require "widget"

--------------------------------------------

-- forward declarations and other locals
local playBtn

-- 'onRelease' event listener for playBtn
local function onPlayBtnRelease()
	
	-- go to level1.lua scene
	storyboard.gotoScene( "gamestage", {
		effect = "fade", time = 500, {currentLevel = 1}
} )
	-- storyboard.gotoScene( "gamestage", "fade", 500, { currentLevel = 0 } )
	
	return true	-- indicates successful touch
end

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------

local function loadBg(name)
	local mybg = display.newImageRect( "Images/intro/" .. name .. ".png", display.contentWidth, display.contentHeight )
	mybg:setReferencePoint( display.TopLeftReferencePoint )
	mybg.x, mybg.y = 0, 0
	mybg.isVisible = false
	group:insert(mybg)
	return mybg
end

-- local bombChannel

local function gotoPlay(_ev)
	storyboard.gotoScene( "gamestage", {
		effect = "fade", time = 500, params = {toysNumber=1,interval=2000}
	} )
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
	group = self.view

	local bg1 = loadBg( "1_group_photo" )
	local bg2 = loadBg( "2_sadness" )
	local bg3 = loadBg( "3_buy_tnt" )
	local bg4 = loadBg( "4_diabolical_1" )
	local bg5 = loadBg( "5_diabolical_2" )
	local bg6 = loadBg( "6_diabolical_3" )
	local bg7 = loadBg( "7_diabolical_4" )
	local bg8 = loadBg( "8_explosion" )

	local group = audio.loadSound("Audio/intro/group_happy.mp3")
	local laugh = audio.loadSound("Audio/intro/laugh.mp3")
	local bomb = audio.loadSound("Audio/intro/explosion.mp3")


	bg1.isVisible = true
	audio.play(group, {loops=0})
	transition.dissolve(bg1, bg2, 500, 2000)
	timer.performWithDelay(2500, function (ev) transition.dissolve(bg2,bg3,500, 2000) end, 1)
	timer.performWithDelay(5000, function (ev) transition.dissolve(bg3,bg4,250, 1500) end, 1)
	timer.performWithDelay(6750, function (ev) transition.dissolve(bg4,bg5,250, 1000) end, 1)
	timer.performWithDelay(8000, function (ev) 
		audio.play(laugh, {loops=0})
		transition.dissolve(bg5,bg6,250, 1000) end, 1)
	timer.performWithDelay(9250, function (ev) transition.dissolve(bg6,bg7,250, 1000) end, 1)
	timer.performWithDelay(10500, function (ev) 
		audio.play(bomb, {loops=0})
		transition.dissolve(bg7,bg8,250, 1000) end, 1)
	timer.performWithDelay(15000, gotoPlay, 1)


	
	-- -- display a background image
	-- local background = display.newImageRect( "background.jpg", display.contentWidth, display.contentHeight )
	-- background:setReferencePoint( display.TopLeftReferencePoint )
	-- background.x, background.y = 0, 0
	
	-- -- create/position logo/title image on upper-half of the screen
	-- local titleLogo = display.newImageRect( "logo.png", 264, 42 )
	-- titleLogo:setReferencePoint( display.CenterReferencePoint )
	-- titleLogo.x = display.contentWidth * 0.5
	-- titleLogo.y = 100
	
	-- -- create a widget button (which will loads level1.lua on release)
	-- playBtn = widget.newButton{
	-- 	label="Play Now",
	-- 	labelColor = { default={255}, over={128} },
	-- 	default="button.png",
	-- 	over="button-over.png",
	-- 	width=154, height=40,
	-- 	onRelease = onPlayBtnRelease	-- event listener function
	-- }
	-- playBtn:setReferencePoint( display.CenterReferencePoint )
	-- playBtn.x = display.contentWidth*0.5
	-- playBtn.y = display.contentHeight - 125
	
	-- -- all display objects must be inserted into group
	-- group:insert( background )
	-- group:insert( titleLogo )
	-- group:insert( playBtn )
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	
	-- INSERT code here (e.g. start timers, load audio, start listeners, etc.)
	
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	
	-- INSERT code here (e.g. stop timers, remove listenets, unload sounds, etc.)
	
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
	--local group = self.view
	group:removeSelf()
	if playBtn then
		playBtn:removeSelf()	-- widgets must be manually removed
		playBtn = nil
	end
end

-----------------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
-----------------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched whenever before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

-----------------------------------------------------------------------------------------

return scene