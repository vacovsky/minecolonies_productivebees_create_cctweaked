-- Turtle farm by JackMacWindows
--
-- This is a simple farming script for ComputerCraft turtles. To use, simply
-- place a tilling turtle on top of a farming region, place a wired modem
-- connected to a chest next to the turtle, and run this script.
--
-- Features:
-- * Fully automatic field tending
-- * Automatic tilling and planting to reduce setup time
-- * Zero configuration to start a basic farm
-- * Boundaries are automatically detected, so no need to calculate size
-- * Non-rectangular and non-flat fields supported
-- * Recovery after being unloaded
-- * Automatic unloading and refueling from one or more chests
--
-- To create a farm, create a complete boundary around the dirt or grass area
-- that you want the farm to be inside. Then add water to ensure the field stays
-- fully watered. The field may be any height - the turtle will automatically
-- move up or down to continue farming. The field may also be non-rectangular,
-- but it will not detect single holes in a straight line going across the field.
-- (e.g. if a boundary is at (100, 0) to (100, 100), the boundary may not have a
-- hole taken out at (100, 25) to (100, 50).)
--
-- The turtle dispenses items when it reaches the origin point, which is the
-- place where the turtle was when the farm was started. This point must have a
-- modem next to it, with one or more chests placed next to that modem. The
-- program will prompt you to set this up if not present. (Make sure to right-
-- click the modem to turn it red and enable it.) Whenever the turtle returns to
-- this point, it will dispense all items except one stack of seeds and one stack
-- of fuel. If either of these stacks are not present, it will pick them up from
-- the chests.
--
-- Farms may have multiple different types of crops, and the turtle will attempt
-- to replace them with the same type of seed. However, these will have to be
-- planted beforehand - when planting the first crops, it will use whatever
-- seeds are found in the chest or turtle first.
--
-- If you'd like to add custom modded crops, scroll down to the "add your own
-- here" sections, and fill out the templates for the blocks and items you want.
--
-- If you need any help, you may ask on the ComputerCraft Discord server at
-- https://discord.computercraft.cc.

-- MIT License
--
-- Copyright (c) 2022 JackMacWindows
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.


local STORAGE_VESSSEL = 'ironchests:gold_barrel'
local FUEL_MIN = (turtle.getFuelLimit() / 10)

local x, y, z = 0, 0, 0
local direction = 0
local invertDirection = false

-- Ground blocks that are part of the farm
local groundBlocks = {
    ["minecraft:dirt"] = true,
    ["minecraft:grass_block"] = true,
    ["minecraft:farmland"] = true,
    ["minecraft:water"] = true,
    ["minecraft:flowing_water"] = true,
    -- add your own here:
    --["<yourmod>:<block>"] = true,
}

-- Blocks that are crops, with their maximum ages
local cropBlocks = {
    ["minecraft:wheat"] = 7,
    ["minecraft:carrots"] = 7,
    ["minecraft:potatoes"] = 7,
    ["minecraft:beetroots"] = 3,
    -- add your own here:
    --["<yourmod>:<block>"] = <maximum age>,
}

-- Mappings of crop blocks to seed items
local seeds = {
    ["minecraft:wheat"] = "minecraft:wheat_seeds",
    ["minecraft:carrots"] = "minecraft:carrot",
    ["minecraft:potatoes"] = "minecraft:potato",
    ["minecraft:beetroots"] = "minecraft:beetroot_seeds",
    -- add your own here:
    --["<yourmod>:<block>"] = "<yourmod>:<seed>",
}

-- Fuel types to pull from a chest if no fuel is in the inventory
local fuels = {
    ["minecraft:coal"] = true,
    ["minecraft:coal_block"] = true,
    ["minecraft:charcoal"] = true,
    ["minecraft:lava_bucket"] = true,
    -- add your own here:
    --["<yourmod>:<item>"] = true,
}

local seedItems = {}
for k, v in pairs(seeds) do seedItems[v] = k end

local function writePos()
    local file = fs.open("jackmacwindows.farm-state.txt", "w")
    file.writeLine(x)
    file.writeLine(y)
    file.writeLine(z)
    file.writeLine(direction)
    file.writeLine(invertDirection and "true" or "false")
    file.close()
end

local function refuel()
    if turtle.getFuelLevel() == "unlimited" or turtle.getFuelLevel() == turtle.getFuelLimit() then return end
    for i = 1, 16 do
        if turtle.getItemCount(i) > 0 then
            turtle.select(i)
            turtle.refuel(turtle.getItemCount() - 1)
            if turtle.getFuelLevel() == turtle.getFuelLimit() then return true end
        end
    end
    -- SET TO VALUE YOU WANT TO SEE BEFORE TURTLE KICKS OFF
    -- if turtle.getFuelLevel() > 0 then return true
    if turtle.getFuelLevel() == 100000 then
        return true
    else
        return false, "Out of fuel"
    end
end

local function forward()
    local ok, err = turtle.forward()
    if ok then
        if direction == 0 then
            x = x + 1
        elseif direction == 1 then
            z = z + 1
        elseif direction == 2 then
            x = x - 1
        else
            z = z - 1
        end
        writePos()
        return true
    elseif err:match "[Ff]uel" then
        ok, err = refuel()
        if ok then
            return forward()
        else
            return ok, err
        end
    else
        return false, err
    end
end

local function back()
    local ok, err = turtle.back()
    if ok then
        if direction == 0 then
            x = x - 1
        elseif direction == 1 then
            z = z - 1
        elseif direction == 2 then
            x = x + 1
        else
            z = z + 1
        end
        writePos()
        return true
    elseif err:match "[Ff]uel" then
        ok, err = refuel()
        if ok then
            return forward()
        else
            return ok, err
        end
    else
        return false, err
    end
end

local function up()
    local ok, err = turtle.up()
    if ok then
        y = y + 1
        writePos()
        return true
    elseif err:match "[Ff]uel" then
        ok, err = refuel()
        if ok then
            return forward()
        else
            return ok, err
        end
    else
        return false, err
    end
end

local function down()
    local ok, err = turtle.down()
    if ok then
        y = y - 1
        writePos()
        return true
    elseif err:match "[Ff]uel" then
        ok, err = refuel()
        if ok then
            return forward()
        else
            return ok, err
        end
    else
        return false, err
    end
end

local function left()
    local ok, err = turtle.turnLeft()
    if ok then
        direction = (direction - 1) % 4
        writePos()
        return true
    else
        return false, err
    end
end

local function right()
    local ok, err = turtle.turnRight()
    if ok then
        direction = (direction + 1) % 4
        writePos()
        return true
    else
        return false, err
    end
end

local function panic(msg)
    term.clear()
    term.setCursorPos(1, 1)
    term.setTextColor(colors.red)
    print("An unrecoverable error occured while farming:", msg,
        "\nPlease hold Ctrl+T to stop the program, then solve the issue described above, run 'rm jackmacwindows.farm-state.txt', and return the turtle to the start position. Don't forget to label the turtle before breaking it.")
    if peripheral.find("modem") then
        peripheral.find("modem", rednet.open)
        rednet.broadcast(msg, "jackmacwindows.farming-error")
    end
    local speaker = peripheral.find("speaker")
    if speaker then
        while true do
            speaker.playNote("bit", 3, 12)
            sleep(1)
        end
    else
        while true do os.pullEvent() end
    end
end

local function check(ok, msg) if not ok then panic(msg) end end

local function tryForward()
    local ok, err, found, block
    repeat
        found, block = turtle.inspect()
        if found then
            if groundBlocks[block.name] or cropBlocks[block.name] then
                ok, err = up()
                if not ok then return ok, err end
            else
                return false, "Out of bounds"
            end
        end
    until not found
    ok, err = forward()
    if not ok then return ok, err end
    local lastY = y
    repeat
        found, block = turtle.inspectDown()
        if not found then
            ok, err = down()
            if not ok then return ok, err end
        end
    until found
    if groundBlocks[block.name] then
        ok, err = up()
        if not ok then return ok, err end
        turtle.digDown()
    elseif not cropBlocks[block.name] then
        while y < lastY do
            ok, err = up()
            if not ok then return ok, err end
        end
        ok, err = back()
        if not ok then return ok, err end
        return false, "Out of bounds"
    end
    return true
end

local function selectItem(item)
    local lut = {}
    if type(item) == "table" then
        if item[1] then
            for _, v in ipairs(item) do lut[v] = true end
        else
            lut = item
        end
    else
        lut[item] = true
    end
    local lastEmpty
    for i = 1, 16 do
        local info = turtle.getItemDetail(i)
        if info and lut[info.name] then
            turtle.select(i)
            return true, i
        elseif not info and not lastEmpty then
            lastEmpty = i
        end
    end
    return false, lastEmpty
end

local function handleCrop()
    local found, block = turtle.inspectDown()
    if not found then
        if selectItem(seedItems) then turtle.placeDown() end
    elseif block.state.age == cropBlocks[block.name] then
        local seed = seeds[block.name]
        turtle.select(1)
        turtle.digDown()
        turtle.suckDown()
        if turtle.getItemDetail().name ~= seed and not selectItem(seed) then return end
        turtle.placeDown()
    end
end

local function exchangeItems()
    local inventory, fuel, seed = {}, nil, nil
    for i = 1, 16 do
        turtle.select(i)
        local item = turtle.getItemDetail(i)
        if item then
            if not seed and seedItems[item.name] then
                seed = { slot = i, name = item.name, count = item.count, limit = turtle.getItemSpace(i) }
            elseif not turtle.refuel(0) then
                inventory[item.name] = inventory[item.name] or {}
                inventory[item.name][i] = item.count
            elseif not fuel then
                fuel = { slot = i, name = item.name, count = item.count, limit = turtle.getItemSpace(i) }
            end
        end
    end
    local name = peripheral.find("modem", function(_, v) return not v.isWireless() end).getNameLocal()
    for _, chest in ipairs { peripheral.find(STORAGE_VESSSEL) } do
        local items = chest.list()
        for i = 1, chest.size() do
            if items[i] then
                local item = items[i].name
                if inventory[item] then
                    for slot, count in pairs(inventory[item]) do
                        local d = chest.pullItems(name, slot, count, i)
                        if d == 0 then break end
                        if count - d <= 0 then
                            inventory[item][slot] = nil
                        else
                            inventory[item][slot] = count - d
                        end
                    end
                    if not next(inventory[item]) then inventory[item] = nil end
                elseif fuel and fuel.count < fuel.limit and item == fuel.name then
                    local d = chest.pushItems(name, i, fuel.limit - fuel.count, fuel.slot)
                    fuel.count = fuel.count + d
                elseif seed and seed.count < seed.limit and item == seed.name then
                    local d = chest.pushItems(name, i, seed.limit - seed.count, seed.slot)
                    seed.count = seed.count + d
                end
            end
            if not next(inventory) then break end
        end
        if not next(inventory) then break end
    end
    if next(inventory) then
        for _, chest in ipairs { peripheral.find(STORAGE_VESSSEL) } do
            local items = chest.list()
            for i = 1, chest.size() do
                if not items[i] then
                    local item, list = next(inventory)
                    for slot, count in pairs(list) do
                        local d = chest.pullItems(name, slot, count, i)
                        if d == 0 then break end
                        if count - d <= 0 then
                            list[slot] = nil
                        else
                            list[slot] = count - d
                        end
                    end
                    if not next(list) then inventory[item] = nil end
                end
                if not next(inventory) then break end
            end
            if not next(inventory) then break end
        end
    end
    if not fuel or not seed then
        for _, chest in ipairs { peripheral.find(STORAGE_VESSSEL) } do
            local items = chest.list()
            for i = 1, chest.size() do
                if items[i] and ((fuel and items[i].name == fuel.name and fuel.count < fuel.limit) or (not fuel and fuels[items[i].name])) then
                    local d = chest.pushItems(name, i, fuel and fuel.count - fuel.limit, 16)
                    if fuel then
                        fuel.count = fuel.count + d
                    else
                        fuel = { name = items[i].name, count = d, limit = turtle.getItemSpace(16) }
                    end
                end
                if items[i] and ((seed and items[i].name == seed.name and seed.count < seed.limit) or (not seed and seedItems[items[i].name])) then
                    local d = chest.pushItems(name, i, seed and seed.count - seed.limit, 1)
                    if seed then
                        seed.count = seed.count + d
                    else
                        seed = { name = items[i].name, count = d, limit = turtle.getItemSpace(1) }
                    end
                end
                if (fuel and fuel.count >= fuel.limit) and (seed and seed.count >= seed.limit) then break end
            end
            if (fuel and fuel.count >= fuel.limit) and (seed and seed.count >= seed.limit) then break end
        end
    end
end

if fs.exists("jackmacwindows.farm-state.txt") then
    local file = fs.open("jackmacwindows.farm-state.txt", "r")
    x, y, z, direction = tonumber(file.readLine()), tonumber(file.readLine()), tonumber(file.readLine()),
        tonumber(file.readLine())
    invertDirection = file.readLine() == "true"
    file.close()
    -- check if we were on a boundary block first
    local found, block, ok, err, boundary
    local lastY = y
    repeat
        found, block = turtle.inspectDown()
        if not found then check(down()) end
    until found
    if groundBlocks[block.name] then
        check(up())
        turtle.digDown()
    elseif not cropBlocks[block.name] then
        if y == lastY then lastY = lastY + 1 end
        while y < lastY do check(up()) end
        while not back() do check(up()) end
        boundary = true
    end
    if direction == 1 or direction == 3 then
        -- we were in the middle of a rotation, finish that before continuing
        local mv = (direction == 0) == invertDirection and left or right
        if boundary then
            check(mv())
            check(mv())
            check(tryForward())
            invertDirection = not invertDirection
            mv = mv == left and right or left
            writePos()
        end
        check(mv())
        handleCrop()
        if x == 0 and z == 0 then
            while y > 0 do check(down()) end
            while y < 0 do check(up()) end
            exchangeItems()
        end
    end
elseif not peripheral.find(STORAGE_VESSSEL) then
    print [[
Please move the turtle to the starting position next to a modem with a chest.
The expected setup is the turtle next to a wired modem block, with a chest next to that modem block.
This program cannot run until placed correctly.
]]
return
else
    exchangeItems()
end

local ok, err
while true do
    if turtle.getFuelLevel() > (FUEL_MIN) then
        ok, err = tryForward()
        if not ok then
            if err == "Out of bounds" then
                local mv = (direction == 0) == invertDirection and left or right
                check(mv())
                ok, err = tryForward()
                if not ok then
                    if err == "Out of bounds" then
                        check(mv())
                        check(mv())
                        check(tryForward())
                        invertDirection = not invertDirection
                        mv = mv == left and right or left
                        writePos()
                    else
                        panic(err)
                    end
                end
                check(mv())
            else
                panic(err)
            end
        end
        handleCrop()
        if x == 0 and z == 0 then
            while y > 0 do check(down()) end
            while y < 0 do check(up()) end
            exchangeItems()
        end
        if turtle.getFuelLevel() < 100000 then refuel() end
    else
        print('Waiting on refuel\n\nNeed at least', FUEL_MIN, 'but have', turtle.getFuelLevel())
        sleep(30)
    end
end
