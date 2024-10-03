
local json = require "lib/json"

local tsdb = { _version = '0.0.1' }

function tsdb.WriteOutput(prefix, data, fileName)
    local processed = {
        timeStamp = os.epoch("utc"),
        [prefix] = {
            name = prefix,
        },
    }
    for k, v in pairs(data) do
        processed[prefix][k] = v
    end
    WriteToFile(json.encode(processed), fileName, "w")
end


function WriteToFile(input, fileName, mode)
    local file = io.open(fileName, mode)
    io.output(file)
    io.write(input)
    io.close(file)
end

return tsdb