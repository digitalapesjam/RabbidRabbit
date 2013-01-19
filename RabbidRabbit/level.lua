--local level = 0
local levelCompleteListener = nil
local movingPieces = {}
local howManyAlive = 0
local captured = { head = nil, torso = nil, legs = nil }

local function initItem(level, item)
	print(item)
	myphysics.addBody(item, {friction = 0.2})
	-- set random direction and force for impulse

	return item
end

local function createPiecesFor(pieceType, level, group)
	local head  = display.newImageRect( "Images/pieces/" .. pieceType .. "_head.png", 200,150 )
	head.myName = pieceType .. "head"
	head.myPieceType = pieceType
	head.myKind = "head"
	local torso = display.newImageRect( "Images/pieces/" .. pieceType .. "_torso.png", 450,150 )
	torso.myName = pieceType .. "torso"
	torso.myPieceType = pieceType
	torso.myKind = "torso"
	local legs  = display.newImageRect( "Images/pieces/" .. pieceType .. "_legs.png", 320,250 )
	legs.myName = pieceType .. "legs"
	legs.myPieceType = pieceType
	legs.myKind = "legs"

	head.x, head.y = math.random(0, display.contentWidth),50
	torso.x, torso.y = math.random(0, display.contentWidth),50
	legs.x, legs.y = math.random(0, display.contentWidth),50
	--initItem(level, head)


	headPhys = {
		friction = 0.01, bounce = 0.99,
		radius = 80
	}
	torsoPhys = {friction = 0.01, bounce = 0.99}
	legsPhys = {
		friction = 0.01, bounce = 0.99
		-- radius = 180
	}

	return {{shape=head, physics=headPhys}, {shape=torso, physics=torsoPhys}, {shape=legs, physics=legsPhys}}
end

function everySecond(event)
	--print("Check..")
	for _i,parts in pairs(movingPieces) do
		for _j,piece in pairs(parts) do
			local body = piece.shape
			if (piece.removed == nil) then
				--print(body.myName .. " y: " .. (display.contentHeight - body.y))
				if (display.contentHeight - body.y) < (100+body.height) then
					local vx,vy = body:getLinearVelocity()
					--print(body.myName .. "vx: " .. vx .. ", vy: " .. vy)
					if math.abs(vx) < 2 and math.abs(vy) < 2 then
						--print("Removing " .. body.myName)
						-- body:removeSelf()
						body.isBodyActive = false
						piece.removed = true
						howManyAlive = howManyAlive - 1
						if (howManyAlive == 0 and not (levelCompleteListener == nil)) then
							timer.cancel(event.source)
							levelCompleteListener()
						end
					end
				end
			end
		end
	end
end

local function sendOutCaptured(head, torso, legs)
	--print("Ok")
	local group = display.newGroup()
	group:insert(legs)
	group:insert(torso)
	group:insert(head)

	local function exit()
		transition.to(group, {time = 500, x = display.contentWidth + 100})
	end
	transition.to(group, {time = 500, y = display.contentHeight - 500, onComplete = exit})
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
		--print ("Collided with " .. event.other.myName)
		if event.other.myName == "rabbit" then
			--print ("Collided rabbit with a " .. self.myKind)
			if (captured[self.myKind] == nil) then
				captured[self.myKind] = self
				local function doWork(_ev)
					self.isBodyActive = false
					self.x = display.contentWidth - 500
					self.rotation = 0
					if self.myKind == "head" then
						self.y = 150
					end
					if self.myKind == "torso" then
						self.y = 260
					end
					if self.myKind == "legs" then
						self.y = 400
					end
					checkFriendCompletion()
				end
				timer.performWithDelay(1000, doWork, 1)
			end
		end
	end
	body.collision = onCollision
	body:addEventListener("collision", body)
end

local function createItems(level, group)
	-- load images
	local pieces_1 = createPiecesFor(1, level, group)
	local pieces_2 = createPiecesFor(2, level, group)
	movingPieces = {pieces_1, pieces_2}
	howManyAlive = 6
	timer.performWithDelay(1000, everySecond, 0)
	for _i,parts in pairs(movingPieces) do
		for _j,piece in pairs(parts) do
			setupCollision(piece.shape)
		end
	end
	return movingPieces
end

function createLevel(level, rabbit, group, physics)
	return createItems(level, group)
end

function setLevelCompleteListener(lst)
	levelCompleteListener = lst
	return true
end