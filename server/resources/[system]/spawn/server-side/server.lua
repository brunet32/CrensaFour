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
Tunnel.bindInterface("spawn",cRP)
vCLIENT = Tunnel.getInterface("spawn")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local charActived = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- INITSYSTEM
-----------------------------------------------------------------------------------------------------------------------------------------
function cRP.initSystem()
	local source = source
	local characterList = {}
	local steam = vRP.getIdentities(source)
	local consult = vRP.query("characters/getCharacters",{ steam = steam })

	if consult[1] then
		for k,v in pairs(consult) do
			table.insert(characterList,{ user_id = v["id"], name = v["name"].." "..v["name2"], locate = v["locate"] })
		end
	end

	return characterList
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHARACTERCHOSEN
-----------------------------------------------------------------------------------------------------------------------------------------
function cRP.characterChosen(user_id)
	local source = source
	vRP.characterChosen(source,parseInt(user_id),nil)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHARACTERCHOSEN
-----------------------------------------------------------------------------------------------------------------------------------------
function cRP.getCharacters()
	local source = source
	local charactersPersonalization = {}
	local steam = vRP.getIdentities(source)
	local consult = vRP.query("characters/getCharacters",{ steam = steam })

	if consult[1] then
		for k,v in pairs(consult) do
			local userTablesSkin = vRP.userData(v["id"],"Datatable")
			local userTablesBarber = vRP.userData(v["id"],"Barbershop")
			local userTablesClotings = vRP.userData(v["id"],"Clothings")
			local userTablesTatto = vRP.userData(v["id"],"Tatuagens")
			table.insert(charactersPersonalization,{ skin = userTablesSkin["skin"], barber = userTablesBarber, clothes = userTablesClotings, tattoos = userTablesTatto })
		end
	end

	return charactersPersonalization
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- NEWCHARACTER
-----------------------------------------------------------------------------------------------------------------------------------------
local charActived = {}
function cRP.newCharacter(name,name2,sex,locate)
	local source = source
	if charActived[source] == nil then
		charActived[source] = true

		local steam = vRP.getIdentities(source)
		local infoAccount = vRP.infoAccount(steam)
		local myChars = vRP.query("characters/countPersons",{ steam = steam })

		if parseInt(infoAccount["chars"]) <= parseInt(myChars[1]["qtd"]) then
			TriggerClientEvent("Notify",source,"amarelo","Atingiu o limite de personagens.",5000)
			return
		end

		vRP.execute("characters/createCharacters",{ steam = steam, name = name, name2 = name2, locate = locate, phone = vRP.generatePhone() })

		local consult = vRP.query("characters/lastCharacters",{ steam = steam })
		if consult[1] then
			vRP.characterChosen(source,parseInt(consult[1]["id"]),sex,locate)
			vCLIENT.closeNew(source)
		end

		charActived[source] = nil
	end
end