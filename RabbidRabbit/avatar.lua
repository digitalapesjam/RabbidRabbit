local touchOffsetX, touchOffsetY = 0,0

local tab_PULLING,tab_LEFT,MOVING,REST = 0,1,2
local status=tab_REST

local motionBegin, motionDuration, motionTarget, motiontabInitPosX,motiontabInitPosY = 0;

local avatarSpeed=0.5

local tab,avatar

local function ontabTouch( event )
    if event.phase == "began" then
        touchOffsetX = event.x-event.target.x
        touchOffsetY = event.y-event.target.y
        status = tab_PULLING
    elseif event.phase == "ended" then
        touchOffsetX, touchOffsetY = 0,0
        status=tab_LEFT
    else
      event.target.x, event.target.y = event.x-touchOffsetX, event.y-touchOffsetY
     end
    return true
end

local function resetRelease( event) 
      if event.phase == "ended" and not (status == REST) then
        touchOffsetX, touchOffsetY = 0,0
        status=tab_LEFT
      end
      return true
 end 
 
 local function stopAnimation( event )
    status=REST
end

local function tabXRestPosition()
    return avatar.x-150*avatar.xScale
end

local function tabYRestPosition()
    return avatar.y-100
end

local function updateAvatarState()
    if status == REST then
      tab.x = tabXRestPosition()
      tab.y = tabYRestPosition()
    end
    
    if status == tab_LEFT then
      motiontabInitPosX,motiontabInitPosY = tab.x,tab.y
      
      
      avatar.xScale = (avatar.x-tab.x)/math.abs(avatar.x-tab.x)
      
      distance = math.sqrt(math.pow(avatar.x-tab.x,2)+math.pow(avatar.y-tab.y,2))
      
      motionTarget = avatar.x+avatar.xScale*distance
      
      motionDuration = 1000 * distance/(screenW*avatarSpeed)
      
      transition.to(avatar, {motionDuration, x=motionTarget})
      timer.performWithDelay( motionDuration, stopAnimation)
      motionBegin = system.getTimer()
      status=MOVING
    end
    
    if status == MOVING then
     
      local animationState = 1-((system.getTimer()-motionBegin)/motionDuration)
      tab.y = tabYRestPosition() + (motiontabInitPosY-tabYRestPosition())*animationState
      tab.x = tabXRestPosition() + (motiontabInitPosX-tabXRestPosition())*animationState
    end
    
    return true
end

function createAvatar()

  local imSheet = graphics.newImageSheet( "Images/walk_strip_512.png",  { width = 284, height = 512, numFrames = 8} )  
  local walkRightSeqData = 
  {
    name = "walk_right",
    start = 1,
    count = 8,
    time = 700
  }
  avatar = display.newSprite( imSheet, walkRightSeqData )
  avatar:play()  
  avatar.x,avatar.y = halfW,screenH-260
  tab = display.newCircle(avatar.x,avatar.y ,75)
  tab.alpha = 0.1
  
  physics.addBody( avatar, { density=1.0, friction=0.3, bounce=0.0, shape={-256,-256,256,-256,256,256,-256,256} } )
  
  tab:addEventListener( "touch", ontabTouch )
  Runtime:addEventListener( "enterFrame", updateAvatarState )
  Runtime:addEventListener( "touch", resetRelease ) 
  return avatar 
end