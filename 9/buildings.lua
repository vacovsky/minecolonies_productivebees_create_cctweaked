

local colony = peripheral.find("colonyIntegrator")
local monitor = peripheral.find("monitor")
term.clear()
term.setCursorPos(1,1)


function BoolToYN(input)
    if input then return "Y" else return "N" end
end

function DistanceFrom(x1,y1,x2,y2) return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2) end


if #arg >= 1 then
    local type = ""
    local results = {}
    local buildings = colony.getBuildings()

    for i, building in pairs(buildings) do
        if string.find(building.type, arg[1]) then
            type = building.type
            table.insert(results, {
                pos = "(" .. building.location.x .. ", " .. building.location.z .. ")",
                staffed = #building.citizens > 0,
                guarded = building.guarded,
                level = building.level,
                -- distance = DistanceFrom(building.location.x, building.location.y)
            })
        end
    end
    print("Building:", type)
    print("==========================")
    for b, bb in pairs(results) do
        print(bb.level, bb.pos, "S:" .. BoolToYN(bb.staffed), "G:" .. BoolToYN(bb.guarded))
    end
else
    print("Please give a building type as first arugment")
end
