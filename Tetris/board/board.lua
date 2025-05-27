local config = require("config")
local lineLogic = require("board.line_logic")
local blockLogic = require("board.block_logic")

local board = {}
local gameOver = false
local currentFallInterval = config.fallInterval
local level = 0
local points = 0

-- initialization -- 

function board.init()
    for y = 1, config.rows do
        board[y] = {}
        for x = 1, config.cols do
            board[y][x] = { filled = false }
        end
    end
    points = 0
    gameOver = false
    currentFallInterval = config.fallInterval
    level = 0
end

function board.draw()
    love.graphics.setColor(0.05, 0.05, 0.1)
    love.graphics.rectangle("fill", 0, 0, config.cols * config.tileSize, config.rows * config.tileSize)

    for y = 1, config.rows do
        for x = 1, config.cols do
            local cell = board[y][x]
            if cell.filled then
                love.graphics.setColor(cell.color)
                love.graphics.rectangle("fill",
                    (x - 1) * config.tileSize,
                    (y - 1) * config.tileSize,
                    config.tileSize,
                    config.tileSize
                )
            end
        end
    end
end

-- blockLogic --

function board.canMove(block, dx, dy)
    return blockLogic.canMove(board, block, dx, dy)
end

function board.lockBlock(block)
    blockLogic.lockBlock(board, block)
end

-- lineLogic --

function board.clearLines()
    local linesCleared
    board, points, currentFallInterval, level, linesCleared = lineLogic.clearLines(board, points, currentFallInterval, level)
    return linesCleared
end

-- getters --

function board.getFallInterval()
    return currentFallInterval
end

function board.getPoints()
    return points
end

function board.get()
    return board
end

function board.isGameOver()
    for x = 1, config.cols do
        if board[1][x].filled then
            gameOver = true
            break
        end
    end
    return gameOver
end

return board
