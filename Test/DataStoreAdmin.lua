local Datastore = require("datastore")
local DataStorePath = "DataStoreFile/"

local AdminFuctions = {
    ["Test"] = function() 
        io.write("Are u gay ? :")

        local response = io.read()
        print("User said to the question if he is gay !"..response)
    end,
    ["AddProduct"] = function()
        io.write("Datastore naam : ")

        local DatastoreNaam = io.read()
        local Store = io.open(DataStorePath .. DatastoreNaam .. ".json", "r")

        local function AddData()
            io.write("Naam van de product : ")

            local response = io.read()

            io.write("Foto ID : ")

            local FotoID = io.read()

            local GeneratedData = {["Naam"] = response, ["FotoID"] = FotoID,}
            Datastore.AddDataToStore(DatastoreNaam,GeneratedData)
        end

        if Store then
            Store:close()
            AddData()
            print("Data toegevoed")
        else
            print("Datastore is niet gevonden. Will je op *"..DatastoreNaam.."* een datastore maken? Ja/Nee")
            io.write("Ja/Nee : ")

            local response = io.read()
            response = response:lower()

            if response == "ja" then
                Datastore.CreateStore(DatastoreNaam)

                AddData()
                print("Data toegevoed")
            else
                print("Probeer opnieuw")
            end
        end
    end
}

while true do
    io.write("Datastore Commands : ")

    local CommandAsked = io.read()

    if AdminFuctions[CommandAsked] then
        local Function = AdminFuctions[CommandAsked]
        Function()
    else
        print("Command *"..tostring(CommandAsked).."* is niet gevonden. Probeer opnieuw")
    end
end