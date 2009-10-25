 --[[	   
	いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい
	Guild2Guild - updated by Durthos of Proudmoore
	Origionally by Elviso of Mug'Thol - elviso@kenman.net
  	いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

	DefaultConfiguration.lua - Use this file to set the default configuration
	for guild2guild for your guild members to use. I recommend modifying the
	channel and password in the file, and reposting the guild2guild package on
	your guild website so that everone that installs guild2guild can start out 
	preconfigured.
	いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい
]]--

DefaultGuild2Guild_Vars = {
	Debug = false,                -- default: false - enables some usefull debugging information
	Active = true,                -- default: true - enable or disable the add on by default
	EchoGuild = true,             -- default: true - enable or disable relaying of guild chat
	EchoOfficer = true,           -- default: true - enable or disable relaying of officer chat
	Startdelay = 15,              -- default: 15 - the amount of time after login we should wait before starting to relay
	Password = nil,               -- default: nil - the password to use for the synchronization channel
	Channel = "g2gdefault",           -- default: "g2gdefault" - the channel to use for cross guild syncronization
	RelayAddonMessages = true,    -- default: true - controls all addon sending behaviour
	NewAddonDefault = false,      -- default: false - enable forwarding addon messages from the guild channel - specifiies the default behaviour for new add-ons
	Passive = false,              -- default: false - enable to indicate that you should only be elected as relay as a last resort (for slow internet connections)
	["addons"] = {                -- overridden (addons which will either be forwarded or not directly)
		["GUILDMAP"] = false,
		["CGP"] = false,
		["CaN"] = true,
		["GathX"] = true,
		["Thr"] = true,
		["AucAdvAskPrice"] = false,
		["WIM"] = true,
	}
	}

