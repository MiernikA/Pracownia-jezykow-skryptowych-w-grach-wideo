local config = require("config")
local board = require("board.board")
local block = require("block.block")
local input = require("events.input")
local saveGame = require("events.save_game")
 
local isPaused = false
local message = ""
local messageTimer = 0

local fallTimer = 0
local fontLarge

local isDownHeld = { value = false }
local gameOver = { value = false }

function love.load()
    love.window.setTitle("Tetris")
    love.window.setMode(config.cols * config.cellSize + config.sidebarWidth, config.rows * config.cellSize)

    fontLarge = love.graphics.newFont(28)
    love.graphics.setFont(fontLarge)

    board.init()
    block.spawn()

    input.setRefs(isDownHeld, gameOver)
end

function love.update(dt)

    if messageTimer > 0 then
        messageTimer = messageTimer - dt
        if messageTimer <= 0 then
            message = ""
        end
    end

    if isPaused or gameOver.value then
        return
    end
    
    if gameOver.value then
        return
    end

    fallTimer = fallTimer + dt
    local interval = isDownHeld.value and board.getFallInterval() / 15 or board.getFallInterval()
    local current = block.current()

    if fallTimer >= interval then
        if board.canMove(current, 0, 1) then
            current.y = current.y + 1
        else
            board.lockBlock(current)
            board.clearLines()
            if board.isGameOver() then
                gameOver.value = true
            else
                block.spawn()
            end
        end
        fallTimer = 0
    end
end

function love.keypressed(key)

    if key == "p" then
        isPaused = not isPaused
    end

    -- Save or Load only on paused game --
    if isPaused then
        if key == "s" then 
            local state = {
                board = board.get(),
                current = block.current(),
                next = block.next(),
                points = board.getPoints(),
                fallTimer = fallTimer,
                gameOver = gameOver.value
            }
            saveGame.save(state)
            message = "Game saved"
            messageTimer = 2
        elseif key == "l" then  
            local loaded = saveGame.load()
            if loaded then
                board.load(loaded.board)
                block.load(loaded.current, loaded.next)
                board.setPoints(loaded.points)
                fallTimer = loaded.fallTimer
                gameOver.value = loaded.gameOver
                message = "Game loaded"
                messageTimer = 2
            else
                message = "Brak zapisu"
                messageTimer = 2
            end
        end
        return
    end

    input.keypressed(key)

    if key == "return" and gameOver.value then
        love.load() 
    end
end


function love.keyreleased(key)
    input.keyreleased(key)
end

function love.draw()
    local boardData = board.get()
    local current = block.current()

    love.graphics.setColor(0.02, 0.02, 0.12)
    love.graphics.rectangle("fill", 0, 0, config.cols * config.cellSize, config.rows * config.cellSize)

    for y = 1, config.rows do
        for x = 1, config.cols do
            if boardData[y][x].filled then
                local px = (x - 1) * config.cellSize
                local py = (y - 1) * config.cellSize
                drawBlockWithShade(px, py, boardData[y][x].color)
            end
        end
    end

    if not gameOver.value and current then
        for y = 1, #current.shape do
            for x = 1, #current.shape[y] do
                if current.shape[y][x] == 1 then
                    local px = (current.x + x - 2) * config.cellSize
                    local py = (current.y + y - 2) * config.cellSize
                    drawBlockWithShade(px, py, current.color)
                end
            end
        end
    end

    local offsetX = config.cols * config.cellSize + 20
    local boxWidth = 160

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("POINTS", offsetX + (boxWidth - fontLarge:getWidth("POINTS")) / 2, 40)
    love.graphics.print(tostring(board.getPoints()), offsetX + (boxWidth - fontLarge:getWidth(tostring(board.getPoints()))) / 2, 80)

    love.graphics.print("NEXT", offsetX + (boxWidth - fontLarge:getWidth("NEXT")) / 2, 150)
    love.graphics.rectangle("line", offsetX, 190, boxWidth, 160)

    local next = block.next()
    if next then
        local shapeWidth = #next.shape[1]
        local shapeHeight = #next.shape
        local startX = offsetX + (boxWidth - shapeWidth * config.cellSize) / 2
        local startY = 200 + (160 - shapeHeight * config.cellSize) / 2

        for y = 1, shapeHeight do
            for x = 1, shapeWidth do
                if next.shape[y][x] == 1 then
                    local px = startX + (x - 1) * config.cellSize
                    local py = startY + (y - 1) * config.cellSize
                    drawBlockWithShade(px, py, next.color)
                end
            end
        end
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineWidth(2)
    local sepX = config.cols * config.cellSize
    love.graphics.line(sepX, 0, sepX, config.rows * config.cellSize)

    if gameOver.value then
        love.graphics.setColor(1, 0, 0, 0.8)
        love.graphics.rectangle("fill", 0, 0, config.cols * config.cellSize, config.rows * config.cellSize)
        love.graphics.setColor(1, 1, 1)
        local lines = { "GAME OVER", "Press Enter to Restart" }
        local fontHeight = fontLarge:getHeight()
        for i, line in ipairs(lines) do
            local w = fontLarge:getWidth(line)
            love.graphics.print(line, (config.cols * config.cellSize - w) / 2, config.rows * config.cellSize / 2 + (i - 1) * (fontHeight + 5))
        end
    end

    
    if isPaused then
        love.graphics.setColor(1, 1, 1)
        local pauseText = "PAUSE"
        local pauseW = fontLarge:getWidth(pauseText)
        love.graphics.print(pauseText, (config.cols * config.cellSize - pauseW) / 2, config.rows * config.cellSize / 2 - 40)

        if message ~= "" then
            local msgW = fontLarge:getWidth(message)
            love.graphics.print(message, (config.cols * config.cellSize - msgW) / 2, config.rows * config.cellSize / 2)
        end
    end
    
end

function drawBlockWithShade(x, y, color)
    love.graphics.setColor(color)
    love.graphics.rectangle("fill", x, y, config.cellSize, config.cellSize)
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.rectangle("line", x, y, config.cellSize, config.cellSize)
end

