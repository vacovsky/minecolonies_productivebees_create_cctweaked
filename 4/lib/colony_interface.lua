local colonylib = { _version = '0.0.1' }
local json = require "lib/json"

local DEVICES = {}
local CHEAP_VISITORS_WANT = {
    "minecraft:hay_block",
    "minecraft:sunflower",
    "minecraft:cactus",
    "minecraft:gold_ingot",
    "minecraft:iron_ingot"
}

function colonylib.LoadDevices()
    for k, v in pairs(peripheral.getNames()) do
        DEVICES[v] = peripheral.getMethods(v)
    end
    colonylib.WriteToFile(json.encode(DEVICES), "devices.json", "w")
end

function string.starts(String, Start)
    return string.sub(String, 1, string.len(Start)) == Start
end

function colonylib.GetSickCitizenCount()
    local ci = peripheral.find('colonyIntegrator')
    colonylib.WriteToFile(json.encode(ci.getCitizens()), 'cits.json', 'w')
    local counter = 0
    local ci = peripheral.find('colonyIntegrator')
    for _, cit in pairs(ci.getCitizens()) do
        if cit.state == 'Sick' then counter = counter + 1 end
    end
    return counter
end

function colonylib.GetSleepingCitizenCount()
    local counter = 0
    local ci = peripheral.find('colonyIntegrator')
    for _, cit in pairs(ci.getCitizens()) do
        if cit.isAsleep then counter = counter + 1 end
    end
    return counter
end

function colonylib.GetHungryCitizenCount()
    local counter = 0
    local ci = peripheral.find('colonyIntegrator')
    for _, cit in pairs(ci.getCitizens()) do
        if cit.betterFood then counter = counter + 1 end
    end
    return counter
end

function colonylib.GetUnstaffedBuldingTypes()
    local buildingTypes = {}
    local count = 0
    for k, b in pairs(buildings) do
        if b.type ~= "residence"
            and b.type ~= "mysticalsite"
            and b.type ~= "barracks"
            and b.type ~= "townhall" then
            if b.level > 0 and #b.citizens == 0 then
                count = count + 1
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

function colonylib.WriteToFile(input, fileName, mode)
    local file = io.open(fileName, mode)
    io.output(file)
    io.write(input)
    io.close(file)
end

function colonylib.Tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

function colonylib.GetStatusOfAttachedDevices()
    local MM = {}
    MM.timeStamp = os.epoch("utc")
    for deviceName, v in pairs(DEVICES) do
        local device = peripheral.wrap(deviceName)
        MM[deviceName] = {}
        for _, method in pairs(v) do
            -- TODO make whitelist or blacklist for methods and devices
            if method == "amountOfCitizens"
                or method == "getHappiness"
                or method == "maxOfCitizens"
                -- or method == "getCitizens"
                or method == "isUnderAttack"
                or method == "isUnderRaid"
                or method == "getRequests"
                or method == "getBuildings"
                or method == "isUnderRaid"
                or method == "getVisitors"
                or method == "getRequests"
                or method == "getWorkOrders"
            then
                local result = device[method]()
                print(device, method, result)

                -- if type(result) == table and result.tags ~= nil then
                --    print(result)
                --    result.tags = {}
                -- end
                if method == "getBuildings"
                    or method == "getRequests"
                    or method == "getWorkOrders"
                    or method == "getVisitors" then
                    local count = 0
                    for _, item in pairs(result) do
                        count = count + 1
                    end
                    result = count
                end
                MM[deviceName][method] = result
                MM[deviceName]["name"] = "Nolins"
            end
        end
    end

    MM['colonyIntegrator'] = {

    }
    MM['colonyIntegrator']["name"] = "Nolins"
    MM['colonyIntegrator']['getHungryCitizens'] = colonylib.GetHungryCitizenCount()
    MM['colonyIntegrator']['getSleepingCitizens'] = colonylib.GetSleepingCitizenCount()
    MM['colonyIntegrator']['getSickCitizens'] = colonylib.GetSickCitizenCount()
    MM['colonyIntegrator']['getWarehouseUsedPercent'] = colonylib.GetWarehouse()
    return MM
end

function colonylib.GetConstructionCount()
    local buildings = peripheral.find('colonyIntegrator').getBuildings()
    local count = 0
    for k, v in pairs(buildings) do
        if not v.built then count = count + 1 end
    end
    return count
end

function colonylib.GetCheapVisitors()
    local visitors = peripheral.find('colonyIntegrator').getVisitors()
    local count = 0
    for k, v in pairs(visitors) do
        for i, p in pairs(CHEAP_VISITORS_WANT) do
            if p == v.recruitCost.name then count = count + 1 end
        end
    end
    return count
end

function colonylib.GetUnemployedCitizens()
    local count = 0
    local citizens = peripheral.find('colonyIntegrator').getCitizens()
    -- WriteToFile(json.encode(citizens), "citizens.json", "w")
    for k, v in pairs(citizens) do
        if v.work ~= nil and (v.work.job == "com.minecolonies.job.student" or v.work.job == nil) then
            count = count + 1
        end
    end
    return count
end

function colonylib.GetActiveResearchCount()
    local count = 0
    for k, v in pairs(research) do
        if not v.built then count = count + 1 end
    end
    return count
end

-------------- BUILDINGS --------------
function colonylib.GetUnstaffedBuldingCount()
    local buildings = peripheral.find('colonyIntegrator').getBuildings()
    local count = 0
    for k, b in pairs(buildings) do
        if b.maxLevel > 0 and #b.citizens == 0 then count = count + 1 end
    end
end

function colonylib.GetAverageBuildingLevel() -- actual, possible
    local buildings = peripheral.find('colonyIntegrator').getBuildings()
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

function colonylib.GetUnstaffedBuldingTypes()
    local buildings = peripheral.find('colonyIntegrator').getBuildings()
    local buildingTypes = {}
    local count = 0
    for k, b in pairs(buildings) do
        if b.type ~= "residence"
            and b.type ~= "mysticalsite"
            and b.type ~= "barracks"
            and b.type ~= "townhall" then
            if b.level > 0 and #b.citizens == 0 then
                count = count + 1
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

function colonylib.GetGuardedBuildingsCount()
    local buildings = peripheral.find('colonyIntegrator').getBuildings()
    local count = 0
    for k, v in pairs(buildings) do
        if v.guarded then count = count + 1 end
    end
    return count
end

function colonylib.GetResearchedCount()
    local research = peripheral.find('colonyIntegrator').getResearch()
    local count = 0
    for k, v in pairs(research) do
        print(v.status)
        -- if not v.built then constructionSites = constructionSites + 1 end
    end
    return count
end

function colonylib.GetOpenRequestsCount()
    local requests = peripheral.find('colonyIntegrator').getRequests()
    local count = 0
    for k, v in pairs(requests) do
        count = count + 1
    end
    return count
end

function colonylib.GetWarehouse()
    local result = {
        total = 0,
        used = 0,
        percentUsed = 0.0
    }
    local peripherals = peripheral.getNames()
    for _, per in pairs(peripherals) do
        if string.find(per, "minecolonies:warehouse") then
            local wh = peripheral.wrap(per)
            if wh ~= nil then
                result.total = result.total + wh.size()
                result.used = result.used + #wh.list()
            end
        end
    end
    result.percentUsed = (result.used / result.total) * 100
    return result
end

function colonylib.GetIdleBuilders()
    local citizens = peripheral.find('colonyIntegrator').getCitizens()
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


print("Loading devices.")
colonylib.LoadDevices()
print(colonylib.Tablelength(DEVICES) .. " Devices loaded.")

return colonylib
