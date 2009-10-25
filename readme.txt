¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
Guild2Guild v7.5.9 - Updated by Durthos of Proudmoore - dbeleznay@shaw.ca
Modified by Tassleoff
Originally by Elviso of Mug'Thol - elviso@kenman.net
¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
Enables communication between 2 or more guilds via a separate (private) chat channel, 
which translates the messages between the 2 or more guild chats. Two users are required 
to have this addon for it to work (1 in each guild), however only 1 user per guild is 
required to have Guild2Guild for all members of both guilds to reap the benefits. For 
example, guild chat from guild A will appear in guild B's guild chat, and vice-versa.

== Features ==
¤ Works for officer chat as well. You can enable either guild chat, officer chat, or both.
¤ Allows item linking
¤ Completely secure since the transmission channel is via in game whispers. The public
channel that you set is used for cross guild synchronization only
* You can set the add-on to be even more secure by limiting the guilds that you will
accept relays from (in case someone with the addon has characters in multiple guilds)
* forwards messages that other addons send to the guild addon channel
* unlike previous versions, more than two people from either guild can have the add-on 
running at once (in fact its encouraged for stability)
* Everyone with the addon will see the guild chat as though it came directly from the
person that sent the message. Clicking on their name will have all the same functionality
as the regular WOW UI.


== USAGE ==
To use Guild2Guild, just download and install like any other addon, and have a friend (in a
different guild) do the same. Then, decide upon a synchronization channel, and set both of
your G2G's to the same channel, like so:

/g2g channel relaychannel

Once the channel is set, simply enable G2G as such:

/g2g on

You should now be ready for intra-guild communications!

== GUILDMASTERS ==

You can limit the guilds that you can connect to using a white list, and automatically set 
the channel and password by adding a string like: 

<G2G;C:channel;P:secret;A:Guild1,Guild2;>

to your guild information (through the guild options menu). 
Where channel is the name of the channel you want guild2guild to use to coordinate relays, 
password is the password for that channel, and Guild1 and Guild2 are the names of two or more
guilds that you would like to allow to connect to this one.

(Password is optional, you don't need to use it if you don't want to have a password.)

Alternately you can create a custom build of guild2guild for your guild to use by editing the file
DefaultConfiguration.lua to use a new channel, and channel password, and then reposting this
add on to your guild website. 

Guild to Guild will automatically promote people that are allowed to speak in the officer 
channel to relays. This is so that the officer chat can be relayed as well.

== KNOWN BUGS ==
none

== Summary of in-game help commands ==

To view the usage of Guild2Guild:

  /g2g help

To turn this addon on or off:

  /g2g [on|off]

To turn guild chat on or off:

  /g2g gchat [on|off]

To turn officer chat on or off:

  /g2g ochat [on|off]
  
To turn relay change notification on or off:

  /g2g relaynotify [on|off]

To turn on passive mode (for slow connections - be the last person to be elected relay)

  /g2g passive [on|off]

To turn on silent mode (block all incoming messages from the allied guilds)

  /g2g silent [on|off]

To set or change the hidden synchronization channel used by this addon:

  /g2g channel [MY_CHANNEL]

To view your settings:

  /g2g report

(ADVANCED: If something really strange happens you can type /g2g stackdump which will take a 
snapshot of the last few minutes of guild2guild activity. If you mail me your guild2guild saved 
variables file when you log out then I will be better able to debug what went wrong.)

== ADDON LICENSE ==

You are free to copy, distribute, display, and perform these addons and to make derivative addons under the following conditions: 
--Attribution. You must attribute all add ons in the manner specified by Durthos of Proudmoore. 
--Noncommercial. You may not use these add ons for commercial purposes. 
--Share Alike. If you alter, transform, or build upon these add ons, you may distribute the resulting add on only under a license identical to this one. 
--For any reuse or distribution, you must make clear to others the license terms of these add ons. Any of these conditions can be waived if you get permission from Durthos of Proudmoore. Your fair use and other rights are in no way affected by the above.

== COPYRIGHT ==

All World or Warcraft game related content and images are the property of Blizzard Entertainment, Inc. and protected by U.S. and international copyright laws. The Addon (code and supporting files) is property of Durthos of Proudmoore and protected by U.S. and international copyright laws. 

== Changelog ==
7.5.9
- fixed error caused when the person you are talking to disconnects, but you still have messages for them
- fixed error message when you turn on Blizzard Class Colouring in the chat frame
	
7.5.8
- shortened the inter-guild message when a player earns an achievement

7.5.7
- changed to use ChatThrottleLib by Mikk  - http://www.wowwiki.com/ChatThrottleLib which should prevent disconnects when a large raid gets an achievement
- allow the channel password to be set to NIL by typing /g2g password

7.5.6
fixed a few minor bugs related to achievements
- achievements are no longer broadcast unless they come from someone in your guild.
- achievement messages are now displayed in the correct window


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

7.5.2
- initialized chat color properly
	
7.5.1
- fixed a bug that was still causing duplicate names after relay changes
	
7.5.0
- Updated to current TOC
- fixed up after blizzard changed the chatframe api - disabled UI to change the chatframe
	
7.4.9
- Updated to current TOC
- added the ability to disable notification messages when the relay changes

7.4.8
- added the ability for a relay to step down if there are others available (passive mode)
- /report shows the complete list of potential relays, and their versions
- no longer allow allied guilds to be put on the rejected relay list
- added a way to change the chat color for incoming guild messages to the context menu for the chat frame (later broken by blizzerd)
- fixed a synchronization issue where an election would happen immediately after a player logged in if it took them a long time to load


7.4.7 - Jan 5, 2008
- fixed an error where an officer would always try to be the relay even if they didn't have the latest version.


7.4.6 - Jan 5, 2008
- fixed an error on login when the 'guildmembernotify' variable had not yet loaded, but I was trying to query it
- fixed a parse error when looking for player has left the guild messages


7.4.5 - Jan 2, 2008
- Selection of relays is now based on officer rank, ignore list, and whether the 'guild member alert' is set to on
- Play the friend online sound when a member of an allied guild comes online
- Text from players in the allied guild that you are ignoring is no longer displayed locally
- fixed a nil pointer when a message that is too long is sent with a hyperlink
- hide the g2g channel
- No longer working around the guild member alert not firing the event if you don't have the flag set. 
Instead I just set it to true the first time you use guild to guild on that character, and afterwards respect 
your decision. (Turning it off will really turn it off).
	
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
- split messages sent to guild chat on to two lines if they are longer than 254 characters
- prevent addon messages longer than 254 characters from being sent

7.3.9 - Nov 24, 2007
- enabled relaying of addon messages sent to the guild channel
- added a filter for which guild addon messages are relayed
- fixed a null pointer when logging in an unguilded character
- Added channel, and password as options that can go in the guild information pane to be parsed
- Fixed a bug on initialization caused when the guildname had not been loaded yet
	
7.3.8
- Workaround for blizzard bug where GuildInfo is cached between different characters

7.3.5 - Nov 20, 2007
- officer chat is detected automatically
- other addon messages sent to the guild channel are now relayed
- fixed a problem where guild2guild was always trying to take over the first channel
- fixed a bug which was causing connections to other guilds to be lost when the current relay 
logged out, and a new one took over if the guild was not using the whitelist
- fixed a bug where the relay would bounce back and forth once when the relay ownership was 
transferred to an officer

7.3.4 - Oct 15, 2007
prevented double messages from occurring when one of the relay's got drunk and the guild was 
not using whitelists for allied guilds.

7.3.3 - Sept 28, 2007
fixed a synchronization issue electing a new relay when the current relay logged out


7.3.2 - first public version after a re-write to support multiple relays, improve robustness, 
and use a secure whispers instead of the relay channel.