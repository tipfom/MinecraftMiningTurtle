progress = 1
depth = 0

ignoredBlocks = { "minecraft:dirt", "minecraft:stone", "minecraft:cobblestone", "minecraft:gravel", "minecraft:grass" }

function moveDown()
    turtle.digDown()
    if turtle.down() then
        depth = depth + 1
        return true
    else 
        return false
    end
end

function isInventoryFull()
    return turtle.getItemCount(16) > 0
end

function isIgnoredBlock(name)
    for index, block in ipairs(ignoredBlocks) do
       if block == name then return true end 
    end
    return false
end

function dumpInventory()
    turtle.turnLeft() 
    turtle.turnLeft() 
    i = 1
    while i < progress do
        i = i + 1
        for k = 1, 3 do
            turtle.forward()
        end
    end

    for i = 1 , 16 do
        turtle.select(i)
        turtle.drop()
    end
    turtle.select(1)

    turtle.turnLeft() 
    turtle.turnLeft() 
    i = 1
    while i < progress do
        i = i + 1
        for k = 1, 3 do
            turtle.forward()
        end
    end
end

function clearInventory()
    for i = 1, depth do
        turtle.up()
    end

    dumpInventory()

    for i = 1, depth do
        turtle.down()
    end
end

function checkBlock()
    local success, data = turtle.inspect()
    if success then
        if data.name == "minecraft:bedrock" then
            return false
        elseif isIgnoredBlock(data.name) then
            return true
        end
        turtle.dig()
    end
    return true
end

function checkArea()
    for i = 1 , 4 do
        if not checkBlock() then return false end
        turtle.turnLeft()
    end 
    return true
end

function start()
    turtle.refuel()
    print(turtle.getFuelLevel())
    while true do 
        while moveDown() do
            if not checkArea() then return nil end
            if isInventoryFull() then clearInventory() end
        end
        
        while depth > 0 do
            turtle.up()
            depth = depth - 1
        end

        dumpInventory()
        progress = progress + 1

        for k = 1, 3 do
            turtle.dig()
            turtle.forward()
        end
    end
end

start()
