local InfiniteAmmoPlayers = {}
if SERVER then
	local HL2Data = {
		["weapon_smg1"] = {Clip1 = 45, Clip2 = 1, Ammo1 = "SMG1", Ammo2 = "SMG1_Grenade"},
		["weapon_357"] = {Clip1 = 6,Ammo1 = "357"},
		["weapon_ar2"] = {Clip1 = 30, Clip2 = 1, Ammo1 = "ar2", Ammo2 = "AR2AltFire"},
		["weapon_shotgun"] = {Clip1 = 6,Ammo1 = "Buckshot"},
		["weapon_pistol"] = {Clip1 = 18,Ammo1 = "Pistol"},
		["weapon_rpg"] = {Clip1 = 1,Ammo1 = "RPG_Round"},
		["weapon_crossbow"] = {Clip1 = 1,Ammo1 = "XBowBolt"},
		["weapon_frag"] = {Clip1 = 1,Ammo1 = "Grenade"},
		["weapon_slam"] = {Clip1 = 1,Ammo1 = "slam"}
	}
	
	hook.Add("Think","MOREULX.InfAmmoThink",function()
		for k,v in pairs(InfiniteAmmoPlayers) do
			if not IsValid(k) then InfiniteAmmoPlayers[k] = nil continue end
			local wep = k:GetActiveWeapon()
			if IsValid(wep) then
				local data = HL2Data[wep:GetClass()]
				if data then
					wep:SetClip1(data.Clip1)
					k:SetAmmo(math.max(k:GetAmmoCount(data.Ammo1),data.Clip1+1),data.Ammo1)
					if data.Ammo2 then
						wep:SetClip2(data.Clip2 or 0)
						k:SetAmmo(math.max(k:GetAmmoCount(data.Ammo2),data.Clip2+1),data.Ammo2)
					end
				end
				if wep.Primary then
					wep:SetClip1((wep.Primary.ClipSize) + 1)
					k:SetAmmo(math.max((wep.Primary.ClipSize or 30)+1,5),wep.Primary.Ammo)
				end
				if wep.Secondary then
					wep:SetClip2((wep.Secondary.ClipSize or 30) + 1)
					k:SetAmmo(math.max((wep.Secondary.ClipSize or 30)+1,5),wep.Secondary.Ammo)
				end
			end
		end
	end)
end
function ulx.infammo(calling_ply, target_plys,should_revoke)
	local affected_plys = {}
	for i=1, #target_plys do
		local v = target_plys[ i ]
		if should_revoke and InfiniteAmmoPlayers[v] then
			InfiniteAmmoPlayers[v] = nil
			table.insert( affected_plys, v )
		elseif not should_revoke then
			InfiniteAmmoPlayers[v] = true
			table.insert( affected_plys, v )
		end
	end
	ulx.fancyLogAdmin( calling_ply, "#A granted infinite ammo upon #T", affected_plys )
end
local infammo = ulx.command("MoreULX", "ulx infammo", ulx.infammo, "!infammo")
infammo:addParam{ type=ULib.cmds.PlayersArg }
infammo:addParam{ type=ULib.cmds.BoolArg, invisible=true }
infammo:defaultAccess( ULib.ACCESS_ADMIN )
infammo:help( "Gives target(s) infinite ammo while enabled." )
infammo:setOpposite( "ulx limammo", {_, _, true}, "!limammo" )

local RocketPlayers = {}
if SERVER then
	hook.Add("Think","MOREULX.RocketThink",function()
		for k,v in pairs(RocketPlayers) do
			if not (IsValid(k) and k:Alive()) then RocketPlayers[k] = nil end
			k:SetVelocity(Vector(0,0,5000))
			local tr = {}
			local eye = k:EyePos()
			tr.start = eye
			tr.endpos = eye + Vector(0,0,20)
			tr.filter = k
			local trace = util.TraceLine(tr)
			if trace.Hit then
				k:Kill()
				local vPoint = k:GetPos()
				local effectdata = EffectData()
				effectdata:SetStart(vPoint)
				effectdata:SetOrigin(vPoint)
				effectdata:SetScale(1)
				util.Effect("Explosion", effectdata)
			end
		end
	end)
end

function ulx.rocket(calling_ply,target_plys)
	local affected_plys = {}
	for i=1, #target_plys do
		local v = target_plys[ i ]
		if v:Alive() then
			RocketPlayers[v] = true
			table.insert( affected_plys, v )
		end
	end
	ulx.fancyLogAdmin( calling_ply, "#A rocketed #T", affected_plys )
end
local rocket = ulx.command("MoreULX", "ulx rocket", ulx.rocket, "!rocket")
rocket:addParam{ type=ULib.cmds.PlayersArg }
rocket:defaultAccess( ULib.ACCESS_ADMIN )
rocket:help( "Makes them fly, and blows them up when they hit something." )

local BuddhaPlayers = {}
if SERVER then
	hook.Add("EntityTakeDamage","MOREULX.BuddhaTakeDamage",function(ent,dmginfo)
		if BuddhaPlayers[ent] then
			--if ent:Health() == 1 or ent:Health() then
			local dmg = math.max(0,(ent:Health()+ent:Armor())-dmginfo:GetDamage()) + 1
			dmginfo:SetDamage((ent:Health()+ent:Armor()) - dmg)
			--end
		end
	end)
end

function ulx.buddha(calling_ply,target_plys,should_revoke)
	local affected_plys = {}
	for i=1, #target_plys do
		local v = target_plys[ i ]
		if should_revoke and BuddhaPlayers[v] then
			BuddhaPlayers[v] = nil
			table.insert( affected_plys, v )
		elseif not should_revoke then
			BuddhaPlayers[v] = true
			table.insert( affected_plys, v )
		end
	end
	ulx.fancyLogAdmin( calling_ply, "#A buddha'ed #T", affected_plys )
end
local buddha = ulx.command("MoreULX", "ulx buddha", ulx.buddha, "!buddha")
buddha:addParam{ type=ULib.cmds.PlayersArg }
buddha:addParam{ type=ULib.cmds.BoolArg, invisible=true }
buddha:defaultAccess( ULib.ACCESS_ADMIN )
buddha:help( "The target(s) cannot lose health beyond 1." )
buddha:setOpposite( "ulx unbuddha", {_, _, true}, "!unbuddha" )

function ulx.crash(calling_ply,target_ply)
	target_ply:SendLua("cam.End3D()")
	ulx.fancyLogAdmin( calling_ply, "#A crashed #T", target_ply )
end
local crash = ulx.command("MoreULX", "ulx crash", ulx.crash, "!crash")
crash:addParam{ type=ULib.cmds.PlayerArg }
crash:defaultAccess( ULib.ACCESS_ADMIN )
crash:help( "Crashes the target." )

function ulx.crashban(calling_ply, target_ply, minutes, reason )
	target_ply:SendLua("cam.End3D()")
	target_ply.BeingBanned = true
	target_ply:Lock(true)
	target_ply:SetColor(Color(0,0,200,200))
	
	ulx.fancyLogAdmin( calling_ply, "#A crashbanned #T", target_ply )
	local function banOnDC(ply)
		if ply.BeingBanned == true then
			ULib.ban(ply,minutes,reason, calling_ply)
				local time = "for #i minute(s)"
				if minutes == 0 then time = "permanently" end
				local str = "#T was banned " .. time
				if reason and reason ~= "" then str = str .. " (#s)" end
				ulx.fancyLogAdmin( calling_ply, str, target_ply, minutes ~= 0 and minutes or reason, reason )
		end
	end
	ulx.fancyLogAdmin( nil, true,  "#T is being banned", target_ply)
	hook.Add("PlayerDisconnected", "DCBAN", banOnDC )
end
local crashban = ulx.command("MoreULX", "ulx crashban", ulx.crashban, "!crashban")
crashban:addParam{ type=ULib.cmds.PlayerArg }
crashban:addParam{ type=ULib.cmds.NumArg, hint="minutes, 0 for perma", ULib.cmds.optional, ULib.cmds.allowTimeString, min=0 }
crashban:addParam{ type=ULib.cmds.StringArg, hint="reason", ULib.cmds.optional, ULib.cmds.takeRestOfLine, completes=ulx.common_kick_reasons }
crashban:defaultAccess( ULib.ACCESS_ADMIN )
crashban:help( "Crashes and bans the target." )

local LastJoins = {}
local LastDisconnects = {}
if SERVER then
	util.AddNetworkString("MOREULX.ListJoinsDCs")
	hook.Add("PlayerAuthed","MOREULX.GetAuthed",function(ply)
		LastJoins[ply:SteamID()] = ply:Nick()
	end)
	hook.Add("PlayerDisconnected","MOREULX.GetAuthed",function(ply)
		LastDisconnects[ply:SteamID()] = ply:Nick()
	end)
else
	net.Receive("MOREULX.ListJoinsDCs",function(size)
		local joins = net.ReadTable()
		local dcs = net.ReadTable()
		MsgC(Color(255,255,255),"Joins:\n")
		for id,nick in pairs(joins) do
			MsgC(Color(0,255,100),id.."\t"..nick.."\n")
		end
		MsgC(Color(255,255,255),"Disconnects:\n")
		for id,nick in pairs(dcs) do
			MsgC(Color(255,0,100),id.."\t"..nick.."\n")
		end
	end)	
end

function ulx.listjoinsdcs(calling_ply)
	calling_ply:ChatPrint("Look in your console for the list!")
	net.Start("MOREULX.ListJoinsDCs")
		net.WriteTable(LastJoins)
		net.WriteTable(LastDisconnects)
	net.Send(calling_ply)
end
local listjoinsdcs = ulx.command("MoreULX", "ulx listjoinsdcs", ulx.listjoinsdcs, "!listjoinsdcs")
listjoinsdcs:defaultAccess( ULib.ACCESS_ALL )
listjoinsdcs:help( "Lists the last 10 joins and disconnects in console." )

function ulx.model(calling_ply,target_plys,modelOrRevoke)
	local affected_plys = {}
	modelOrRevoke = modelOrRevoke:lower()
	for i=1, #target_plys do
		local v = target_plys[ i ]
		if modelOrRevoke == "revoke" then
			if not v.MOREULXOldModel then continue end
			v:SetModel(v.MOREULXOldModel)
			table.insert( affected_plys, v )
		else
			if not util.IsValidModel(modelOrRevoke) then continue end
			v.MOREULXOldModel = v.MOREULXOldModel or v:GetModel()
			v:SetModel(modelOrRevoke)
			table.insert( affected_plys, v )
		end
	end
	ulx.fancyLogAdmin( calling_ply, "#A modeled #T", affected_plys )
end
local model = ulx.command("MoreULX", "ulx model", ulx.model, "!model")
model:addParam{ type=ULib.cmds.PlayersArg }
model:addParam{ type=ULib.cmds.StringArg, hint="model", ULib.cmds.takeRestOfLine }
model:defaultAccess( ULib.ACCESS_ADMIN )
model:help( "Sets the model of the target(s)." )
model:setOpposite( "ulx unmodel", {_, _, "revoke"}, "!unmodel" )

function ulx.scale(calling_ply,target_plys,scale)
	local affected_plys = {}
	for i=1, #target_plys do
		local v = target_plys[ i ]
		v.MOREULXScale = scale
		v.MOREULXViewOffset = v.MOREULXViewOffset or v:GetViewOffset()
		v.MOREULXViewOffsetDucked =v.MOREULXViewOffsetDucked or v:GetViewOffsetDucked()
		
		v:SetViewOffset(v.MOREULXViewOffset*scale)
		v:SetViewOffsetDucked(v.MOREULXViewOffsetDucked*scale)
		v:SetModelScale(scale,0)
		table.insert( affected_plys, v )
	end
	ulx.fancyLogAdmin( calling_ply, "#A scaled #T", affected_plys )
end
local scale = ulx.command("MoreULX", "ulx scale", ulx.scale, "!scale")
scale:addParam{ type=ULib.cmds.PlayersArg }
scale:addParam{ type=ULib.cmds.NumArg, hint="scale, can be decimal. default is 1.", default=1, min=0.1, max=10}
scale:defaultAccess( ULib.ACCESS_ADMIN )
scale:help( "Scales the player, also setting their view offset." )

function ulx.jumppower(calling_ply,target_plys,speed,revoke)
	local affected_plys = {}
	for i=1, #target_plys do
		local v = target_plys[i]
		if revoke then
			if v.MOREULXJumpPower then
				v:SetJumpPower(v.MOREULXJumpPower)
				table.insert( affected_plys, v )
			end
		else
			v.MOREULXJumpPower = v.MOREULXJumpPower or v:GetJumpPower()
			v:SetJumpPower(speed)
			table.insert( affected_plys, v )
		end
	end
	ulx.fancyLogAdmin( calling_ply, "#A set the jump power of #T", affected_plys )
end
local jumppower = ulx.command("MoreULX", "ulx jumppower", ulx.jumppower, "!jumppower")
jumppower:addParam{ type=ULib.cmds.PlayersArg }
jumppower:addParam{ type=ULib.cmds.NumArg, hint="jump power", default=100, min=0.1, max=1000,ULib.cmds.round}
jumppower:addParam{ type=ULib.cmds.BoolArg, invisible=true }
jumppower:defaultAccess( ULib.ACCESS_ADMIN )
jumppower:help( "Sets the sprinting speed of the target(s)." )
jumppower:setOpposite( "ulx resetjumppower", {_, _, _, true}, "!resetjumppower" )

function ulx.sprintspeed(calling_ply,target_plys,speed,revoke)
	local affected_plys = {}
	for i=1, #target_plys do
		local v = target_plys[i]
		if revoke then
			if v.MOREULXRunSpeed then
				v:SetRunSpeed(v.MOREULXRunSpeed)
				table.insert( affected_plys, v )
			end
		else
			v.MOREULXRunSpeed = v.MOREULXRunSpeed or v:GetRunSpeed()
			v:SetRunSpeed(speed)
			table.insert( affected_plys, v )
		end
	end
	ulx.fancyLogAdmin( calling_ply, "#A set the sprint speed of #T", affected_plys )
end
local sprintspeed = ulx.command("MoreULX", "ulx sprintspeed", ulx.sprintspeed, "!sprintspeed")
sprintspeed:addParam{ type=ULib.cmds.PlayersArg }
sprintspeed:addParam{ type=ULib.cmds.NumArg, hint="speed", default=240, min=0.1, max=1000,ULib.cmds.round}
sprintspeed:addParam{ type=ULib.cmds.BoolArg, invisible=true }
sprintspeed:defaultAccess( ULib.ACCESS_ADMIN )
sprintspeed:help( "Sets the sprinting speed of the target(s)." )
sprintspeed:setOpposite( "ulx resetsprintspeed", {_, _, _, true}, "!resetsspeed" )

function ulx.walkspeed(calling_ply,target_plys,speed,revoke)
	local affected_plys = {}
	for i=1, #target_plys do
		local v = target_plys[i]
		if revoke then
			if v.MOREULXWalkSpeed then
				v:SetWalkSpeed(v.MOREULXWalkSpeed)
				table.insert( affected_plys, v )
			end
		else
			v.MOREULXWalkSpeed = v.MOREULXWalkSpeed or v:GetWalkSpeed()
			v:SetWalkSpeed(speed)
			table.insert( affected_plys, v )
		end
	end
	ulx.fancyLogAdmin( calling_ply, "#A set the walk speed of #T", affected_plys )
end
local walkspeed = ulx.command("MoreULX", "ulx walkspeed", ulx.walkspeed, "!walkspeed")
walkspeed:addParam{ type=ULib.cmds.PlayersArg }
walkspeed:addParam{ type=ULib.cmds.NumArg, hint="speed", default=220, min=1, max=1000,ULib.cmds.round}
walkspeed:addParam{ type=ULib.cmds.BoolArg, invisible=true }
walkspeed:defaultAccess( ULib.ACCESS_ADMIN )
walkspeed:help( "Sets the running speed of the target(s)." )
walkspeed:setOpposite( "ulx resetwalkspeed", {_, _, _, true}, "!resetwspeed" )

function ulx.cleardecals(calling_ply)
	for k,v in pairs(player.GetAll()) do
		v:ConCommand("r_cleardecals")
	end
	ulx.fancyLogAdmin( calling_ply, "#A cleared decals.")
end
local cleardecals = ulx.command("MoreULX", "ulx cleardecals", ulx.cleardecals, "!cleardecals")
cleardecals:defaultAccess( ULib.ACCESS_ADMIN )
cleardecals:help( "Clears the decals." )

function ulx.clearragdolls(calling_ply)
	for k,v in pairs(player.GetAll()) do
		v:SendLua([[for k,v in pairs(ents.FindByClass('class C_ClientRagdoll')) do v:Remove() end]])
	end
	ulx.fancyLogAdmin( calling_ply, "#A cleared clientside ragdolls.")
end
local clearragdolls = ulx.command("MoreULX", "ulx clearragdolls", ulx.clearragdolls, "!clearragdolls")
clearragdolls:defaultAccess( ULib.ACCESS_ADMIN )
clearragdolls:help( "Clears clientside ragdolls on all players, reducing lag." )

function ulx.stopsound(calling_ply)
	for k,v in pairs(player.GetAll()) do
		v:SendLua([[RunConsoleCommand("stopsound")]])
	end
	ulx.fancyLogAdmin( calling_ply, "#A ran stopsound on all players.")
end
local stopsound = ulx.command("MoreULX", "ulx stopsound", ulx.stopsound, "!stopsound")
stopsound:defaultAccess( ULib.ACCESS_ADMIN )
stopsound:help( "Runs stopsound on all players." )

function ulx.restartmap(calling_ply)
	ulx.fancyLogAdmin( calling_ply, "#A restarted the map.")
	game.ConsoleCommand("changelevel "..string.gsub(game.GetMap(),".bsp","",1))
end
local restartmap = ulx.command("MoreULX", "ulx restartmap", ulx.restartmap, "!restartmap")
restartmap:defaultAccess( ULib.ACCESS_ADMIN )
restartmap:help( "Reloads the map." )

function ulx.cleanprops(calling_ply,target_ply)
	for k,v in pairs(ents.FindByClass("prop_physics")) do
		if (v.Owner and v.Owner == target_ply) or (v.FPPOwnerID and v.FPPOwnerID == target_ply:SteamID()) then
			v:Remove()
		end
	end
	
	ulx.fancyLogAdmin( calling_ply, "#A cleaned the props of #T", target_ply )
end
local cleanprops = ulx.command("MoreULX", "ulx cleanprops", ulx.cleanprops, "!cleanprops")
cleanprops:addParam{ type=ULib.cmds.PlayerArg }
cleanprops:defaultAccess( ULib.ACCESS_ADMIN )
cleanprops:help( "Cleans the props of the target." )

function ulx.nolag(calling_ply)
	for k,v in pairs(ents.FindByClass("prop_physics")) do
		v:GetPhysicsObject():EnableMotion(false)
	end
	
	ulx.fancyLogAdmin( calling_ply, "#A freezed all props." )
end
local nolag = ulx.command("MoreULX", "ulx nolag", ulx.nolag, "!nolag")
nolag:defaultAccess( ULib.ACCESS_ADMIN )
nolag:help( "Freezes all props on the map." )

function ulx.reconnect(calling_ply,target_ply)
	target_ply:SendLua([[RunConsoleCommand("retry")]])
	ulx.fancyLogAdmin( calling_ply, "#A reconnected #T", target_ply )
end
local reconnect = ulx.command("MoreULX", "ulx reconnect", ulx.reconnect, "!reconnect")
reconnect:addParam{ type=ULib.cmds.PlayerArg }
reconnect:defaultAccess( ULib.ACCESS_ADMIN )
reconnect:help( "Reconnects the target." )
