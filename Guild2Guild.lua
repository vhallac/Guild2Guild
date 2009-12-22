--[[
	¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
	Guild2Guild - updated by Durthos of Proudmoore
	Origionally by Elviso of MugThol - elviso@kenman.net
      -  	¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
	Enables communication between 2 guilds via a seperate (private) chat channel, which
	translates the messages between the 2 guild chats. Two users are required to have this
	addon for it to work (1 in each guild), however only 1 user per guild is required to have
	Guild2Guild for all members of both guilds to reap the benefits. For example, guild chat
	from guild A will appear in guild Bs guild chat, and vice-versa.

	TODO:
	* I also need to set priority on relays that are not in instances.
	* epochs
	* maybe some UI

	Changelog:
	7.5.9
	- fixed error caused when the person you are talking to disconnects, but you still have messages for them
	- fixed error message when you turn on Blizzard Class Colouring in the chat frame

	7.5.8
	- shortened the inter-guild message when a player earns an achievement

	7.5.7
	- changed to use ChatThrottleLib by Mikk  - http://www.wowwiki.com/ChatThrottleLib which should prevent disconnects when a large raid gets an achievement
	- allow the channel password to be set to NIL by typing /g2g password

	7.5.6
	- fixed a few minor bugs related to achieviemnts
	- achievments are no longer broadcasted unless they come from someone in your guild.
	- achievment messages are now displaed in the correct window

	7.5.5
	- achievements are now propagated across guilds
	- fixed an extra space that was being introduced when in guild2guild messages
	- added a 'silent' mode which allows a player to not see any guild2guild messages
	- the addon now automatically shuts down if the password is set incorrectly

	7.5.4
	- updated for current TOC

	7.5.3
	- added an additional call to set the variable (arg2) for the sender. For the case of addons like Prat and PhanxChat
	which were incorrectly reading it from the global namespace instead of the passed in arguments. This fixes the bug
	where some users would see messages as coming from the relay instead of from the correct sender
	- added more useful debugging information

	7.5.2
	- initialized chat color properly

	7.5.1
	- fixed a bug that was still causing duplicate names after relay changes

	7.5.0
	- Updated to current TOC
	- fixed up after blizzard changed the chatframe api

	7.4.9
	- Updated to current TOC
	- added the ability to disable notification messages

	7.4.8
	- ability for a relay to step down if there are others available (passive mode)
	- /report shows the complete list of potential relays, and their versions
	- no longer allow allied guilds to be put on the rejected relay list
	- added a way to change the chat color for incoming guild messages to the context menu for the chat frame
	- fixed a synchronization issue where an election would happen immediately after a player logged in if it took them a long time to load

	7.4.7
	fixed an error where an officer would always try to be the relay

	7.4.6 - Jan 5, 2008
	- fixed an error on login when the 'guildmembernotify' variable had not yet loaded, but I was trying to query it
	- fixed a parse error when looking for player has left the guild messages


	7.4.5 - Jan 2, 2008
	- Selection of relays is now based on officer rank, ignore list, and whether the 'guild member alert' is set to on
	- Play the friend online sound when a member of an allied guild comes online
	- Text from players in the allied guild that you are ignoring is no longer displayed locally
	- fixed a nil pointer when a message that is too long is sent with a hyperlink
	- hide the g2g channel

	7.4.4 - Dec 27, 2007
	- avoid sending Online/Offline messages for players that are merely on the relays friends list, and not actually in the guild.

	7.4.3 - Dec 27, 2007
	- incorrect function when a player turns off guild2guild preventing them from exiting the advanced configuration page

	7.4.2 - Dec 27, 2007
	- added notifications when a guild member comes online

	7.4.1 - Dec 9, 2007
	- added debug code to log on errors
	- limited relayed addon messages to 1 per second

	7.4.0 - Dec 2, 2007
	split messages sent to guild chat on to two lines if they are longer than 254 characters
	prevent addon messages longer than 254 characters from being sent

	7.3.9 - Nov 24, 2007
	added a filter for which guild addon messages are relayed
	fixed a null pointer when loggin in an unguilded character
	Added channel, and password as options that can go in the guild information pane to be parsed
	Fixed a bug on initialization caused when the guildname had not been loaded yet

	7.3.8 - Nov 24, 2007
	Workaround for blizzard bug where GuildInfo is cached between different characters
	Re-enabled relaying guild addon messages

	7.3.7 - Nov 22, 2007
	temporarily disabled relaying guild addon messages

	7.3.6 - Nov 21, 2007
	Fixed some null pointers

	7.3.5 - officer chat is detected automatically
	- other addon messages sent to the guild channel are now relayed
	- fixed a problem where guild2guild was always trying to take over the first channel
	- fixed a bug which was causing connections to other guilds to be lost when the current relay logged out, and a new one took over if the guild was not using the whitelist

	7.3.4 - fixed duplicate messages caused when the relay is drunk, and the guild is not using
	a whitelist

	7.3.3 - fixed a synchronization issue electing a new relay when the current relay logged out

	7.3.2 - first public version after a re-write to support multiple relays, improve
		robustness, and use a secure whispers instead of the relay channel

	¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
]]--



local function dump(...)
	local out = "";
	local numVarArgs = select("#", ...);
	for i = 1, numVarArgs do
		local d = select(i, ...);
		local t = type(d);
		if (t == "table") then
			out = out .. "{";
			local first = true;
			if (d) then
				for k, v in pairs(d) do
					if (not first) then out = out .. ", "; end
					first = false;
					out = out .. dump(k);
					out = out .. " = ";
					out = out .. dump(v);
				end
			end
			out = out .. "}";
		elseif (t == "nil") then
			out = out .. "NIL";
		elseif (t == "number") then
			out = out .. d;
		elseif (t == "string") then
			out = out .. "\"" .. d .. "\"";
		elseif (t == "boolean") then
			if (d) then
				out = out .. "true";
			else
				out = out .. "false";
			end
		else
			out = out .. t:upper() .. "??";
		end

		if (i < numVarArgs) then out = out .. ", "; end
	end
	return out;
end

G2GOldChatHandler = nil;
G2GOldChangeChatColor = nil;

G2G_ONLINE 	= ".*%[(.+)%]%S*"..string.sub(ERR_FRIEND_ONLINE_SS, 20)
G2G_OFFLINE	= string.format(ERR_FRIEND_OFFLINE_S, "(.+)")
G2G_JOINED	= string.format(ERR_GUILD_JOIN_S, "(.+)")
G2G_LEFT	= string.format(ERR_GUILD_LEAVE_S, "(.+)")
G2G_PROMO	= string.format(ERR_GUILD_PROMOTE_SSS, "(.+)", "(.+)", "(.+)")
G2G_DEMOTE	= string.format(ERR_GUILD_DEMOTE_SSS, "(.+)", "(.+)", "(.+)")
G2G_ACHIEVEMENT = string.format(ACHIEVEMENT_BROADCAST, "(.+)", "(.+)")
G2G_F_ACHIEVEMENT = string.format(ACHIEVEMENT_BROADCAST, "|Hplayer:%s|h[%s]|h", "%s")

-- Callback handler we use to fire custom events

local cbh
--[[
		¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
		¤¤¤ Variable Setup ¤¤¤
		¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
]]--

Guild2Guild = {
	Version = "7.5.9",
	VerNum = 759,
	playerNotes = {},
	otherPlayerNotes = {},
	knownRosters = {},
	Loaded = false,
	Initialized = false,
	Finalizing = false,
	Ready = false,
	tColors = {
		cBlue = "|cff007fff",
		cLtGray = "|cffdfdfdf",
		cLtRed = "|cffff6060",
		cLtYellow = "|cffffff78",
		cGold = "|cffffd700",
		cGreen = "|cff00ff00",
		cRed = "|cffff0000",
		cSilver = "|cffc7c7cf",
		cWhite = "|cffffffff",
		cYellow = "|cffffff00",
		cCL = "|r",
	},
	LocalVars = {
		Leader = nil,
		Magic = time(),
		CurrMax = 0,
		CurrMaxVersion = 0,
		LastUpdate = time (),
		LastCrossGuildUpdate = time (),
		Guilds = {},
		Relays = {},
		RejectedRelays = {},
		WarnedVersionNum = false,
		GuildInfoInitialized = false,
		OfficerRank = nil,
		PlayerIsOfficer = false,
		OfficersWarned = false,
		guildRankIndex = nil,
		AlliedGuilds = nil,
		sentQueryMessage = false,
		awaitingQueryResponse = false,
		OldestVersion = nil,
		ElectionCalled = false,
		sentInitLeaderMessage = false,
		debugStack = {},
		stackCount = 0,
		VerifiedGuilds = {},
		PreviousMessage = "",
		PreviousSender = "",
		GuildInfoText = "",
		Guis = {},
		lastAddonMessageTime = 0,
		lastElectionMessageTime = 0,
		guildRoster = {},
		friends = {},
		ignores = {},
		channelRoster = {},
		localRank = 0,
		versions = {},
		failedAttempts = 0
	},

--[[
		¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
		¤¤¤ OnLoad/Init Methods ¤¤¤
		¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
]]--


-----------------------------
-- ResetLocalVariables - resets all variables to their initial states
-----------------------------
	ResetLocalVariables = function(self)
		local GGlocal = Guild2Guild.LocalVars

		self.Initialized = false
		self.Finalizing = false
		self.Ready = false

		GGlocal.Leader = nil
		GGlocal.Magic = time()
		GGlocal.CurrMax = 0
		GGlocal.CurrMaxVersion = 0
		GGlocal.LastUpdate = time ()
		GGlocal.LastCrossGuildUpdate = time ()
		GGlocal.Guilds = {}
		GGlocal.Relays = {}
		GGlocal.RejectedRelays = {}
		GGlocal.WarnedVersionNum = false
		GGlocal.GuildInfoInitialized = false
		GGlocal.OfficerRank = nil
		GGlocal.PlayerIsOfficer = false
		GGlocal.OfficersWarned = false
		GGlocal.guildRankIndex = nil
		GGlocal.AlliedGuilds = nil
		GGlocal.sentQueryMessage = false
		GGlocal.awaitingQueryResponse = false
		GGlocal.OldestVersion = nil
		GGlocal.ElectionCalled = false
		GGlocal.sentInitLeaderMessage = false
		GGlocal.debugStack = {}
		GGlocal.stackCount = 0
		GGlocal.VerifiedGuilds = {}
		GGlocal.PreviousMessage = ""
		GGlocal.PreviousSender = ""
		GGlocal.GuildInfoText = ""
		GGlocal.lastAddonMessageTime = 0
		GGlocal.lastElectionMessageTime = 0
		GGlocal.guildRoster = {}
		GGlocal.friends = {}
		GGlocal.ignores = {}
		GGlocal.channelRoster = {}
		GGlocal.localRank = 0
		GGlocal.versions = {}
		GGlocal.failedAttempts = 0
	end,


-----------------------------
-- OnLoad - called on initial start up to prepare the add-on
-----------------------------
	OnLoad = function(self)
		local cColors = Guild2Guild.tColors
		self:DCF(cColors.cGreen.."v"..Guild2Guild.Version..cColors.cSilver.." loaded :: Type "..cColors.cGreen.."/g2g help"..cColors.cSilver.." for usage.",1)
		this:RegisterEvent("ADDON_LOADED")
		SlashCmdList["GUILD2GUILD"] = function(sMsg)
			self:Slash_Command(sMsg)
		end
		SLASH_GUILD2GUILD1 = "/g2g";
	end,

-----------------------------
-- GG_Init - called after the add-on has loaded to prepare to handle future events
-----------------------------
	GG_Init = function(self)
		local playerName = UnitName("player");
		if((playerName) and (playerName == UNKNOWNOBJECT) or (playerName == UKNOWNBEING)) then return end

		if not self.Initialized then
			if Guild2Guild_Vars == nil then
				Guild2Guild_Vars = DefaultGuild2Guild_Vars
			end

			for key, value in pairs(DefaultGuild2Guild_Vars) do
				if (Guild2Guild_Vars[key] == nil) then
					Guild2Guild_Vars[key] = value
				end
			end

			-- clear out the incorrect guild member notify
			Guild2Guild_Vars.G2GGuildMemberNotify = nil;
			-- end clearing out guildmember notify

			Guild2Guild_Vars.debugStack = {}
			Guild2Guild.LocalVars.OldestVersion = self.VerNum
			if (Guild2Guild_Vars.Startdelay == false) then
				Guild2Guild_Vars.Startdelay = 15
			end
			self:Event_Manager()
			self.Initialized = true
--			self:executeGUIs("initialize")
			return this:UnregisterEvent("ADDON_LOADED")
		end
	end,

-----------------------------
-- AddChatType - Adds the Guild2Guild chat type to the chat frame context menu
-----------------------------

	AddChatType = function(self)

		local v = {
				id = "G2G";
				menuText = "G2G";
			}

		setglobal("CHAT_"..v.id.."_GET", "["..v.menuText.."]: ");

		setglobal("CHAT_MSG_"..v.id, v.menuText);

		tinsert(ChatTypeGroup["GUILD"], "CHAT_MSG_"..v.id ); -- Fake event list

		ChatTypeInfo[v.id] = {};
		Guild2Guild_Vars.chatTypes = Guild2Guild_Vars.chatTypes or {}
		local chatType = Guild2Guild_Vars.chatTypes[v.id]
		if (not chatType) then
			chatType = {};
			chatType[DEFAULT_CHAT_FRAME:GetID()] = true;
			local info = ChatTypeInfo["GUILD"];
			chatType.r = info.r;
			chatType.g = info.g;
			chatType.b = info.b;
			Guild2Guild_Vars.chatTypes[v.id] = chatType;
			Guild2Guild_Vars.color = Guild2Guild.RGBToHex(info.r,info.g,info.b)
		end
		local chatFrame;
		for i=1, NUM_CHAT_WINDOWS do
			if (chatType[i]) then
				chatFrame = getglobal("ChatFrame"..i);
				if (not Guild2Guild.IsChatTypeVisible(v.id, chatFrame)) then
					ChatFrame_AddMessageGroup(chatFrame, v.id);
				end
			end
		end
		ChatTypeInfo[v.id].r = chatType.r;
		ChatTypeInfo[v.id].g = chatType.g;
		ChatTypeInfo[v.id].b = chatType.b;

		ChatTypeInfo[v.id].sticky = 0;

	end,

-----------------------------
-- IsChatTypeVisible - helper function to determine if a chat type is visible in the context menu
-----------------------------

	IsChatTypeVisible = function (chatTypeGroup, chatFrame)
		if (not chatFrame) then
			return;
		end
		local messageTypeList = chatFrame.messageTypeList
		if ( messageTypeList ) then
			for joinedIndex, joinedValue in pairs(messageTypeList) do
				if ( chatTypeGroup == joinedValue ) then
					return true;
				end
			end
		end
		return false;
	end,
----------------------------
-- Event_Manager - Hooks the UI call back functions
----------------------------

	Event_Manager = function(self)
		local GGVars = Guild2Guild_Vars
		if GGVars.Active then
			if GGVars.Debug then self:DCF("Register fired.",5,"Event_Manager") end
			Guild2GuildFrame:RegisterEvent("CHAT_MSG_CHANNEL")
			Guild2GuildFrame:RegisterEvent("CHAT_MSG_GUILD")
			Guild2GuildFrame:RegisterEvent("CHAT_MSG_OFFICER")
			Guild2GuildFrame:RegisterEvent("CHAT_MSG_CHANNEL_JOIN")
			Guild2GuildFrame:RegisterEvent("CHAT_MSG_CHANNEL_LEAVE")
			Guild2GuildFrame:RegisterEvent("CHAT_MSG_ADDON")
			Guild2GuildFrame:RegisterEvent("CHAT_MSG_WHISPER")
			Guild2GuildFrame:RegisterEvent("GUILD_ROSTER_UPDATE")
			Guild2GuildFrame:RegisterEvent("PLAYER_ALIVE")
			Guild2GuildFrame:RegisterEvent("CHAT_MSG_SYSTEM")
			Guild2GuildFrame:RegisterEvent("CVAR_UPDATE")
			Guild2GuildFrame:RegisterEvent("FRIENDLIST_UPDATE")
			Guild2GuildFrame:RegisterEvent("IGNORELIST_UPDATE")
			Guild2GuildFrame:RegisterEvent("CHANNEL_ROSTER_UPDATE")
			Guild2GuildFrame:RegisterEvent("CHAT_MSG_GUILD_ACHIEVEMENT")
			Guild2GuildFrame:RegisterEvent("CHAT_MSG_ACHIEVEMENT")
			Guild2GuildFrame:RegisterEvent("CHAT_MSG_CHANNEL_NOTICE")
		else
			if GGVars.Debug then self:DCF("Unregister fired.",5,"Event_Manager") end
			Guild2GuildFrame:UnregisterEvent("CHAT_MSG_CHANNEL")
			Guild2GuildFrame:UnregisterEvent("CHAT_MSG_GUILD")
			Guild2GuildFrame:UnregisterEvent("CHAT_MSG_OFFICER")
			Guild2GuildFrame:UnregisterEvent("CHAT_MSG_CHANNEL_JOIN")
			Guild2GuildFrame:UnregisterEvent("CHAT_MSG_CHANNEL_LEAVE")
			Guild2GuildFrame:UnregisterEvent("CHAT_MSG_ADDON")
			Guild2GuildFrame:UnregisterEvent("CHAT_MSG_WHISPER")
			Guild2GuildFrame:UnregisterEvent("GUILD_ROSTER_UPDATE")
			Guild2GuildFrame:UnregisterEvent("PLAYER_ALIVE")
			Guild2GuildFrame:UnregisterEvent("CHAT_MSG_SYSTEM")
			Guild2GuildFrame:UnregisterEvent("CVAR_UPDATE")
			Guild2GuildFrame:UnregisterEvent("FRIENDLIST_UPDATE")
			Guild2GuildFrame:UnregisterEvent("IGNORELIST_UPDATE")
			Guild2GuildFrame:UnregisterEvent("CHANNEL_ROSTER_UPDATE")
			Guild2GuildFrame:UnregisterEvent("CHAT_MSG_GUILD_ACHIEVEMENT")
			Guild2GuildFrame:UnregisterEvent("CHAT_MSG_ACHIEVEMENT")
			Guild2GuildFrame:UnregisterEvent("CHAT_MSG_CHANNEL_NOTICE")
		end
		self:Hook_UI()
	end,


----------------------------
-- ReadyToWork - returns false until the start delay time has passed, then initialized the final connection and returns true
----------------------------

	ReadyToWork = function(self)

		if self.Ready then return true end

		local GGlocal = Guild2Guild.LocalVars
		local GGVars = Guild2Guild_Vars
		local cColors = Guild2Guild.tColors

		if ((time() - GGlocal.Magic) < GGVars.Startdelay) then return false end
		if not GGlocal.GuildInfoInitialized then
			if (IsInGuild()) then
				GuildRoster();   -- calling GuildRoster will force a callback on which should call ParseGuildInfo that will eventually initialize GuildInfo
			elseif ((time() - GGlocal.Magic) > 90) then
				self:Guild2Guild_PrintDEBUG("player not in guild","ReadyToWork")
				self:DCF(cColors.cRed.."Player is not in a guild:"..cColors.cWhite.."disabling guild2guild.",1)
				self:SetActive(false)

				GGlocal.GuildInfoInitialized = true
			end
			return false
		end

		local firstChannelNumber = GetChannelList();
  		if (firstChannelNumber == nil) then
			self:Guild2Guild_PrintDEBUG("no channels yet","Ready to work")
			GGlocal.Magic = time() - GGVars.Startdelay + 3;
			return false;
		end

		if (Guild2Guild_Vars.GuildMemberNotify == nil) then
			SetCVar("guildMemberNotify", "1");
			Guild2Guild_Vars.GuildMemberNotify = "1"
		end

		local gmn = GetCVar("guildMemberNotify");
		if (gmn == nil or gmn == "0") then
			Guild2Guild_Vars.GuildMemberNotify = "0"
		else
			Guild2Guild_Vars.GuildMemberNotify = "1"
		end

		self:Guild2Guild_PrintDEBUG("guildMemberNotify",gmn, Guild2Guild_Vars.GuildMemberNotify, "ReadyToWork")

		IgnoreList_Update();
		self:ParseFriendList();
		self:ParseIgnoreList();

		if (self.Finalizing) then return end
		self.Finalizing = true                        -- cheap hacky form of locking
		if (self.Ready) then return end

		if not self:Init_Channel() then
			self.Finalizing = false;
			return false
		end

--[[ ADDED BY BEH START
local playersOnline = {}
local numPlayersTotal = 0
local name, note
		numPlayersTotal = GetNumGuildMembers(true)
--		ChatFrame3:AddMessage("Number of members: " .. numPlayersTotal)
		for i = 1, numPlayersTotal do
			name, _, _, _, _, _, note, _, _, _ = GetGuildRosterInfo(i)
--			ChatFrame3:AddMessage(name.. " " .. note)
			if name then
				Guild2Guild.playerNotes[name] = note
			end
		end
-- ADDED BY BEH END ]]--

		self:AddChatType()
		self.Ready = true
		return true
	end,


----------------------------
-- ParseFriendList - updates the current friendlist
----------------------------

	ParseFriendList = function (self)
		local GGlocal = Guild2Guild.LocalVars

		local numFriends=GetNumFriends();

		GGlocal.friends = {}
		for idx=1,numFriends do
			local name = GetFriendInfo(idx);
			if(name~=nil)then
				GGlocal.friends[name] = true
			end
		end
		self:Guild2Guild_PrintDEBUG("numFriends: "..numFriends, "ParseFriendList")
	end,

----------------------------
-- ParseIgnoreList - updates the current ignorelist
----------------------------

	ParseIgnoreList = function (self)
		local GGlocal = Guild2Guild.LocalVars

		local numIgnores=GetNumIgnores();

		GGlocal.ignores = {}

		for idx=1,numIgnores do
			local name = GetIgnoreName(idx);
			if(name~=nil)then
				GGlocal.ignores[name] = true
			end
		end
		self:Guild2Guild_PrintDEBUG("numIgnores: "..numIgnores, "ParseIgnoreList")
		self:CalculateRank()
	end,

----------------------------
-- ParseGuildInfo - Looks for the Officer Rank (R) or the Allied Guilds (A) in the guild information and sets the communication levels appropriately
----------------------------

	ParseGuildInfo = function(self)
		local GGlocal = Guild2Guild.LocalVars
		local GGVars = Guild2Guild_Vars

		if ((not IsInGuild()) and ((time() - GGlocal.Magic) > 90)) then
			self:Guild2Guild_PrintDEBUG("player not in guild","ParseGuildInfo")
			GGlocal.GuildInfoInitialized = true
			Guild2GuildFrame:UnregisterEvent("GUILD_ROSTER_UPDATE")
			return true
		else
--			self:Guild2Guild_PrintDEBUG("guildcheck: (inGuild, elapsed time)",IsInGuild(),time() - GGlocal.Magic, "ParseGuildInfo")
		end

		local guildname, _, gr = GetGuildInfo("player");  -- zero based

		local guildinfotext= GetGuildInfoText()

		if (GGlocal.GuildInfoInitialized and GGlocal.GuildInfoText ~= nil and GGlocal.GuildInfoText == guildinfotext) then
--			self:Guild2Guild_PrintDEBUG("GuildInfo Unchanged")
			return;
		end
		GGlocal.GuildInfoText = guildinfotext;

		GGlocal.RejectedRelays = {};

		if (guildinfotext == nil or (guildinfotext == "" and ((time() - GGlocal.Magic) < 90)) or guildname == nil or guildname == "") then
			self:Guild2Guild_PrintDEBUG("guildname or guildinfotext empty",guildname, guildinfotext, "ParseGuildInfo")
			return false
		end
		local found, _, g2gCommand = string.find(guildinfotext,"<G2G;([^>]-)>")
--		self:Guild2Guild_PrintDEBUG("full command",g2gCommand,"ParseGuildInfo")

		local i = 0;
		while i < 10 and GGlocal.OfficerRank == nil do
			if (not (self:G2G_isOfficerRank(i))) then
				GGlocal.OfficerRank = i-1
			end
			i = i + 1;
		end

		while (found ~= nil) do
			local cmd, value;
			found, _, cmd, value, g2gCommand = string.find(g2gCommand, "(%a):([^;]-);(.*)")

--			self:Guild2Guild_PrintDEBUG("subcommand",cmd, value,"ParseGuildInfo")

			if (cmd == "A") then
				local guildName = GetGuildInfo("player");
				GGlocal.AlliedGuilds = {}
				GGlocal.VerifiedGuilds= {}
				GGlocal.AlliedGuilds[guildName] = true
				GGlocal.VerifiedGuilds[guildName] = true
				for w in string.gmatch(value, "[^,]+") do
					GGlocal.AlliedGuilds[w] = true
					GGlocal.VerifiedGuilds[w] = true
				end
			elseif (cmd == "C") then
				Guild2Guild_Vars.Channel = value;
			elseif (cmd == "P") then
				Guild2Guild_Vars.Password = value;
			end
		end

		if (GGlocal.OfficerRank ~= nil) then
			GGlocal.PlayerIsOfficer = gr <= GGlocal.OfficerRank
			if (GGlocal.PlayerIsOfficer) then
				GGlocal.guildRankIndex = 9
			else
				GGlocal.guildRankIndex = 0
			end
		else
			GGlocal.guildRankIndex = 9 - gr;
		end


		local numGuildMembers=GetNumGuildMembers(true);
		local showOfflineTemp=GetGuildRosterShowOffline();
		SetGuildRosterShowOffline(true);

		for idx=1,numGuildMembers do
			local name = GetGuildRosterInfo(idx);

			if(name~=nil)then
				GGlocal.guildRoster[name] = true
			end
		end
		SetGuildRosterShowOffline(showOfflineTemp);

		self:Guild2Guild_PrintDEBUG("final",GGlocal.AlliedGuilds, GGlocal.OfficerRank, Guild2Guild_Vars.Channel, Guild2Guild_Vars.Password, "ParseGuildInfo")

--		Guild2GuildFrame:UnregisterEvent("GUILD_ROSTER_UPDATE")

		GGlocal.GuildInfoInitialized = true
		return true
	end,

----------------------------
-- G2G_isOfficerRank - helper function for the above
----------------------------
	G2G_isOfficerRank = function (self,rankIndex)

	       --get permission flags for that player's guild rank number
	       --have to add one here because SetRank() numbers from 1, while GetInfo() above numbers from 0
	       GuildControlSetRank(rankIndex + 1)
	       local permissionFlags = {GuildControlGetRankFlags()}

	       --if player can chat in officer channel, we return true.  false otherwise
	       if permissionFlags[4] and permissionFlags[4] == 1 then return true end

	       return false

	end,

----------------------------
-- Init_Channel - initializes the cross guild synchronization channel
----------------------------
	Init_Channel = function(self)
		local GGlocal = Guild2Guild.LocalVars
		local GGVars = Guild2Guild_Vars
		local cColors = Guild2Guild.tColors
		local bState = GGVars.Active
		if GGVars.Debug then self:DCF("fired.",5,"Init_Channel") end

		if GGVars.Debug then self:DCF("Channel Initialized",5,"Init_Channel") end

		-- join the channel
		if bState and GGVars.Channel then
			self:JoinChannel(GGVars.Channel,GGVars.Password)

			local id = GetChannelName(GGVars.Channel);
			SetSelectedDisplayChannel(3)
			local channelCount = GetNumDisplayChannels();
			for i=1, channelCount, 1 do
				local name, _, _, dispNum = GetChannelDisplayInfo(i)
				if (dispNum == id) then
					SetSelectedDisplayChannel(i)
					break
				end
			end

			if (id == 0) then
				self:DCF(cColors.cRed.."Guild2Guild failed to join channel: "..cColors.cWhite..GGVars.Channel..cColors.cSilver.." Shutting down.",1)
				self:SetActive(false)
				return false
			else
				self:DCF(cColors.cBlue.."using channel: "..cColors.cWhite..GGVars.Channel.." "..id,1)
				ChatFrame_RemoveChannel(DEFAULT_CHAT_FRAME,GGVars.Channel)
			end
			GGlocal.LastUpdate = time() - 30;                  -- pretend that we have just received a message
			return true

		elseif not bState and GGVars.Channel then
			self:Guild2Guild_PrintDEBUG("leave channel:",GGVars.Channel,"Init_Channel")
			--leave chan
			LeaveChannelByName(GGVars.Channel)
		elseif bState and not GGVars.Channel then
			self:DCF(cColors.cRed.."You must set a channel using "..cColors.cWhite.."/g2g channel "..cColors.cSilver.."["..cColors.cGold.."MY_CHANNEL"..cColors.cSilver.."]"..cColors.cRed.." before using this addon. Guild2Guild has been turned off. Please set a channel and then re-enable Guild2Guild with "..cColors.cWhite	.."/g2g on"..cColors.cSilver..".",1)
			self:SetActive(false)
		end
		return false
	end,

----------------------------
-- SetupChannelRoster - counts the number of people in the channel
----------------------------

	SetupChannelRoster = function(self,channelID)
		local GGVars = Guild2Guild_Vars
		local GGlocal = Guild2Guild.LocalVars

		channelName, _, _, channelNumber, count = GetChannelDisplayInfo(channelID);
		self:Guild2Guild_PrintDEBUG(channelID, channelName, channelNumber, count, "SetupChannelRoster")

		if (channelName ~= GGVars.Channel) then
			return
		end

		GGlocal.channelRoster = {}
		for id=1, count, 1 do
			name = GetChannelRosterInfo(channelID, id)
			if (name ~= nil) then
				GGlocal.channelRoster[name] = true
			end
		end
		Guild2GuildFrame:UnregisterEvent("CHANNEL_ROSTER_UPDATE")
	end,

----------------------------
-- Hook_UI - sets up the new chat handler which prevents messages from Guild2Guild from appearing on the screen
----------------------------

	Hook_UI = function(self)
		local GGVars = Guild2Guild_Vars

		local GGlocal = Guild2Guild.LocalVars
		self:Guild2Guild_PrintDEBUG("Hooking UI")

		local GGVars = Guild2Guild_Vars
		local bState = GGVars.Active

		if (bState) then
			if (G2GOldChatHandler == nil) then
				G2GOldChatHandler = ChatFrame_OnEvent
				ChatFrame_OnEvent = Guild2Guild.NewChatHandler
				self:Guild2Guild_PrintDEBUG("set NewChatHandler")
			end

			if (G2GOldChangeChatColor == nil) then
				G2GOldChangeChatColor = ChangeChatColor
				ChangeChatColor = Guild2Guild.NewChangeChatColor

				self:Guild2Guild_PrintDEBUG("set NewChangeChatColor")
			end

			self:Guild2Guild_PrintDEBUG("UI Hooked")

		else
			if (G2GOldChatHandler ~= nil) then
				ChatFrame_OnEvent = G2GOldChatHandler
				G2GOldChatHandler = nil
			end

			if (G2GOldChangeChatColor ~= nil) then
				ChangeChatColor = G2GOldChangeChatColor
				G2GOldChangeChatColor = nil
			end

			self:Guild2Guild_PrintDEBUG("UI Unhooked")
		end
	end,

----------------------------
-- NewChatHandler - used to avoid displaying chat messages sent by Guild2Guild
----------------------------

	NewChatHandler = function (self,event,...)
		local msg, realSender, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12 = ...;

		-- use the gloabal arg1 and arg2 so that programs like Prat and Phanxchat work as expected.
		arg1 = msg;
		arg2 = realSender;

		-- Use a "return" command to prevent the incoming messsages that we don't want
		-- from appearing in the chat frame.

		if (event == "CHAT_MSG_WHISPER") then
			if (arg1 and arg1 ~= nil) then
				if (string.sub(arg1,1,3) == "G2G") then
					return;
				end
			end

		elseif (event == "CHAT_MSG_WHISPER_INFORM") then
			if (arg1 and arg1 ~= nil) then
				if (string.sub(arg1,1,3) == "G2G") then
					return;
				end
			end
  		elseif event == "CHAT_MSG_CHANNEL" and arg9 and arg9 ~= nil and strlower(arg9) == strlower(Guild2Guild_Vars.Channel) then
			return;
  		elseif event == "CHAT_MSG_GUILD" or event == "CHAT_MSG_OFFICER" then
--			Guild2Guild.Guild2Guild_PrintDEBUG(Guild2Guild,"inc", arg2, Guild2Guild.LocalVars.Leader, "NewChatHandler1")

		  	if (arg2 and arg2 ~=nil and Guild2Guild.LocalVars.Leader and Guild2Guild.LocalVars.Leader ~= nil and arg2 == Guild2Guild.LocalVars.Leader) then
				if (arg1 and arg1 ~= nil) then
					if (string.sub(arg1,1,1) == "[") then
--						Guild2Guild.Guild2Guild_PrintDEBUG(Guild2Guild,"inc", arg1,arg2, arg12,"NewChatHandler2")

						local found, realSender, msg
						found,_,realSender,msg = string.find(arg1, "%[([^%]]*)%]: (.*)")
						if (found) then
							if (Guild2Guild_Vars.Silent) then
								Guild2Guild.Guild2Guild_PrintDEBUG(Guild2Guild,"squelch", arg1,arg2,"NewChatHandler2")
								return
							end

							arg1 = Guild2Guild_Vars.color..msg
							arg2 = realSender -- to see if setting the global variable helps
                                                        guid = Guild2Guild_Vars.CachedPlayerIDs[arg2];
							if (guid) then
								arg12 = guid
                                                            else
                                                                arg12=""
							end

--							Guild2Guild.Guild2Guild_PrintDEBUG(Guild2Guild,"disp", arg1,realSender,arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11,arg12,"NewChatHandler3")
						end

						if (Guild2Guild.LocalVars.ignores[arg2]) then
							return
						end
					end
				end
			end
		end
--		Guild2Guild.Guild2Guild_PrintDEBUG(Guild2Guild,"inc", event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12)

	-- Call the original ChatFrame_OnEvent function for default handling of the event.
	G2GOldChatHandler(self, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12);

	end,

----------------------------
-- NewChangeChatColor - used to catch changes in chat text colour
----------------------------
	NewChangeChatColor = function(chatType, r, g, b)
		Guild2Guild.Guild2Guild_PrintDEBUG(Guild2Guild,chatType, r, g, b,"NewChangeChatColor")

		if ( chatType and chatType == "G2G" and ChatTypeInfo[chatType] ) then
			ChatTypeInfo[chatType].r = r;
			ChatTypeInfo[chatType].g = g;
			ChatTypeInfo[chatType].b = b;
			Guild2Guild_Vars.chatTypes[chatType].r = r;
			Guild2Guild_Vars.chatTypes[chatType].g = g;
			Guild2Guild_Vars.chatTypes[chatType].b = b;

			Guild2Guild_Vars.color = Guild2Guild.RGBToHex(r,g,b)
		end
		G2GOldChangeChatColor(chatType, r, g, b)
	end,

	RGBToHex = function (r, g, b)
		r = r * 255
		g = g * 255
		b = b * 255
		return string.format("|cff%02x%02x%02x", r, g, b)
	end,


--[[
		¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
		¤¤¤ Main Event Processor ¤¤¤
		¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
]]--

----------------------------
-- SendG2GSyncMessage - Universal Synchronization message sender
----------------------------

	SendG2GSyncMessage = function(self, msgType, additionalMsg)
		local GGVars = Guild2Guild_Vars
		local GGlocal = Guild2Guild.LocalVars

		local sMsg = "<G2G"..self.VerNum..">"..msgType..GGlocal.localRank..GGlocal.Magic;

		if (not(additionalMsg == nil)) then
			sMsg = sMsg..";"..additionalMsg
		end
		ChatThrottleLib:SendAddonMessage("ALERT", "G2G", sMsg, "GUILD");
	end,

----------------------------
-- SendCrossGuildSyncMessage- Universal Synchronization message sender
----------------------------

	SendCrossGuildSyncMessage = function(self, msgType, dest, player)
		local GGVars = Guild2Guild_Vars
		local GGlocal = Guild2Guild.LocalVars
		local guildName = GetGuildInfo("player");

		local sID, sName = GetChannelName(GGVars.Channel)
		local sMsg = "<G2G"..self.VerNum..">"..guildName..";"..GGlocal.guildRankIndex..msgType

		if (dest == "CHANNEL") then
			ChatThrottleLib:SendChatMessage("ALERT", "G2G", sMsg,"CHANNEL",GetDefaultLanguage("player"),sID)
		elseif (dest == "PLAYER") then
			ChatThrottleLib:SendAddonMessage("ALERT", "G2G", sMsg, "WHISPER",player)
		end
	end,

----------------------------
-- SendLeaderMessage - send the message to inform the world that we are the relay
----------------------------

	SendLeaderMessage = function(self, sendToChannel)
		local GGlocal = Guild2Guild.LocalVars

		if (sendToChannel) then
			if (not GGlocal.sentInitLeaderMessage) then
				self:SendCrossGuildSyncMessage("I", "CHANNEL", nil)
				GGlocal.sentInitLeaderMessage = true
			end

			self:SendCrossGuildSyncMessage("L", "CHANNEL", nil)
			GGlocal.LastCrossGuildUpdate = time()
		end

		self:SendG2GSyncMessage("L")
		GGlocal.LastUpdate = time()
	end,

----------------------------
-- SendElectionMessage - send the info about ourselves to see if we should be the relay
----------------------------

	SendElectionMessage = function(self, reset)
		local GGlocal = Guild2Guild.LocalVars

		if (time() > GGlocal.lastElectionMessageTime) then
			GGlocal.ElectionCalled = true
			self:Guild2Guild_PrintDEBUG("calling election","SendElectionMessage")


			if (reset) then
				GGlocal.CurrMax = 0
				GGlocal.CurrMaxVersion = 0
			end

			self:SendG2GSyncMessage("E")
			GGlocal.LastUpdate = time()
			GGlocal.lastElectionMessageTime = time()
		end
	end,


----------------------------
-- SendLocalQueryMessage - send the info about ourselves to see if we should be the relay
----------------------------

	SendLocalQueryMessage = function(self)
		self:Guild2Guild_PrintDEBUG("sending query","SendQueryMessage")
		local GGlocal = Guild2Guild.LocalVars

		GGlocal.sentQueryMessage = true
		GGlocal.awaitingQueryResponse = true

		GGlocal.LastUpdate = time()
		self:SendG2GSyncMessage("Q")
	end,

----------------------------
-- SendRejectionLetter -
----------------------------

	SendRejectionLetter = function(self, recipient)
		self:Guild2Guild_PrintDEBUG("sending rejection to "..recipient,"SendRejectionLetter")
		self:SendCrossGuildSyncMessage("R", "PLAYER" , recipient)
	end,

----------------------------
-- OnUpdate - makes sure that heartbeat messages get transmitted
----------------------------
	OnUpdate = function(self,event,arg1)
		local GGVars = Guild2Guild_Vars
		local GGlocal = Guild2Guild.LocalVars

		if not GGVars.Active then return end

		if not self:ReadyToWork() then return end

		if (GGlocal.Leader == UnitName("player")) then
			local timeout = 55
			if (GGlocal.ElectionCalled or GGlocal.OldestVersion < 724) then timeout = 10 end
			local shouldSendCrossGuildUpdate = (not GGlocal.ElectionCalled) and             -- don't send an update until the election is over
									time() - GGlocal.LastCrossGuildUpdate > 300
			if (time() - GGlocal.LastUpdate > timeout or shouldSendCrossGuildUpdate) then
				local sendToChannel = GGlocal.ElectionCalled or shouldSendCrossGuildUpdate
				self:SendLeaderMessage(sendToChannel)
			end
		else
			local timeout = 65
			if (GGlocal.awaitingQueryResponse) then timeout = 10 end
			if (time() - GGlocal.LastUpdate > timeout) then
				self:Guild2Guild_PrintDEBUG("Calling election due to no heartbeat")
				self:SendElectionMessage(true)
			end
		end
--		self:executeGUIs("OnUpdate")

	end,

----------------------------
-- OnEvent - Main Event Handler
----------------------------

	OnEvent = function(self,event,arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12)
--		if Guild2Guild_Vars and Guild2Guild_Vars.Debug then self:DCF("\""..event.."\" fired, entry: "..arg1,5,"OnEvent") end

--		if (event ~= "CHAT_MSG_ADDON") then
--			self:Guild2Guild_PrintDEBUG(event,arg1,"OnEvent")
--		end

		if (event == "ADDON_LOADED" and arg1 == "Guild2Guild") then
			self.Loaded = true
			if Guild2Guild_Vars and Guild2Guild_Vars.Debug then self:DCF("ADDON_LOADED",5,"OnEvent") end
			return self:GG_Init()
		end

		if not self.Loaded then
			if Guild2Guild_Vars and Guild2Guild_Vars.Debug then self:DCF("returning early because ADDON_LOADED = false",5,"OnEvent") end
			return
		end
		if not self.Initialized then
			if Guild2Guild_Vars and Guild2Guild_Vars.Debug then self:DCF("returning early because self.Initialized = false",5,"OnEvent") end
			return self:GG_Init()
		end

		local GGVars = Guild2Guild_Vars

		if not GGVars.Active then return end

		if (event == "PLAYER_ALIVE") then
			GuildRoster();
			Guild2GuildFrame:UnregisterEvent("PLAYER_ALIVE")
			return
		elseif (event == "GUILD_ROSTER_UPDATE") then
			self:ParseGuildInfo()
			return
		elseif (event == "FRIENDLIST_UPDATE") then
			self:ParseFriendList()
			return
		elseif (event == "IGNORELIST_UPDATE") then
			self:ParseIgnoreList()
			return
		elseif (event == "CHANNEL_ROSTER_UPDATE") then
			self:SetupChannelRoster(arg1)
			return
		end

		local cColors = Guild2Guild.tColors
		local GGlocal = Guild2Guild.LocalVars

		if (event == "CHAT_MSG_CHANNEL_NOTICE" and arg1 == "WRONG_PASSWORD" and arg9 == GGVars.Channel) then
			GGlocal.failedAttempts = GGlocal.failedAttempts + 1;
			self:Guild2Guild_PrintDEBUG(event, GGlocal.failedAttempts, "WRONG_PASSWORD")

			if (GGlocal.failedAttempts > 3) then
				self:Guild2Guild_PrintDEBUG("too many attempts","Ready to work")
				self:DCF(cColors.cRed.."Channel Password is set incorrectly "..cColors.cWhite.."disabling guild2guild.",1)
				self:SetActive(false)
				return
			end
		end

		if not self:ReadyToWork() then return end;

		local guildname = GetGuildInfo("player")
		if (not (IsInGuild()) or guildname == nil) then
			self:SetActive(false)
			self:DCF(cColors.cRed.."Player is not in a guild:"..cColors.cWhite.."disabling guild2guild.",1)
		end

		if (not GGlocal.sentQueryMessage) then
			self:SendLocalQueryMessage()
		end
		local sID, sName = GetChannelName(GGVars.Channel)

		if GGVars.Channel then
			if sID == 0 or sName == nil then
				if Guild2Guild_Vars and Guild2Guild_Vars.Debug then self:DCF("It should be impossible to get here but I did",5,"OnEvent") end
				if not self:Init_Channel() then return end
			end
		else
			if not self:Init_Channel() then return end
		end

--		if (event ~= "CHAT_MSG_ADDON" and event ~= "CHAT_MSG_GUILD") then
--			self:Guild2Guild_PrintDEBUG(event,arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12, "OnEvent1")
--		end

		if (event == "CHAT_MSG_CHANNEL_LEAVE" and strlower(arg9) == strlower(GGVars.Channel)) then
			GGlocal.channelRoster[arg2] = nil
			if (GGlocal.ignores[arg2] ~= nil) then
				self:CalculateRank()
			end

			self:HandlePlayerLeaving(arg2)
		elseif (event == "CHAT_MSG_CHANNEL_JOIN" and strlower(arg9) == strlower(GGVars.Channel)) then
			GGlocal.channelRoster[arg2] = true
			GGVars.CachedPlayerIDs[arg2] = arg12
			if (GGlocal.ignores[arg2] ~= nil) then
				self:CalculateRank()
			end
		elseif (event == "CHAT_MSG_ADDON") then
			if (arg1 == "G2G") then
				if (arg3 == "GUILD") then
					self:HandleGuildSyncMessage(arg2,arg4)
				elseif (arg3 == "WHISPER") then
					self:HandleIncomingGuildMessage(arg2, arg4, arg12)
				end
-- ADDED: VH
			elseif (arg1 == "G2GNR" and arg3 == "WHISPER") then
				-- Private message: Do not pass on to our guild channel
				-- These can only come directly through WHISPER
				found,_, cmd, player, guild, extra = string.find(arg2,"(.);([^;]-);([^;]-);(.*)")
				if (cmd == "Z") then
--					DEFAULT_CHAT_FRAME:AddMessage("cmd z")
					found, _, note, online = string.find(extra, "([^;]-);(.*)")
					self.knownRosters[guild] = true
					self.otherPlayerNotes[player] = Guild2Guild.otherPlayerNotes[player] or {}
					self.otherPlayerNotes[player].guild = guild
					self.otherPlayerNotes[player].note = note
					self.otherPlayerNotes[player].online = online
					if online == "1" then
						cbh:Fire("PLAYERONLINE", player, guild, note)
					end
				elseif (cmd == "Y") then
-- 				DEFAULT_CHAT_FRAME:AddMessage("cmd y")
					local numPlayersTotal = 0
					local name, note, online
					numPlayersTotal = GetNumGuildMembers(true)
					for i = 1, numPlayersTotal do
						name, rank, rankindex, level, class, zone, note, officernote, online, status = GetGuildRosterInfo(i)
						online = online and "1" or "0"
						if name then
							self:SendTargetedAuxMessage(arg4, name, "Z", note .. ";" .. online);
--							DEFAULT_CHAT_FRAME:AddMessage("sending: " .. arg4 .. ";" .. name .. ";Z;" .. note)
						end
					end
--[[
					for name, note in pairs(Guild2Guild.playerNotes) do
						-- ... tell the logged in player to record the player info
--						DEFAULT_CHAT_FRAME:AddMessage("sending: " .. arg4 .. ";" .. name .. ";Z;" .. note)
						self:SendTargetedAuxMessage(arg4, name, "Z", note);

-- If the above fails, try:
--						local sMsg = "Z;" .. name .. ";" .. GetGuildInfo("player") .. ";" .. note
--						self:SendCrossGuildSyncMessage(sMsg, "PLAYER", arg4)
					end
]]--
				end
-- END:   VH
			elseif ((arg3 == "GUILD") and (GGlocal.Leader == UnitName("player"))) then
				self:ForwardAddOnMessage(arg1, arg2,arg4)
			end

  		elseif event == "CHAT_MSG_CHANNEL" and strlower(arg9) == strlower(GGVars.Channel) then
  			local addOnMessage = false
			self:HandleChannelSyncMessage(arg1,arg2,addOnMessage,arg12)
		elseif event == "CVAR_UPDATE" and arg1 == "GUILDMEMBER_ALERT" then
			Guild2Guild_Vars.GuildMemberNotify = arg2
			self:Guild2Guild_PrintDEBUG(event,arg1,arg2, "OnEvent")
			self:CalculateRank()
		end

		if ( not (GGlocal.Leader == UnitName("player"))) then
			return    -- don't worry about these other messages if we aren't the leader
		end

		if (event == "CHAT_MSG_CHANNEL_JOIN" and
			strlower(arg9) == strlower(GGVars.Channel)) then
			local sendToChannel = true
			return self:SendLeaderMessage(sendToChannel)

		elseif (event == "CHAT_MSG_SYSTEM") then
			self:HandleChatMessageSystem(arg1,arg12)

		elseif (event == "CHAT_MSG_GUILD_ACHIEVEMENT" or (event == "CHAT_MSG_ACHIEVEMENT" and arg2 == UnitName("player"))) then
			self:HandleChatMessageAchievement(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12)

		elseif (event == "CHAT_MSG_GUILD" and GGVars.EchoGuild)
			or (event == "CHAT_MSG_OFFICER" and GGVars.EchoOfficer) then
			self:HandleOutgoingGuildMessage (event, arg1, arg2)

		elseif event == "CHAT_MSG_WHISPER" and string.sub(arg1,1,3) == "G2G" then
			self:HandleIncomingGuildMessage (arg1, arg2, arg12)
   		end
   	end,

----------------------------
-- HandlePlayerLeaving -
----------------------------

	HandlePlayerLeaving = function(self, arg2)
		local GGlocal = Guild2Guild.LocalVars
		self:Guild2Guild_PrintDEBUG(arg2,"left","HandlePlayerLeaving")

		if (GGlocal.Leader == arg2) then
			self:Guild2Guild_PrintDEBUG("leader left - calling election","HandlePlayerLeaving")
			return self:SendElectionMessage(true)
		end

		local guild = GGlocal.Relays[arg2]
		if (guild ~= nil) then
			self:Guild2Guild_PrintDEBUG(arg2,"relay left","HandlePlayerLeaving")
			GGlocal.Relays[arg2] = nil
			ChatThrottleLib:ClearPipe(ChatThrottleLib:PipeName("G2G", "WHISPER", arg2))
			if (not (GGlocal.Guilds[guild] == nil) and GGlocal.Guilds[guild][1] == arg2) then
				GGlocal.Guilds[guild]=nil
			end
		end
--		self:executeGUIs("sync", guild, arg2)
	end,

----------------------------
-- HandleGuildSyncMessage -
----------------------------

	HandleGuildSyncMessage = function(self,message,sender)
		local GGlocal = Guild2Guild.LocalVars

		self:Guild2Guild_PrintDEBUG(message, sender, "HandleGuildSyncMessage")

		local found,sVersion,version,sCmd,sMsg,sMsg2,rest
		found,_,sVersion,sCmd,sMsg,sMsg2,rest = string.find(message,"<G2G([^>]+)>(%w)(.-);(.-);(.*)")
		if (found ~= 1) then
			found,_,sVersion,sCmd,sMsg = string.find(message,"<G2G([^>]+)>(%w)(.*)")
			sMsg2 = ""
		end
		if (found ~= 1) then
			sVersion = "713"
			found,_,sCmd,sMsg = string.find(message,"(%w)(.*)")
			if found ~= 1 then
				self:DCF("Guild2Guild: Obsolete version detected, please ask "..sender.." to upgrade", 1)
				return
			end
		end
--		self:Guild2Guild_PrintDEBUG("parsed",found,sVersion,sCmd,sMsg,"HandleGuildSyncMessage")

		version = tonumber(sVersion)
		if (version > self.VerNum and not GGlocal.WarnedVersionNum) then
			self:DCF("A new version of Guild2Guild was detected, please upgrade",1)
			GGlocal.WarnedVersionNum = true;
		end

		GGlocal.versions[sender] = version

		if (GGlocal.OldestVersion > version) then
			GGlocal.OldestVersion = version
		end

		if  sCmd== "L" then
			GGlocal.ElectionCalled = false
			self:ReceiveLeaderMessage(sMsg, version, sender)

		elseif sCmd == "E" then
			value = tonumber(sMsg)

--			self:Guild2Guild_PrintDEBUG("Election, magic: "..value.."curmax"..GGlocal.CurrMax.."ver"..version.."curmaxver"..GGlocal.CurrMaxVersion,"HandleGuildSyncMessage")
			if (version > GGlocal.CurrMaxVersion or (value >= GGlocal.CurrMax and version == GGlocal.CurrMaxVersion)) then
				GGlocal.CurrMax = value
				GGlocal.Leader = sender
				GGlocal.CurrMaxVersion = version
			elseif GGlocal.Leader == UnitName("player") then
				self:Guild2Guild_PrintDEBUG("Calling election - defending current position")
				self:SendElectionMessage(false)
			end
		elseif (sCmd == "Q" and GGlocal.Leader == UnitName("player")) then
			local sendToChannel = false
			self:SendLeaderMessage(sendToChannel)

		elseif (sCmd == "X") then
			self:HandleGuildAuxMessage(rest)
		end
	end,

----------------------------
-- ReceiveLeaderMessage -
----------------------------
	ReceiveLeaderMessage = function(self, sMsg, version,sender)
		local GGlocal = Guild2Guild.LocalVars
		local relayIsAnOfficer = string.sub(sMsg,1,1) == "9"

		local leaderRank = tonumber(string.sub(sMsg, 1, 3))

		if (GGlocal.localRank >= leaderRank or version <= 741 or version > 746) and (version < self.VerNum) then
			self:Guild2Guild_PrintDEBUG("Calling election due to newer version")
			self:SendElectionMessage(false)
			return
		end

		if (self.VerNum == version and GGlocal.localRank > leaderRank) then
			self:Guild2Guild_PrintDEBUG("Calling election due to lower rank")
			self:SendElectionMessage(false)
			return
		end

		GGlocal.Leader = sender
		GGlocal.CurrMax= tonumber(sMsg)
		GGlocal.LastUpdate = time()
		GGlocal.CurrMaxVersion = 0
		GGlocal.awaitingQueryResponse = false
	end,

----------------------------
-- CalculateRank -
----------------------------
	CalculateRank = function(self)

		local GGlocal = Guild2Guild.LocalVars
		local GGVars = Guild2Guild_Vars

		local officerBonus = 200

		if (GGVars.Passive or GGVars.Silent) then
			officerBonus = 100
		elseif (GGlocal.PlayerIsOfficer) then
			officerBonus = 900
		end

		local numIgnores = 0;
		for player, value in pairs(GGlocal.ignores) do
			if (GGlocal.channelRoster[player] or GGlocal.guildRoster[player]) then
				numIgnores = numIgnores + 1
			end
		end

		if numIgnores > 9 then
			numIgnores = 9
		end

		local ignoreCount = (9 - numIgnores) * 10

		local guildRelay = 0
		if (GGVars.GuildMemberNotify ~= nil and GGVars.GuildMemberNotify ~= "0") then
			guildRelay = 2
		end

		GGlocal.localRank = officerBonus + ignoreCount + guildRelay

		self:Guild2Guild_PrintDEBUG("CalculateRank", GGlocal.localRank)
	end,

----------------------------
-- HandleChannelSyncMessage -
----------------------------

	HandleChannelSyncMessage = function(self,message,sender,addOnMessage,guid)
		local GGlocal = Guild2Guild.LocalVars

		self:Guild2Guild_PrintDEBUG("relay heartbeat:"..message.."->"..sender,addOnMessage,"HandleChannelSyncMessage")

		local found,sVersion,version,guild,officer,sCmd
		found,_,sVersion,guild,officer,sCmd = string.find(message,"<G2G([^>]+)>(.*);(%w)(%w)")
		if (found ~= 1) then
			sCmd = "L"
			found,_,sVersion,guild,officer = string.find(message,"<G2G([^>]+)>(.*);(%w)")
		end
		if (found ~= 1) then return end

		version = tonumber(sVersion)
		if (version > self.VerNum and not GGlocal.WarnedVersionNum) then
			self:DCF("A new version of Guild2Guild was detected, please upgrade",1)
			GGlocal.WarnedVersionNum = true;
		end

		if (sCmd == "L" or sCmd == "I") then
			self:UpdateRelayInfo(guild,sender,version,officer, sCmd=="I",addOnMessage,guid)

		elseif (sCmd == "Q" and GGlocal.Leader == UnitName("player")) then
			self:SendCrossGuildSyncMessage("L", "PLAYER", sender)

		elseif (sCmd == "R") then
			self:HandleRejection(guild,sender)
		end
	end,

----------------------------
-- UpdateRelayInfo -
----------------------------
	UpdateRelayInfo = function(self,guild,sender,version,officer, reintialize, addOnMessage, guid)
		self:Guild2Guild_PrintDEBUG(guild, sender, version, officer, addOnMessage,"UpdateRelayInfo")
		local GGlocal = Guild2Guild.LocalVars
		local GGVars = Guild2Guild_Vars

		if (addOnMessage) then
			GGlocal.VerifiedGuilds[guild] = true
		end

		if (GGlocal.VerifiedGuilds[guild] == nil) then
			-- in order to avoid drunk guild names, ask for the addon message directly
			if (GGlocal.Leader == UnitName("player") and version >= 731) then
				self:SendCrossGuildSyncMessage("Q", "PLAYER", sender)
				GGlocal.VerifiedGuilds[guild] = false
			end
		end

		if ((GGlocal.Leader == UnitName("player")) and not(GGlocal.VerifiedGuilds[guild])) then
			return
		end

		if (GGlocal.AlliedGuilds == nil or (GGlocal.AlliedGuilds[guild] ~= nil and GGlocal.AlliedGuilds[guild])) then
			if (GGVars.ShowNewRelayMessages and (GGlocal.Guilds[guild] ~= nil and GGlocal.Guilds[guild][1] ~= sender)) then
				self:DCF(guild.." just elected a new relay: ".. sender,1)
			end

			if ((GGlocal.Leader == UnitName("player") and (GetGuildInfo("player") ~= guild)) and
					(reinitialize or
					 GGlocal.Guilds[guild] == nil or
					 (GGlocal.Guilds[guild] ~= nil and GGlocal.Guilds[guild][1] ~= sender))) then
				if (version < 731) then
					self:SendCrossGuildSyncMessage("L", "CHANNEL", nil)
				else
-- ADD: VH
					-- If we haven't seen this guild before ...
					if (Guild2Guild.knownRosters[guild] == nil) then
						-- ... ask the relay to send its roster to our guild
						DEFAULT_CHAT_FRAME:AddMessage("Asking " .. sender .. " to send guild roster")
						ChatThrottleLib:SendAddonMessage("NORMAL", "G2GNR", "Y;;;", "WHISPER", sender)
					end
-- END: VH
					self:SendCrossGuildSyncMessage("L", "PLAYER", sender)
				end
			end

			GGlocal.Guilds[guild] = {sender,version,officer == "9",time(),GGlocal.VerifiedGuilds[guild]}
			GGlocal.Relays[sender] = guild;
			GGVars.CachedPlayerIDs[sender] = guid
		else
			if (GGlocal.AlliedGuilds[guild] == nil) then
				self:DCF("Refused incoming connection from:"..guild.." initiated by:".. sender,1)
				GGlocal.AlliedGuilds[guild] = false
				GGlocal.VerifiedGuilds[guild] = false
			end
		end
	end,

----------------------------
-- HandleRejection -
----------------------------
	HandleRejection = function(self,guild,sender)
		local GGlocal = Guild2Guild.LocalVars

		self:DCF("The connection to the guild:"..guild.." was refused by ".. sender,1)
		if (GGlocal.AlliedGuilds[guild] == nil or GGlocal.AlliedGuilds[guild] == false) then
			GGlocal.AlliedGuilds[guild] = false
			GGlocal.VerifiedGuilds[guild] = false
			GGlocal.Guilds[guild] = nil
		end
	end,

----------------------------
-- HandleOutgoingGuildMessage -
----------------------------

	HandleOutgoingGuildMessage = function(self, event,message, sender)
		local GGlocal = Guild2Guild.LocalVars

--		self:Guild2Guild_PrintDEBUG("outgoing message",sender, message, "HandleOutgoingGuildMessage")
		if (sender == UnitName("player")) and (string.find(message,"%[.*%]:%s") or string.find(message,"Guild2Guild:")) then return end
		local sMod = "G"
		if event == "CHAT_MSG_OFFICER" then
			sMod = "O"
		end
		local sMsg = {"G2G"..sMod.."["..sender.."]: "..message}

		local nMessages = 1
		local cut = 128;
		if (string.len(sMsg[1]) > 251) then
			nMessages = 2;
			local secondString = string.sub(sMsg[1],cut)
			local linkEnd = string.find(secondString,"|r")
			local linkStart = string.find(secondString,"|c")
			if (linkEnd ~= nil and linkEnd > 0 and (linkStart == nil or linkStart < 0 or linkStart > linkEnd)) then
				cut = string.find(sMsg[1],"|c[^%]]-%]|h|r",cut)

				if (cut < 0) then
					cut = 127
				end

				secondString = string.sub(sMsg[1],cut)
			end

			sMsg[2] = "G2G"..sMod.."["..sender.."]: "..secondString;
			sMsg[1] = string.sub(sMsg[1],1,cut-1)
		end
		for msg = 1, nMessages do
			for key, value in pairs(GGlocal.Guilds) do
				if (key ~= GetGuildInfo("player")) then
					if (value and value ~= nil and value[1] ~= nil and value[1] ~= UnitName("player") and value[5]) then
						if (value[2] < 729) then
							ChatThrottleLib:SendChatMessage("NORMAL", "G2G", sMsg[msg],"WHISPER",GetDefaultLanguage("player"),value[1])
						else
							ChatThrottleLib:SendAddonMessage("NORMAL", "G2G", sMsg[msg], "WHISPER",value[1])
						end
					end
				end
			end
		end
	end,

----------------------------
-- HandleChatMessageSystem -
----------------------------

	HandleChatMessageSystem = function(self, arg1, guid)
		local GGlocal = Guild2Guild.LocalVars

		local player;
		local event;

		_, _, player = string.find(arg1, G2G_ONLINE)
		if (player) then
--			self:Guild2Guild_PrintDEBUG(event,arg1,player, "online")
			if (GGlocal.guildRoster[player] == nil) then
				self:Guild2Guild_PrintDEBUG("skipping", event,arg1,player, "player not in guild")
				return
			end
			event = "N"
			self:SendOutgoingAuxMessage(player,event, "");
			return
		end

		_, _, player = string.find(arg1, G2G_OFFLINE)
		if (player) then
			if (GGlocal.guildRoster[player] == nil) then
				self:Guild2Guild_PrintDEBUG("skipping", event,arg1,player, "player not in guild")
				return
			end

--			self:Guild2Guild_PrintDEBUG(event,arg1,player, "offline")
			event = "F"
			self:SendOutgoingAuxMessage(player,event, "");
			return
		end

		_, _, player = string.find(arg1, G2G_JOINED)
		if (player) then
			GGlocal.guildRoster[player] = true
--			self:Guild2Guild_PrintDEBUG(event,arg1,player, "joined")
			event = "J"
			self:SendOutgoingAuxMessage(player,event, "");
			return
		end

		_, _, player = string.find(arg1, G2G_LEFT)
		if (player) then
			GGlocal.guildRoster[player] = nil
--			self:Guild2Guild_PrintDEBUG(event,arg1,player, "left")
			event = "L"
			self:SendOutgoingAuxMessage(player,event, "");
			return
		end

		_, _, promoter, player, rank = string.find(arg1, G2G_PROMO)
		if (player) then
--			self:Guild2Guild_PrintDEBUG(event,arg1,promoter, player, rank, "promo")
			event = "P"
			self:SendOutgoingAuxMessage(player,event,promoter..";"..rank);
			return

		end

		_, _, demoter, player, rank = string.find(arg1, G2G_DEMOTE)
		if (player) then
--			self:Guild2Guild_PrintDEBUG(event,arg1,demoter, player, rank, "demote")
			event = "D"
			self:SendOutgoingAuxMessage(player,event, demoter..";"..rank);
			return
		end

	end,

----------------------------
-- HandleChatMessageAchievement -
----------------------------
	HandleChatMessageAchievement = function(self, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12)
		self:Guild2Guild_PrintDEBUG("HandleChatMessageAchievement", arg1, arg2, arg12)

		_, _, _, achievement = string.find(arg1, G2G_ACHIEVEMENT)

                local extra = achievement..";"..arg12..";"
		local event;
		event = "C"
		self:SendOutgoingAuxMessage(arg2,event, extra);
	end,

----------------------------
-- SendOutgoingAuxMessage -
----------------------------

	SendOutgoingAuxMessage = function(self, player, event, extra)
		local GGlocal = Guild2Guild.LocalVars
		self:Guild2Guild_PrintDEBUG("outgoing message",player, event, extra, "SendOutgoingAuxMessage")

		local sMod = "X"
		local sMsg = sMod..";"..event..";"..player..";"..GetGuildInfo("player")..";"..extra

		for key, value in pairs(GGlocal.Guilds) do
			if (key ~= GetGuildInfo("player")) then
				if (value and value ~= nil and value[1] ~= nil and value[1] ~= UnitName("player") and value[5]) then
					if (value[2] > 741) then
						ChatThrottleLib:SendAddonMessage("BULK", "G2G",sMsg,"WHISPER",value[1])
					end
				end
			end
		end
	end,
----------------------------
-- SendTargetedAuxMessage -
----------------------------

	SendTargetedAuxMessage = function(self, target, player, event, extra)
		local GGlocal = Guild2Guild.LocalVars
		self:Guild2Guild_PrintDEBUG("outgoing message", player, event, extra, "SendTargetedAuxMessage")

		local sMod = "X"
		local sMsg = sMod..";"..event..";"..player..";"..GetGuildInfo("player")..";"..extra

		SendAddonMessage("G2G",sMsg,"WHISPER",target)
	end,

----------------------------
-- ForwardAddOnMessage -
----------------------------

	ForwardAddOnMessage = function (self, sAddon, message,sender)
		local GGlocal = Guild2Guild.LocalVars
		local GGVars = Guild2Guild_Vars


		if (sender == UnitName("player") and not (GGlocal.receivedAddonMessage == nil) and sAddon == GGlocal.receivedAddonMessage[1] and message == GGlocal.receivedAddonMessage[2]) then
			return
		end

		if ( time() > GGlocal.lastAddonMessageTime) then  -- rudimentary chat throttling
			GGlocal.lastAddonMessageTime = time()
		else
			return
		end

		if (GGVars.addons == nil) then
			GGVars.addons = DefaultGuild2Guild_Vars.addons;
		end

		if (GGVars.RelayAddonMessages == nil) then
			GGVars.RelayAddonMessages = DefaultGuild2Guild_Vars.RelayAddonMessages;
		end

		if (not (GGVars.RelayAddonMessages)) then
			return
		end

		if (GGVars.NewAddonDefault == nil) then
			GGVars.NewAddonDefault = DefaultGuild2Guild_Vars.NewAddonDefault;
		end

		if (GGVars.addons[sAddon] == nil) then
			GGVars.addons[sAddon] = GGVars.NewAddonDefault;
		elseif not (GGVars.addons[sAddon]) then
--			self:Guild2Guild_PrintDEBUG("rejecting message",sAddon, message, sender, "ForwardAddOnMessage")
			return
		end

--		self:Guild2Guild_PrintDEBUG("outgoing message",sAddon, message, sender, "ForwardAddOnMessage")
		local sMsg = "A"..sAddon..";"..message

		if (string.len(sMsg) > 251) then
			self:Guild2Guild_PrintDEBUG("message too long",sAddon, message, sender, "ForwardAddOnMessage")
			GGVars.addons[sAddon] = false;
			return
		end

		for key, value in pairs(GGlocal.Guilds) do
			if (key ~= GetGuildInfo("player")) then
				if (value and value ~= nil and value[1] ~= nil and value[1] ~= UnitName("player") and value[5]) then
					if (value[2] > 734) then
						ChatThrottleLib:SendAddonMessage("BULK", "G2G",sMsg,"WHISPER",value[1])
					end
				end
			end
		end
	end,

----------------------------
-- HandleForwardedAddonMessage -
----------------------------
	HandleForwardedAddonMessage = function (self, message)
		local found, addon, sMsg
		local GGlocal = Guild2Guild.LocalVars
		local GGVars = Guild2Guild_Vars

		found,_, addon, sMsg = string.find(message,"A([^;]-);(.*)")

		if (GGVars.addons == nil) then
			GGVars.addons = DefaultGuild2Guild_Vars.addons;
		end

		if (GGVars.addons[addon] == nil) then
			GGVars.addons[addon] = true;
		elseif not (GGVars.addons[addon]) then
--			self:Guild2Guild_PrintDEBUG("rejecting message",sAddon, sMsg, "HandleForwardedAddonMessage")
			return
		end

		self:Guild2Guild_PrintDEBUG("received",addon,sMsg, "HandleForwardedAddonMessage")

		GGlocal.receivedAddonMessage = {addon,sMsg}

		if (found) then
			ChatThrottleLib:SendAddonMessage("BULK",addon,sMsg,"GUILD")
		end
	end,

----------------------------
-- HandleForwardedAuxMessage -
----------------------------
	HandleForwardedAuxMessage = function (self, message)
		self:Guild2Guild_PrintDEBUG("received",message, "HandleForwardedAuxMessage")
		self:SendG2GSyncMessage("X",message)
	end,

----------------------------
-- HandleGuildAuxMessage -
----------------------------
	HandleGuildAuxMessage = function (self, message)
		local found, guild, rest
		local GGlocal = Guild2Guild.LocalVars
		local GGVars = Guild2Guild_Vars

		if (GGVars.Silent) then
			return
		end

		found,_, event, player, guild, rest = string.find(message,"(.);([^;]-);([^;]-);(.*)")

		self:Guild2Guild_PrintDEBUG("received",event,player, guild, rest, "HandleGuildAuxMessage")

		local sMsg = nil;
-- VH: TODO: Make sure it works even when GGVars.GuildMemberNotify is 0
		if (event == "N" and not(GGVars.GuildMemberNotify == "0" or GGlocal.friends[player])) then
			sMsg = string.format(ERR_FRIEND_ONLINE_SS, player, player).." ("..guild..")"
-- ADD: VH
		-- If I am the relay ...
		if (GGlocal.Leader == UnitName("player")) then
			-- ... for each of my guild members ...
			for name, note in pairs(self.playerNotes) do
				-- ... tell the logged in player to record the player info
				ChatThrottleLib:SendAddonMessage("NORMAL", "G2GNR", "Z;" .. name .. ";" .. GetGuildInfo("player") .. ";" .. note, "WHISPER", player)
			end
		end
		-- if player is not in my guild ...
		if not GGlocal.guildRoster[player] then
			if self.otherPlayerNotes[player] then
				-- ... mark as online and ...
				self.otherPlayerNotes[player].online = "1"
				-- ... add to other guild's roster display table
				cbh:Fire("PLAYERONLINE", player, self.otherPlayerNotes[player].guild, self.otherPlayerNotes[player].note)
			else
				cbh:Fire("PLAYERONLINE", player, "", "")
			end
		end
-- TODO:
-- END: VH
			PlaySound("FriendJoinGame")
		elseif (event == "F" and not(Guild2Guild_Vars.GuildMemberNotify == "0" or GGlocal.friends[player])) then
-- ADD: VH
		-- if player is not in my guild ...
		if (not GGlocal.guildRoster[player]) then
			-- ... mark player as offline ...
			if self.otherPlayerNotes[player] then
				self.otherPlayerNotes[player].online = "0"
			end
			-- ... and remove from other guild's roster display table
			cbh:Fire("PLAYEROFFLINE", player)
		end
-- END: VH
			sMsg = string.format(ERR_FRIEND_OFFLINE_S, player).." ("..guild..")"
		elseif (event == "J") then
			sMsg = string.format(ERR_GUILD_JOIN_S, player).." ("..guild..")"
		elseif (event == "L") then
			sMsg = string.format(ERR_GUILD_LEAVE_S, player).." ("..guild..")"
		elseif (event == "P") then
			local promoter, rank;
			_, _, promoter, rank = string.find (rest, "([^;]-);(.*)")
			sMsg = string.format(ERR_GUILD_PROMOTE_SSS, promoter, player, rank).." ("..guild..")"
		elseif (event == "D") then
			local promoter, rank;
			_, _, promoter, rank = string.find (rest, "([^;]-);(.*)")
			sMsg = string.format(ERR_GUILD_DEMOTE_SSS, promoter, player, rank).." ("..guild..")"
		elseif (event == "A") then
			self:Guild2Guild_PrintDEBUG("displaying ",event,player, guild, rest, "HandleGuildAuxMessage")
			for i=1, NUM_CHAT_WINDOWS do
				chatFrame = getglobal("ChatFrame"..i);
				if (Guild2Guild.IsChatTypeVisible("GUILD_ACHIEVEMENT", chatFrame)) then
					ChatFrame_OnEvent(chatFrame, "CHAT_MSG_GUILD_ACHIEVEMENT",  rest .." ("..guild..")", player, "", "", player, "", 0, 0, "", 0, 172);
				end
			end
		elseif (event == "B") then
			self:Guild2Guild_PrintDEBUG("displaying ",event,player, guild, rest, "HandleGuildAuxMessage")
			achievement = rest;
			sMsg = string.format(G2G_F_ACHIEVEMENT, player, player, achievement).." ("..guild..")"
			for i=1, NUM_CHAT_WINDOWS do
				chatFrame = getglobal("ChatFrame"..i);
				if (Guild2Guild.IsChatTypeVisible("GUILD_ACHIEVEMENT", chatFrame)) then
					ChatFrame_OnEvent(chatFrame, "CHAT_MSG_GUILD_ACHIEVEMENT",  sMsg, player, "", "", player, "", 0, 0, "", 0, 172, "");
				end
			end
			sMsg = nil
		elseif (event == "C") then
			found,_, achievement, guid = string.find(rest,"([^;]-);([^;]-);")
			self:Guild2Guild_PrintDEBUG("displaying ",event,player, guild, achievement, guid, "HandleGuildAuxMessage")
			GGVars.CachedPlayerIDs[player] = guid

			local coloredName = GetColoredName("CHAT_MSG_GUILD_ACHIEVEMENT", sMsg, player, "", "", player, "", 0, 0, "", 0, 172, guid);

			sMsg = string.format(G2G_F_ACHIEVEMENT, player, coloredName, achievement).." ("..guild..")"
			for i=1, NUM_CHAT_WINDOWS do
				chatFrame = getglobal("ChatFrame"..i);
				if (Guild2Guild.IsChatTypeVisible("GUILD_ACHIEVEMENT", chatFrame)) then
					ChatFrame_OnEvent(chatFrame, "CHAT_MSG_GUILD_ACHIEVEMENT",  sMsg, player, "", "", player, "", 0, 0, "", 0, 172, guid);
				end
			end
			sMsg = nil
-- ADD: VH
		elseif (event == "Z") then
			found, _, note, online = string.find(rest, "([^;]-);(.*)")
			self.knownRosters[guild] = true
			self.otherPlayerNotes[player] = Guild2Guild.otherPlayerNotes[player] or {}
			self.otherPlayerNotes[player].guild = guild
			self.otherPlayerNotes[player].note = note
			self.otherPlayerNotes[player].online = online
			if (online == "1") then
				cbh:Fire("PLAYERONLINE", player, guild, note)
			end
-- END: VH
		end

		if (sMsg == nil) then
			return
		end

		self:AddSystemMessage(sMsg)

	end,

----------------------------
-- AddSystemMessage -
----------------------------

	AddSystemMessage = function (self, message)
		local info = ChatTypeInfo["SYSTEM"];

		DEFAULT_CHAT_FRAME:AddMessage(message, info.r, info.g, info.b, info.id);
	end,

----------------------------
-- HandleIncomingGuildMessage -
----------------------------

	HandleIncomingGuildMessage = function(self, message, sender, guid)
		local GGlocal = Guild2Guild.LocalVars
		local GGVars = Guild2Guild_Vars

--		self:Guild2Guild_PrintDEBUG("inc:",message, sender, "HandleIncomingGuildMessage")

		if (string.find(message,"G2GOFF:12345")==1) then
			self:DCF("Guild2Guild shutting down! Requested by "..sender,1)
			self:Slash_Command("off")
			return
		end
		if (string.find(message,"G2GREPORT")==1) then
			self:ReportStatus(sender)
			return
		end
		if (string.sub(message,1,1)=="<") then
			local addOnMessage = true
			self:HandleChannelSyncMessage(message, sender, addOnMessage, guid)
			return
		end
		if (GGlocal.Relays[sender] ~= nil) then
			-- send the message out to the guild
			if (string.sub(message,1,1)=="A") then
				self:HandleForwardedAddonMessage(message)
				return
			elseif (string.sub(message,1,1)=="X") then
				self:HandleForwardedAuxMessage(message)
				return
			end

			-- debug
--			self:Guild2Guild_PrintDEBUG("incoming message",message,"HandleIncomingGuildMessage")
			if (sender == GGlocal.PreviousSender and message == GGlocal.PreviousMessage) then  -- prevent duplicate messages from coming accidentally
				return
			end
			GGlocal.PreviousMessage = message
			GGlocal.PreviousSender = sender
			local sChan = "OFFICER"
			if string.sub(message,4,4) == "G" then
				if not (GGVars.EchoGuild) then
					return      -- don't send messages if echoing is off
				end
				sChan = "GUILD"
			else
				if not (GGVars.EchoOfficer) then
					return      -- don't send messages if echoing is off
				end
			end
			if (sChan == "OFFICER" and GGlocal.OfficerRank ~= nil and not GGlocal.PlayerIsOfficer) then
				if (not GGlocal.OfficersWarned) then
					ChatThrottleLib:SendChatMessage("NORMAL", "G2G", "G2GO["..sender.."]: Guild2Guild: Warning officer chat is not connected to "..GetGuildInfo("player"),"WHISPER",GetDefaultLanguage("player"),sender)
					GGlocal.OfficersWarned = true
				end
				return
			end

			local sMsg = string.sub(message,5)
			return ChatThrottleLib:SendChatMessage("NORMAL", "G2G", sMsg,sChan,GetDefaultLanguage("player"),sID)
		else
			if (GGlocal.RejectedRelays[sender] == nil) then
				self:SendCrossGuildSyncMessage("Q", "PLAYER", sender)
				GGlocal.RejectedRelays[sender] = {false,time()}
			elseif (not GGlocal.RejectedRelays[sender][1] and time() - GGlocal.RejectedRelays[sender][2] > 10) then
				GGlocal.RejectedRelays[sender][1] = true
				self:SendRejectionLetter(sender)
				self:DCF("Refused incoming message from: ".. sender,1)
			end
		end

	end,

----------------------------
-- ReportStatus -
----------------------------

	ReportStatus = function(self, sender)
		local sON, sOFF, sNOTSET = "ON", "OFF", "NOT SET"

		local GGVars = Guild2Guild_Vars
		local GGlocal = Guild2Guild.LocalVars

		ChatThrottleLib:SendChatMessage("BULK", "G2G", "Version Number: "..self.Version,"WHISPER",GetDefaultLanguage("player"),sender)
		for guild, relay in pairs(GGlocal.Guilds) do
			if relay[3] then sTemp = "true" else sTemp = "false" end
			ChatThrottleLib:SendChatMessage("BULK", "G2G", "Connected to: "..guild.." using "..relay[1]..": Ver"..relay[2]..", Officer: "..sTemp,"WHISPER",GetDefaultLanguage("player"),sender)
		end

		local sTemp = ""
		sRejectedConnections = ""
		local count = 0
		local rejectCount = 0
		if (GGlocal.AlliedGuilds ~= nil) then
			for guild, value in pairs(GGlocal.AlliedGuilds) do
				if (value) then
					if count > 0 then sTemp = sTemp.."," end
					sTemp = sTemp..guild
					count = count+1
				else
					if rejectCount > 0 then sRejectedConnections = sRejectedConnections.."," end
					sRejectedConnections = sRejectedConnections..guild
					rejectCount = rejectCount +1
				end
			end
		else
			sTemp = sNOTSET
		end
		ChatThrottleLib:SendChatMessage("BULK", "G2G", "Allied Guilds:"..sTemp,"WHISPER",GetDefaultLanguage("player"),sender)
		count = 0
		sTemp = ""
		if rejectCount > 0 then ChatThrottleLib:SendChatMessage("BULK", "G2G", "Rejected Connections:"..sRejectedConnections,"WHISPER",GetDefaultLanguage("player"),sender) end
		rejectCount = 0
		sRejectedConnections = ""

		if (GGlocal.VerifiedGuilds ~= nil) then
			for guild, value in pairs(GGlocal.VerifiedGuilds) do
				if (value) then
					if count > 0 then sTemp = sTemp.."," end
					sTemp = sTemp..guild
					count = count+1
				else
					if rejectCount > 0 then sRejectedConnections = sRejectedConnections.."," end
					sRejectedConnections = sRejectedConnections..guild
					rejectCount = rejectCount +1
				end
			end
		else
			sTemp = sNOTSET
		end
		ChatThrottleLib:SendChatMessage("BULK", "G2G", "Verified Guilds:"..sTemp,"WHISPER",GetDefaultLanguage("player"),sender)
		if rejectCount > 0 then ChatThrottleLib:SendChatMessage("BULK", "G2G", "Unverified Guilds:"..sRejectedConnections,"WHISPER",GetDefaultLanguage("player"),sender) end
		if (GGlocal.OfficerRank ~= nil) then sTemp = GGlocal.OfficerRank else sTemp = sNOTSET end
		ChatThrottleLib:SendChatMessage("BULK", "G2G", "Officer Rank:"..sTemp,"WHISPER",GetDefaultLanguage("player"),sender)
		if GGVars.EchoGuild then sTemp = sON else sTemp = sOFF end
		ChatThrottleLib:SendChatMessage("BULK", "G2G", "Guild chat relay is: "..sTemp,"WHISPER",GetDefaultLanguage("player"),sender)
		if GGVars.EchoOfficer then sTemp = sON else sTemp = sOFF end
		ChatThrottleLib:SendChatMessage("BULK", "G2G", "Officer chat relay is: "..sTemp,"WHISPER",GetDefaultLanguage("player"),sender)
		if GGVars.ShowNewRelayMessages then sTemp = sON else sTemp = sOFF end
		ChatThrottleLib:SendChatMessage("BULK", "G2G", "Relay Change Notification is: "..sTemp,"WHISPER",GetDefaultLanguage("player"),sender)
		if GGVars.Startdelay then sTemp = GGVars.Startdelay else sTemp = sNOTSET end
		ChatThrottleLib:SendChatMessage("BULK", "G2G", "The Startdelay is: "..sTemp,"WHISPER",GetDefaultLanguage("player"),sender)
		ChatThrottleLib:SendChatMessage("BULK", "G2G", "Oldest Version Seen: "..GGlocal.OldestVersion,"WHISPER",GetDefaultLanguage("player"),sender)
		for player, version in pairs(GGlocal.versions) do
			ChatThrottleLib:SendChatMessage("BULK", "G2G", "  "..player..": "..version,"WHISPER",GetDefaultLanguage("player"),sender)
		end

	end,

----------------------------
-- SetActive -
----------------------------
	SetActive = function(self,active)
		local GGVars = Guild2Guild_Vars
		GGVars.Active = active;
		self:Event_Manager()
		self:Init_Channel()
	end,

--[[
		¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
		¤¤¤ Slash Command Goodness ¤¤¤
		¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
]]--

	Slash_Command = function(self,sCmdIn)
		local GGVars = Guild2Guild_Vars
		local cColors = Guild2Guild.tColors
		local GGlocal = Guild2Guild.LocalVars
		local sON, sOFF, sNOTSET = cColors.cGreen.."ON", cColors.cRed.."OFF", cColors.cRed.."NOT SET"
		local tCmds, sCmd = {}
--		self:Guild2Guild_PrintDEBUG(sCmdIn,Slash_Command)

		for sCmd in string.gmatch(sCmdIn,"%w+") do
--			self:Guild2Guild_PrintDEBUG(sCmd,Slash_Command)
			table.insert(tCmds,string.lower(sCmd))
		end
		-- G2G ON
		if tCmds[1] == "on" then
			if not GGVars.Active then
				self:DCF("is now "..sON,1)
				self:ResetLocalVariables()
				self:SetActive(true)
			else
				self:DCF("Guild2Guild:ON",-1)
			end
		-- G2G OFF
		elseif tCmds[1] == "off" then
			if GGVars.Active then
				self:SetActive(false)
				GGlocal.CurrMax = 0
				GGlocal.CurrMax = 0
				GGlocal.CurrMaxVersion = 0
				GGlocal.LastUpdate = time()
				GGlocal.Leader = nil
				self:DCF("is now "..sOFF,1)
			else
				self:DCF("Guild2Guild:OFF",-1)
			end
		-- PASSIVE
		elseif tCmds[1] == "passive" then
			if tCmds[2] then
				if tCmds[2] == "on" then
					GGVars.Passive = true
				elseif tCmds[2] == "off" then
					GGVars.Passive = false
				else
					self:DCF(false,0)
					return
				end
			else
				GGVars.Passive = not(GGVars.Passive)
			end
			local sTemp = sOFF
			if GGVars.Passive then
				sTemp = sON
			end
			self:DCF("Passive mode is now "..sTemp,1)
			self:CalculateRank()
		-- SILENT
		elseif tCmds[1] == "silent" then
			if tCmds[2] then
				if tCmds[2] == "on" then
					GGVars.Silent = true
				elseif tCmds[2] == "off" then
					GGVars.Silent = false
				else
					self:DCF(false,0)
					return
				end
			else
				GGVars.Silent = not(GGVars.Silent)
			end
			local sTemp = sOFF
			if GGVars.Silent then
				sTemp = sON
			end
			self:DCF("Silent mode is now "..sTemp,1)
			self:CalculateRank()

		-- CHANNEL
		elseif tCmds[1] == "channel" then
			if tCmds[2] then
				if GGVars.Channel then
					LeaveChannelByName(GGVars.Channel)
				end
				GGVars.Channel = tCmds[2]
				self:Init_Channel()
				self:DCF("Channel is now set to: "..cColors.cWhite..tCmds[2],1)
			else
				self:DCF(false,0)
			end
		-- GCHAT
		elseif tCmds[1] == "gchat" then
			if tCmds[2] == "on" and not GGVars.EchoGuild then
				GGVars.EchoGuild = true
				self:DCF("Guild chat linking is now "..sON,1)
			elseif tCmds[2] == "off" and GGVars.EchoGuild then
				GGVars.EchoGuild = false
				self:DCF("Guild chat linking is now "..sOFF,1)
			elseif tCmds[2] == "off" and not GGVars.EchoGuild
			  or tCmds[2] == "on" and GGVars.EchoGuild
			  then
				self:DCF("Guild Chat",-1)
			else
				self:DCF(false,0)
			end
		-- OCHAT
		elseif tCmds[1] == "ochat" then
			if tCmds[2] == "on" and not GGVars.EchoOfficer then
				GGVars.EchoOfficer = true
				self:DCF("Officer chat linking is now "..sON,1)
			elseif tCmds[2] == "off" and GGVars.EchoOfficer then
				GGVars.EchoOfficer = false
				self:DCF("Officer chat linking is now "..sOFF,1)
			elseif tCmds[2] == "off" and not GGVars.EchoOfficer
			  or tCmds[2] == "on" and GGVars.EchoOfficer
			  then
				self:DCF("Officer Chat",-1)
			else
				self:DCF(false,0)
			end
		-- RELAYNOTIFY
		elseif tCmds[1] == "relaynotify" then
			if tCmds[2] == "on" and not GGVars.ShowNewRelayMessages then
				GGVars.ShowNewRelayMessages = true
				self:DCF("Relay Change Notification is now "..sON,1)
			elseif tCmds[2] == "off" and GGVars.ShowNewRelayMessages then
				GGVars.ShowNewRelayMessages = false
				self:DCF("Relay Change Notification is now "..sOFF,1)
			elseif tCmds[2] == "off" and not GGVars.ShowNewRelayMessages
			  or tCmds[2] == "on" and GGVars.ShowNewRelayMessages
			  then
				self:DCF("Relay Change Notification",-1)
			else
				self:DCF(false,0)
			end
		-- FORCE
		elseif tCmds[1] == "force" then
			local sendToChannel = true
			self:SendLeaderMessage(sendToChannel)
		-- DEBUG
		elseif tCmds[1] == "debug" then
			if tCmds[2] == "on" and not GGVars.Debug then
				GGVars.Debug = true
				self:DCF("Debugging is now "..sON,1)
			elseif tCmds[2] == "off" and GGVars.Debug then
				GGVars.Debug = false
				self:DCF("Debugging is now "..sOFF,1)
			elseif tCmds[2] == "off" and not GGVars.Debug
			  or tCmds[2] == "on" and GGVars.Debug
			  then
				self:DCF("Debug",-1)
			else
				self:DCF(false,0)
			end
      	-- StartDelay
		elseif tCmds[1] == "startdelay" then
			if tCmds[2] then
				GGVars.Startdelay = tonumber(tCmds[2])
				self:DCF("Startdelay is now set to: "..cColors.cWhite..tCmds[2],1)
			else
				self:DCF(false,0)
			end
      	-- Password
		elseif tCmds[1] == "password" then
			GGVars.Password = tCmds[2]
			self:Init_Channel()
			local sTemp
			if GGVars.Password then sTemp = cColors.cWhite..GGVars.Password else sTemp = sNOTSET end
			self:DCF("Password is now set to: "..cColors.cWhite..sTemp,1)
		-- REPORT
		elseif tCmds[1] == "report" then
			local sTemp
			self:DCF(cColors.cGreen.."settings:",1)
			if GGVars.Active then sTemp = sON else sTemp = sOFF end
			self:DCF("Guild2Guild is: "..sTemp,1)
			self:DCF("Version Number: "..self.Version,1)
			if GGVars.Passive then sTemp = sON else sTemp = sOFF end
			self:DCF("Passive mode is: "..sTemp,1)
			if GGVars.Silent then sTemp = sON else sTemp = sOFF end
			self:DCF("Silent mode is: "..sTemp,1)
			for guild, relay in pairs(GGlocal.Guilds) do
				if relay[3] then sTemp = "true" else sTemp = "false" end
--				self:Guild2Guild_PrintDEBUG(guild,relay[1],relay[2],relay[3],sTemp,"report")
				self:DCF("Connected to: "..guild.." using "..relay[1]..": Ver"..relay[2]..", Officer: "..sTemp,1)
			end
			sTemp = ""
			sRejectedConnections = ""
			local count = 0
			local rejectCount = 0
			if (GGlocal.AlliedGuilds ~= nil) then
				for guild, value in pairs(GGlocal.AlliedGuilds) do
					if (value) then
						if count > 0 then sTemp = sTemp.."," end
						sTemp = sTemp..guild
						count = count+1
					else
						if rejectCount > 0 then sRejectedConnections = sRejectedConnections.."," end
						sRejectedConnections = sRejectedConnections..guild
						rejectCount = rejectCount +1
					end
				end
			else
				sTemp = sNOTSET
			end
			self:DCF("Allied Guilds:"..sTemp,1)
			count = 0
			sTemp = ""
			if rejectCount > 0 then self:DCF("Rejected Connections:"..sRejectedConnections) end
			rejectCount = 0
			sRejectedConnections = ""

			if (GGlocal.VerifiedGuilds ~= nil) then
				for guild, value in pairs(GGlocal.VerifiedGuilds) do
					if (value) then
						if count > 0 then sTemp = sTemp.."," end
						sTemp = sTemp..guild
						count = count+1
					else
						if rejectCount > 0 then sRejectedConnections = sRejectedConnections.."," end
						sRejectedConnections = sRejectedConnections..guild
						rejectCount = rejectCount +1
					end
				end
			else
				sTemp = sNOTSET
			end
			self:DCF("Verified Guilds:"..sTemp,1)
			if rejectCount > 0 then self:DCF("Unverified Guilds:"..sRejectedConnections,1) end
			if (GGlocal.OfficerRank ~= nil) then sTemp = GGlocal.OfficerRank else sTemp = sNOTSET end
			self:DCF("Officer Rank:"..sTemp,1)
			if GGVars.EchoGuild then sTemp = sON else sTemp = sOFF end
			self:DCF("Guild chat relay is: "..sTemp,1)
			if GGVars.EchoOfficer then sTemp = sON else sTemp = sOFF end
			self:DCF("Officer chat relay is: "..sTemp,1)
			if GGVars.ShowNewRelayMessages then sTemp = sON else sTemp = sOFF end
			self:DCF("Relay Change Notification is: "..sTemp,1)
			if GGVars.Channel then sTemp = cColors.cWhite..GGVars.Channel else sTemp = sNOTSET end
			self:DCF("The channel is: "..sTemp,1)
			if GGVars.Startdelay then sTemp = cColors.cWhite..GGVars.Startdelay else sTemp = sNOTSET end
			self:DCF("The Startdelay is: "..sTemp,1)
			if GGVars.Password then sTemp = cColors.cWhite..GGVars.Password else sTemp = sNOTSET end
			self:DCF("The Password is: "..sTemp,1)
			self:DCF("Oldest Version Seen: "..GGlocal.OldestVersion,1)
			for sender, version in pairs(GGlocal.versions) do
				self:DCF("  "..sender..": "..version)
			end
--[[
			count = 0
			sTemp = ""
			if (GGlocal.friends ~= nil) then
				for friend, value in pairs(GGlocal.friends) do
					if count > 0 then sTemp = sTemp.."," end
					sTemp = sTemp..friend
					count = count+1
				end
			else
				sTemp = sNOTSET
			end
			self:DCF("Friends:"..sTemp,1)

			count = 0
			sTemp = ""
			if (GGlocal.ignores ~= nil) then
				for friend, value in pairs(GGlocal.ignores) do
					if count > 0 then sTemp = sTemp.."," end
					sTemp = sTemp..friend
					count = count+1
				end
			else
				sTemp = sNOTSET
			end
			self:DCF("Ignores:"..sTemp,1)

			count = 0
			sTemp = ""
			if (GGlocal.channelRoster ~= nil) then
				for friend, value in pairs(GGlocal.channelRoster) do
					if count > 0 then sTemp = sTemp.."," end
					sTemp = sTemp..friend
					count = count+1
				end
			else
				sTemp = sNOTSET
			end
			self:DCF("Channel:"..sTemp,1)
]]--


			--if GGVars.Debug then sTemp = sON else sTemp = sOFF end
			--self:DCF("Debugging is: "..sTemp)
		-- HELP
		elseif tCmds[1] == "help" then
			local sPre = cColors.cWhite.."     /g2g "
			local sA = cColors.cSilver.."["..cColors.cGold
			local sZ = cColors.cSilver.."]"
			local sOnOff = "ON"..cColors.cSilver.."||"..cColors.cGold.."OFF"
			self:DCF(cColors.cGreen.."v"..Guild2Guild.Version..cColors.cSilver.." - "..cColors.cWhite.." by Elviso of Mug'Thol, Updated by Durthos of Proudmoore"..cColors.cSilver.." - "..cColors.cRed.."dbeleznay"..cColors.cWhite.."@"..cColors.cBlue.."shaw.ca",1)
			self:DCF("To turn this addon on or off:")
			self:DCF(sPre..sA..sOnOff..sZ)
			self:DCF("To turn passive mode on or off:")
			self:DCF(sPre.."passive "..sOnOff..sZ)
			self:DCF("To turn silent mode on or off:")
			self:DCF(sPre.."silent "..sOnOff..sZ)
			self:DCF("To turn guild chat on or off:")
			self:DCF(sPre.."gchat "..sA..sOnOff..sZ)
			self:DCF("To turn officer chat on or off:")
			self:DCF(sPre.."ochat "..sA..sOnOff..sZ)
			self:DCF("To turn relay change notification on or off:")
			self:DCF(sPre.."relaynotify "..sA..sOnOff..sZ)
			self:DCF("To set or change the hidden channel used by this addon:")
			self:DCF(sPre.."channel "..sA.."MY_CHANNEL"..sZ)
			self:DCF("To view your settings:")
			self:DCF(sPre.."report ")
			self:DCF("To create a stack for debugging purposes:")
			self:DCF(sPre.."stackdump ")
		-- STACKDUMP
		elseif tCmds[1] == "stackdump" then
			self:DCF("stackdump created. Please email your guild2guild saved variables file to dbeleznay@shaw.ca.",1)
			table.insert(GGVars.debugStack,self:Guild2Guild_Clone(GGlocal.debugStack))
			GGVars.debugAddOns = self:Guild2Guild_GetAddOns()
		-- DEFAULT
		elseif tCmds[1] == "test" then

		local event = "C";
		local player = "Durthos";
		local extra = "|cffffff00|Hachievement:768:030000000021A890:1:6:10:9:4294967295:4294967295:4294967295:4294967295|h[Explore Tirisfal Glades]|h|r;0x0300000003376CEE;";
		local sMsg = event..";"..player..";"..GetGuildInfo("player")..";"..extra

		self:HandleGuildAuxMessage(sMsg);
--[[
			ChatThrottleLib:SendAddonMessage("NORMAL", "G2G", "|cffffff00|Hachievement:768:030000000021A890:1:6:10:9:4294967295:4294967295:4294967295:4294967295|h[Explore Tirisfal Glades]|h|r;0x0300000003376CEE;", "WHISPER",tCmds[2])
			ChatThrottleLib:SendAddonMessage("NORMAL", "G2G", "|cffffff00|Hachievement:768:030000000021A890:1:6:10:9:4294967295:4294967295:4294967295:4294967295|h[Explore Tirisfal Glades]|h|r;0x0300000003376CEE;", "WHISPER",tCmds[2])

		ChatThrottleLib:ClearPipe(ChatThrottleLib:PipeName("G2G", "WHISPER", tCmds[2]))
--                self:HandlePlayerLeaving(tCmds[2]);
]]--
		else
			self:DCF("Type "..cColors.cWhite.."/g2g help"..cColors.cSilver.." for a list of commands.",1)
		end
	end,

--[[
		¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
		¤¤¤ Accessory Functions ¤¤¤
		¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
]]--

-------------------------------------------------------------------------------
-- Guild2Guild_GetAddOns - return a list of addons that are loaded
-------------------------------------------------------------------------------
	Guild2Guild_GetAddOns = function (self)
		local addlist = ""
		for i = 1, GetNumAddOns() do
			local name, title, notes, enabled, loadable, reason, security = GetAddOnInfo(i)

			local loaded = IsAddOnLoaded(i)
			if (loaded) then
				if not name then name = "Anonymous" end
				name = name:gsub("[^a-zA-Z0-9]+", "")
				local version = GetAddOnMetadata(i, "Version")
				local class = getglobal(name)
				if not class or type(class)~='table' then class = getglobal(name:lower()) end
				if not class or type(class)~='table' then class = getglobal(name:sub(1,1):upper()..name:sub(2):lower()) end
				if not class or type(class)~='table' then class = getglobal(name:upper()) end
				if class and type(class)=='table' then
					if (class.version) then
						version = class.version
					elseif (class.Version) then
						version = class.Version
					elseif (class.VERSION) then
						version = class.VERSION
					end
				end
				local const = getglobal(name:upper().."_VERSION")
				if (const) then version = const end

				if type(version)=='table' then
					version = table.concat(version,":")
				end

				if (version) then
					addlist = addlist.."  "..name..", v"..version.."\n"
				else
					addlist = addlist.."  "..name.."\n"
				end
			end
		end
		return addlist
	end,

-------------------------------------------------------------------------------
-- AddStackMessage - Adds a debug message to the stack
-------------------------------------------------------------------------------

	AddStackMessage = function(self,sMsg)
		if (not (self.Initialized)) then return end
		local GGlocal = Guild2Guild.LocalVars
		local GGVars = Guild2Guild_Vars

		GGVars.logging = GGVars.logging or false
		GGVars.log = GGVars.log or {}
		GGVars.logsize = GGVars.logsize or 0
		if (GGVars.logging) then
			table.insert(GGVars.log, sMsg)
			if (GGVars.logsize >= 10000) then
				table.remove(GGVars.log,1)
			else
				GGVars.logsize = GGVars.logsize + 1
			end
		end
		table.insert(GGlocal.debugStack, sMsg)
		if (GGlocal.stackCount >= 75) then
			table.remove(GGlocal.debugStack,1)
		else
			GGlocal.stackCount = GGlocal.stackCount + 1
		end
	end,

-------------------------------------------------------------------------------
-- DCF - outputs text to the user
-------------------------------------------------------------------------------

	-- lazy text output
	DCF = function(self,sMsg,iStyle,sExtra)
		local cColors = Guild2Guild.tColors
		local D_C_F = DEFAULT_CHAT_FRAME
		local sGG = cColors.cGreen.."[Guild2Guild] "
		if iStyle == 1 then
			self:AddStackMessage("DCF:"..sMsg)
			return D_C_F:AddMessage(sGG..cColors.cSilver..sMsg)
		elseif iStyle == 0 then
			return D_C_F:AddMessage(sGG..cColors.cRed.."ERROR: Option invalid or non-existant. No changes were made.")
		elseif iStyle == -1 then
			return D_C_F:AddMessage(sGG..cColors.cWhite..sMsg..": "..cColors.cSilver.."Option already set. No changes were made.")
		elseif iStyle == 5 then
			return D_C_F:AddMessage(cColors.cRed.."[G2G DEBUG:"..cColors.cGold..sExtra..cColors.cRed.."] "..cColors.cWhite..sMsg)
		else
			self:AddStackMessage("DCF:"..sMsg)
			return D_C_F:AddMessage(cColors.cSilver..sMsg)
		end
	end,

-------------------------------------------------------------------------------
-- Guild2Guild_PrintDEBUG - Print's a debug message to the debug window if it is visible
-------------------------------------------------------------------------------

	Guild2Guild_PrintDEBUG = function(self, ...)

		local debugWin;
		for i=1, NUM_CHAT_WINDOWS do
			if (GetChatWindowInfo(i):lower() == "g2gdebug") then
				debugWin = i;
				break;
			end
		end

		local out = time()..",";
		for i = 1, select("#", ...) do
			if (i > 1) then out = out .. ", "; end
			local currentArg = select(i, ...)
			local argType = type(currentArg);
			if (argType == "string") then
				out = out .. '"'..currentArg..'"';
			elseif (argType == "number") then
				out = out .. currentArg;
			else
				out = out .. dump(currentArg);
			end
		end
		self:AddStackMessage(out)
		if (not debugWin) then
			return
		end

		getglobal("ChatFrame"..debugWin):AddMessage(out, 1.0, 1.0, 0.3);
	end,

-------------------------------------------------------------------------------
-- Guild2Guild_Clone - return a copy of the table t
-------------------------------------------------------------------------------
	Guild2Guild_Clone = function (self,t)
		local new = {}             -- create a new table
		local i, v = next(t, nil)  -- i is an index of t, v = t[i]
		while i do
			if type(v)=="table" then v=self:Guild2Guild_Clone(v) end
			new[i] = v
			i, v = next(t, i)        -- get next index
		end
		return new
	end,


-------------------------------------------------------------------------------
-- JoinChannel - Joins a channel
-------------------------------------------------------------------------------

	JoinChannel = function(self,channel,password)
		if(GetChannelName(channel) == 0) then
			self:Guild2Guild_PrintDEBUG("JoinChannel : Joining channel "..channel.." with password ("..tostring(password)..")");
			local zoneChannel, channelName = JoinChannelByName(channel,password,DEFAULT_CHAT_FRAME:GetID());
		else
			self:Guild2Guild_PrintDEBUG("JoinChannel : Already in channel "..channel);
		end
	end,

-------------------------------------------------------------------------------
-- RegisterGUI - Registers a Gui
-------------------------------------------------------------------------------

	RegisterGUI = function ( self, params )
		local GGlocal = Guild2Guild.LocalVars

		table.insert(GGlocal.Guis, params );
	end,

-------------------------------------------------------------------------------
-- executeGUIs - updates all guis appropriately
-------------------------------------------------------------------------------
	executeGUIs = function( funcName, param1, param2, param3, param4 )
		local GGlocal = Guild2Guild.LocalVars
		local result = false
		for k,v in pairs(GGlocal.Guis) do
			if ( v ) then
				local func = getglobal(v[funcName]);
				if ( func ) then
					if ( func(param1, param2, param3, param4) ) then
						result = true
					end
				end
			end
		end
		return result
	end,

	getOnlineUsers = function(self, tbl)
		for player, info in pairs(self.otherPlayerNotes) do
			if info.online == "1" then
				table.insert(tbl, {
					player = player,
					guild = info.guild or "",
					note = info.note or ""
				})
			end
		end
		return tbl
	end,


	RequestPlayerInfos = function(self)
		local playerName = UnitName("player")
		for name, guild in pairs(self.LocalVars.Relays) do
			if name ~= playerName then
				ChatThrottleLib:SendAddonMessage("NORMAL", "G2GNR", "Y;;;", "WHISPER", name)
			end
		end
	end,

	--[[
	The callback object to register events to.
	The events that may get fired are:
	* PLAYERONLINE: playerOnline(event, playerName, playerGuild, playerInfo)
	* PLAYEROFFLINE: playerOffline(event, playerName)
]]--
	infocb = {},
};

cbh = LibStub:GetLibrary("CallbackHandler-1.0", 3):New(Guild2Guild.infocb)

if (_G.ChatThrottleLib) then
  local rehook = false
  if(_G.ChatThrottleLib.version ~= 20) then
    rehook = true
    Guild2Guild.Guild2Guild_PrintDEBUG(Guild2Guild,"Failed to find my version of ChatThrottleLib: new version found", _G.ChatThrottleLib.version)
  elseif (_G.ChatThrottleLib.ClearPipe == nil) then
    rehook = true
    Guild2Guild.Guild2Guild_PrintDEBUG(Guild2Guild,"Failed to find my version of ChatThrottleLib: Someone else loaded it first", _G.ChatThrottleLib.version)
  end

  if (rehook) then
    function _G.ChatThrottleLib:ClearPipe (pipename)
      Guild2Guild.Guild2Guild_PrintDEBUG(Guild2Guild, "Running Stub ClearPipe")
    end

    function _G.ChatThrottleLib:PipeName (prefix, chattype, destination)
      return (prefix..(chattype or "SAY")..(destination or ""))
    end
  end
end


--[[¤¤¤ EOF ¤¤¤]]--
