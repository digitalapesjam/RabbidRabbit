storyboard = require( "storyboard" )
scene = storyboard.newScene()

-- include Corona's "physics" library
physics = require "physics"
physics.start(); physics.pause()

-- Include game components
require "level"
require "avatar"


-- forward declarations and other locals
screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5

function scene:createScene( event )
	local group = self.view
	physics.setDrawMode("hybrid")	

  -- background
	local background = display.newImageRect( "Images/stagebg.jpg", display.contentWidth, display.contentHeight )
  background:setReferencePoint( display.TopLeftReferencePoint )
	background.x, background.y = 0, 0
  group:insert( background )
  
  -- avatar
  createAvatar(group)

  -- walls
  local function addWall(name, x,y, w,h)
  	local wall = display.newRect(x,y, w,h)
  	wall:setFillColor(20)
  	wall.myName = name
  	wall.alpha = 0.1
  	physics.addBody(wall, "static", {friction = 0.3})
  	group:insert(wall)
  end
  

	addWall("ground", 0,display.contentHeight-50, screenW,50)
	addWall("ceiling", 0,0, screenW,20)
	addWall("left", 0,0, 20,screenH)
	addWall("right", display.contentWidth-20,0, 20,screenH)

  	local pieces = createLevel(5, 1000, group);
	setLevelCompleteListener( scene );

	-- for _j,piece in pairs(pieces) do
	-- 	physics.addBody(piece.shape, "dynamic", piece.physics)
	-- end
  
  -- clearLevelTimer()
  -- scene:onLevelComplete(nil,nil)
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
	destroyAvatar()
	clearLevel()
	physics.stop()
	package.loaded[physics] = nil
	physics = nil
end

function scene:onLevelComplete(levDesc, playerPerf)
	storyboard.gotoScene ( "levelcomplete", {
		effect = "fade", time = 200,
		params = {
			levelDecription = levelDesc,
      playerPerformance = playerPerf
		}
	} )
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