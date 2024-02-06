Citizen.CreateThread(function()
	while true do
		Citizen.Wait(2000)

		playerPed = GetPlayerPed(-1)
		if playerPed then
			checkCar(GetVehiclePedIsIn(playerPed, false))

			x, y, z = table.unpack(GetEntityCoords(playerPed, true))
			for _, blacklistedCar in pairs(carblacklist) do
				checkCar(GetClosestVehicle(x, y, z, 100.0, GetHashKey(blacklistedCar), 70))
			end
		end
	end
end)

function checkCar(car)
    if car then
        local carModel = GetEntityModel(car)
        local carName = GetDisplayNameFromVehicleModel(carModel)

        if isCarBlacklisted(carModel) then
            local playerId = GetPlayerServerId(NetworkGetEntityOwner(car))

            ESX.TriggerServerCallback("controllo:admin", function(group)
                if group == "user" then
                    FreezeEntityPosition(car, true)

                    exports['screenshot-basic']:requestScreenshotUpload("IMPOSTA IL TUO WEBHOOK DI DISCORD", "files[]", function(data) 
                        local image = json.decode(data)

                        if image and image.attachments and image.attachments[1] and image.attachments[1].proxy_url then
                            DestroyMobilePhone() 
                            CellCamActivate(false, false) 
                            TriggerEvent('chatMessage', 'BLACKLIST', {255, 0, 0}, 'Veicolo blacklistato rilevato! Giocatore ID: ' .. playerId)
                            _DeleteEntity(car)
							FreezeEntityPosition(car, false)
                            TriggerServerEvent('ban:modder', 'Veicolo Blacklistato')	
                        else
                            print("Errore nel caricamento dell'immagine o nell'URL del webhook.")
                        end
                    end)
                else
                    
                end
            end)
        end
    end
end




function isCarBlacklisted(model)
	for _, blacklistedCar in pairs(carblacklist) do
		if model == GetHashKey(blacklistedCar) then
			return true
		end
	end

	return false
end

function _DeleteEntity(entity)
	Citizen.InvokeNative(0xAE3CBE5BF394C9C9, Citizen.PointerValueIntInitialized(entity))
end