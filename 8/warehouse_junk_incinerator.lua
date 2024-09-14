local json = require "lib/json"

local whi = require 'lib/warehouse_interface'
COLONY_NAME = 'Nolins'
JUNKLIST_CHEST = ''

-- LOAD JUNK ITEM LIST
local JUNK = {
    'productivebees:wax',
    'minecraft:snowball',
    'gravestone:obituary',
    'farm_and_charm:kernels',
}

local TRASHCAN = 'ironchests:diamond_chest_0'

function IncinerateJunk()
    local count = 0
    for _, item in pairs(JUNK) do
        local this = whi.GetFromAnyWarehouse(false, item, TRASHCAN, 64)
        count = count + this
        print('Burned', this, item)
    end

    local data = {
        timeStamp = os.epoch("utc"),
        junkincinerator = {
            name = COLONY_NAME,
            incineratedJunkCount = count
        }
    }
    WriteToFile(json.encode(data), "incineratorData.json", "w")
end

function WriteToFile(input, fileName, mode)
    local file = io.open(fileName, mode)
    io.output(file)
    io.write(input)
    io.close(file)
end

print('Starting junk incinerator...')
while true do
    -- IncinerateJunk()
    pcall(IncinerateJunk)
    sleep(600)


    -- TODO
    -- JUNK ITEMS are defined by what's in the designated trash chest.
    -- LOOP THROUGH JUNK CHEST TO CONFIRM IF ALL SHOULD BE DELETED
    -- TRANSFER ITEMS OF EACH TYPE FROM WAREHOUSE TO INCINERATOR WITH .5 SECONDS DELAY
end
