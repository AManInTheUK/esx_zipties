ESX                = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('esx_zipties:getItemAmount', function(source, cb, item)
  local xPlayer = ESX.GetPlayerFromId(source)
  local zipties = xPlayer.getInventoryItem('ziptie').count
  cb(zipties)
end)

RegisterServerEvent('esx_zipties:debug')
AddEventHandler('esx_zipties:debug', function(data)
  print(data)
  print(dump(data))
end)

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

RegisterServerEvent('esx_zipties:setziptie')
AddEventHandler('esx_zipties:setziptie', function(target)
  TriggerClientEvent('esx_zipties:setziptie', target)
end)

RegisterServerEvent('esx_zipties:unsetziptie')
AddEventHandler('esx_zipties:unsetziptie', function(target)
  TriggerClientEvent('esx_zipties:unsetziptie', target)
end)
RegisterServerEvent('esx_zipties:autounsetziptie')
AddEventHandler('esx_zipties:autounsetziptie', function(target)
  TriggerClientEvent('esx_zipties:autounsetziptie', target)
end)

RegisterServerEvent('esx_zipties:removeItem')
AddEventHandler('esx_zipties:removeItem', function(item)
  local _source = source
  local xPlayer = ESX.GetPlayerFromId(_source)
  xPlayer.removeInventoryItem(item, 1)
  TriggerClientEvent('esx:showNotification', _source, 'You have use a ' .. item)
end)

RegisterServerEvent('esx_zipties:stealPlayerItem')
AddEventHandler('esx_zipties:stealPlayerItem', function(target, itemType, itemName, amount)
	local _source = source
	local sourceXPlayer = ESX.GetPlayerFromId(_source)
	local targetXPlayer = ESX.GetPlayerFromId(target)

	if itemType == 'item_standard' then
		local targetItem = targetXPlayer.getInventoryItem(itemName)
		local sourceItem = sourceXPlayer.getInventoryItem(itemName)

		-- does the target player have enough in their inventory?
		if targetItem.count > 0 and targetItem.count <= amount then

			-- can the player carry the said amount of x item?
			if sourceItem.limit ~= -1 and (sourceItem.count + amount) > sourceItem.limit then
				TriggerClientEvent('esx:showNotification', _source, 'invalid quantity')
			else
				targetXPlayer.removeInventoryItem(itemName, amount)
				sourceXPlayer.addInventoryItem(itemName, amount)
				TriggerClientEvent('esx:showNotification', sourceXPlayer.source, 'you stolen ' .. amount .. ' ' .. sourceItem.label .. ' from ' .. targetXPlayer.name)
				TriggerClientEvent('esx:showNotification', 'Someone ', '~b~' .. sourceXPlayer.source .. ' stolen ' .. amount .. ' ' .. sourceItem.label)
			end
		else
			TriggerClientEvent('esx:showNotification', _source, 'Invalid Quanity')
		end

	elseif itemType == 'item_account' then

		targetXPlayer.removeAccountMoney(itemName, amount)

		sourceXPlayer.addAccountMoney(itemName, amount)

		TriggerClientEvent('esx:showNotification', sourceXPlayer.source, 'you stolen ' .. amount .. ' from ' .. targetXPlayer.name)
		TriggerClientEvent('esx:showNotification', 'Someone ', '~b~' .. sourceXPlayer.source .. 'stolen ' .. amount)

	elseif itemType == 'item_weapon' then

    targetXPlayer.removeWeapon(itemName)

		sourceXPlayer.addWeapon(itemName, amount)

		TriggerClientEvent('esx:showNotification', sourceXPlayer.source, 'Stolen ' .. ESX.GetWeaponLabel(itemName) .. ' from ' .. targetXPlayer.name)
		TriggerClientEvent('esx:showNotification', 'Someone ', '~b~' .. sourceXPlayer.source .. ' stolen ' .. ESX.GetWeaponLabel(itemName))
	end
end)

ESX.RegisterServerCallback('esx_zipties:getTargetPlayerData', function(source, cb, target)

  if Config.EnableESXIdentity then

    local xPlayer = ESX.GetPlayerFromId(target)

    local identifier = GetPlayerIdentifiers(target)[1]

    local result = MySQL.Sync.fetchAll("SELECT * FROM users WHERE identifier = @identifier", {
      ['@identifier'] = identifier
    })

    local user      = result[1]
    local firstname     = user['firstname']
    local lastname      = user['lastname']
    local sex           = user['sex']
    local dob           = user['dateofbirth']
    local height        = user['height'] .. " Inches"

    local data = {
      name        = GetPlayerName(target),
      job         = xPlayer.job,
      inventory   = xPlayer.inventory,
      accounts    = xPlayer.accounts,
      weapons     = xPlayer.loadout,
      firstname   = firstname,
      lastname    = lastname,
      sex         = sex,
      dob         = dob,
      height      = height
    }

      cb(data)
  else

    local xPlayer = ESX.GetPlayerFromId(target)

    local data = {
      name       = GetPlayerName(target),
      job        = xPlayer.job,
      inventory  = xPlayer.inventory,
      accounts   = xPlayer.accounts,
      weapons    = xPlayer.loadout
    }

    cb(data)

  end

end)

RegisterServerEvent('esx_zipties:drag')
AddEventHandler('esx_zipties:drag', function(target)
  local _source = source
  TriggerClientEvent('esx_zipties:drag', target, _source)
end)

RegisterServerEvent('esx_zipties:putInVehicle')
AddEventHandler('esx_zipties:putInVehicle', function(target)
  TriggerClientEvent('esx_zipties:putInVehicle', target)
end)

RegisterServerEvent('esx_zipties:OutVehicle')
AddEventHandler('esx_zipties:OutVehicle', function(target)
    TriggerClientEvent('esx_zipties:OutVehicle', target)
end)
