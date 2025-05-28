local saveFile = "savegame.lua"

function table.serialize(tbl)
    local function serializeTbl(t)
        local result = "{"
        for k, v in pairs(t) do
            local key = type(k) == "number" and "[" .. k .. "]" or tostring(k)
            if type(v) == "table" then
                result = result .. key .. "=" .. serializeTbl(v) .. ","
            elseif type(v) == "string" then
                result = result .. key .. "=\"" .. v .. "\","
            elseif type(v) == "number" or type(v) == "boolean" then
                result = result .. key .. "=" .. tostring(v) .. ","
            end
        end
        return result .. "}"
    end
    return serializeTbl(tbl)
end

local function save(state)
    local file = love.filesystem.newFile(saveFile, "w")
    local serialized = "return " .. table.serialize(state)
    file:write(serialized)
    file:close()
end

local function load()
    if love.filesystem.getInfo(saveFile) then
        local chunk = love.filesystem.load(saveFile)
        return chunk()
    end
    return nil
end

return {
    save = save,
    load = load
}
