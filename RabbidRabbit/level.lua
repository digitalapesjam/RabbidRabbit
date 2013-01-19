--local level = 0
local levelCompleteListener = nil

local function initItem(level, item)
	print(item)
	myphysics.addBody(item, {friction = 0.2})
	-- set random direction and force for impulse

	return item
end

local function createPiecesFor(pieceType, level, group)
	local head  = display.newImageRect( "Images/pieces/" .. pieceType .. "_head.png" )
	local torso = display.newImageRect( "Images/pieces/" .. pieceType .. "_torso.png" )
	local legs  = display.newImageRect( "Images/pieces/" .. pieceType .. "_legs.png" )

	--initItem(level, head)

	return {head, torso, legs}
end

local function createItems(level, group)
	-- load images
	return {} --createPiecesFor(1, level, group)
end

function createLevel(level, rabbit, group, physics)
	return createItems(level, group)
end

function setLevelCompleteListener(lst)
	levelCompleteListener = lst
	return true
end