local Json = require("json")

local DataStorePath = "DataStoreFile/"

local module = {}

--//Store datastore functions.
function module.CreateStore(StoreName)
    local Store = io.open(DataStorePath .. StoreName .. ".json", "w")

    if Store then
        local NewData = {["Producten"] = {}}

        Store:write(Json.encode(NewData))
        Store:close()
        print("Store : "..StoreName.." has been succesfully created.")
    else
        print("Failed to create store: " .. StoreName)
    end
end

function module.GetStore(StoreName)
    local Store = io.open(DataStorePath..StoreName..".json", "r")
    
    if not Store then
        module.CreateStore(StoreName)

        return module.GetStore(StoreName)
    elseif Store then
        return Store
    end
end

function module.IsStoreValid(StoreName)
    local Store = io.open(DataStorePath..StoreName..".json", "r")
    
    if Store then
        return true
    else
        return false
    end
end

--//Data store function something kk
function module.AddDataToStore(StoreName, Value, Index)
    local ValidStore = module.IsStoreValid(StoreName)

    if ValidStore then
        local Store = module.GetStore(StoreName)
        local ReadedStore = Store:read("*a")
        local DecodedData = Json.decode(ReadedStore)

        print(DecodedData["Producten"])

        --[[if Index then
            DecodedData["Producten"][Index] = Value
        else
            local Count = module.GetCountOffKeys(DecodedData["Producten"])

            DecodedData["Producten"][tostring(Count)] = Value
        end]]

        table.insert(DecodedData["Producten"], Value)

        local EncodedData = Json.encode(DecodedData)
        local File = io.open(DataStorePath.. StoreName..".json","w")
        print(EncodedData)
        File:write(EncodedData)
        File:close()
    else
        print("Datastore is not valid. Please check if the datastore is valid or not.")
    end
end

function module.GetCountOffKeys(Directory)
    local Count = 1
    
    if Directory then
        for i, v in pairs(Directory) do
            Count = Count + 1
        end
    end

    return Count
end
--//Test functions for datastore
function module.TestPrint(stringtoprint)
    print(stringtoprint)

    return true
end

function printTable(t, indent)
    indent = indent or 0
    local prefix = string.rep("  ", indent)

    for key, value in pairs(t) do
        if type(value) == "table" then
            print(prefix .. tostring(key) .. ": {")
            printTable(value, indent + 1)
            print(prefix .. "}")
        else
            print(prefix .. tostring(key) .. ": " .. tostring(value))
        end
    end
end

function module.FindItemsByName(StoreName, KeyWord)
    local ValidStore = module.IsStoreValid(StoreName)

    if ValidStore then
        local lowerKeyWord = KeyWord:lower()

        local Store = module.GetStore(StoreName)
        local ReadedStore = Store:read("*a")
        local DecodedData = Json.decode(ReadedStore)

        local FoundItems = {}

        for i, v in pairs(DecodedData["Producten"]) do
            local Naam = v["Naam"]
            if Naam:lower():find(lowerKeyWord) then
                table.insert(FoundItems, v)
            end
        end

        return Json.encode(FoundItems)
    end
end

return module