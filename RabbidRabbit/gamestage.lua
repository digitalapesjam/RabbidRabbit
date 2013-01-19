storyboard = require( "storyboard" )
scene = storyboard.newScene()

-- include Corona's "physics" library
physics = require "physics"
physics.start(); physics.pause()

-- Include game components
require "avatar"

-- forward declarations and other locals
screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5

function scene:createScene( event )
	local group = self.view

  -- background
	local background = display.newImageRect( "Images/stagebg.jpg", display.contentWidth, display.contentHeight )
  background:setReferencePoint( display.TopLeftReferencePoint )
	background.x, background.y = 0, 0
  
  -- avatar
  local av = createAvatar()
  
  -- ground level
  local ground = display.newRect(0,display.contentHeight-50,screenW,50)
  ground:setFillColor( 20 )
  ground.alpha = 0.1
	physics.addBody( ground, "static", { friction=0.3} )
	
	-- all display objects must be inserted into group
	group:insert( background )
	group:insert( ground)
	group:insert( av )
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	physics.start()
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	physics.stop()
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
	local group = self.view
	
	package.loaded[physics] = nil
	physics = nil
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