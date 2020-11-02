ESX = nil

local completepaytable = nil
local tableupdate = false
local temppaytable =  nil
local totalbagpay = 0
local lastpickup = nil
local platenumb = nil
local paused = false
local iscurrentboss = false
local work_truck = nil
local truckdeposit = false
local trashcollection = false
local trashcollectionpos = nil
local bagsoftrash = nil
local currentbag = nil
local namezone = "Delivery"
local namezonenum = 0
local namezoneregion = 0
local MissionRegion = 0
local viemaxvehicule = 1000
local argentretire = 0
local livraisonTotalPaye = 0
local livraisonnombre = 0
local MissionRetourCamion = false
local MissionNum = 0
local MissionLivraison = false
local PlayerData              = nil
local GUI                     = {}
GUI.Time                      = 0
local hasAlreadyEnteredMarker = false
local lastZone                = nil
local Blips                   = {}
local plaquevehicule = ""
local plaquevehiculeactuel = ""
local CurrentAction           = nil
local CurrentActionMsg        = ''
local CurrentActionData       = {}
--------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
end)

RegisterNetEvent('esx_posti:setbin')
AddEventHandler('esx_posti:setbin', function(binpos, platenumber,  bags)
		if GetVehicleNumberPlateText(GetVehiclePedIsIn(GetPlayerPed(-1), false)) == platenumber then
			work_truck = GetVehiclePedIsIn(GetPlayerPed(-1), false)
			platenumb = platenumber
			trashcollectionpos = binpos
			bagsoftrash = bags
			currentbag = bagsoftrash
			MissionLivraison = false
			trashcollection = true
			paused = true
			CurrentActionMsg = ''
			CollectionAction = 'collection'
	end
end)

RegisterNetEvent('esx_posti:addbags')
AddEventHandler('esx_posti:addbags', function(platenumber, bags, crewmember)
		if platenumb == platenumber then
			if iscurrentboss then
				totalbagpay = totalbagpay + bags
				addcremember = true
				if temppaytable == nil then 
					temppaytable = {}
				 end

				for i, v in pairs(temppaytable) do
					
					if temppaytable[i] == crewmember then
						addcremember = false
					end
				end
				if addcremember then
					table.insert(temppaytable, crewmember)
				end
			end
	end
end)

RegisterNetEvent('esx_posti:startpayrequest')
AddEventHandler('esx_posti:startpayrequest', function(platenumber, amount)
		if platenumb == platenumber then
			TriggerServerEvent('esx_posti:pay', amount)
			platenumb = nil
		end
end)

RegisterNetEvent('esx_posti:removedbag')
AddEventHandler('esx_posti:removedbag', function(platenumber)
		if platenumb == platenumber then
			currentbag = currentbag - 1
		end
end)

RegisterNetEvent('esx_posti:countbagtotal')
AddEventHandler('esx_posti:countbagtotal', function(platenumber)
		if platenumb == platenumber then
			if not iscurrentboss then
			TriggerServerEvent('esx_posti:bagsdone', platenumb, totalbagpay)
			totalbagpay = 0
			end
	end
end)

RegisterNetEvent('esx_posti:clearjob')
AddEventHandler('esx_posti:clearjob', function(platenumber)
	if platenumb == platenumber then
		trashcollectionpos = nil
		bagsoftrash = nil
		work_truck = nil
		trashcollection = false
		truckdeposit = false
		CurrentAction = nil
		CollectionAction = nil
		paused = false
	end
end)


function MenuVehicleSpawner()
	local elements = {}
		table.insert(elements, { label = 'Postiauto', value = 'boxville2' })
	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'vehiclespawner',
		{
			title    = _U('vehiclespawner'),
			elements = elements
		},
		function(data, menu)
		
			ESX.Game.SpawnVehicle(data.current.value, Config.Zones.VehicleSpawnPoint.Pos, 158.13, function(vehicle)
				ESX.ShowNotification('Muistithan pukea ~o~työasun!')
				platenum = math.random(10000, 99999)
				SetVehicleNumberPlateText(vehicle, "POS"..platenum)             
				MissionLivraisonSelect()
				plaquevehicule = "POS"..platenum
				TaskWarpPedIntoVehicle(GetPlayerPed(-1), vehicle, -1)   
			end)

			menu.close()
		end,
		function(data, menu)
			menu.close()
		end
	)
end

function IsATruck()
	local isATruck = false
	local playerPed = GetPlayerPed(-1)
	for i=1, #Config.Trucks, 1 do
		if IsVehicleModel(GetVehiclePedIsUsing(playerPed), Config.Trucks[i]) then
			isATruck = true
			break
		end
	end
	return isATruck
end

AddEventHandler('esx_posti:hasEnteredMarker', function(zone)

	local playerPed = GetPlayerPed(-1)

	if zone == 'Cloakrooms' then
		CurrentAction     = 'menu_cloakroom'
		CurrentActionMsg  = ('Paina ~INPUT_CONTEXT~ avataksesi vaatekaapin')
		CurrentActionData = {}
	  end

	if zone == 'VehicleSpawner' then
			if MissionRetourCamion or MissionLivraison then
				CurrentAction = 'hint'
                CurrentActionMsg  = _U('already_have_truck')
			else
				MenuVehicleSpawner()
		end
	end

	if zone == 'RetourCamion' then
			CurrentAction = 'hint'
			CurrentActionMsg  = ('Paina ~INPUT_CONTEXT~ palauttaaksesi postiauton')
	end

	if zone == namezone then
		if MissionLivraison and MissionNum == namezonenum and MissionRegion == namezoneregion then 
			if IsPedSittingInAnyVehicle(playerPed) and IsATruck() then
				VerifPlaqueVehiculeActuel()
				
				if plaquevehicule == plaquevehiculeactuel then
					if Blips['delivery'] ~= nil then
						RemoveBlip(Blips['delivery'])
						Blips['delivery'] = nil
					end

					CurrentAction     = 'delivery'
                    CurrentActionMsg  = _U('delivery')
				else
					CurrentAction = 'hint'
                    CurrentActionMsg  = ('Sinun täytyy olla ~p~postiautossa')
				end
			else
				CurrentAction = 'hint'
                CurrentActionMsg  = ('Sinun täytyy olla ~p~postiautossa')
			end
		end
	end

	if zone == 'AnnulerMission' then
		if MissionLivraison then
			if IsPedSittingInAnyVehicle(playerPed) and IsATruck() then
				VerifPlaqueVehiculeActuel()
				
				if plaquevehicule == plaquevehiculeactuel then
                    CurrentAction     = 'retourcamionannulermission'
                    CurrentActionMsg  = ('Paina ~INPUT_PICKUP~ palauttaaksesi postiauton')
				else
					CurrentAction = 'hint'
                    CurrentActionMsg  = ('Ei oo sun postiauto???')
				end
			else
                CurrentAction     = 'retourcamionperduannulermission'
			end
		end
	end

	if zone == 'RetourCamion' then
		if MissionRetourCamion then
			if IsPedSittingInAnyVehicle(playerPed) and IsATruck() then
				VerifPlaqueVehiculeActuel()

				if plaquevehicule == plaquevehiculeactuel then
                    CurrentAction     = 'retourcamion'
				else
                    CurrentAction     = 'retourcamionannulermission'
                    CurrentActionMsg  = _U('not_your_truck')
				end
			else
                CurrentAction     = 'retourcamionperdu'
			end
		end
	end

end)

AddEventHandler('esx_posti:hasExitedMarker', function(zone)
	ESX.UI.Menu.CloseAll()    
    CurrentAction = nil
	CurrentActionMsg = ''
end) 

function nouvelledestination()
	livraisonnombre = livraisonnombre+1
	local count = 0
	local multibagpay = 0
		for i, v in pairs(temppaytable) do 
		count = count + 1 
	end

	if Config.MulitplyBags then 
	multibagpay = totalbagpay * (count + 1)
	else
	multibagpay = totalbagpay
	end
	local testprint = (destination.Paye + multibagpay)
	local temppayamount =  (destination.Paye + multibagpay) / (count + 1)
	TriggerServerEvent('esx_posti:requestpay', platenumb,  temppayamount)
	livraisonTotalPaye = 0
	totalbagpay = 0
	temppayamount = 0
	temppaytable = nil
	multibagpay = 0
	
	if livraisonnombre >= Config.MaxDelivery then
		MissionLivraisonStopRetourDepot()
	else

		livraisonsuite = math.random(0, 100)
		
		if livraisonsuite <= 10 then
			MissionLivraisonStopRetourDepot()
		elseif livraisonsuite <= 99 then
			MissionLivraisonSelect()
		elseif livraisonsuite <= 100 then
			if MissionRegion == 1 then
				MissionRegion = 2
			elseif MissionRegion == 2 then
				MissionRegion = 1
			end
			MissionLivraisonSelect()	
		end
	end
end

function retourcamion_oui()
	if Blips['delivery'] ~= nil then
		RemoveBlip(Blips['delivery'])
		Blips['delivery'] = nil
	end
	
	if Blips['annulermission'] ~= nil then
		RemoveBlip(Blips['annulermission'])
		Blips['annulermission'] = nil
	end
	
	MissionRetourCamion = false
	livraisonnombre = 0
	MissionRegion = 0
	
	donnerlapaye()
end

function retourcamion_non()
	
	if livraisonnombre >= Config.MaxDelivery then
		ESX.ShowNotification(_U('need_it'))
	else
		ESX.ShowNotification(_U('ok_work'))
		nouvelledestination()
	end
end

function retourcamionperdu_oui()
	if Blips['delivery'] ~= nil then
		RemoveBlip(Blips['delivery'])
		Blips['delivery'] = nil
	end
	
	if Blips['annulermission'] ~= nil then
		RemoveBlip(Blips['annulermission'])
		Blips['annulermission'] = nil
	end
	MissionRetourCamion = false
	livraisonnombre = 0
	MissionRegion = 0
	
	donnerlapayesanscamion()
end

function retourcamionperdu_non()
	ESX.ShowNotification(_U('scared_me'))
end

function retourcamionannulermission_oui()
	if Blips['delivery'] ~= nil then
		RemoveBlip(Blips['delivery'])
		Blips['delivery'] = nil
	end
	
	if Blips['annulermission'] ~= nil then
		RemoveBlip(Blips['annulermission'])
		Blips['annulermission'] = nil
	end
	
	MissionLivraison = false
	livraisonnombre = 0
	MissionRegion = 0
	
	donnerlapaye()
end

function retourcamionannulermission_non()	
	ESX.ShowNotification(_U('resume_delivery'))
end

function retourcamionperduannulermission_oui()
	if Blips['delivery'] ~= nil then
		RemoveBlip(Blips['delivery'])
		Blips['delivery'] = nil
	end
	
	if Blips['annulermission'] ~= nil then
		RemoveBlip(Blips['annulermission'])
		Blips['annulermission'] = nil
	end
	
	MissionLivraison = false
	livraisonnombre = 0
	MissionRegion = 0
	
	donnerlapayesanscamion()
end

function retourcamionperduannulermission_non()	
	ESX.ShowNotification(_U('resume_delivery'))
end

function round(num, numDecimalPlaces)
    local mult = 5^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function donnerlapaye()
	ped = GetPlayerPed(-1)
	vehicle = GetVehiclePedIsIn(ped, false)
	vievehicule = GetVehicleEngineHealth(vehicle)
	calculargentretire = round(viemaxvehicule-vievehicule)
	
	if calculargentretire <= 0 then
		argentretire = 0
	else
		argentretire = calculargentretire
	end

    ESX.Game.DeleteVehicle(vehicle)

	local amount = livraisonTotalPaye-argentretire
	
	if vievehicule >= 1 then
		if livraisonTotalPaye == 0 then
			livraisonTotalPaye = 0
		else
			if argentretire <= 0 then

				livraisonTotalPaye = 0
			else

				livraisonTotalPaye = 0
			end
		end
	else
		if livraisonTotalPaye ~= 0 and amount <= 0 then

			livraisonTotalPaye = 0
		else
			if argentretire <= 0 then

				livraisonTotalPaye = 0
			else


				livraisonTotalPaye = 0
			end
		end
	end
end

function donnerlapayesanscamion()
	ped = GetPlayerPed(-1)
	argentretire = Config.TruckPrice
	
	-- donne paye
	local amount = livraisonTotalPaye-argentretire
	
	if livraisonTotalPaye == 0 then

		livraisonTotalPaye = 0
	else
		if amount >= 1 then

			livraisonTotalPaye = 0
		else

			livraisonTotalPaye = 0
		end
	end
end

function SelectBinandCrew()
	work_truck = GetVehiclePedIsIn(GetPlayerPed(-1), true)
	bagsoftrash = math.random(2, 8)
	local NewBin, NewBinDistance = ESX.Game.GetClosestObject(Config.DumpstersAvaialbe)
	trashcollectionpos = GetEntityCoords(NewBin)
	platenumb = GetVehicleNumberPlateText(GetVehiclePedIsIn(GetPlayerPed(-1), true))
	TriggerServerEvent("esx_posti:binselect", trashcollectionpos, platenumb, bagsoftrash)
end



function OpenCloakroomMenu()

	local elements = {
	  {label = ('Siviilivaatteet'), value = 'citizen_wear'},
	  {label = ('Työvaatteet'), value = 'posti_asu'}
	}

	
	ESX.UI.Menu.CloseAll()
  
	  ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'cloakroom',
		{
		  title    = 'Vaatekaappi',
		  align    = 'bottom-right',
		  elements = elements,
		  },
  
		  function(data, menu)
  
		menu.close()
  
		if data.current.value == 'citizen_wear' then
		  ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
			local model = nil
  
			if skin.sex == 0 then
			  model = GetHashKey("mp_m_freemode_01")
			else
			  model = GetHashKey("mp_f_freemode_01")
			end
  
			RequestModel(model)
			while not HasModelLoaded(model) do
			  RequestModel(model)
			  Citizen.Wait(1)
			end
  
			SetPlayerModel(PlayerId(), model)
			SetModelAsNoLongerNeeded(model)
  
			TriggerEvent('skinchanger:loadSkin', skin)
			TriggerEvent('esx:restoreLoadout')
		  end)
		end
	  
	  if data.current.value == 'posti_asu' then
  
		TriggerEvent('skinchanger:getSkin', function(skin)
		  
			  if skin.sex == 0 then
  
				  local clothesSkin = {
					  ['tshirt_1'] = 15, ['tshirt_2'] = 0,
					  ['torso_1'] = 9, ['torso_2'] = 15,
					  ['arms'] = 0,
					  ['pants_1'] = 98, ['pants_2'] = 18,
					  ['shoes_1'] = 31, ['shoes_2'] = 0,
					  ['helmet_1'] = 76, ['helmet_2'] = 4
				  }
				  TriggerEvent('skinchanger:loadClothes', skin, clothesSkin)
  
			  else
  
				  local clothesSkin = { 
					  ['tshirt_1'] = 2, ['tshirt_2'] = 0,
					  ['torso_1'] = 75, ['torso_2'] = 2,
					  ['arms'] = 9,
					  ['pants_1'] = 101, ['pants_2'] = 18,
					  ['shoes_1'] = 32, ['shoes_2'] = 0,
					  ['helmet_1'] = 75, ['helmet_2'] = 4
				  }
				  TriggerEvent('skinchanger:loadClothes', skin, clothesSkin)
  
			  end
  
			  local playerPed = GetPlayerPed(-1)
			  SetPedArmour(playerPed, 0)
			  ClearPedBloodDamage(playerPed)
			  ResetPedVisibleDamage(playerPed)
			  ClearPedLastWeaponDamage(playerPed)
		  end)
		end
  
		CurrentAction     = 'menu_cloakroom'
		CurrentActionMsg  = ('Paina ~INPUT_CONTEXT~ avataksesi vaatekaapin')
		CurrentActionData = {}
  
	  end,
	  function(data, menu)
  
		menu.close()
  
		CurrentAction     = 'menu_cloakroom'
		CurrentActionMsg  = ('Paina ~INPUT_CONTEXT~ avataksesi vaatekaapin')
		CurrentActionData = {}
	  end)
end  


-- Key Controls
Citizen.CreateThread(function()
    while true do

		Citizen.Wait(0)
		plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
		if CurrentAction ~= nil or CollectionAction ~= nil then

        	SetTextComponentFormat('STRING')
        	AddTextComponentString(CurrentActionMsg)
       		DisplayHelpTextFromStringLabel(0, 0, 1, -1)

			if IsControlJustReleased(0, 38) then

				if CollectionAction == 'collection' then
					if not HasAnimDictLoaded("anim@heists@narcotics@trash") then
					RequestAnimDict("anim@heists@narcotics@trash") 
					end
					while not HasAnimDictLoaded("anim@heists@narcotics@trash") do 
					Citizen.Wait(0)
					end
					plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
					dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, trashcollectionpos.x, trashcollectionpos.y, trashcollectionpos.z)
					if dist <= 3.5 then
						if currentbag > 0 then
							TaskStartScenarioInPlace(PlayerPedId(), "PROP_HUMAN_BUM_BIN", 0, true)
							TriggerServerEvent('esx_posti:bagremoval', platenumb)
							trashcollection = false
							Citizen.Wait(4000)
							ClearPedTasks(PlayerPedId())
							local randombag = math.random(0,2)
							if randombag == 0 then
								garbagebag = CreateObject(GetHashKey("prop_poster_tube_02"), 0, 0, 0, true, true, true) -- creates object
								AttachEntityToEntity(garbagebag, GetPlayerPed(-1), GetPedBoneIndex(GetPlayerPed(-1), 57005), 0.11, 0.10, -0.02, 100.0, 190.0, 180.0, true, true, false, true, 1, true) -- object is attached to right hand    
							elseif randombag == 1 then
								garbagebag = CreateObject(GetHashKey("prop_poster_tube_01"), 0, 0, 0, true, true, true) -- creates object
								AttachEntityToEntity(garbagebag, GetPlayerPed(-1), GetPedBoneIndex(GetPlayerPed(-1), 57005), 0.11, 0.10, -0.02, 100.0, 190.0, 180.0, true, true, false, true, 1, true) -- object is attached to right hand    
							elseif randombag == 2 then
								garbagebag = CreateObject(GetHashKey("prop_poster_tube_02"), 0, 0, 0, true, true, true) -- creates object
								AttachEntityToEntity(garbagebag, GetPlayerPed(-1), GetPedBoneIndex(GetPlayerPed(-1), 57005), 0.11, 0.10, -0.02, 100.0, 190.0, 180.0, true, true, false, true, 1, true) -- object is attached to right hand    
							end   
							TaskPlayAnim(PlayerPedId(-1), 'anim@heists@narcotics@trash', 'walk', 1.0, -1.0,-1,49,0,0, 0,0)
							truckdeposit = true
							CollectionAction = 'deposit'
						else
							if iscurrentboss then
								TaskStartScenarioInPlace(PlayerPedId(), "PROP_HUMAN_PARKING_METER", 0, true) 
								if temppaytable == nil then
									temppaytable = {}
								end
								TriggerServerEvent('esx_posti:reportbags', platenumb)
								Citizen.Wait(4000)
								ClearPedTasks(PlayerPedId())
        	        	        setring = false
            	        	    bagsoftrash = math.random(2,10)
								currentbag = bagsoftrash 
								CurrentAction = nil
								trashcollection = false
								truckdeposit = false
								ESX.ShowNotification("Postit haettu jatka matkaasi!")
								while not IsPedInVehicle(GetPlayerPed(-1), work_truck, false) do
									Citizen.Wait(0)
								end
								TriggerServerEvent('esx_posti:endcollection', platenumb)
								SetVehicleDoorShut(work_truck,3,false)
								Citizen.Wait(2000)
								nouvelledestination()
							end
						end
					end
				
				elseif CollectionAction == 'deposit'  then
					local trunk = GetWorldPositionOfEntityBone(work_truck, GetEntityBoneIndexByName(work_truck, "platelight"))
 					plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
					dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, trunk.x, trunk.y, trunk.z)
					if dist <= 2.0 then
						Citizen.Wait(5)
						ClearPedTasksImmediately(GetPlayerPed(-1))
						TaskPlayAnim(PlayerPedId(-1), 'anim@heists@narcotics@trash', 'throw_b', 1.0, -1.0,-1,2,0,0, 0,0)
 						Citizen.Wait(800)
						local garbagebagdelete = DeleteEntity(garbagebag)
						totalbagpay = totalbagpay+Config.BagPay
						Citizen.Wait(100)
						ClearPedTasksImmediately(GetPlayerPed(-1))
						CollectionAction = 'collection'
						truckdeposit = false
						trashcollection = true
					end
				end  

				if CurrentAction == 'delivery' then
					SelectBinandCrew()
					while work_truck == nil do
						Citizen.Wait(0)
					end
					iscurrentboss = true
					SetVehicleDoorOpen(work_truck,3,false, false)

                end

                if CurrentAction == 'retourcamion' then
                    retourcamion_oui()
                end

                if CurrentAction == 'retourcamionperdu' then
                    retourcamionperdu_oui()
				end
				
				if CurrentAction == 'menu_cloakroom' then
					OpenCloakroomMenu()
				end

                if CurrentAction == 'retourcamionannulermission' then
                    retourcamionannulermission_oui()
                end

                if CurrentAction == 'retourcamionperduannulermission' then
                    retourcamionperduannulermission_oui()
                end

                CurrentAction = nil
            end

        end

    end
end)

-- DISPLAY MISSION MARKERS AND MARKERS
Citizen.CreateThread(function()
	while true do
		Wait(0)

		if truckdeposit then
			local trunk = GetWorldPositionOfEntityBone(work_truck, GetEntityBoneIndexByName(work_truck, "platelight"))
			plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
			DrawMarker(27, trunk.x , trunk.y, trunk.z, 0, 0, 0, 0, 0, 0, 1.25, 1.25, 1.0001, 0, 128, 0, 200, 0, 0, 0, 0)
			dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, trunk.x , trunk.y, trunk.z)
			if dist <= 2.0 then
			ESX.Game.Utils.DrawText3D(vector3(trunk.x , trunk.y ,trunk.z + 0.50), "[~g~E~s~] Laittaaksesi postit autoon", 1.0)
			end
		end

		if trashcollection then
			DrawMarker(1, trashcollectionpos.x, trashcollectionpos.y, trashcollectionpos.z, 0, 0, 0, 0, 0, 0, 3.001, 3.0001, 1.0001, 255, 0, 0, 200, 0, 0, 0, 0)
			plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
			dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, trashcollectionpos.x, trashcollectionpos.y, trashcollectionpos.z)
			if dist <= 5.0 then
				if currentbag <= 0 then
					if iscurrentboss then
					ESX.Game.Utils.DrawText3D(trashcollectionpos + vector3(0.0, 0.0, 1.0), "[~g~E~s~] Tarkista postit", 1.0)		
					else
					ESX.Game.Utils.DrawText3D(trashcollectionpos + vector3(0.0, 0.0, 1.0), "Homma valmis. Odota autossa!", 1.0)		
					end
				else
					ESX.Game.Utils.DrawText3D(trashcollectionpos + vector3(0.0, 0.0, 1.0), "[~g~E~s~] Nouda postit ["..currentbag.."/"..bagsoftrash.."]", 1.0)
				end
			end
		end
		if MissionLivraison then
			DrawMarker(destination.Type, destination.Pos.x, destination.Pos.y, destination.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, destination.Size.x, destination.Size.y, destination.Size.z, destination.Color.r, destination.Color.g, destination.Color.b, 100, false, true, 2, false, false, false, false)
			DrawMarker(Config.Livraison.AnnulerMission.Type, Config.Livraison.AnnulerMission.Pos.x, Config.Livraison.AnnulerMission.Pos.y, Config.Livraison.AnnulerMission.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.Livraison.AnnulerMission.Size.x, Config.Livraison.AnnulerMission.Size.y, Config.Livraison.AnnulerMission.Size.z, Config.Livraison.AnnulerMission.Color.r, Config.Livraison.AnnulerMission.Color.g, Config.Livraison.AnnulerMission.Color.b, 100, false, true, 2, false, false, false, false)
		elseif MissionRetourCamion then
			DrawMarker(destination.Type, destination.Pos.x, destination.Pos.y, destination.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, destination.Size.x, destination.Size.y, destination.Size.z, destination.Color.r, destination.Color.g, destination.Color.b, 100, false, true, 2, false, false, false, false)
		end

		local coords = GetEntityCoords(GetPlayerPed(-1))
		
		for k,v in pairs(Config.Zones) do
				DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b, 100, false, true, 2, false, false, false, false)
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		
		Wait(0)

		if not paused then 

				local coords      = GetEntityCoords(GetPlayerPed(-1))
				local isInMarker  = false
				local currentZone = nil

				for k,v in pairs(Config.Zones) do
					if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size.x) then
						isInMarker  = true
						currentZone = k
					end
				end
				
			
				for k,v in pairs(Config.Livraison) do
					if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size.x) then
						isInMarker  = true
						currentZone = k
					end
				end

				if isInMarker and not hasAlreadyEnteredMarker then
					hasAlreadyEnteredMarker = true
					lastZone                = currentZone
					TriggerEvent('esx_posti:hasEnteredMarker', currentZone)
				end

				if not isInMarker and hasAlreadyEnteredMarker then
					hasAlreadyEnteredMarker = false
					TriggerEvent('esx_posti:hasExitedMarker', lastZone)
				end
			end
		end
end)


function MissionLivraisonSelect()
	if MissionRegion == 0 then
		MissionRegion = math.random(1,2)
	end
	
	if MissionRegion == 1 then 
		MissionNum = math.random(1, 10)
		while lastpickup == MissionNum do
			Citizen.Wait(50)
			MissionNum = math.random(1, 10)
		end
		    if MissionNum == 3 then destination = Config.Livraison.Paikka3 namezone = "Paikka1" namezonenum = 1 namezoneregion = 1
		elseif MissionNum == 4 then destination = Config.Livraison.Paikka4 namezone = "Paikka2" namezonenum = 2 namezoneregion = 1
		elseif MissionNum == 5 then destination = Config.Livraison.Paikka5 namezone = "Paikka3" namezonenum = 3 namezoneregion = 1
		elseif MissionNum == 6 then destination = Config.Livraison.Paikka6 namezone = "Paikka4" namezonenum = 4 namezoneregion = 1
		elseif MissionNum == 7 then destination = Config.Livraison.Paikka7 namezone = "Paikka5" namezonenum = 5 namezoneregion = 1
		elseif MissionNum == 8 then destination = Config.Livraison.Paikka8 namezone = "Paikka6" namezonenum = 6 namezoneregion = 1
		elseif MissionNum == 9 then destination = Config.Livraison.Paikka9 namezone = "Paikka7" namezonenum = 7 namezoneregion = 1
		elseif MissionNum == 10 then destination = Config.Livraison.Paikka10 namezone = "Paikka8" namezonenum = 8 namezoneregion = 1 
		end
		
	elseif MissionRegion == 2 then 
		MissionNum = math.random(1, 11)
		while lastpickup == MissionNum do
			Citizen.Wait(50)
			MissionNum = math.random(1, 11)
		end
			if MissionNum == 1 then destination = Config.Livraison.Paikka11 namezone = "Paikka9" namezonenum = 1 namezoneregion = 2
		elseif MissionNum == 2 then destination = Config.Livraison.Paikka12 namezone = "Paikka10" namezonenum = 2 namezoneregion = 2
		elseif MissionNum == 3 then destination = Config.Livraison.Paikka13 namezone = "Paikka11" namezonenum = 3 namezoneregion = 2
		elseif MissionNum == 4 then destination = Config.Livraison.Paikka14 namezone = "Paikka12" namezonenum = 4 namezoneregion = 2
		elseif MissionNum == 5 then destination = Config.Livraison.Paikka15 namezone = "Paikka13" namezonenum = 5 namezoneregion = 2
		elseif MissionNum == 6 then destination = Config.Livraison.Paikka16 namezone = "Paikka14" namezonenum = 6 namezoneregion = 2
		elseif MissionNum == 7 then destination = Config.Livraison.Paikka17 namezone = "Paikka15" namezonenum = 7 namezoneregion = 2
		elseif MissionNum == 8 then destination = Config.Livraison.Paikka18 namezone = "Paikka16" namezonenum = 8 namezoneregion = 2
		elseif MissionNum == 9 then destination = Config.Livraison.Paikka19 namezone = "Paikka17" namezonenum = 9 namezoneregion = 2
		elseif MissionNum == 10 then destination = Config.Livraison.Paikka20 namezone = "Paikka18" namezonenum = 10 namezoneregion = 2
		elseif MissionNum == 11 then destination = Config.Livraison.Paikka21 namezone = "Paikka19" namezonenum = 11 namezoneregion = 2
		end
	end
	lastpickup = MissionNum
	MissionLivraisonLetsGo()
end

function MissionLivraisonLetsGo()
	if Blips['delivery'] ~= nil then
		RemoveBlip(Blips['delivery'])
		Blips['delivery'] = nil
	end
	
	if Blips['annulermission'] ~= nil then
		RemoveBlip(Blips['annulermission'])
		Blips['annulermission'] = nil
	end
	
	Blips['delivery'] = AddBlipForCoord(destination.Pos.x,  destination.Pos.y,  destination.Pos.z)
	SetBlipRoute(Blips['delivery'], true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(_U('blip_delivery'))
	EndTextCommandSetBlipName(Blips['delivery'])
	
	Blips['annulermission'] = AddBlipForCoord(Config.Livraison.AnnulerMission.Pos.x,  Config.Livraison.AnnulerMission.Pos.y,  Config.Livraison.AnnulerMission.Pos.z)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(_U('blip_goal'))
	EndTextCommandSetBlipName(Blips['annulermission'])

	if MissionRegion == 1 then 
		ESX.ShowNotification(_U('meet_ls'))
	elseif MissionRegion == 2 then
		ESX.ShowNotification(_U('meet_bc'))
	elseif MissionRegion == 0 then 
		ESX.ShowNotification(_U('meet_del'))
	end

	MissionLivraison = true
end

function MissionLivraisonStopRetourDepot()
	destination = Config.Livraison.RetourCamion
	
	Blips['delivery'] = AddBlipForCoord(destination.Pos.x,  destination.Pos.y,  destination.Pos.z)
	SetBlipRoute(Blips['delivery'], true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(_U('blip_depot'))
	EndTextCommandSetBlipName(Blips['delivery'])
	
	if Blips['annulermission'] ~= nil then
		RemoveBlip(Blips['annulermission'])
		Blips['annulermission'] = nil
	end

	ESX.ShowNotification(_U('return_depot'))
	
	MissionRegion = 0
	MissionLivraison = false
	MissionNum = 0
	MissionRetourCamion = true
end

function SavePlaqueVehicule()
	plaquevehicule = GetVehicleNumberPlateText(GetVehiclePedIsIn(GetPlayerPed(-1), false))
end

function VerifPlaqueVehiculeActuel()
	plaquevehiculeactuel = GetVehicleNumberPlateText(GetVehiclePedIsIn(GetPlayerPed(-1), false))
end

local blips = {
	{title="Postin Pukulokero", colour=60, id=267, x=78.88,  y= 111.85,  z=26.57},
    }

Citizen.CreateThread(function()

for _, info in pairs(blips) do
  info.blip = AddBlipForCoord(info.x, info.y, info.z)
  SetBlipSprite(info.blip, info.id)
  SetBlipDisplay(info.blip, 4)
  SetBlipScale(info.blip, 0.7)
  SetBlipColour(info.blip, 60)
  SetBlipAsShortRange(info.blip, true)
  BeginTextCommandSetBlipName("STRING")
  AddTextComponentString(info.title)
  EndTextCommandSetBlipName(info.blip)
end
end)
								
