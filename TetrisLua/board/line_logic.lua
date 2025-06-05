local config = require("config")

local lineLogic = {}
local pointsSound = nil

function lineLogic.setPointsSound(sound)
    pointsSound = sound
end

local function findFullLines(board)
    local fullLines = {}

    for y = 1, config.rows do
        local isFull = true
        for x = 1, config.cols do
            if not board[y][x].filled then
                isFull = false
                break
            end
        end
        if isFull then
            table.insert(fullLines, y)
        end
    end

    return fullLines
end

local function removeLines(board, fullLines)
    local fullSet = {}

    if pointsSound then
        pointsSound:setVolume(0.4)
        pointsSound:stop()
        pointsSound:play()
    end

    for _, y in ipairs(fullLines) do
        fullSet[y] = true
    end

    local newBoard = {}
    local newRow = config.rows

    for y = config.rows, 1, -1 do
        if not fullSet[y] then
            newBoard[newRow] = board[y]
            newRow = newRow - 1
        end
    end

    for y = newRow, 1, -1 do
        newBoard[y] = {}
        for x = 1, config.cols do
            newBoard[y][x] = { filled = false }
        end
    end

    return newBoard
end

function lineLogic.clearLines(board, points, fallInterval, level)
    local fullLines = findFullLines(board)
    if #fullLines == 0 then
        return board, points, fallInterval, level, 0
    end

    board = removeLines(board, fullLines)

    local linesCleared = #fullLines
    points = points + linesCleared * 100

    local newLevel = math.floor(points / 1000)
    if newLevel > level then
        level = newLevel
        fallInterval = math.max(0.1, fallInterval * 0.9)
    end

    return board, points, fallInterval, level, linesCleared
end

return lineLogic
