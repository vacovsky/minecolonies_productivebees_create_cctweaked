
local network = { _version = '1.0.1' }

function network.ListMatchingDevices(devStr)
    local peripherals = peripheral.getNames()
    local devices = {}
    for _, attached_peripheral in pairs(peripherals) do
        if string.find(attached_peripheral, devStr) then
            devices[#devices + 1] = attached_peripheral
        end
    end
    return devices
end

return network