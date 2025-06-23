local drawNames = true
local drawDistance = 20.0
RegisterCommand("hidenames", function()
    drawNames = not drawNames
    local status = drawNames and "enabled" or "disabled"
    TriggerEvent("chat:addMessage", {
        color = {255, 255, 255},
        args = {"^1[Ocean Palms RP]", "^7You have " .. status .. " name tags."}
    })
end, false)

local showSelf = true -- set to false if you want to hide your own tag


local function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local camCoords = GetGameplayCamCoords()
    local dist = #(camCoords - vector3(x, y, z))

    if onScreen then
        local scale = (1 / dist) * 1.2
        local fov = (1 / GetGameplayCamFov()) * 100
        scale = scale * fov

        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextCentre(true)
        SetTextColour(255, 255, 255, 230)
        SetTextOutline()

        -- Measure actual text width on screen
        BeginTextCommandWidth("STRING")
        AddTextComponentString(text)
        local textWidth = EndTextCommandGetWidth(0)  -- 0 = default font
        local padding = 0.005
        local backgroundWidth = textWidth + padding
        local backgroundHeight = 0.025

        -- Draw background rectangle
        DrawRect(_x, _y + 0.012, backgroundWidth, backgroundHeight, 30, 30, 30, 150)

        -- Draw the actual text
        SetTextEntry("STRING")
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end



Citizen.CreateThread(function()
    while true do
        Wait(0)

        if drawNames then -- ⬅️ Check this flag before drawing
            local myPed = PlayerPedId()
            local myCoords = GetEntityCoords(myPed)

            for _, player in ipairs(GetActivePlayers()) do
                local ped = GetPlayerPed(player)
                if DoesEntityExist(ped) and not IsEntityDead(ped) then
                    local coords = GetEntityCoords(ped)
                    local dist = #(myCoords - coords)

                    if dist < drawDistance then
                        if showSelf or player ~= PlayerId() then
                            local serverId = GetPlayerServerId(player)
                            local playerName = GetPlayerName(player) or "Unknown"
                            local isTalking = NetworkIsPlayerTalking(player)
                            local voiceStatus = isTalking and "~g~[Talking]" or "~r~[Not Talking]"
                            local tag = string.format("%s ~s~ %s ~c~ [%s]", voiceStatus, playerName, serverId)

                            local headCoords = vector3(coords.x, coords.y, coords.z + 1.05)
                            DrawText3D(headCoords.x, headCoords.y, headCoords.z, tag)
                        end
                    end
                end
            end
        end
    end
end)
