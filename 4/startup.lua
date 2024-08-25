
shell.openTab("data_output")

json = require "json"

----------------------------------
-- CONFIGURATION SECTION
local REFRESH_TIME = 60
local CHEAP_VISITORS_WANT = {
    "minecraft:hay_block",
    "minecraft:sunflower",
    "minecraft:cactus",
    "minecraft:gold_ingot",
    "minecraft:iron_ingot"
}

-- END CONFIGURATION SECTION
----------------------------------
local colony = peripheral.find("colonyIntegrator")
local monitor = peripheral.find("monitor")
local warehouse = peripheral.find("minecolonies:warehouse")

if monitor ~= nil then
    monitor.clear()
end

local buildings = nil
local citizens = nil
local requests = nil
local research = nil
local visitors = nil

function Main()
    getWarehouse()
    if colony.isInColony() then
        refreshColonyInfo()
    else
        displayOutOfRangeWarning()
    end
    return true
end

function WriteToFile(input, fileName, mode)
    local file = io.open(fileName, mode)
    io.output(file)
    io.write(input)
    io.close(file)
 end

function displayOutOfRangeWarning()
    term.setBackgroundColor(colors.red)  -- Set the background colour to black.
    term.clear()                            -- Paint the entire display with the current background colour.
    term.setCursorPos(0,10)
    printWithFormat("&0!!!!!  OUT  OF  RANGE  !!!!")
end

function refreshColonyInfo()
    citizens = colony.getCitizens()
    buildings = colony.getBuildings()
    requests = colony.getRequests()
    visitors = colony.getVisitors()
    if visitors == nil then
        visitors = 0
    end
    -- research = colony.getResearch()
    -- WriteToFile(json.encode(citizens), "citizens.json", "w")
    if monitor == nil then displayLatestColonyInfo() else displayLatestColonyInfoInMonitor() end
end

function printWithFormat(...)
    local s = "&1"
    for k, v in ipairs(arg) do
            s = s .. v
    end
    s = s .. "&0"

    local fields = {}
    local lastcolor, lastpos = "0", 0
    for pos, clr in s:gmatch"()&(%x)" do
            table.insert(fields, {s:sub(lastpos + 2, pos - 1), lastcolor})
            lastcolor, lastpos = clr , pos
    end

    for i = 2, #fields do
            term.setTextColor(2 ^ (tonumber(fields[i][2], 16)))
            io.write(fields[i][1])
    end
end
------------------------CONSOLE-----------------
function displayLatestColonyInfo()
    term.setBackgroundColor(colors.black)  -- Set the background colour to black.
    term.clear()                            -- Paint the entire display with the current background colour.
    term.setCursorPos(1,1)

    local warehouseStats = getWarehouse()
    printWithFormat("&3", colony.getColonyName(), "(id:", colony.getColonyID() .. ")")
    print("==========================")

    printWithFormat("&0")

    print("Style: ", colony.getColonyStyle())
    print("Happiness:", string.format("%.2f",((colony.getHappiness() * 10) / 10)), "/ 10")
    print("Citizens: ", colony.amountOfCitizens(), "/", colony.maxOfCitizens(), "|", GetUnemployedCitizens())
    print("Visitors: ", #visitors, "~", GetCheapVisitors())
    print("Buildings: ", #buildings, "~", getConstructionCount())
    print("Avg Bld. Lvl: ", GetAverageBuildingLevel().avg, "/", GetAverageBuildingLevel().total)

    -- local warehouseVal = string.format("%.2f",((warehouseStats.percentUsed * 10) / 10)) .. "% used"
    print("Warehouse Use: ", string.format("%.2f",((warehouseStats.percentUsed * 10) / 10)) .. "%")


    -- print("Research:", getResearchedCount(), "/", #research)

    print()
    print()
    printWithFormat("&e!!!!!!!   Alerts   !!!!!!!")
    print("==========================")
    printWithFormat("&0")

    if colony.isUnderAttack() then
        printWithFormat("&e")
        print("- Colony under attack!")
        printWithFormat("&0")
    end

    local ibc, idleBuilders = getIdleBuilders()
    if getIdleBuilders() > 0 then
        printWithFormat("&4")
        print("-", ibc, "idle builders")
        for bni, bn in pairs(idleBuilders) do
            print("  -", bn)
        end
        printWithFormat("&0")
    end

    if colony.amountOfCitizens() + 2 >= colony.maxOfCitizens() then
        printWithFormat("&6")
        print("-", colony.maxOfCitizens() - colony.amountOfCitizens(), "open beds")
        printWithFormat("&0")
    end

    if getOpenRequestsCount() > 0 then
        printWithFormat("&4")
        print("-", getOpenRequestsCount(), "open requests")
        printWithFormat("&0")
    end

    if getGuardedBuildingsCount() < #buildings then
        printWithFormat("&4")
        print("-", #buildings - getGuardedBuildingsCount(), "unguarded buildings")
        printWithFormat("&0")
    end

    if colony.getHappiness() <= 8.5 then
        printWithFormat("&3")
        print("- Happiness is low:", string.format("%.2f",((colony.getHappiness() * 10) / 10)))
        printWithFormat("&0")
    end

    local unstaffedBuildings, totalUnstaffed = GetUnstaffedBuldingTypes()
    if totalUnstaffed > 0 then
        printWithFormat("&e")
        print("-", totalUnstaffed, "unstaffed buildings")
        for type, count in pairs(unstaffedBuildings) do
            print("  -", count, type)
        end
        printWithFormat("&0")
    end
    -- if colony.mourning then print("- Recent death") end
end



--------------------MONITOR---------------------
function RightJustify(input, line)
    monitor.setCursorPos(monitor.getSize() - string.len(input), line)
end

function displayLatestColonyInfoInMonitor()
    local line = 1
    monitor.setTextScale(1)
    monitor.clear()
    monitor.setCursorPos(1, line)
    monitor.setTextColor(8)
    monitor.write(colony.getColonyName())

    local colonyIdMsg = "id: " .. colony.getColonyID()
    monitor.setCursorPos(monitor.getSize() - string.len(colonyIdMsg), line)
    monitor.write("id:" .. colony.getColonyID())

    line = line + 1
    monitor.setCursorPos(1, line)
    monitor.write("=============================")

    line = line + 2
    monitor.setCursorPos(1, line)
    monitor.setTextColor(1)
    monitor.write("Style")
    RightJustify(colony.getColonyStyle(), line)
    monitor.write(colony.getColonyStyle())

    line = line + 1
    monitor.setCursorPos(1, line)
    monitor.setTextColor(1)
    monitor.write("Happiness")
    local happyValue = string.format("%.2f",((colony.getHappiness() * 10) / 10)) .. " / 10"
    RightJustify(happyValue, line)
    monitor.write(happyValue)

    line = line + 1
    monitor.setCursorPos(1, line)
    monitor.setTextColor(1)
    monitor.write("Citizens")
    local citizenValues = tostring(colony.amountOfCitizens() .. " / " .. colony.maxOfCitizens() .. " | " .. GetUnemployedCitizens())
    RightJustify(citizenValues, line)
    monitor.write(citizenValues)

    line = line + 1
    monitor.setCursorPos(1, line)
    monitor.setTextColor(1)
    monitor.write("Buildings")
    local buildingValues = tostring(#buildings .. " ~ " .. getConstructionCount())
    RightJustify(buildingValues, line)
    monitor.write(buildingValues)

    line = line + 1
    monitor.setCursorPos(1, line)
    monitor.setTextColor(1)
    monitor.write("Avg Bld Lvl")
    local moreBuildingValues = tostring(GetAverageBuildingLevel().avg  .. " / " .. GetAverageBuildingLevel().total)
    RightJustify(moreBuildingValues, line)
    monitor.write(moreBuildingValues)


    line = line + 1
    monitor.setCursorPos(1, line)
    monitor.setTextColor(1)
    monitor.write("Visitors")
    local visitorValue = tostring(#visitors .. " ~ " .. GetCheapVisitors())
    RightJustify(visitorValue, line)
    monitor.write(visitorValue)



    line = line + 1
    local warehouseStats = getWarehouse()
    monitor.setCursorPos(1, line)
    monitor.setTextColor(1)
    monitor.write("Warehouse")
    local warehouseVal = string.format("%.2f",((warehouseStats.percentUsed * 10) / 10)) .. "% used"
    RightJustify(warehouseVal, line)
    monitor.write(warehouseVal)
    -- print("Warehouse Cap.:", string.format("%.2f",((warehouseStats.percentUsed * 10) / 10)), "/ 10")



    line = line + 3
    monitor.setCursorPos(1, line)
    monitor.setTextColor(16384)
    monitor.write("!!!!!!!!   Alerts   !!!!!!!!!")
    line = line + 1
    monitor.setCursorPos(1, line)
    monitor.write("=============================")
    line = line + 1

    if colony.isUnderAttack() then
        line = line + 1
        monitor.setCursorPos(1, line)
        monitor.setTextColor(16384)
        monitor.write("- Colony under attack!")
    end

    local ibc, idleBuilders = getIdleBuilders()
    if getIdleBuilders() > 0 then
        line = line + 1
        monitor.setCursorPos(1, line)
        monitor.setTextColor(16)
        monitor.write("- " .. ibc .. " idle builders")
        for bni, bn in pairs(idleBuilders) do
            line = line + 1
            monitor.setCursorPos(1, line)
            monitor.write("  - " .. bn)
        end
    end

    if colony.amountOfCitizens() + 2 >= colony.maxOfCitizens() then
        line = line + 1
        monitor.setCursorPos(1, line)
        monitor.setTextColor(64)
        monitor.write("- " .. colony.maxOfCitizens() - colony.amountOfCitizens() .. " open beds")
    end

    if getOpenRequestsCount() > 0 then
        line = line + 1
        monitor.setCursorPos(1, line)
        monitor.setTextColor(1)
        monitor.write("- " .. getOpenRequestsCount() .. " open requests")
    end

    if getGuardedBuildingsCount() < #buildings then
        line = line + 1
        monitor.setCursorPos(1, line)
        monitor.setTextColor(16)
        monitor.write("- " .. #buildings - getGuardedBuildingsCount() ..  " unguarded buildings")
    end

    if colony.getHappiness() <= 8.5 then
        line = line + 1
        monitor.setCursorPos(1, line)
        monitor.setTextColor(8)
        monitor.write("- Happiness is low: " .. string.format("%.2f",((colony.getHappiness() * 10) / 10)))
    end

    local unstaffedBuildings, totalUnstaffed = GetUnstaffedBuldingTypes()
    if totalUnstaffed > 0 then
        line = line + 1
        monitor.setCursorPos(1, line)
        monitor.setTextColor(16384)
        monitor.write("- " .. totalUnstaffed .. " unstaffed buildings")
        for type, count in pairs(unstaffedBuildings) do
            line = line + 1
            monitor.setCursorPos(1, line)
            monitor.write("  - " .. count .. " " .. type)
        end
    end
    -- -- if colony.mourning then print("- Recent death") end
end

function getConstructionCount()
    local count = 0
    for k, v in pairs(buildings) do
        if not v.built then count = count + 1 end
    end
    return count
end

function GetCheapVisitors()
    local count = 0
    for k, v in pairs(visitors) do
        for i, p in pairs(CHEAP_VISITORS_WANT) do
            if p == v.recruitCost.name then count = count + 1 end
        end
    end
    return count
end

function GetUnemployedCitizens()
    local count = 0
    -- WriteToFile(json.encode(citizens), "citizens.json", "w")

    for k, v in pairs(citizens) do
        if v.work ~= nil and (v.work.job == "com.minecolonies.job.student" or v.work.job == nil) then
            count = count + 1
        end
    end
    return count
end

function getActiveResearchCount()
    local count = 0
    for k, v in pairs(research) do
        if not v.built then count = count + 1 end
    end
    return count
end

-------------- BUILDINGS --------------
function GetUnstaffedBuldingCount() 
    local count = 0
    for k, b in pairs(buildings) do
        if b.maxLevel > 0 and #b.citizens == 0 then count = count + 1 end
    end
end

function GetAverageBuildingLevel() -- actual, possible
    local actualTotal = 0
    local maxTotal = 0
    local count = 0
    for k, b in pairs(buildings) do
        if b.maxLevel > 0 then
            count = count + 1
            maxTotal = maxTotal + b.maxLevel
            actualTotal = actualTotal + b.level
        end
    end
    return {
        avg = string.format("%.2f", ((actualTotal / count))),
        total = string.format("%.2f", ((maxTotal / count)))
    }
end

function GetUnstaffedBuldingTypes()
    local buildingTypes = {}
    local count = 0
    for k, b in pairs(buildings) do
        if b.type ~= "residence" 
        and b.type ~= "mysticalsite"
        and b.type ~= "barracks"
        and b.type ~= "townhall" then
            if b.level > 0 and #b.citizens == 0 then
                count =  count + 1
                if buildingTypes[b.type] ~= nil then
                    -- print(b.type, buildingTypes[b.type])
                    buildingTypes[b.type] = buildingTypes[b.type] + 1
                else
                    buildingTypes[b.type] = 1
                end
            end
        end 
    end
    return buildingTypes, count
end

function getGuardedBuildingsCount()
    local count = 0
    for k, v in pairs(buildings) do
        if v.guarded then count = count + 1 end
    end
    return count
end

function getResearchedCount()
    local count = 0
    for k, v in pairs(research) do
        print(v.status)
        -- if not v.built then constructionSites = constructionSites + 1 end
    end
    return count
end

function getOpenRequestsCount()
    local count = 0
    for k, v in pairs(requests) do
        count = count + 1
    end
    return count
end


function getWarehouse()
    local result = {
        total = 0,
        used = 0,
        percentUsed = 0.0
    }
    if warehouse ~= nil then
        result.total = warehouse.size()
        result.used = #warehouse.list()
        result.percentUsed = (result.used / result.total) * 100
    end
    return result
end

function getIdleBuilders()
    local idleBuilders = {}
    local count = 0
    for k, v in pairs(citizens) do
        if v.work ~= nil and (v.work.job == "com.minecolonies.job.builder" and v.isIdle) then
            count = count + 1
            table.insert(idleBuilders, v.name)
        end
    end
    return count, idleBuilders
end

function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
  end

while true do
    Main()
    -- pcall(Main)
    sleep(REFRESH_TIME)
end
