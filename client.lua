-- Coordinates Display Script
-- Author: SensiCode99 & Integrated with additional chat display functionality

local showCoords = false -- Variable to track if coordinates should be displayed

-- Function to display colored coordinates on the screen
function displayCoords(x, y, z, heading)
    -- Set text font and size
    SetTextFont(4)         -- Use a smaller font
    SetTextProportional(1)
    SetTextScale(0.5, 0.5) -- Smaller text size

    -- Begin drawing the text
    SetTextEntry("STRING")

    -- Set text color to white
    SetTextColour(0, 255, 255, 255) -- White color

    -- Add all coordinates in one string
    AddTextComponentString(string.format("X: %.2f | Y: %.2f | Z: %.2f | Heading: %.2f", x, y, z, heading))

    -- Position the text at the bottom right of the screen and draw
    DrawText(0.6, 0.9) -- Adjusted position for better visibility
end

-- Function to display street names on the screen
function displayStreetNames(streetName, crossStreetName)
    -- Set text font and size
    SetTextFont(4)
    SetTextProportional(1)
    SetTextScale(0.6, 0.6) -- Smaller text size

    -- Begin drawing the text for street names
    SetTextEntry("STRING")

    -- Set text color for street names
    SetTextColour(178, 34, 34, 255) -- Yellow color for street names

    -- Add street names in one string
    AddTextComponentString(string.format("Street: %s | Cross Street: %s", streetName, crossStreetName))

    -- Position the text at the bottom center of the screen and draw
    DrawText(0.5, 0.85) -- Adjust position for visibility
end

-- Function to display coordinates in a chat message
function displayChatCoordinates()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local playerHeading = GetEntityHeading(playerPed)

    -- Format coordinates and heading with colors
    local x = string.format("~r~X: %.2f", playerCoords.x)            -- Red
    local y = string.format("~g~Y: %.2f", playerCoords.y)            -- Green
    local z = string.format("~b~Z: %.2f", playerCoords.z)            -- Blue
    local heading = string.format("~m~Heading: %.2f", playerHeading) -- Magenta

    -- Display coordinates in a chat message
    TriggerEvent('chat:addMessage', {
        color = { 255, 255, 255 },
        multiline = true,
        args = { "Coordinates", string.format("%s, %s, %s | %s", x, y, z, heading) }
    })
end

-- Command to toggle both on-screen and chat display of coordinates
RegisterCommand('coords', function()
    showCoords = not showCoords  -- Toggle the showCoords variable
    if showCoords then
        displayChatCoordinates() -- Show coordinates immediately when toggled on
        print("Coordinates display enabled.")

        Citizen.CreateThread(function()
            while showCoords do
                Citizen.Wait(5000) -- Update chat every 5 seconds
                displayChatCoordinates()
            end
        end)
    else
        TriggerEvent('chat:addMessage', {
            color = { 255, 0, 0 },
            multiline = true,
            args = { "Coordinates", "Coordinates display toggled off." }
        })
        print("Coordinates display disabled.")
    end
end)

-- Street Handler
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(12)

        local playerID                    = PlayerPedId() -- Corrected function name
        local playerCoordinates           = GetEntityCoords(playerID)
        local streetHash, crossStreetHash = GetStreetNameAtCoord(table.unpack(playerCoordinates))
        local streetName                  = GetStreetNameFromHashKey(streetHash)
        local crossStreetName             = GetStreetNameFromHashKey(crossStreetHash)

        -- Removed console printing of street names
        -- Print street names to console (for debugging)
        -- print('LOCATION', streetName, crossStreetName)

        -- Display street names on screen
        if showCoords then
            displayStreetNames(streetName, crossStreetName)
        end
    end
end)

-- Draw coordinates on the screen every frame if toggled on
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if showCoords then
            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed)
            displayCoords(coords.x, coords.y, coords.z, GetEntityHeading(playerPed))
        end
    end
end)