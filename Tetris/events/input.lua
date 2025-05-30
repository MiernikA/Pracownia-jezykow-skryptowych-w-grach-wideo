local board = require("board.board")
local piece = require("block.block")

local input = {}

local isDownHeldRef = nil
local gameOverRef = nil
local music = nil

function input.setMusic(m)
    music = m
end

local function rotateShape(shape)
    local rotated = {}
    for x = 1, #shape[1] do
        rotated[x] = {}
        for y = #shape, 1, -1 do
            rotated[x][#shape - y + 1] = shape[y][x]
        end
    end
    return rotated
end

function input.setRefs(isDownHeld, gameOver)
    isDownHeldRef = isDownHeld
    gameOverRef = gameOver
end

function input.keypressed(key)
    if gameOverRef.value then
        if key == "return" then
            board.init()
            piece.spawn()
            if music then
                music:seek(0)
                music:play()
            end
            gameOverRef.value = false
        end
        return
    end

    local current = piece.current()
    if key == "left" and board.canMove(current, -1, 0) then
        current.x = current.x - 1
    elseif key == "right" and board.canMove(current, 1, 0) then
        current.x = current.x + 1
    elseif key == "down" and board.canMove(current, 0, 1) then
        isDownHeldRef.value = true
    elseif key == "space" then
        local rotated = rotateShape(current.shape)
        local temp = { x = current.x, y = current.y, shape = rotated }
        if board.canMove(temp, 0, 0) then
            current.shape = rotated
        end
    end
end

function input.keyreleased(key)
    if key == "down" then
        isDownHeldRef.value = false
    end
end

return input
