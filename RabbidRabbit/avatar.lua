local touchOffsetX, touchOffsetY = 0,0

local tab_PULLING,tab_LEFT,MOVING,REST = 0,1,2
local status=tab_REST

local motionBegin, motionDuration, motionTarget, motiontabInitPosX,motiontabInitPosY = 0;

local avatarSpeed=0.3

local tab,avatar,line

local pullSound,pullSoundChannel,music,musciChannel,steps,stepsChannel

local group

 local function releaseTab()
    touchOffsetX, touchOffsetY = 0,0
    status=tab_LEFT
    audio.stop(pullSoundChannel)
 end

local function ontabTouch( event )
    if event.phase == "began" then
        touchOffsetX = event.x-event.target.x
        touchOffsetY = event.y-event.target.y
        status = tab_PULLING
        pullSoundChannel = audio.play(pullSound)
    elseif event.phase == "ended" then
        releaseTab()
    else
      event.target.x, event.target.y = event.x-touchOffsetX, event.y-touchOffsetY
     end
    return true
end

local function resetRelease( event) 
      if event.phase == "ended" and not (status == REST) then
        releaseTab()
      end
      return true
 end 

 
 local function stopAnimation( event )
    status=REST
    avatar:setSequence("catch")
    avatar:play()
    audio.stop(stepsChannel)
end

local function tabXRestPosition()
    return avatar.x-150*avatar.xScale
end

local function tabYRestPosition()
    return avatar.y-100
end

local function updateAvatarState()
    if status == REST then
      if not stepsChannel == nil then
        audio.stop(stepsChannel)
      end
      tab.x = tabXRestPosition()
      tab.y = tabYRestPosition()+10*math.sin(system.getTimer()/150)
    end
    
    if status == tab_LEFT then
       motiontabInitPosX,motiontabInitPosY = tab.x,tab.y
       avatar.xScale = -(avatar.x-tab.x)/math.abs(avatar.x-tab.x)
       
       distance = math.abs(avatar.x-tab.x)
       motionTarget = tab.x
       
      if motionTarget < 128 then
        motionTarget = 128
      end
        
      if  motionTarget > screenW-128 then
        motionTarget = screenW-128
      end
      
      motionDuration = 1000 * distance/(screenW*avatarSpeed)
      transition.to(avatar, {time=motionDuration, x=motionTarget, onComplete=stopAnimation, transition=easing.linear})
      motionBegin = system.getTimer()
      status=MOVING
      avatar:setSequence("walk")
      avatar:play()
      stepsChannel = audio.play(steps,{loops=-1})
    end
    
    if status == MOVING then
      local animationState = 1-((system.getTimer()-motionBegin)/motionDuration)
      tab.y = tabYRestPosition() + (motiontabInitPosY-tabYRestPosition())*animationState
      tab.x = tabXRestPosition() + (motiontabInitPosX-tabXRestPosition())*animationState
    end
    
    if not (line == nil) then
      line:removeSelf()
    end
    
    local direction = 1
    local modifier = 50
    if avatar.x < tab.x then
      direction=-1
    end
    
 
    line = display.newLine(avatar.x-modifier*direction*0.5,avatar.y,tab.x+modifier*direction,tab.y+modifier)
    line:setColor(0, 0, 0, 128)
    line.width = 10
    avatar:toFront()
    
    return true
end

local function createSensor(avatar, group)
  physics = require "physics"
  local sensor = display.newRect(avatar.x, avatar.y - (avatar.height/2) - 40, avatar.width, 10)
  sensor.alpha = 0
  sensor.myName = "rabbitSensor"
  local function updateSensor(_ev)
    sensor.x = avatar.x
  end
  physics.addBody(sensor, "kinematic", {isSensor = true})
  Runtime:addEventListener( "enterFrame", updateSensor )
end

function createAvatar(grp)
 
  group = grp

  local imSheet = graphics.newImageSheet( "Images/stand_bring_walk_492.png",  { width = 284, height = 492, numFrames = 10} )  
  local avatarAnimationSequence = {
    { name = "stand", start = 1, count = 1 },
    { name = "catch", start = 2, count = 1 },
    { name = "walk",start = 3, count = 8, time = 700 }
  }
  
  avatar = display.newSprite( imSheet, avatarAnimationSequence )
  avatar.myName = "rabbit"
  avatar:play()  
  avatar.x,avatar.y = halfW,screenH-260
  
  steps = audio.loadSound("Audio/steps.mp3")
  pullSound = audio.loadSound("Audio/pull.mp3")
  music = audio.loadSound("Audio/soundtrack.mp3")
  --musicChannel = audio.play(music,{loops=-1,fadein=5000})
  
  tab = display.newImage("Images/thering.png")
  tab.xScale,tab.yScale=0.3,0.3
  
  physics.addBody( avatar, { density=1.0, friction=0.3, bounce=0.0, shape={-128,-246,128,-246,128,246,-128,246} } )
  
  tab:addEventListener( "touch", ontabTouch )
  Runtime:addEventListener( "enterFrame", updateAvatarState )
  Runtime:addEventListener( "touch", resetRelease ) 

  createSensor(avatar, group)
  group:insert(tab)
  group:insert(avatar)
  return true 
end