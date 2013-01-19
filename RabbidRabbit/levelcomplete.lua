storyboard = require( "storyboard" )
scene = storyboard.newScene()

local prevLevelDescription
local prevPlayerPerformance
local group

local function drawScore(label,score, x , y, width, height)
    local myText = display.newText(label, x, y, native.systemFont, 90 )
    myText:setTextColor(255, 255, 255)
    
  
  	for i = 1,100,25 do
    local star
      if score >= i then
        star = display.newImage("Images/star_on.png")
      else
        star = display.newImage("Images/star_off.png")
      end
      star.width=width
      star.height=height
      star.x = x+star.width*i/25
      star.y=y
      group:insert(star)
    end

  --group:insert(mytext)
  return true
end


function scene:createScene( event )
	group = self.view
  prevPlayerPerformance = event.params.playerPerformance
  prevLevelDescription = event.params.levelDescription
  
  local style = 50
  local skill = 50
  
  
  drawScore("Style",style,screenW/4,400,100,100)
  drawScore("Skill",skill,2.5*screenW/4,400,100,100)
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	--storyboard.gotoScene( "gamestage", {params = {currentLevel = nextLevel}} )
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
	local group = self.view
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