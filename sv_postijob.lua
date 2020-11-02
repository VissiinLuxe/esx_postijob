ESX = nil
passanger1 = nil
passanger2 = nil
passanger3 = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_posti:pay')
AddEventHandler('esx_posti:pay', function(amount)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local payamount = math.ceil(amount)
	xPlayer.addMoney(tonumber(payamount))
end)

RegisterServerEvent('esx_posti:binselect')
AddEventHandler('esx_posti:binselect', function(binpos, platenumber, bagnumb)
	TriggerClientEvent('esx_posti:setbin', -1, binpos, platenumber,  bagnumb)
end)

RegisterServerEvent('esx_posti:requestpay')
AddEventHandler('esx_posti:requestpay', function(platenumber, amount)
	TriggerClientEvent('esx_posti:startpayrequest', -1, platenumber, amount)
end)

RegisterServerEvent('esx_posti:bagremoval')
AddEventHandler('esx_posti:bagremoval', function(platenumber)
	TriggerClientEvent('esx_posti:removedbag', -1, platenumber)

end)

RegisterServerEvent('esx_posti:endcollection')
AddEventHandler('esx_posti:endcollection', function(platenumber)
	TriggerClientEvent('esx_posti:clearjob', -1, platenumber)
end)

RegisterServerEvent('esx_posti:reportbags')
AddEventHandler('esx_posti:reportbags', function(platenumber)
	TriggerClientEvent('esx_posti:countbagtotal', -1, platenumber)
end)

RegisterServerEvent('esx_posti:bagsdone')
AddEventHandler('esx_posti:bagsdone', function(platenumber, bagstopay)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	TriggerClientEvent('esx_posti:addbags', -1, platenumber, bagstopay, xPlayer )
end)
