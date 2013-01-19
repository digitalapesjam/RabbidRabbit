local touchOffsetX, touchOffsetY = 0,0

local LABEL_PULLED,LABEL_MOVING,LABEL_REST = 0,1,2
local labelStatus=LABEL_REST

local label,avatar

local function onLabelTouch( event )
    
    if event.phase == "began" then
        touchOffsetX = event.x-event.target.x
        touchOffsetY = event.y-event.target.y
        labelStatus = LABEL_PULLED
    elseif event.phase == "ended" then
        touchOffsetX, touchOffsetY = 0,0
        labelStatus=LABEL_MOVING
    else
      event.target.x, event.target.y = event.x-touchOffsetX, event.y-touchOffsetY
     end
    return true
end

local function updateAvatarState()
    if (labelStatus == LABEL_REST) then
      label.x = avatar.x-20
      label.y = avatar.y
    end
    
    -- if (labelStatus == LABEL_MOVING
    
    
    return true
end

function createAvatar()
  
  
  local imSheet = graphics.newImageSheet( "Images/avatar.png",  { width = 512, height = 512, numFrames = 15} )  
  avatar = display.newSprite( imSheet, { start=1, count=15} )
  avatar:play()  
  avatar.x,avatar.y = halfW,screenH-200
  label = display.newCircle(avatar.x,avatar.y ,75)
  
  
  label:addEventListener( "touch", onLabelTouch )
  physics.addBody( avatar, { density=1.0, friction=0.3, bounce=0.0, shape={-200,-200,200,-200,200,200,-200,200} } )
  
  
  Runtime:addEventListener( "enterFrame", updateAvatarState )
  return avatar 
end