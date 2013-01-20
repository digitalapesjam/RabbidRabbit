require "util"

--local level = 0
local levelCompleteListener = nil
local movingPieces = {}
local capturedHistory = { index=1 }
local captured = { head = nil, torso = nil, legs = nil }
local piecesCheckTimer = nil

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

	head.x, head.y = math.random(0, display.contentWidth),	-100
	torso.x, torso.y = math.random(0, display.contentWidth),-100
	legs.x, legs.y = math.random(0, display.contentWidth),	-100

	head.maxBounceAllowed = 10 -- level
	torso.maxBounceAllowed = 10 -- level
	legs.maxBounceAllowed = 10 -- level

	headPhys = {
		friction = 0.01, bounce = 0.99,
		radius = head.width - 20
	}
	torsoPhys = {friction = 0.01, bounce = 0.99}
	legsPhys = {
		friction = 0.01, bounce = 0.99
		-- radius = 180
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
		levelCompleteListener({1,1,1,1}, capturedHistory)
		return true
	end
	return false
end

function everySecond(event)
	--print("Check..")
	for i,piece in pairs(movingPieces) do
		if (not (piece == nil) and not (piece.shape.y == nil) and not (piece.shape.height == nil)) then
			local body = piece.shape
			--print(body.myName .. " y: " .. (display.contentHeight - body.y))
			if (display.contentHeight - body.y) < (50+body.height) and
				not (body['getLinearVelocity'] == nil) then
				local vx,vy = body:getLinearVelocity()
				--print(body.myName .. "vx: " .. vx .. ", vy: " .. vy)
				if math.abs(vx) < 2 and math.abs(vy) < 2 then
					--print("Removing " .. body.myName)
					-- body:removeSelf()
					body.isBodyActive = false
					movingPieces[i] = nil
					checkCompleted()
				end
			end
		end
	end

	for i,piece in pairs(movingPieces) do
		if not (piece==nil) then
			print(i .. " is still alive " .. piece.shape.myName)
		end
	end
	print("foo")
end

local function sendOutCaptured(head, torso, legs)
	torso.y = head.y + (head.height * 0.9)
	legs.y = torso.y + (torso.height * 0.9)
	local group = display.newGroup()
	group:insert(legs)
	group:insert(torso)
	group:insert(head)

	capturedHistory[ capturedHistory.index ] = {
		head = head.myPieceType,
		torso = head.myPieceType,
		legs = head.myPieceType
	}
	capturedHistory.index = capturedHistory.index + 1

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

local function removeFromMoving( body )
	for i,piece in pairs(movingPieces) do
		if (not (piece==nil)) then
			if piece.shape == body then
				movingPieces[i] = nil
				return
			end
		end
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
						removeFromMoving(self)
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
						self.isBodyActive = false
						removeFromMoving(self)

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
	for _i = 1,num,1 do
		local idx = math.random(1,6)
		local pieces = createPiecesFor(idx, level, group)
		movingPieces = table.copy(movingPieces, pieces)
	end
	-- local pieces_1 = createPiecesFor(1, level, group)
	-- local pieces_2 = createPiecesFor(2, level, group)
	-- local pieces_3 = createPiecesFor(3, level, group)
	-- local pieces_4 = createPiecesFor(4, level, group)
	-- movingPieces = table.copy(pieces_1, pieces_2, pieces_3, pieces_4)
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
end
function clearLevelTimer()
	timer.cancel(piecesCheckTimer)
end
function createLevel(number, interval, group)
	return createItems(number, interval, group)
end

function setLevelCompleteListener(lst)
	levelCompleteListener = lst
	return true
end