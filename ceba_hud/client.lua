--[[    
															 
██████╗ ██╗   ██╗     ██████╗███████╗██████╗  █████╗
██╔══██╗╚██╗ ██╔╝    ██╔════╝██╔════╝██╔══██╗██╔══██╗
██████╔╝ ╚████╔╝     ██║     █████╗  ██████╔╝███████║
██╔══██╗  ╚██╔╝      ██║     ██╔══╝  ██╔══██╗██╔══██║
██████╔╝   ██║       ╚██████╗███████╗██████╔╝██║  ██║
╚═════╝    ╚═╝        ╚═════╝╚══════╝╚═════╝ ╚═╝  ╚═╝
																						  
--]]


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

ESX = nil

-- local pogoda = false

-- ZMIENNE --
local prox = 10.0 -- Sets the Default Voice Distance
local isTalking = false
local showDayss = true
local playerJoin = false
local moveHud = false




Citizen.CreateThread(function()
	while true do 
		Citizen.Wait(500)
		if not playerJoin then
			NetworkSetVoiceActive(false)
			NetworkSetTalkerProximity(1.0)
			playerJoin = true
		end
	end
end)



Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
	NetworkSetTalkerProximity(1.0)
	TurnRadar(false)
end)

-- MINIMAPA I PRZESUWANIE TAK O --
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(500)

		local playerPed = GetPlayerPed(-1)

		if IsPedInAnyVehicle(playerPed, true) then
			TurnRadar(true)
		else
			TurnRadar(false)
		end
	end
end)

-- VOICE CHAT --
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if IsControlJustPressed(1, Keys["F5"]) then --F5
			local vprox
			if prox <= 2.5 then
				prox = 10.0
				vprox = "normal"
			elseif prox == 10.0 then
				prox = 26.0
				vprox = "shout"
			elseif prox >= 26.0 then
				prox = 2.5
				vprox = "whisper"
			end
			NetworkSetTalkerProximity(prox)
			SendNUIMessage({action = "setProximity", value = vprox})
		end
		if IsControlPressed(1, Keys["F5"]) then --F5
			local posPlayer = GetEntityCoords(GetPlayerPed(-1))
			DrawMarker(1, posPlayer.x, posPlayer.y, posPlayer.z - 1, 0, 0, 0, 0, 0, 0, prox * 2, prox * 2, 0.8001, 0, 75, 255, 165, 0,0, 0,0)
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(50)
		if isTalking == false then
			if NetworkIsPlayerTalking(PlayerId()) then
				isTalking = true
				SendNUIMessage({action = "setTalking", value = true})
			end
		else
			if NetworkIsPlayerTalking(PlayerId()) == false then
				isTalking = false
				SendNUIMessage({action = "setTalking", value = false})
			end
		end
	end
end)

Citizen.CreateThread(function()
    RequestAnimDict("facials@gen_male@variations@normal")
   RequestAnimDict("mp_facial")

    local talkingPlayers = {}
    while true do
        Citizen.Wait(300)

        for k,v in pairs(GetPlayers()) do
            local boolTalking = NetworkIsPlayerTalking(v)
            if v ~= PlayerId() then
                if boolTalking then
                   PlayFacialAnim(GetPlayerPed(v), "mic_chatter", "mp_facial")
                    talkingPlayers[v] = true
                elseif not boolTalking and talkingPlayers[v] then
                    PlayFacialAnim(GetPlayerPed(v), "mood_normal_1", "facials@gen_male@variations@normal")
                    talkingPlayers[v] = nil
                end
            end
        end
    end
end)

RegisterCommand("getprox", function(source, args, raw)
    player = GetPlayerPed(-1)
          local currentprox = NetworkGetTalkerProximity()
end, false)

Citizen.CreateThread(function()
    while true do
    Citizen.Wait(60000)
        player = GetPlayerPed(-1)
        local currentprox = NetworkGetTalkerProximity()
            setVoice(voice.current)
    end
end)

function GetPlayers()
    local players = {}

    for i = 0, 256 do -- jeśli 64 sloty 255;
        if NetworkIsPlayerActive(i) then
            table.insert(players, i)
        end
    end

    return players
end


-- TE POJEBANE NAPISY OBOK VOICE --
-- LOKALIZACJA --
local zones = { ['AIRP'] = "Lotnisko LS", ['ALAMO'] = "Alamo Sea", ['ALTA'] = "Alta", ['ARMYB'] = "Fort Zancudo", ['BANHAMC'] = "Banham Canyon", ['BANNING'] = "Banning", ['BEACH'] = "Vespucci Beach", ['BHAMCA'] = "Banham Canyon", ['BRADP'] = "Braddock Pass", ['BRADT'] = "Braddock Tunnel", ['BURTON'] = "Burton", ['CALAFB'] = "Calafia Bridge", ['CANNY'] = "Raton Canyon", ['CCREAK'] = "Cassidy Creek", ['CHAMH'] = "Chamberlain Hills", ['CHIL'] = "Vinewood Hills", ['CHU'] = "Chumash", ['CMSW'] = "Chiliad Mountain", ['CYPRE'] = "Cypress Flats", ['DAVIS'] = "Davis", ['DELBE'] = "Del Perro Beach", ['DELPE'] = "Del Perro", ['DELSOL'] = "La Puerta", ['DESRT'] = "Grand Senora", ['DOWNT'] = "Downtown", ['DTVINE'] = "Downtown Vinewood", ['EAST_V'] = "East Vinewood", ['EBURO'] = "El Burro Heights", ['ELGORL'] = "El Gordo", ['ELYSIAN'] = "Elysian Island", ['GALFISH'] = "Galilee", ['GOLF'] = "Klub Golfowy", ['GRAPES'] = "Grapeseed", ['GREATC'] = "Great Chaparral", ['HARMO'] = "Harmony", ['HAWICK'] = "Hawick", ['HORS'] = "Vinewood Racetrack", ['HUMLAB'] = "Humane Labs and Research", ['JAIL'] = "Bolingbroke Penitentiary", ['KOREAT'] = "Little Seoul", ['LACT'] = "Land Act Reservoir", ['LAGO'] = "Lago Zancudo", ['LDAM'] = "Land Act Dam", ['LEGSQU'] = "Legion Square", ['LMESA'] = "La Mesa", ['LOSPUER'] = "La Puerta", ['MIRR'] = "Mirror Park", ['MORN'] = "Morningwood", ['MOVIE'] = "Richards Majestic", ['MTCHIL'] = "Mount Chiliad", ['MTGORDO'] = "Mount Gordo", ['MTJOSE'] = "Mount Josiah", ['MURRI'] = "Murrieta Heights", ['NCHU'] = "North Chumash", ['NOOSE'] = "N.O.O.S.E", ['OCEANA'] = "Pacific Ocean", ['PALCOV'] = "Paleto Cove", ['PALETO'] = "Paleto Bay", ['PALFOR'] = "Paleto Forest", ['PALHIGH'] = "Palomino Highlands", ['PALMPOW'] = "Palmer-Taylor Power Station", ['PBLUFF'] = "Pacific Bluffs", ['PBOX'] = "Pillbox Hill", ['PROCOB'] = "Procopio Beach", ['RANCHO'] = "Rancho", ['RGLEN'] = "Richman Glen", ['RICHM'] = "Richman", ['ROCKF'] = "Rockford Hills", ['RTRAK'] = "Redwood Track", ['SANAND'] = "San Andreas", ['SANCHIA'] = "San Chianski", ['SANDY'] = "Sandy Shores", ['SKID'] = "Mission Row", ['SLAB'] = "Stab City", ['STAD'] = "Maze Bank Arena", ['STRAW'] = "Strawberry", ['TATAMO'] = "Tataviam Mountains", ['TERMINA'] = "Terminal", ['TEXTI'] = "Textile City", ['TONGVAH'] = "Tongva Hills", ['TONGVAV'] = "Tongva Valley", ['VCANA'] = "Vespucci Canals", ['VESP'] = "Vespucci", ['VINE'] = "Vinewood", ['WINDF'] = "Wind Farm", ['WVINE'] = "West Vinewood", ['ZANCUDO'] = "Zancudo River", ['ZP_ORT'] = "Port LS", ['ZQ_UAR'] = "Davis Quartz" }
local directions = { [0] = 'N', [45] = 'NW', [90] = 'W', [135] = 'SW', [180] = 'S', [225] = 'SE', [270] = 'E', [315] = 'NE', [360] = 'N', }
local streetText = ''
-- local pogodaHash = ''

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(500)
		local pos = GetEntityCoords(GetPlayerPed(-1))
		local var1, var2 = GetStreetNameAtCoord(pos.x, pos.y, pos.z, Citizen.ResultAsInteger(), Citizen.ResultAsInteger())
		local current_zone = zones[GetNameOfZone(pos.x, pos.y, pos.z)]

		for k,v in pairs(directions)do
			direction = GetEntityHeading(GetPlayerPed(-1))
			if(math.abs(direction - k) < 22.5)then
				direction = v
				break;
			end
		end

		if(GetStreetNameFromHashKey(var1) and GetNameOfZone(pos.x, pos.y, pos.z)) then
			if(zones[GetNameOfZone(pos.x, pos.y, pos.z)] and tostring(GetStreetNameFromHashKey(var1))) then
				streetText = direction..' | '..tostring(GetStreetNameFromHashKey(var1))
				SendNUIMessage({
					showStreet = true,
					locationn = streetText
				})
			end
		end
	end
end)

-- DZIEŃ I GODZINA --
local dayText = ''

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1500)

		local dayInt = GetClockDayOfWeek()
		local day = ''

		if dayInt == 0 then
			day = 'Niedziela'
		elseif dayInt == 1 then
			day = 'Poniedziałek'
		elseif dayInt == 2 then
			day = 'Wtorek'
		elseif dayInt == 3 then
			day = 'Środa'
		elseif dayInt == 4 then
			day = 'Czwartek'
		elseif dayInt == 5 then
			day = 'Piątek'
		elseif dayInt == 6 then
			day = 'Sobota'
		end

		local hourInt = GetClockHours()
		local hour = ''
		if string.len(tostring(hourInt)) == 1 then
			hour = '0'..hourInt
		else
			hour = hourInt
		end

		local minuteInt = GetClockMinutes()
		local minute = ''
		if string.len(tostring(minuteInt)) == 1 then
			minute = '0'..minuteInt
		else
			minute = minuteInt
		end

			dayText = hour..':'..minute..' | '..day

		SendNUIMessage({
			showDay = true,
			days = dayText
		})
	end
end)


-- FUNCKJA MINIMAPA --
function TurnRadar(on)
	if on then
		if moveHud == false then
			moveHud = true
			SendNUIMessage({
				action = "moveHudd",
				show = true
			})
		end
		DisplayRadar(true)
	else
		if moveHud == true then
			moveHud = false
			SendNUIMessage({
				action = "moveHudd",
				show = false
			})
		end
		DisplayRadar(false)
	end
end
