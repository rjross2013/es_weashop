

local max_number_weapons = 15 --maximum number of weapons that the player can buy. Weapons given at spawn doesn't count.
local cost_ratio = 100 --Ratio for withdrawing the weapons. This is price/cost_ratio = cost.
TriggerEvent('es:exposeDBFunctions', function(db)
	db.createDatabase('es_weashop', function()end)
end)
RegisterServerEvent('CheckMoneyForWea')
AddEventHandler('CheckMoneyForWea', function(weapon,price)
	TriggerEvent('es:getPlayerFromId', source, function(user)
		TriggerEvent('es:exposeDBFunctions', function(db)
					
		db.getDocumentByRow('es_weashop', 'identifier', user.identifier, function(dbuser)
		
		if (tonumber(user.money) >= tonumber(price)) then
			local player = user.identifier
			local nb_weapon = 0
			for i=1, #dbuser.weapons do
				nb_weapon = nb_weapon + 1
			end
			
			
			print(nb_weapon)
			if (tonumber(max_number_weapons) > tonumber(nb_weapon)) then
				-- Pay the shop (price)
				user:removeMoney((price))
				
				
				dbuser.weapons[#dbuser.weapons+1] = weapon
				dbuser.cost[#dbuser.cost+1] = (price)/cost_ratio
				db.updateDocument('es_weashop', dbuser._id, {weapons = dbuser.weapons, cost = dbuser.cost})
				
				TriggerClientEvent('FinishMoneyCheckForWea',source)
				TriggerClientEvent("es_freeroam:notify", source, "CHAR_MP_ROBERTO", 1, "Roberto", false, "MURDER TIME. FUN TIME!\n")
			else
				TriggerClientEvent('ToManyWeapons',source)
				TriggerClientEvent("es_freeroam:notify", source, "CHAR_MP_ROBERTO", 1, "Roberto", false, "You have reached the weapon limit ! (max: "..max_number_weapons..")\n")
			end
		else
			-- Inform the player that he needs more money
			TriggerClientEvent("es_freeroam:notify", source, "CHAR_MP_ROBERTO", 1, "Roberto", false, "You don't have enough cash !\n")
		end
		end)
	end)
end)
end)
RegisterServerEvent("weaponshop:playerSpawned")
AddEventHandler("weaponshop:playerSpawned", function(spawn)
	TriggerEvent('es:getPlayerFromId', source, function(user)
		TriggerEvent('weaponshop:GiveWeaponsToPlayer', source)
	end)
end)

RegisterServerEvent("weaponshop:GiveWeaponsToPlayer")
AddEventHandler("weaponshop:GiveWeaponsToPlayer", function(player)
	TriggerEvent('es:getPlayerFromId', player, function(user)
		local playerID = user.identifier
		local delay = nil
			TriggerEvent('es:exposeDBFunctions', function(db)
		--local executed_query = MySQL:executeQuery("SELECT * FROM user_weapons WHERE identifier = '@username'",{['@username'] = playerID})
		--local result = MySQL:getResults(executed_query, {'weapon_model','withdraw_cost'}, "identifier")
		
		delay = 2000
		
			db.getDocumentByRow('es_weashop', 'identifier', user.identifier, function(dbuser)
				for i=1, #dbuser.weapons do
				if (tonumber(user.money) >= tonumber(dbuser.cost[i])) then
					TriggerClientEvent("giveWeapon", player, dbuser.weapons[i], delay)
					user:removeMoney((dbuser.cost[i]))
				else
					TriggerClientEvent("es_freeroam:notify", source, "CHAR_MP_ROBERTO", 1, "Roberto", false, "You don't have enough cash !\n")
					return
				end
			end
			TriggerClientEvent("es_freeroam:notify", source, "CHAR_MP_ROBERTO", 1, "Roberto", false, "Here are your weapons !\n")
		
		end)
		end)
	end)
end)
AddEventHandler('es:newPlayerLoaded', function(source, user)
	TriggerEvent('es:exposeDBFunctions', function(db)
		db.createDocument('es_weashop', {identifier = user.identifier, weapons = {}, cost = {}}, function()end)
	end)	
end)