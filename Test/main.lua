local socket = require("socket")
local Util = require("Util")
local DataStoreService = require("datastore")

local server = socket.bind("10.20.183.221", 8080)
Util.wait(20)

local ip, port = server:getsockname()

print("Server is running on IP: " .. ip .. " and Port: " .. port)

local Value = DataStoreService.TestPrint("Valentino Ndoni is gay")
local printtotest = tostring(Value)
local KeyName = "Test VISTA College Museum"

print("Datastore returned value | " .. printtotest)

local Datastore do
    if not DataStoreService.GetStore(KeyName) then
        Datastore = DataStoreService.CreateStore(KeyName)
    end
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

--DataStoreService.AddDataToStore(KeyName,{["Naam"] = "Ryzen 9 game pc ofzo"})
--DataStoreService.AddDataToStore("Valentino is gay", {["Blok Name"] = "Freak bob",["Age"] = 19,["Relation"] = "Single", ["Street name"] = "Iva Hoek Van De Blok"})
--printTable(Datastore)
DataStoreService.FindItemsByName(KeyName, "CPU")

function parse_query(query)
    local params = {}
    for k, v in query:gmatch("([^&=?]+)=([^&=?]+)") do
        params[k] = v
    end
    return params
end

while true do
    local client = server:accept()
    print("Client connected.")
    client:settimeout(3)

    local request, err = client:receive("*l")
    if not request then
        print("Error receiving request: " .. (err or "Unknown error"))
        client:close()
    else
        print("Received request: " .. request)

        local path, query = request:match("GET (/[^?]*)%?(.+) HTTP")
        if not path then
            path = request:match("GET (/[^%s]*) HTTP")
        end

        print("Path: " .. (path or "No path"))
        print("Query: " .. (query or "No query"))

        if query then
            local params = parse_query(query)

            local command = params["Command"]
            local id = params["ID"]
            local text = params["Text"]

            print("Command: " .. (command or "No command"))
            print("ID: " .. (id or "No ID"))

            if command and (id or text) then
                local response_body
                if command == "getImage" and id then
                    local image_path = "FotosProducten/" .. id .. ".jpg"
                    local image_file, image_err = io.open(image_path, "rb")

                    print("Handling Image: " .. image_path)

                    if image_file then
                        local image_data = image_file:read("*all")
                        image_file:close()

                        response_body = "HTTP/1.1 200 OK\r\n" ..
                                         "Content-Type: image/jpeg\r\n" ..
                                         "Content-Length: " .. #image_data .. "\r\n" ..
                                         "Connection: keep-alive\r\n" ..
                                         "Access-Control-Allow-Origin: *\r\n" ..
                                         "\r\n" .. image_data
                        print("Sending Image Response...")
                        client:send(response_body)
                    else
                        response_body = "HTTP/1.1 500 Internal Server Error\r\n" ..
                                         "Content-Type: text/plain\r\n" ..
                                         "Content-Length: " .. #image_err .. "\r\n" ..
                                         "Connection: close\r\n" ..
                                         "Access-Control-Allow-Origin: *\r\n" ..
                                         "\r\n" .. image_err
                        print("Sending Image Error: " .. image_err)
                        client:send(response_body)
                    end
                elseif command == "getText" and text then
                    local response_body = text
                    local response = "HTTP/1.1 200 OK\r\n" ..
                                     "Content-Type: text/plain\r\n" ..
                                     "Content-Length: " .. #response_body .. "\r\n" ..
                                     "Connection: keep-alive\r\n" ..
                                     "Access-Control-Allow-Origin: *\r\n" ..
                                     "\r\n" ..
                                     response_body
                
                    client:send(response)
                    client:close()
                elseif command == "findProducts" and text then
                    local response_body = DataStoreService.FindItemsByName(KeyName,text)
                    local response = "HTTP/1.1 200 OK\r\n" ..
                                     "Content-Type: text/plain\r\n" ..
                                     "Content-Length: " .. #response_body .. "\r\n" ..
                                     "Connection: keep-alive\r\n" ..
                                     "Access-Control-Allow-Origin: *\r\n" ..
                                     "\r\n" ..
                                     response_body
                
                    client:send(response)
                    client:close()
                else
                    response_body = "Command: " .. command .. "\nID: " .. id .. "\nStatus: Command not recognized."
                    local response = "HTTP/1.1 200 OK\r\n" ..
                                   "Content-Type: text/plain\r\n" ..
                                   "Content-Length: " .. #response_body .. "\r\n" ..
                                   "Connection: keep-alive\r\n" ..
                                   "Access-Control-Allow-Origin: *\r\n" ..
                                   "\r\n" .. response_body
                    print("Sending Response: " .. response_body) 
                    client:send(response)
                end
            else
                response_body = "Error: Missing Command or ID parameters.\n"
                local response = "HTTP/1.1 400 Bad Request\r\n" ..
                                 "Content-Type: text/plain\r\n" ..
                                 "Content-Length: " .. #response_body .. "\r\n" ..
                                 "Connection: close\r\n" ..
                                 "Access-Control-Allow-Origin: *\r\n" ..
                                 "\r\n" .. response_body
                print("Sending error: " .. response_body) 
                client:send(response)
            end
        else
            local response_body = "Error: Invalid request format.\n"
            local response = "HTTP/1.1 400 Bad Request\r\n" ..
                             "Content-Type: text/plain\r\n" ..
                             "Content-Length: " .. #response_body .. "\r\n" ..
                             "Connection: close\r\n" ..
                             "Access-Control-Allow-Origin: *\r\n" ..
                             "\r\n" .. response_body
            print("Sending error: " .. response_body)
            client:send(response)
        end
        
        client:close()
    end
end
