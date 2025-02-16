-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
cRP = {}
Tunnel.bindInterface("tencode",cRP)
vSERVER = Tunnel.getInterface("tencode")
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADBUTTON
-----------------------------------------------------------------------------------------------------------------------------------------
local policeRadar = false
local policeFreeze = false
local policeService = false
-----------------------------------------------------------------------------------------------------------------------------------------
-- NOTIFYPUSH
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("notifyShooting")
AddEventHandler("notifyShooting",function(coords)
	if policeService then
		TriggerEvent("NotifyPush",{ code = "10", title = "Confronto em andamento", x = coords["x"], y = coords["y"], z = coords["z"], criminal = "Disparos de arma de fogo", blipColor = 6 })
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- POLICE:UPDATESERVICE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("police:updateService")
AddEventHandler("police:updateService",function(status)
	policeService = status
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLOSESYSTEM
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("closeSystem",function()
	SetNuiFocus(false,false)
	SetCursorLocation(0.5,0.5)
	SendNUIMessage({ tencode = false })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SENDCODE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("sendCode",function(data)
	SetNuiFocus(false,false)
	SetCursorLocation(0.5,0.5)
	vSERVER.sendCode(data["code"])
	SendNUIMessage({ tencode = false })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADRADAR
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	SetNuiFocus(false,false)

	while true do
		local timeDistance = 999
		local ped = PlayerPedId()
		if IsPedInAnyPoliceVehicle(ped) and policeService then
			if policeRadar then
				if not policeFreeze then
					timeDistance = 100

					local vehicle = GetVehiclePedIsUsing(ped)
					local vehicleDimension = GetOffsetFromEntityInWorldCoords(vehicle,0.0,1.0,1.0)

					local vehicleFront = GetOffsetFromEntityInWorldCoords(vehicle,0.0,105.0,0.0)
					local vehicleFrontShape = StartShapeTestCapsule(vehicleDimension,vehicleFront,3.0,10,vehicle,7)
					local _,_,_,_,vehFront = GetShapeTestResult(vehicleFrontShape)

					if IsEntityAVehicle(vehFront) then
						local vehModel = GetEntityModel(vehFront)
						local vehHash = vRP.vehicleModel(vehModel)
						local vehSpeed = GetEntitySpeed(vehFront) * 3.6
						local vehPlate = GetVehicleNumberPlateText(vehFront)

						SendNUIMessage({ radar = "top", plate = vehPlate, model = vehicleName(vehHash), speed = vehSpeed })
					end

					local vehicleBack = GetOffsetFromEntityInWorldCoords(vehicle,0.0,-105.0,0.0)
					local vehicleBackShape = StartShapeTestCapsule(vehicleDimension,vehicleBack,3.0,10,vehicle,7)
					local _,_,_,_,vehBack = GetShapeTestResult(vehicleBackShape)

					if IsEntityAVehicle(vehBack) then
						local vehModel = GetEntityModel(vehBack)
						local vehHash = vRP.vehicleModel(vehModel)
						local vehSpeed = GetEntitySpeed(vehBack) * 3.6
						local vehPlate = GetVehicleNumberPlateText(vehBack)

						SendNUIMessage({ radar = "bot", plate = vehPlate, model = vehicleName(vehHash), speed = vehSpeed })
					end
				end
			end
		end

		if not IsPedInAnyVehicle(ped) and policeRadar then
			policeRadar = false
			SendNUIMessage({ radar = false })
		end

		Citizen.Wait(timeDistance)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TOGGLERADAR
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("toggleRadar",function(source,args,rawCommand)
	if MumbleIsConnected() then
		local ped = PlayerPedId()
		if IsPedInAnyPoliceVehicle(ped) and policeService then
			if policeRadar then
				policeRadar = false
				SendNUIMessage({ radar = false })
			else
				policeRadar = true
				SendNUIMessage({ radar = true })
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TOGGLEFREEZE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("toggleFreeze",function(source,args,rawCommand)
	local ped = PlayerPedId()
	if IsPedInAnyPoliceVehicle(ped) and policeService then
		policeFreeze = not policeFreeze
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TENCODE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("enterTencodes",function(source,args,rawCommand)
	if policeService and MumbleIsConnected() then
		SetNuiFocus(true,true)
		SetCursorLocation(0.5,0.1)
		SendNUIMessage({ tencode = true })
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- KEYMAPPING
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterKeyMapping("enterTencodes","Manusear o código policial.","keyboard","F3")
RegisterKeyMapping("toggleRadar","Ativar/Desativar radar das viaturas.","keyboard","N")
RegisterKeyMapping("toggleFreeze","Travar/Destravar radar das viaturas.","keyboard","M")