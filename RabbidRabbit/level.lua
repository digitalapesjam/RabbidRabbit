--local level = 0
local levelCompleteListener = nil
local movingPieces = {}
local howManyAlive = 0

local function initItem(level, item)
	print(item)
	myphysics.addBody(item, {friction = 0.2})
	-- set random direction and force for impulse

	return item
end

local function createPiecesFor(pieceType, level, group)
	local head  = display.newImageRect( "Images/pieces/" .. pieceType .. "_head.png", 200,150 )
	head.myName = "1_head"
	local torso = display.newImageRect( "Images/pieces/" .. pieceType .. "_torso.png", 450,150 )
	torso.myName = "1_torso"
	local legs  = display.newImageRect( "Images/pieces/" .. pieceType .. "_legs.png", 320,250 )
	legs.myName = "1_legs"

	head.x, head.y = 800,50
	torso.x, torso.y = 1000,50
	legs.x, legs.y = 1500,50
	--initItem(level, head)


	headPhys = {
		friction = 0.01, bounce = 0.9,
		radius = 140
	}
	torsoPhys = {friction = 0.01, bounce = 0.9}
	legsPhys = {
		friction = 0.01, bounce = 0.9,
		radius = 240
	}

	return {{shape=head, physics=headPhys}, {shape=torso, physics=torsoPhys}, {shape=legs, physics=legsPhys}}
end

function everySecond(event)
	print("Check..")
	for _i,parts in pairs(movingPieces) do
		for _j,piece in pairs(parts) do
			local body = piece.shape
			if (piece.removed == nil) then
				print(body.myName .. " y: " .. (display.contentHeight - body.y))
				if (display.contentHeight - body.y) < (100+body.height) then
					local vx,vy = body:getLinearVelocity()
					print(body.myName .. "vx: " .. vx .. ", vy: " .. vy)
					if math.abs(vx) < 2 and math.abs(vy) < 2 then
						print("Removing " .. body.myName)
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
local function createItems(level, group)
	-- load images
	local pieces = createPiecesFor(1, level, group)
	movingPieces = {pieces}
	howManyAlive = 3

	timer.performWithDelay(1000, everySecond, 0)

	return movingPieces
end

function createLevel(level, rabbit, group, physics)
	return createItems(level, group)
end

function setLevelCompleteListener(lst)
	levelCompleteListener = lst
	return true
end