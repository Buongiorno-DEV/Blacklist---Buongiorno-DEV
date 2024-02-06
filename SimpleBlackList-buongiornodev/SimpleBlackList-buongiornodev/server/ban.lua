local BanList            = {}
local BanListLoad        = false

CreateThread(function()
	while true do
		Wait(1000)

		if BanListLoad == false then
			loadBanList()

			if BanList ~= {} then
				BanListLoad = true
			else
			end
		end
	end
end)

CreateThread(function()
	while true do
		Wait(600000)

		if BanListLoad == true then
			loadBanList()
		end
	end
end)


RegisterServerEvent('ban:modder')
AddEventHandler('ban:modder', function(reason,servertarget)
	local license,identifier,liveid,xblid,discord,playerip,target
	local duree     = 0
	local reason    = reason

	if not reason then reason = "Auto Anti-Cheat" end

	if tostring(source) == "" then
		target = tonumber(servertarget)
	else
		target = source
	end

	if target and target > 0 then
		local ping = GetPlayerPing(target)

		if ping and ping > 0 then
			if duree and duree < 365 then
				local sourceplayername = "Anticheat"
				local targetplayername = GetPlayerName(target)

				for k,v in ipairs(GetPlayerIdentifiers(target))do
					if string.sub(v, 1, string.len("license:")) == "license:" then
						license = v
					elseif string.sub(v, 1, string.len("steam:")) == "steam:" then
						identifier = v
					elseif string.sub(v, 1, string.len("live:")) == "live:" then
						liveid = v
					elseif string.sub(v, 1, string.len("xbl:")) == "xbl:" then
						xblid  = v
					elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
						discord = v
					elseif string.sub(v, 1, string.len("ip:")) == "ip:" then
						playerip = v
					end
				end

				if duree > 0 then
					ban(target,license,identifier,liveid,xblid,discord,playerip,targetplayername,sourceplayername,duree,reason,123) --Timed ban here
					DropPlayer(target, "Sei stato disconnesso motivo: " .. reason)
				else
					ban(target,license,identifier,liveid,xblid,discord,playerip,targetplayername,sourceplayername,duree,reason,123) --Perm ban here
					DropPlayer(target, "Sei stato disconnesso motivo: " .. reason)
				end
			else
			end
		else
		end
	else
	end
end)

AddEventHandler('playerConnecting', function(playerName,setKickReason)
	local license,steamID,liveid,xblid,discord,playerip  = "n/a","n/a","n/a","n/a","n/a","n/a"

	for k,v in ipairs(GetPlayerIdentifiers(source))do
		if string.sub(v, 1, string.len("license:")) == "license:" then
			license = v
		elseif string.sub(v, 1, string.len("steam:")) == "steam:" then
			steamID = v
		elseif string.sub(v, 1, string.len("live:")) == "live:" then
			liveid = v
		elseif string.sub(v, 1, string.len("xbl:")) == "xbl:" then
			xblid  = v
		elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
			discord = v
		elseif string.sub(v, 1, string.len("ip:")) == "ip:" then
			playerip = v
		end
	end

	if (Banlist == {}) then
		Citizen.Wait(1000)
	end

	for i = 1, #BanList, 1 do
		if
			((tostring(BanList[i].license)) == tostring(license)
			or (tostring(BanList[i].identifier)) == tostring(steamID)
			or (tostring(BanList[i].liveid)) == tostring(liveid)
			or (tostring(BanList[i].xblid)) == tostring(xblid)
			or (tostring(BanList[i].discord)) == tostring(discord)
			or (tostring(BanList[i].playerip)) == tostring(playerip))
		then
			if (tonumber(BanList[i].permanent)) == 1 then
				setKickReason("Sei stato bannato motivo: " .. BanList[i].reason)
				CancelEvent()
				break
			end
		end
	end
end)

function ban(source,license,identifier,liveid,xblid,discord,playerip,targetplayername,sourceplayername,duree,reason,permanent)
	local expiration = duree * 86400
	local timeat     = os.time()
	local added      = os.date()

	if expiration < os.time() then
		expiration = os.time()+expiration
	end

	table.insert(BanList, {
		license    = license,
		identifier = identifier,
		liveid     = liveid,
		xblid      = xblid,
		discord    = discord,
		playerip   = playerip,
		reason     = reason,
		expiration = expiration,
		permanent  = permanent
	})

	MySQL.Async.execute('INSERT INTO buongiorno_ban (license,identifier,liveid,xblid,discord,playerip,targetplayername,sourceplayername,reason,expiration,timeat,permanent) VALUES (@license,@identifier,@liveid,@xblid,@discord,@playerip,@targetplayername,@sourceplayername,@reason,@expiration,@timeat,@permanent)', {
		['@license']          = license,
		['@identifier']       = identifier,
		['@liveid']           = liveid,
		['@xblid']            = xblid,
		['@discord']          = discord,
		['@playerip']         = playerip,
		['@targetplayername'] = targetplayername,
		['@sourceplayername'] = sourceplayername,
		['@reason']           = reason,
		['@expiration']       = expiration,
		['@timeat']           = timeat,
		['@permanent']        = permanent,
	}, function()
	end)

	BanListHistoryLoad = false
end

function loadBanList()
	MySQL.Async.fetchAll('SELECT * FROM buongiorno_ban', {}, function(data)
		BanList = {}

		for i=1, #data, 1 do
			table.insert(BanList, {
				license    = data[i].license,
				identifier = data[i].identifier,
				liveid     = data[i].liveid,
				xblid      = data[i].xblid,
				discord    = data[i].discord,
				playerip   = data[i].playerip,
				reason     = data[i].reason,
				expiration = data[i].expiration,
				permanent  = data[i].permanent
			})
		end
	end)
end


ESX.RegisterServerCallback("controllo:admin", function(source, cb)
    local player = ESX.GetPlayerFromId(source)

    if player ~= nil then
        local group = player.getGroup()

        if group ~= nil then 
            cb(group)
        else
            cb("user")
        end
    else
        cb("user")
    end
end)