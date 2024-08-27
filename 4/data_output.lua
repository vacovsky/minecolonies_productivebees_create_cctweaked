local json = require "lib/json"
local colony = require "lib/colony_interface"
-- Specific to colony integrator

local WAIT_SECONDS = 120


--------------------------

print("Beginning monitor loop.")

local loopCounter = 0

while true do
   loopCounter = loopCounter + 1
   print("Loop " .. loopCounter .. " started.")
   local last = colony.GetStatusOfAttachedDevices()

   colony.WriteToFile(json.encode(last), "monitorData.json", "w")
   print("Loop " .. loopCounter .. " finished. Next pass in "..WAIT_SECONDS.." seconds.")
   sleep(WAIT_SECONDS)
end
