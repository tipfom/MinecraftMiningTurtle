-- Configuration
chunkWidth = 5
forwardLimit = 20

criticalFuelLevel = chunkWidth * 3 + forwardLimit * 3 + chunkWidth * 80
necessaryFuelLevel = criticalFuelLevel * 5

----------------
depth = 0
forwardSteps = 0
sidewardSteps = 0

ignoredBlocks = { "minecraft:dirt", "minecraft:stone", "minecraft:cobblestone", "minecraft:gravel", "minecraft:grass", "minecraft:bedrock", "minecraft:chest", "buildcrafttransport:pipe_holder" }

function moveDown()
    turtle.digDown()
    if turtle.down() then
        depth = depth + 1
        return true
    else 
        return false
    end
end

function turn180degrees()
    turtle.turnLeft()
    turtle.turnLeft()
end

function needsToEmptyInventory()
    return (turtle.getItemCount(16) > 0)
end

function needsToRefuel()
    return (turtle.getFuelLevel() < criticalFuelLevel)
end

function isIgnoredBlock(name)
    for index, block in ipairs(ignoredBlocks) do
       if block == name then return true end 
    end
    return false
end

function forceMoveOneBlock()
    while not turtle.forward() do 
        turtle.attack() 
        turtle.dig() 
    end
end

function moveForward(stepCount)
    i = 0
    while i < stepCount do
        i = i + 1
        for k = 1, 3 do
            forceMoveOneBlock()
        end
    end
end

function dumpInventory()
    turtle.up()
    turtle.up()
    turtle.forward()   
    turtle.forward()

    for i = 4 , 16 do
        turtle.select(i)
        turtle.dropDown()
    end
    if turtle.getItemCount(1) > 0 then -- obsolete?
        turtle.select(1)
        turtle.dropDown()
    end
    turtle.select(2)
    turtle.back()
    turtle.back()
    turtle.down()
    turtle.down()
end

function refuel()
    turtle.up()
    turtle.up()
    turtle.up()
    moveForward(forwardSteps)

    turtle.forward()
    turtle.forward()
    turtle.select(1)
    while turtle.getFuelLevel() < turtle.getFuelLimit() do
        if turtle.suck(1) then
            turtle.refuel()
        elseif turtle.getFuelLevel() < necessaryFuelLevel then
            print("Error: Need more fuel")
            os.sleep(2)
        else
            break
        end
    end
    turtle.back()
    turtle.back()

    print("Finished Refuel: ", turtle.getFuelLevel(), " Fuel available")
    turtle.select(2)

    turn180degrees()
    moveForward(forwardSteps)

    turtle.down()
    turtle.down()
    turtle.down()
    turn180degrees()

    return true
end

function emptyInventory()
    for i = 1, depth do
        while not turtle.up() do 
            turtle.attackUp()
            turtle.digUp()
        end
    end

    turn180degrees()
    moveForward(sidewardSteps)
    turtle.turnLeft()

    dumpInventory()
    
    turtle.turnLeft()
    moveForward(sidewardSteps)
    
    for i = 1, depth do
        while not turtle.down() do
             turtle.attackDown() 
             turtle.digDown()
        end
    end
end

function checkBlock()
    local success, data = turtle.inspect()
    if success then
        if not isIgnoredBlock(data.name) then
            turtle.dig()
        end
    end
end

function clearSorrounding()
    for i = 1 , 4 do
        checkBlock()
        turtle.turnLeft()
    end 
end


function placeSafetyBlock()
    turtle.placeDown()
end

function clearShaft()
    while moveDown() do
        clearSorrounding()
        if needsToEmptyInventory() then emptyInventory() end
    end
    
    while depth > 0 do
        while not turtle.up() do
            turtle.attackUp() 
            turtle.digUp()
        end
        depth = depth - 1
    end
    placeSafetyBlock()
end

function moveForwardAndCarryPipe()
    turtle.select(4)
    turtle.forward()
    turtle.dig()
    
    for i = 1, 3 do
        turtle.select(2)
        placeSafetyBlock()
        turtle.turnLeft()
        turtle.place()
        turtle.turnRight()
        turtle.turnRight()
        turtle.place()
        turtle.turnLeft()

        turtle.select(3)

        turtle.place()

        turn180degrees()
        forceMoveOneBlock()
        turn180degrees()
    end

    turtle.forward()
    turtle.up()
    turtle.select(2)
    turtle.place()
    turtle.turnRight()
    turtle.place()
    turtle.turnRight()
    turtle.turnRight()
    turtle.place()
    turtle.turnRight()
    turtle.back()
    turtle.down()

    turtle.select(4)
    turtle.place()
    turtle.select(2)

    turn180degrees()
    forceMoveOneBlock()
    turn180degrees()
end

function start()
    turtle.refuel()
    refuel()
    turn180degrees()

    while forwardSteps < forwardLimit do
        turtle.turnRight()

        clearShaft()
        while sidewardSteps < chunkWidth do
            moveForward(1)    
            sidewardSteps = sidewardSteps + 1
            clearShaft()
        end

        turn180degrees()
        moveForward(sidewardSteps)
        sidewardSteps = 0
        
        turtle.turnLeft()
        dumpInventory()
        if needsToRefuel() then 
            refuel() 
        else
            os.sleep(2)
        end

        moveForwardAndCarryPipe()
        turn180degrees()

        forwardSteps = forwardSteps + 1
    end
end

start()
