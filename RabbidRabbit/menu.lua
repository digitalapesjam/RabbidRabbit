-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

-- include Corona's "widget" library
local widget = require "widget"

--------------------------------------------

-- forward declarations and other locals
local group

-- 'onRelease' event listener for playBtn
local function onPlayBtnRelease()
	
	-- go to level1.lua scene
	storyboard.gotoScene( "intro", "fade", 500 )
	
	return true	-- indicates successful touch
end

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
-- 
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
-- 
-----------------------------------------------------------------------------------------

local function createButton(text,x,y,width,height) 
      button = display.newRoundedRect(x,y,width,height,20)
    button.alpha = 0.8
    group:insert(button)
    
    local myText = display.newEmbossedText(text, x, y+(height/2), native.systemFontBold, 50)
    myText:setReferencePoint(display.CenterReferencePoint)
    myText:setTextColor(0, 0, 0)
    myText.x=x+width/2
    myText.y=y+height/2
    
    group:insert(myText)
    return button
end

local function playFunction()
  storyboard.gotoScene("gamestage",{effect="fade",time=200,params={toysNumber=3,interval=2000}})
end


local function updateAnimations()
  
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
	group = self.view

	-- display a background image
	local background = display.newImageRect( "Images/menubg.png", display.contentWidth, display.contentHeight )
	background:setReferencePoint( display.TopLeftReferencePoint )
	background.x, background.y = 0, 0
  group:insert( background )
	
  playBtn = createButton("Play",display.contentWidth*0.75-300,display.contentHeight/2 + 100,400,500)
	
  playBtn:addEventListener( "touch", playFunction )
  Runtime:addEventListener( "enterFrame", updateAnimations )
--	group:insert( titleLogo )
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
	local group = self.view
	
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