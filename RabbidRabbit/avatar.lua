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
    print("some touch event")
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
  avatar.x,avatar.y = halfW,screenH-200
  label = display.newCircle(avatar.x,avatar.y ,75)
  label.alpha = 0.4
  
  
  label:addEventListener( "touch", onLabelTouch )
  physics.addBody( avatar, { density=1.0, friction=0.3, bounce=0.0, shape={-200,-200,200,-200,200,200,-200,200} } )
  
  
  Runtime:addEventListener( "enterFrame", updateAvatarState )
  return avatar 
end