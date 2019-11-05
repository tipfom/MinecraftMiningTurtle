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

function moveProgress()
    i = 1
    while i < progress do
        i = i + 1
        for k = 1, 3 do
            while not turtle.forward() do turtle.attack() end
        end
    end
end

function dumpInventory()
    for i = 3 , 16 do
        turtle.select(i)
        turtle.drop()
    end
    turtle.select(3)
end

function clearInventory()
    for i = 1, depth do
        while not turtle.up() do turtle.attackUp() end
    end

    moveProgress()
    dumpInventory()
    turtle.turnLeft() 
    turtle.turnLeft() 
    moveProgress()
    
    for i = 1, depth do
        while not turtle.down() do turtle.attackDown() end
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

function tryRefuel()
    if turtle.getFuelLevel() > 1000 then return false end
    turtle.turnLeft()
    os.sleep(2)
    turtle.select(1)
    turtle.suck(32)
    turtle.refuel()
    print("Fuel:", turtle.getFuelLevel())
    turtle.select(3)
    os.sleep(2)
    turtle.turnRight()
    return true
end

function placeSafetyBlock()
    turtle.select(2)
    turtle.placeDown()
    turtle.select(3)
end

function start()
    tryRefuel()
    turtle.turnLeft()
    turtle.turnLeft()

    while true do 
        while moveDown() do
            if not checkArea() then return nil end
            if isInventoryFull() then clearInventory() end
        end
        
        while depth > 0 do
            while not turtle.up() do turtle.attackUp() end
            depth = depth - 1
        end
        placeSafetyBlock()

        turtle.turnLeft()
        turtle.turnLeft()
        
        moveProgress()
        dumpInventory()
        tryRefuel()
        turtle.turnLeft()
        turtle.turnLeft()
        moveProgress()
        progress = progress + 1

        for k = 1, 3 do
            turtle.dig()
            while not turtle.forward() do turtle.attack() end
        end
    end
end

start()
