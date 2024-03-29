-- Configuration
chunkWidth = 5
forwardLimit = 20

criticalFuelLevel = chunkWidth * 3 + forwardLimit * 3 + 80
necessaryFuelLevel = criticalFuelLevel * 10

----------------
depth = 0
forwardSteps = 0
sidewardSteps = 0

ignoredBlocks = { "minecraft:dirt", "minecraft:stone", "minecraft:cobblestone", "minecraft:gravel", "minecraft:grass", "minecraft:bedrock", "minecraft:chest" }

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

function needsToReturnHome()
    return (turtle.getItemCount(16) > 0) or (turtle.getFuelLevel() < criticalFuelLevel)
end

function isIgnoredBlock(name)
    for index, block in ipairs(ignoredBlocks) do
       if block == name then return true end 
    end
    return false
end

function moveForward(stepCount)
    i = 0
    while i < stepCount do
        i = i + 1
        for k = 1, 3 do
            while not turtle.forward() do 
                turtle.attack() 
                turtle.dig() 
            end
        end
    end
end

function dumpInventory()
    for i = 3 , 16 do
        turtle.select(i)
        turtle.drop()
    end
    if turtle.getItemCount(1) > 0 then 
        turtle.select(1)
        turtle.drop()
    end
    turtle.select(2)
end

function returnToHomeFromShaft()
    moveForward(sidewardSteps)
    turtle.turnLeft()
    moveForward(forwardSteps)
end

function returnToShaftFromHome()
    moveForward(forwardSteps)
    turtle.turnRight()
    moveForward(sidewardSteps)
end

function tryRefuel()
    turtle.turnRight()

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

    print("Finished Refuel: ", turtle.getFuelLevel(), " Fuel available")
    turtle.select(2)

    turtle.turnLeft()
    return true
end

function returnHome()
    for i = 1, depth do
        while not turtle.up() do 
            turtle.attackUp()
            turtle.digUp()
        end
    end

    turn180degrees()
    returnToHomeFromShaft()
    dumpInventory()
    tryRefuel()
    turn180degrees()
    returnToShaftFromHome()
    
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
        if needsToReturnHome() then returnHome() end
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

function start()
    tryRefuel()
    turtle.turnLeft()
    
    while true do 
        clearShaft()
        
        if sidewardSteps < chunkWidth then
            sidewardSteps = sidewardSteps + 1
            moveForward(1)
        else
            turn180degrees()
            moveForward(sidewardSteps)
            turtle.turnRight()
            moveForward(1)
            turtle.turnRight()
            sidewardSteps = 0

            forwardSteps = forwardSteps + 1
            if forwardSteps > forwardLimit then
                returnToHomeFromShaft()
                break
            end
        end
    end
end

start()
