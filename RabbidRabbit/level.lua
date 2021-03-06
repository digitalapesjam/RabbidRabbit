require "util"

--local level = 0
local levelCompleteListener = nil
local movingPieces = {}
local capturedHistory = {}
local captured = { head = nil, torso = nil, legs = nil }
local piecesCheckTimer = nil
local generatedToys = {}
local interval = 0
local score=0, scoreText

function resetLevel()
	levelCompleteListener = nil
	movingPieces = {}
	capturedHistory = {}
	captured = {head = nil, torso = nil, legs = nil}
	piecesCheckTimer = nil
	generatedToys = {}
end
local function loadPiece(pieceType, pieceName, group)
	local path = "Images/pieces/" .. pieceType .. "_" .. pieceName .. ".png"
	local img = display.newImage( path )
	local w,h = img.width, img.height
	img:removeSelf()
	local piece = display.newImageRect( path, w/3, h/3 )
	piece.myName = pieceType .. pieceName
	piece.myPieceType = pieceType
	piece.myKind = pieceName
	piece.bounced = 0
	piece.rotation = math.random(0,360)
	group:insert(piece)
	return piece
end
local function createPiecesFor(pieceType, level, group)
	local head = loadPiece(pieceType, "head", group)
	local torso = loadPiece(pieceType, "torso", group)
	local legs = loadPiece(pieceType, "legs", group)

	head.x, head.y = math.random(0, display.contentWidth),	-200
	torso.x, torso.y = math.random(0, display.contentWidth),-200
	legs.x, legs.y = math.random(0, display.contentWidth),	-200

	head.maxBounceAllowed = 10 -- level
	torso.maxBounceAllowed = 10 -- level
	legs.maxBounceAllowed = 10 -- level
	
	headPhys = {
		friction = 0.01, bounce = 0.5,
		radius = head.width/2
	}
	torsoPhys = {friction = 0.01, bounce = 0.5}
	legsPhys = {
		friction = 0.01, bounce = 0.5
	}

	return {{shape=head, physics=headPhys}, {shape=torso, physics=torsoPhys}, {shape=legs, physics=legsPhys}}
end

local function checkCompleted()
	for _i,piece in pairs(movingPieces) do
		if not (piece == nil) then
			return false
		end
	end
	if not (levelCompleteListener == nil) then
		timer.cancel(piecesCheckTimer)
		print("Level completed. Captured history: " .. #capturedHistory)
		for i,c in pairs(capturedHistory) do
			print(i .. ")" .. c.head .. " - " .. c.torso .. " - " .. c.legs)
		end
		levelCompleteListener:onLevelComplete(generatedToys, capturedHistory, score)
		return true
	end
	return false
end

local function removeFromMoving( body, delete )
	if delete then
		local function removeBody(_ev)
			print("Removing " .. body.myName)
			body:removeSelf()
			
		end
		timer.performWithDelay(100, removeBody, 1)
	end
	for i,piece in pairs(movingPieces) do
		if (not (piece==nil)) then
			if piece.shape == body then
				movingPieces[i] = nil
				return
			end
		end
	end
end

function everySecond(event)
	--print("Check..")
	for i,piece in pairs(movingPieces) do
		if (not (piece == nil) and not (piece.shape.y == nil) and not (piece.shape.height == nil)) then
			local body = piece.shape
			if (body.y > display.contentHeight or body.y < -200) then
				body.y = 100
			end 
			--print(body.myName .. " y: " .. (display.contentHeight - body.y))
			if (not (body['getLinearVelocity']==nil)) then
				local vx,vy = body:getLinearVelocity()
				if body.y > 200 and math.abs(vx) <= 1 and math.abs(vy) <= 1 then
					body.isBodyActive = false
					removeFromMoving(body, true)
					checkCompleted()
				end
			end
		end
	end

	for i,piece in pairs(movingPieces) do
		if not (piece==nil) then
			print(i .. " is still alive " .. piece.shape.myName .. " - " .. (display.contentHeight - piece.shape.y) .. " - " .. piece.shape.height)
		end
	end
	print("foo")
end

local function sendOutCaptured(head, torso, legs)
      if not (head == torso) then
        score = score + 10
      end
      if not (torso == legs) then
        score = score + 10
      end
      if not (legs == head) then
        score = score + 10
      end
      scoreText.text = score
  
  
  torso.y = head.y + (head.height * 0.9)
	legs.y = torso.y + (torso.height * 0.9)
	local group = display.newGroup()
	group:insert(legs)
	group:insert(torso)
	group:insert(head)

	local index = #capturedHistory+1
	capturedHistory[ index ] = {
		head = head.myPieceType,
		torso = torso.myPieceType,
		legs = legs.myPieceType
	}

	local function exit()
		local function remove()
			group:removeSelf()
		end
		transition.to(group, {time = 700, x = display.contentWidth + 100, onComplete = remove})
	end
	transition.to(group, {time = 1500, y = display.contentHeight - 500, onComplete = exit})
end
local function checkFriendCompletion()
	if 	not (captured.head == nil) and
		not (captured.torso == nil) and
		not (captured.legs == nil) then
		--print("Friend completed")
		local head, torso, legs = captured.head, captured.torso, captured.legs
		captured = {}
		sendOutCaptured(head, torso, legs)
	end
end

local function setupCollision( body )
	local function onCollision( self, event )
		if event.other.myName == "ground" then
			-- print("Ground collision " .. self.bounced .. " - " .. self.maxBounceAllowed)
			self.bounced = self.bounced + 1
			if self.bounced >= self.maxBounceAllowed then
				local function remove(_ev)
					if self.isBodyActive == true then
						self.isBodyActive = false
						removeFromMoving(self, true)
						checkCompleted()
					end
				end
				timer.performWithDelay(10, remove, 1)
			end
		end
		--print ("Collided with " .. event.other.myName)
		if event.other.myName == "rabbitSensor" then
			--print ("Collided rabbit with a " .. self.myKind)
			if (captured[self.myKind] == nil) then
				captured[self.myKind] = self
				local function doWork(_ev)
					if(self.isBodyActive==true) then
            score = score + 10
            scoreText.text = score
            
						self.isBodyActive = false
						removeFromMoving(self, false)

						self.x = display.contentWidth - 400
						self.rotation = 0
						if self.myKind == "head" then
							self.y = 150
						end
						if self.myKind == "torso" then
							self.y = 220
						end
						if self.myKind == "legs" then
							self.y = 350
						end
						checkFriendCompletion()
						checkCompleted()
					end
				end
				timer.performWithDelay(10, doWork, 1)
			end
		end
	end
	body.collision = onCollision
	body:addEventListener("collision", body)
end


local function createItems(num, intv, group)
	-- load images
	for i = 1,6,1 do
		generatedToys[i] = 0
	end
	for _i = 1,num,1 do
		local idx = math.random(1,6)
		generatedToys[idx] = generatedToys[idx] + 1
		local pieces = createPiecesFor(idx, level, group)
		movingPieces = table.copy(movingPieces, pieces)
	end
	local howManyAlive = #movingPieces
	piecesCheckTimer = timer.performWithDelay(1000, everySecond, 0)
	local physics = require "physics"

	local index = 1
	local function launch(_ev)
		local obj = movingPieces[index]
		index = index + 1
		obj.shape.y = 50
		obj.physics.filter = {groupIndex = -2}
		physics.addBody(obj.shape, "dynamic", obj.physics)
		setupCollision(obj.shape)
	end
	timer.performWithDelay(intv, launch, #movingPieces)
	-- for _i,piece in pairs(movingPieces) do
	-- 	physics.addBody(piece.shape, "dynamic", piece.physics)
	-- 	setupCollision(piece.shape)
	-- end
	return movingPieces
end

function clearLevel()
	clearLevelTimer()
	resetLevel()
end
function clearLevelTimer()
	timer.cancel(piecesCheckTimer)
end
function createLevel(number, launchInterval, totalScore, group)
	interval = launchInterval
  score = totalScore
  scoreText = display.newText(score, 150, 100, native.systemFontBold, 90 )
  group:insert(scoreText)
	return createItems(number, launchInterval, group)
end

function setLevelCompleteListener(lst)
	levelCompleteListener = lst
	return true
end