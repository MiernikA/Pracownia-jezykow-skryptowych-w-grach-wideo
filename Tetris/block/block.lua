local blocksList = require("block.blocks_list")  
local current, nextBlock

local function generateBlock()
    local element = blocksList[love.math.random(#blocksList)]
    return {
        shape = element.shape,
        color = element.color,
        x = 4,
        y = 1
    }
end

local function spawn()
    current = nextBlock or generateBlock()
    nextBlock = generateBlock()
end


-- loading --

local function load(currentBlock, next)
    current = currentBlock
    nextBlock = next
end

return {
    current = function() return current end,
    next = function() return nextBlock end,
    spawn = spawn,
    load = load
}