local touchOffsetX, touchOffsetY = 0,0

local tab_PULLING,tab_LEFT,MOVING,REST = 0,1,2
local status=tab_REST
local direction = 1

local motionBegin, motionDuration, motionTarget, motiontabInitPosX,motiontabInitPosY = 0;

local avatarSpeed=1

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

local function updateAvatarState()
    if status == REST then
      tab.x = avatar.x-20
      tab.y = avatar.y
    end
    
    if status == tab_LEFT then
      motiontabInitPosX,motiontabInitPosY = tab.x,tab.y
      
      
      direction = (avatar.x-tab.x)/math.abs(avatar.x-tab.x)
      
      distance = math.sqrt(math.pow(avatar.x-tab.x,2)+math.pow(avatar.y-tab.y,2))
      
      motionTarget = avatar.x+direction*distance
      
      motionDuration = 1000 * distance/(screenW*avatarSpeed)
      
      transition.to(avatar, {motionDuration, x=motionTarget})
      timer.performWithDelay( motionDuration, stopAnimation)
      motionBegin = system.getTimer()
      status=MOVING
      print("transition")
    end
    
    if status == MOVING then
     
      local animationState = 1-((system.getTimer()-motionBegin)/motionDuration)
      tab.y = avatar.y + (motiontabInitPosY-avatar.y)*animationState
      tab.x = avatar.x + (motiontabInitPosX-avatar.x)*animationState
      print(animationState)
    end

    return true
end

function createAvatar()
  
  local imSheet = graphics.newImageSheet( "Images/avatar.png",  { width = 512, height = 512, numFrames = 15} )  
  avatar = display.newSprite( imSheet, { start=1, count=15} )
  avatar:play()  
  avatar.x,avatar.y = halfW,screenH-200
  tab = display.newCircle(avatar.x,avatar.y ,75)
  
  physics.addBody( avatar, { density=1.0, friction=0.3, bounce=0.0, shape={-200,-200,200,-200,200,200,-200,200} } )
  
  tab:addEventListener( "touch", ontabTouch )
  Runtime:addEventListener( "enterFrame", updateAvatarState )
  Runtime:addEventListener( "touch", resetRelease ) 
  return avatar 
end