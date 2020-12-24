-- Local
local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}
local PlayerData              = {}
local CurrentAction 						= nil
local GUI                       = {}
GUI.Time                        = 0
local HasAlreadyEnteredMarker   = false
local LastZone                  = nil
local CurrentActionMsg          = ''
local CurrentActionData         = {}
local IsZiptied		              = false
local IsDragged 								= false
local ZiptieTimer              = {}
local CurrentTask             = {}

-- Init ESX
ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)
-- Fin init ESX

--- Gestion Des blips
RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  PlayerData = xPlayer
end)


RegisterNetEvent('esx_zipties:drag')
AddEventHandler('esx_zipties:drag', function(criminal)
  IsDragged = not IsDragged
  PPed = tonumber(criminal)
end)

RegisterNetEvent('esx_zipties:notify')
AddEventHandler('esx_zipties:notify', function(msg)
	ESX.ShowAdvancedNotification('Criminal', '', msg , 'CHAR_ARTHUR', 7)
end)


Citizen.CreateThread(function()
  while true do
    Wait(10)
    if IsZiptied then
      if IsDragged then
        local ped = GetPlayerPed(GetPlayerFromServerId(PPed))
        local myped = GetPlayerPed(-1)
        AttachEntityToEntity(myped, ped, 11816, 0.54, 0.54, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
      else
        DetachEntity(GetPlayerPed(-1), true, false)
      end
    end
  end
end)

RegisterNetEvent('esx_zipties:setziptie')
AddEventHandler('esx_zipties:setziptie', function()

  IsZiptied    = not IsZiptied;
  local playerPed = GetPlayerPed(-1)

  Citizen.CreateThread(function()
    if IsZiptied then
			ESX.ShowAdvancedNotification('Criminal', '', 'You have been ~r~ziptied', 'CHAR_ARTHUR', 7)
      RequestAnimDict('mp_arresting')
      DisablePlayerFiring(playerPed, true)

			if Config.EnableZiptieTimer then

				if ZiptieTimer.Active then
					ESX.ClearTimeout(ZiptieTimer.Task)
				end

				StartHandcuffTimer()
			end

      while not HasAnimDictLoaded('mp_arresting') do
        Wait(100)
      end

      TaskPlayAnim(playerPed, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0, 0, 0, 0)
      SetEnableHandcuffs(playerPed, true)
      DisablePlayerFiring(playerPed, true)
      SetPedCanPlayGestureAnims(playerPed, false)
      FreezeEntityPosition(playerPed,  true)
		else
			if Config.EnableZiptieTimer and ZiptieTimer.Active then
				ESX.ClearTimeout(ZiptieTimer.Task)
			end
			ClearPedSecondaryTask(playerPed)
			SetEnableHandcuffs(playerPed, false)
			DisablePlayerFiring(playerPed, false)
			SetPedCanPlayGestureAnims(playerPed, true)
			FreezeEntityPosition(playerPed, false)
    end
  end)
end)

RegisterNetEvent('esx_zipties:unsetziptie')
AddEventHandler('esx_zipties:unsetziptie', function()

  IsZiptied    = not IsZiptied;
  local playerPed = GetPlayerPed(-1)

  Citizen.CreateThread(function()
    if not IsZiptied then
			ESX.ShowAdvancedNotification('Criminal', '', 'You have been ~g~ Untied', 'CHAR_ARTHUR', 7)
      SetEnableHandcuffs(playerPed, false)
			ClearPedSecondaryTask(playerPed)
      DisablePlayerFiring(playerPed, false)
      SetPedCanPlayGestureAnims(playerPed,  true)
      FreezeEntityPosition(playerPed, false)
			DetachEntity(GetPlayerPed(-1), true, false)
			TriggerServerEvent('jsfour-blindfoldRemove', playerPed)
    end
  end)
end)

RegisterNetEvent('esx_zipties:autounsetziptie')
AddEventHandler('esx_zipties:autounsetziptie', function()
  IsZiptied    = not IsZiptied;
  local playerPed = GetPlayerPed(-1)
  Citizen.CreateThread(function()
			ESX.ShowAdvancedNotification('Criminal', '', 'Ziptie broke', 'CHAR_ARTHUR', 7)
      SetEnableHandcuffs(playerPed, false)
			ClearPedSecondaryTask(playerPed)
      DisablePlayerFiring(playerPed, false)
      SetPedCanPlayGestureAnims(playerPed,  true)
      FreezeEntityPosition(playerPed, false)
			DetachEntity(GetPlayerPed(-1), true, false)
  end)
end)

RegisterNetEvent('esx_zipties:putInVehicle')
AddEventHandler('esx_zipties:putInVehicle', function()
  local playerPed = GetPlayerPed(-1)
  local coords    = GetEntityCoords(playerPed)
  if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.0) then
    local vehicle = GetClosestVehicle(coords.x,  coords.y,  coords.z,  5.0,  0,  71)
    if DoesEntityExist(vehicle) then
      local maxSeats = GetVehicleMaxNumberOfPassengers(vehicle)
      local freeSeat = nil
      for i=maxSeats - 1, 0, -1 do
        if IsVehicleSeatFree(vehicle,  i) then
          freeSeat = i
          break
        end
      end
      if freeSeat ~= nil then
        TaskWarpPedIntoVehicle(playerPed,  vehicle,  freeSeat)
      end
    end
  end
end)

RegisterNetEvent('esx_zipties:OutVehicle')
AddEventHandler('esx_zipties:OutVehicle', function(t)
	local ped = GetPlayerPed(t)
	ClearPedTasksImmediately(ped)
	plyPos = GetEntityCoords(GetPlayerPed(-1),  true)
	local xnew = plyPos.x+2
	local ynew = plyPos.y+2

	SetEntityCoords(GetPlayerPed(-1), xnew, ynew, plyPos.z)
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
      if IsControlPressed(6, Keys["L"]) and IsControlPressed(0 , Keys['LEFTSHIFT']) then

				ESX.UI.Menu.CloseAll()
				local elements = {}

			  table.insert(elements, {label = 'Ziptie', value = 'ziptie'})
				table.insert(elements, {label = 'Un-Ziptie', value = 'unziptie'})
				table.insert(elements, {label = 'Search', value = 'search'})
				table.insert(elements, {label = 'Drag', value = 'drag'})
				table.insert(elements, {label = 'Put in vehicle', value = 'putin'})
				table.insert(elements, {label = 'Take out vehicle', value = 'takeout'})

	      RespawnToHospitalMenu = ESX.UI.Menu.Open(
	        'default', GetCurrentResourceName(), 'menuName',
	        {
	          title = 'Criminal',
	          align = 'top-left',
	          elements = elements
	        },
	        function(data, menu) --Submit Cb
						local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

						if data.current.value == 'ziptie' then
							ZiptiePlayer()
					 	end

						if data.current.value == 'unziptie' then
							unZiptiePlayer()
						end

						if data.current.value == 'search' then
						if IsEntityPlayingAnim(GetPlayerPed(closestPlayer), "mp_arresting", "idle", 3) then
								OpenBodySearchMenu(closestPlayer)
							else
								ESX.ShowAdvancedNotification('Criminal', '', 'Player not ~r~ziptied', 'CHAR_ARTHUR', 7)
							end
						end

						if data.current.value == 'drag' then
							if IsEntityPlayingAnim(GetPlayerPed(closestPlayer), "mp_arresting", "idle", 3) then
								TriggerServerEvent('esx_zipties:drag', GetPlayerServerId(closestPlayer))
							else
								ESX.ShowAdvancedNotification('Criminal', '', 'Player not ~r~ziptied', 'CHAR_ARTHUR', 7)
							end
						end

						if data.current.value == 'putin' then
							if IsEntityPlayingAnim(GetPlayerPed(closestPlayer), "mp_arresting", "idle", 3) then
								TriggerServerEvent('esx_zipties:putInVehicle', GetPlayerServerId(closestPlayer))
							end
						end

						if data.current.value == 'takeout' then
							if IsEntityPlayingAnim(GetPlayerPed(closestPlayer), "mp_arresting", "idle", 3) then
								TriggerServerEvent('esx_zipties:OutVehicle', GetPlayerServerId(closestPlayer))
							end
						end

						menu.close()
				 end,
				 function(data, menu) --Cancel Cb
        	menu.close()
         end) -- end cb
	    end
		end
end)

function ZiptiePlayer()
	local dict = "missminuteman_1ig_2"
	RequestAnimDict(dict)
	local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
	if closestPlayer == -1 or closestDistance > 3.0 then
		ESX.ShowAdvancedNotification('Criminal', '', 'No player nearby', 'CHAR_ARTHUR', 7)
	else
		ESX.TriggerServerCallback('esx_zipties:getItemAmount', function(zipties)
			if zipties > 0 then
				if IsEntityPlayingAnim(GetPlayerPed(closestPlayer), "missminuteman_1ig_2", "handsup_enter", 3) then
					local playerPed = GetPlayerPed(-1)
						Citizen.CreateThread(function()
						TriggerServerEvent('esx_zipties:setziptie', GetPlayerServerId(closestPlayer))
						TriggerServerEvent('esx_zipties:removeItem', 'ziptie')

					end)
				else
					ESX.ShowAdvancedNotification('Criminal', '', 'Player not ~r~surendering', 'CHAR_ARTHUR', 7)
				end
			else
				ESX.ShowAdvancedNotification('Criminal', '', 'not enough ~r~zipties', 'CHAR_ARTHUR', 7)
			end
		end, 'zipties')
	end
end

function unZiptiePlayer()
	local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
	if closestPlayer == -1 or closestDistance > 3.0 then
		ESX.ShowAdvancedNotification('Criminal', '', 'No player nearby', 'CHAR_ARTHUR', 7)
	else
		TriggerServerEvent('esx_zipties:unsetziptie', GetPlayerServerId(closestPlayer))
		ESX.ShowAdvancedNotification('Criminal', '', 'You have ~g~release ~w~your ~r~victem', 'CHAR_ARTHUR', 7)
	end
end

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		TriggerEvent('esx_zipties:unrestrain')

		if Config.EnableZiptieTimer and ZiptieTimer.Active then
			ESX.ClearTimeout(ZiptieTimer.Task)
		end
	end
end)

RegisterNetEvent('esx_zipties:unrestrain')
AddEventHandler('esx_zipties:unrestrain', function()
	if IsZiptied then
		local playerPed = PlayerPedId()
		IsZiptied = false
		ESX.ShowAdvancedNotification('Criminal', '', 'Ziptie ~g~broke lose ~w~your free!', 'CHAR_ARTHUR', 7)
		ClearPedSecondaryTask(playerPed)
		SetEnableHandcuffs(playerPed, false)
		DisablePlayerFiring(playerPed, false)
		SetPedCanPlayGestureAnims(playerPed, true)
		FreezeEntityPosition(playerPed, false)
		--DisplayRadar(true)

		-- end timer
		if Config.EnableZiptieTimer and ZiptieTimer.Active then
			ESX.ClearTimeout(ZiptieTimer.Task)
		end
	end
end)

function StartHandcuffTimer()
	if Config.EnableZiptieTimer and ZiptieTimer.Active then
		ESX.ClearTimeout(ZiptieTimer.Task)
	end

	ZiptieTimer.Active = true

	ZiptieTimer.Task = ESX.SetTimeout(Config.ZiptieTimer, function()
		TriggerEvent('esx_zipties:unrestrain')
		print('Yes')
		ZiptieTimer.Active = false
	end)
end

-- Ziptied
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)
		if IsZiptied then
			disableControl()
		else
			Citizen.Wait(1000)
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if IsZiptied and not IsEntityPlayingAnim(GetPlayerPed(PlayerId()), "mp_arresting", "idle", 3) then
			Citizen.Wait(100)
			TaskPlayAnim(GetPlayerPed(PlayerId()), "mp_arresting", "idle", 8.0, -8, -1, 49, 0, 0, 0, 0)
		end

		if IsEntityPlayingAnim(GetPlayerPed(PlayerId()), "mp_arresting", "idle", 3) then
			disableControl()
		end

		if IsEntityPlayingAnim(GetPlayerPed(PlayerId()), "random@mugging3", "handsup_standing_base", 3) then
			disableControl()
		end
	end
end)

function disableControl()
	DisableControlAction(2, 1, true) -- Disable pan
	DisableControlAction(2, 2, true) -- Disable tilt
	DisableControlAction(0, 59, true)
  DisableControlAction(2, 24, true) -- Attack
  DisableControlAction(2, 257, true) -- Attack 2
  DisableControlAction(2, 25, true) -- Aim
  DisableControlAction(2, 263, true) -- Melee Attack 1
  DisableControlAction(0, 24, true) -- Attack
  DisableControlAction(0, 257, true) -- Attack 2
  DisableControlAction(0, 25, true) -- Aim
  DisableControlAction(0, 263, true) -- Melee Attack 1
  DisableControlAction(27, 23, true) -- Also 'enter'?
  DisableControlAction(0, 23, true) -- Also 'enter'?
  DisableControlAction(0, 288, true) -- Disable phone
  DisableControlAction(0,289, true) -- Inventory
  DisableControlAction(0, 289,  true) -- Inventory block
  DisableControlAction(0, 73,  true) -- Handups
  DisableControlAction(0, 105,  true) -- Handups
  DisableControlAction(0, 29,  true) -- Point
  DisablePlayerFiring(GetPlayerPed(-1), true)
  DisableControlAction(0, 82,  true) -- Animations
  DisableControlAction(0, 69, true) -- INPUT_VEH_ATTACK
  DisableControlAction(0, 92, true) -- INPUT_VEH_PASSENGER_ATTACK
  DisableControlAction(0, 114, true) -- INPUT_VEH_FLY_ATTACK
  DisableControlAction(0, 140, true) -- INPUT_MELEE_ATTACK_LIGHT
  DisableControlAction(0, 141, true) -- INPUT_MELEE_ATTACK_HEAVY
  DisableControlAction(0, 142, true) -- INPUT_MELEE_ATTACK_ALTERNATE
  DisableControlAction(0, 257, true) -- INPUT_ATTACK2
  DisableControlAction(0, 263, true) -- INPUT_MELEE_ATTACK1
  DisableControlAction(0, 264, true) -- INPUT_MELEE_ATTACK2
  DisableControlAction(0, 24, true) -- INPUT_ATTACK
  DisableControlAction(0, 25, true) -- INPUT_AIM
	DisableControlAction(0, 75, true)  -- Disable exit vehicle
	DisableControlAction(27, 75, true) -- Disable exit vehicle
	DisableControlAction(0, 65, true) -- Disable f9
	DisableControlAction(0, 167, true) -- Disable f6
	DisableControlAction(2, Keys['R'], true) -- Reload
	DisableControlAction(2, 59, true) -- Disable steering in vehicle
	DisableControlAction(0, 47, true)  -- Disable weapon
	DisableControlAction(0, 47, true)  -- Disable weapon
	DisableControlAction(0, 264, true) -- Disable melee
	DisableControlAction(0, 257, true) -- Disable melee
	DisableControlAction(0, 140, true) -- Disable melee
	DisableControlAction(0, 141, true) -- Disable melee
	DisableControlAction(0, 142, true) -- Disable melee
	DisableControlAction(0, 143, true) -- Disable melee
	DisableControlAction(2, Keys['P'], true) -- Disable pause screen
	DisableControlAction(0, Keys['BACKSPACE'], true) -- Disable backspace
	DisableControlAction(0, Keys['~'], true) -- Disable backspace
	DisableControlAction(0, Keys['T'], true) -- Disable backspace
  ESX.UI.Menu.CloseAll()
end

-- function StartZiptieTimer()
-- 	if Config.EnableZiptieTimer and ZiptieTimer then
-- 		ESX.ClearTimeout(ZiptieTimer)
-- 	end
--
-- 	ZiptieTimer = ESX.SetTimeout(Config.ZiptieTimer, function()
-- 		ESX.ShowNotification('you feel your zipties slowly losing grip and fading away.')
-- 		TriggerEvent('esx_zipties:unsetziptie')
-- 	end)
--
-- 	ZiptieTimer = nil
-- end

function OpenBodySearchMenu(player)

  ESX.TriggerServerCallback('esx_zipties:getTargetPlayerData', function(data)

    local elements = {}

    local blackMoney = 0

    for i=1, #data.accounts, 1 do
      if data.accounts[i].name == 'black_money' then
        blackMoney = data.accounts[i].money
      end
    end

    table.insert(elements, {
      label          = 'Steal ' .. blackMoney,
      value          = 'black_money',
      itemType       = 'item_account',
      amount         = blackMoney
    })

    table.insert(elements, {label = '--- Armes ---', value = nil})

    for i=1, #data.weapons, 1 do
      table.insert(elements, {
        label          = 'Steal ' .. ESX.GetWeaponLabel(data.weapons[i].name),
        value          = data.weapons[i].name,
        itemType       = 'item_weapon',
        amount         = data.ammo,
      })
    end

    table.insert(elements, {label = 'Inventory', value = nil})

    for i=1, #data.inventory, 1 do
      if data.inventory[i].count > 0 then
        table.insert(elements, {
          label          = 'Steal ' .. data.inventory[i].count .. ' ' .. data.inventory[i].label,
          value          = data.inventory[i].name,
          itemType       = 'item_standard',
          amount         = data.inventory[i].count,
        })
      end
    end

    ESX.UI.Menu.Open(
      'default', GetCurrentResourceName(), 'body_search',
      {
        title    = 'Steal',
        align    = 'top-left',
        elements = elements,
      },
      function(data, menu)
        local itemType = data.current.itemType
        local itemName = data.current.value
        local amount   = data.current.amount

        if data.current.value ~= nil then
          TriggerServerEvent('esx_zipties:stealPlayerItem', GetPlayerServerId(player), itemType, itemName, amount)
          OpenBodySearchMenu(player)
        end
      end,
      function(data, menu)
        menu.close()
      end)

  end, GetPlayerServerId(player))
end

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
