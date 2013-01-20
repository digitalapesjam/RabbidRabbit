storyboard = require( "storyboard" )
scene = storyboard.newScene()

local prevLevelDescription
local prevPlayerPerformance
local group

local quit,continue,styleText,skillText,scoreText,gameOverText

local function drawScore(label,score, x , y)
    local myText = display.newEmbossedText(label, x, y, native.systemFontBold, 90 )
    myText:setReferencePoint(display.CenterReferencePoint)
    myText:setTextColor(255, 255, 255)
    myText.x=x
    myText.y=y
    
    list = {myText}
  
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
      list[#list+1] = star
    end

  group:insert(myText)
  return list
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
    return {button,myText}
end

local function continueFunction(event) 
    storyboard.gotoScene( "gamestage", {effect = "fade", time = 200,params={toysNumber=1,interval=2000}} )
end

local function quitFunction(event) 
  if event.phase == "ended" then
    storyboard.gotoScene( "menu", {effect = "fade", time = 200})
  end
end

local function displayToys()
  
end

local function removeScore()
    if not (continue == nil) then 
      continue[1]:removeEventListener( "touch", continueFunction )
      for i,n in pairs(continue) do 
        n:removeSelf()
      end
    end
    
    if not (quit == nil) then 
      quit[1]:removeEventListener( "touch", quitFunction )
      for i,n in pairs(quit) do 
        n:removeSelf()
      end
    end
   
    if not (skillText == nil) then 
      for i,n in pairs(skillText) do 
        n:removeSelf()
      end
    end
    
    if not (styleText == nil) then 
      for i,n in pairs(styleText) do 
        n:removeSelf()
      end
    end
    
    if not (gameOverText == nill) then
      gameOverText:removeSelf()
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
  group = self.view
  
  prevPlayerPerformance = event.params.playerPerformance
  prevLevelDescription = event.params.levelDescription
  
  
  local total = 0
  for i,n in pairs(prevLevelDescription) do
      total = total + n
  end
  
  local entropy = 0
  for i,n in pairs(prevPlayerPerformance) do
    
      if not (n.head == n.torso) then
        entropy = entropy + 33.4
      end
      
      if not (n.torso == n.legs) then
        entropy = entropy + 33.4
      end
      
      if not (n.legs == n.head) then
        entropy = entropy + 33.4
      end
  end

  local style = entropy/#prevPlayerPerformance
  local skill = 100*#prevPlayerPerformance/total
  print("Style:"..style..", "..#prevPlayerPerformance)
  print("Skill:"..skill..", "..total)
  

  if skill > 0 then    
    styleText = drawScore("Style",style,0.9*screenW/3,300)
    skillText = drawScore("Skill",skill,2.1*screenW/3,300)
       
    continue = createButton("Continue",1550,950,300,200)
    quit = createButton("Quit",1550,1200,300,200)
    
    continue[1]:addEventListener( "touch", continueFunction )
    quit[1]:addEventListener( "touch", quitFunction )
    
    displayToys()
  else
    gameOverText = display.newEmbossedText("Game Over!", 1024, 300, native.systemFontBold, 180 )
    gameOverText:setReferencePoint(display.CenterReferencePoint)
    gameOverText:setTextColor(255, 255, 255)
    gameOverText.x=1024
    gameOverText.y=300
    
    continue = createButton("Retry",850,950,300,200)
    quit = createButton("Quit",850,1200,300,200)
    
    continue[1]:addEventListener( "touch", continueFunction )
    quit[1]:addEventListener( "touch", quitFunction )
  end
  
  storyboard.removeScene("gamestage")
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )    
  removeScore()
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