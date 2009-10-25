
local Guild2GuildGui_flashButton = false
local Guild2GuildGui_flashColor = { r=1, g=1, b=1 }
local Guild2GuildGui_flashTime = 1

function Guild2GuildGui_sync( attrib )

    if ( attrib == "enable" ) then
        -- nothing to do

    elseif ( attrib == "hidden" ) then
        if ( Guild2Guild_Profile.gui.hidden == 1 ) then
            Guild2GuildGuiFrame:Hide()
        else
            Guild2GuildGuiFrame:Show();
        end

    elseif ( attrib == "alpha" ) then
        Guild2GuildGuiFrame:SetAlpha(Guild2Guild_Profile.mainalpha);
        Guild2GuildGuiFrame:SetBackdropBorderColor(0, 0, 0, Guild2Guild_Profile.backalpha);
        Guild2GuildGuiFrame:SetBackdropColor(0, 0, 0, Guild2Guild_Profile.backalpha);

    elseif ( attrib == "minimize" ) then
        if ( Guild2Guild_Profile.gui.minimize == 1 ) then
            Guild2GuildScrollFrame:Hide()
            Guild2GuildGuiFrame:SetHeight(25);
        else
            Guild2GuildScrollFrame:Show()
            Guild2GuildGuiFrame:SetHeight(126);
        end

    elseif ( attrib == "queue" ) then
        Guild2GuildStatusText:SetText( Guild2Guild_Runtime.queueBrief )
        Guild2GuildStatusText:SetTextColor(
            Guild2Guild_Runtime.queueBriefColor.r,
            Guild2Guild_Runtime.queueBriefColor.g,
            Guild2Guild_Runtime.queueBriefColor.b )

        Guild2GuildQueueText:SetText( Guild2Guild_Runtime.queueDetail );
        Guild2GuildScrollFrame:UpdateScrollChildRect();
        Guild2GuildScrollFrameScrollBar:SetValue(0);

        Guild2GuildGui_flashButton = ( Guild2Guild_Runtime.queueLength > 0 )
        Guild2GuildGui_flashColor = Guild2Guild_Runtime.queueBriefColor
    end
end

function Guild2GuildGui_onupdate( arg1 )

    if ( Guild2Guild_Spells and
         Guild2GuildGui_flashButton and
         Guild2Guild_Profile.gui.flashqueue == 1 ) then

        local cyclePercent = Guild2GuildUtil_GetCyclePercent(
            "WCGui", arg1, Guild2GuildGui_flashTime )

        -- cycle from 0.7 to 1.0 alpha
        local alpha = cyclePercent * 0.3 + 0.7

        Guild2GuildStatusText:SetTextColor(
            Guild2GuildGui_flashColor.r,
            Guild2GuildGui_flashColor.g,
            Guild2GuildGui_flashColor.b ,
            alpha )
    end
end

------------------------------------------------------------------------------
-- Externally access functions
------------------------------------------------------------------------------

function Guild2GuildGui_OnLoad()
    Guild2Guild.RegisterGUI( {
        initialize = "Guild2GuildGui_initialize",
        sync = "Guild2GuildGui_sync",
        onupdate = "Guild2GuildGui_onupdate",
        slash = "Guild2GuildGui_SlashCommandHandler",
        reset = "Guild2GuildGui_reset",
    } )

    Guild2GuildCastButton:SetText("cast")
    Guild2GuildClearButton:SetText("clear")
end

function Guild2GuildGui_OnEvent(event)

end

function Guild2GuildGui_initialize()

	if ( Guild2Guild.LocalVars ~= nil ) then
        Guild2GuildGui_sync("minimize")
        Guild2GuildGui_sync("hidden")
        Guild2GuildGui_sync("alpha")
    else
        Guild2GuildGuiFrame:Hide()
    end
end

function Guild2GuildGui_reset()
    Guild2GuildGui_sync("minimize")
    Guild2GuildGui_sync("hidden")
    Guild2GuildGui_sync("alpha")

    Guild2GuildGuiFrame:ClearAllPoints()
    Guild2GuildGuiFrame:SetPoint("TOPLEFT","UIParent","LEFT",0,0)
end

function Guild2GuildGui_ToggleMinimized(sync)
    if ( not sync ) then
        Guild2Guild_ToggleProfileKey( {"gui","minimize"} );
    end
    Guild2GuildGui_sync("minimize");
end

function Guild2GuildGui_ToggleHidden(sync)
    if ( not sync ) then
        Guild2Guild_ToggleProfileKey( {"gui","hidden"} );
    end
    Guild2GuildGui_sync("hidden");
end

function Guild2GuildGui_ToggleFlashQueue(sync)
    if ( not sync ) then
        Guild2Guild_ToggleProfileKey( {"gui","flashqueue"} );
    end
    Guild2GuildGui_sync("queue");
end

function Guild2GuildGui_ShowTooltip(msg)
    -- put the tool tip in the default position
    GameTooltip:SetOwner(this, "ANCHOR_TOPRIGHT");
    GameTooltip:SetText(msg, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g,
        NORMAL_FONT_COLOR.b, 1);
end

function Guild2GuildGui_SlashCommandHandler( msg, command, option )
    if( command == "show" ) then
        Guild2Guild_Profile.gui.hidden = 0
        Guild2GuildGui_ToggleHidden(true)
    elseif( command == "hide" ) then
        Guild2Guild_Profile.gui.hidden = 1
        Guild2GuildGui_ToggleHidden(true)
    elseif( command == "min" ) then
        Guild2Guild_Profile.gui.minimize = 1
        Guild2GuildGui_ToggleMinimized(true)
    elseif( command == "max" ) then
        Guild2Guild_Profile.gui.minimize = 0
        Guild2GuildGui_ToggleMinimized(true)
    else
        return false
    end

    return true
end

function Guild2GuildGui_ToggleDropDown()
	Guild2GuildGuiDropDown.point = "BOTTOMLEFT";
	Guild2GuildGuiDropDown.relativePoint = "TOPLEFT";
	ToggleDropDownMenu(1, nil, Guild2GuildGuiDropDown, "Guild2GuildCastButton", 0, 0);
end

function Guild2GuildGui_DropDownInitialize()

    if ( not Guild2Guild_Spells ) then return end

    Guild2Guild_DropDownInitialize()

	local info = {};

    if ( UIDROPDOWNMENU_MENU_LEVEL == 1 ) then

		info = {};
    	info.disabled = 1;
        UIDropDownMenu_AddButton(info);

        info = { };
        info.text = "flash";
        info.keepShownOnClick = 1;
        info.checked = Guild2Guild_getChecked( Guild2Guild_Profile.gui.flashqueue );
        info.func = Guild2GuildGui_ToggleFlashQueue;
        UIDropDownMenu_AddButton(info);

        info = { };
        info.text = "min";
        info.keepShownOnClick = 1;
        info.checked = Guild2Guild_getChecked( Guild2Guild_Profile.gui.minimize );
        info.func = Guild2GuildGui_ToggleMinimized;
        UIDropDownMenu_AddButton(info);

        info = { };
        info.text = "hide";
        info.keepShownOnClick = 1;
        info.checked = Guild2Guild_getChecked( Guild2Guild_Profile.gui.hidden );
        info.func = Guild2GuildGui_ToggleHidden;
        UIDropDownMenu_AddButton(info);
    end
end        

function Guild2GuildGuiDropDown_OnLoad()
    UIDropDownMenu_Initialize(this, Guild2GuildGui_DropDownInitialize, "MENU");
	UIDropDownMenu_SetButtonWidth(50);
	UIDropDownMenu_SetWidth(50);
end
