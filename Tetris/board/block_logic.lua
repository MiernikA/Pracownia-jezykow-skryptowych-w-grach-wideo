local config = require("config")
local blockLogic = {}
local placeSound = nil

function blockLogic.setPlaceSound(sound)
    placeSound = sound
end

function blockLogic.lockBlock(board, block)
    for y = 1, #block.shape do
        for x = 1, #block.shape[y] do
            if block.shape[y][x] == 1 then
                local nx = block.x + x - 1
                local ny = block.y + y - 1
                if ny >= 1 and ny <= config.rows and nx >= 1 and nx <= config.cols then
                    board[ny][nx] = { filled = true, color = block.color }
                end
            end
        end
    end

    if placeSound then
        placeSound:setVolume(0.3)
        placeSound:stop()
        placeSound:seek(0.2)
        placeSound:play()
    end
end

function blockLogic.canMove(board, block, dx, dy)
    for y = 1, #block.shape do
        for x = 1, #block.shape[y] do
            if block.shape[y][x] == 1 then
                local nx = block.x + x - 1 + dx
                local ny = block.y + y - 1 + dy
                if nx < 1 or nx > config.cols or ny > config.rows then
                    return false
                end
                if ny >= 1 and board[ny][nx].filled then
                    return false
                end
            end
        end
    end
    return true
end

return blockLogic
