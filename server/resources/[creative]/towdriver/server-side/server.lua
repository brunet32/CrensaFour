-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRPC = Tunnel.getInterface("vRP")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
cRP = {}
Tunnel.bindInterface("towdriver",cRP)
-----------------------------------------------------------------------------------------------------------------------------------------
-- USERLIST
-----------------------------------------------------------------------------------------------------------------------------------------
local userList = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- TOGGLESERVICE
-----------------------------------------------------------------------------------------------------------------------------------------
function cRP.toggleService()
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		if userList[user_id] == nil then
			userList[user_id] = source
		end
	end

	return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CALLPLAYERS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("towdriver:callPlayers")
AddEventHandler("towdriver:callPlayers",function(source,vehName,vehPlate)
	local ped = GetPlayerPed(source)
	local coords = GetEntityCoords(ped)

	for k,v in pairs(userList) do
		async(function()
			TriggerClientEvent("NotifyPush",v,{ code = "28", title = "Registro de Veículo", x = coords["x"], y = coords["y"], z = coords["z"], vehicle = vehicleName(vehName).." - "..vehPlate, time = "Recebido às "..os.date("%H:%M"), blipColor = 33 })
		end)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- PAYMENTMETHOD
-----------------------------------------------------------------------------------------------------------------------------------------
function cRP.paymentMethod()
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		vRP.generateItem(user_id,"plastic",parseInt(math.random(25,35)),true)
		vRP.generateItem(user_id,"glass",parseInt(math.random(25,35)),true)
		vRP.generateItem(user_id,"rubber",parseInt(math.random(25,35)),true)
		vRP.generateItem(user_id,"aluminum",parseInt(math.random(25,35)),true)
		vRP.generateItem(user_id,"copper",parseInt(math.random(25,35)),true)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- TRYTOW
-----------------------------------------------------------------------------------------------------------------------------------------
function cRP.tryTow(vehid01,vehid02,mod)
	TriggerClientEvent("towdriver:syncTow",-1,vehid01,vehid02,tostring(mod))
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PLAYERLEAVE
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("vRP:playerLeave",function(user_id,source)
	if userList[user_id] then
		userList[user_id] = nil
	end
end)