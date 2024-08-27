local whi = require 'warehouse_interface'
COLONY_NAME = 'Nolins'
JUNKLIST_CHEST = ''

-- LOAD JUNK ITEM LIST
local JUNK = {
    'productivebees:wax',
    'minecraft:snowball',
    -- 'minecraft:carrot',
    -- 'minecraft:potato',
    -- 'minecraft:cobbled_deepslate',
    -- 'minecraft:nether_quartz',
    -- 'farm_and_charm:corn',

    'farm_and_charm:kernels',

}

local TRASHCAN = 'ironchests:obsidian_barrel_1'

function IncinerateJunk()
    local count = 0
    for _, item in pairs(JUNK) do
        local this = whi.GetFromAnyWarehouse(false, item, TRASHCAN, 64)
        count = count + this
        print('Burned', this, item)
    end
    local data = {
        incinerator = {
            name = COLONY_NAME,
            incineratedCount = count
        }
    }
    WriteToFile(json.encode(data), "monitorData.json", "w")
end

function WriteToFile(input, fileName, mode)
    local file = io.open(fileName, mode)
    io.output(file)
    io.write(input)
    io.close(file)
end

print('Starting junk incinerator...')
while true do
    -- pcall(IncinerateJunk)
    pcall(IncinerateJunk)
    sleep(120)


    -- TODO
    -- JUNK ITEMS are defined by what's in the designated trash chest.
    -- LOOP THROUGH JUNK CHEST TO CONFIRM IF ALL SHOULD BE DELETED
    -- TRANSFER ITEMS OF EACH TYPE FROM WAREHOUSE TO INCINERATOR WITH .5 SECONDS DELAY
end
