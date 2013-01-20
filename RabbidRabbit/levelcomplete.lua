storyboard = require( "storyboard" )
scene = storyboard.newScene()

local prevLevelDescription
local prevPlayerPerformance
local group

local function drawScore(label,score, x , y)
    local myText = display.newEmbossedText(label, x, y, native.systemFontBold, 90 )
    myText:setReferencePoint(display.CenterReferencePoint)
    myText:setTextColor(255, 255, 255)
    myText.x=x
    myText.y=y
    
  
  	for i = 25,100,25 do
      local star
      if score >= i then
        star = display.newImage("Images/star_on.png")
      else
        star = display.newImage("Images/star_off.png")
      end
      star.width=150
      star.height=150
      star.x = x-240+star.width*(i-25)/25
      star.y=y+200
      group:insert(star)
    end

  group:insert(myText)
  return true
end

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

local function displayToys()
  
end

local function removeToys()
  
end

local function continueFunction(event) 
    storyboard.gotoScene( "gamestage", {effect = "fade", time = 200} )
end

local function quitFunction(event) 
  if event.phase == "ended" then
    storyboard.gotoScene( "menu", {effect = "fade", time = 200})
  end
end


function scene:createScene( event )
	group = self.view
  
  local background = display.newImageRect( "Images/scorebg.png", display.contentWidth, display.contentHeight )
  background:setReferencePoint( display.TopLeftReferencePoint )
  background.x, background.y = 0, 0
  group:insert( background )
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
  
  
  prevPlayerPerformance = event.params.playerPerformance
  prevLevelDescription = event.params.levelDescription
  
  
  local total = 0
  for i,n in pairs(prevLevelDescription) do
      total = total + n
  end

  local style = 50
  local skill = #prevPlayerPerformance*100/total
  print("Performance:"..#prevPlayerPerformance..", "..total)
  
  local gameover=false
  
  if not gameover then    
    drawScore("Style",style,0.9*screenW/3,300)
    drawScore("Skill",skill,2.1*screenW/3,300)
       
    continue = createButton("Continue",1550,950,300,200)
    quit = createButton("Quit",1550,1200,300,200)
    
    continue:addEventListener( "touch", continueFunction )
    quit:addEventListener( "touch", quitFunction )
    
    displayToys()
  end
  
	local group = self.view
  storyboard.removeScene("gamestage")
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
  continue:removeSelf()
  quit:removeSelf()
  removeToys()
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