local chest = 'minecraft:chest'
local deployer = 'create:deployer'
local milk_bucket = 'minecraft:milk_bucket'


function GetMilk()
    local destChest = peripheral.find(chest)
    for slot, item in pairs(peripheral.find(deployer).list()) do
        if item.name == milk_bucket then
            destChest.pullItems('back', slot)
        end
    end
end

while true do
    GetMilk()
    sleep(5)
end
