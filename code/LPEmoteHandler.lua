
EVENT_ON_SMART_EMOTE = "EVENT_ON_SMART_EMOTE"
EVENT_ON_IDLE_EMOTE = "EVENT_ON_IDLE_EMOTE"

local performedSmartEmote
local performedIdleEmote


local function CheckPlayerMovementWhileEmoting(x, y)
	local _, _, didMove = LPUtilities.DidPlayerMove(x, y)
	if didMove then
		EVENT_MANAGER:UnregisterForUpdate("PlayerMovement")
		LPEventHandler.FireEvent(EVENT_ON_SMART_EMOTE, false)
	end
	return didMove
end


local function ResolveLoopingEmote()
	local x, y = GetMapPlayerPosition(LorePlay.player)
	EVENT_MANAGER:RegisterForUpdate("PlayerMovement", 2000, function() 
		CheckPlayerMovementWhileEmoting(x, y)
		end)
end


local function ResolveEmote()
	local x, y = GetMapPlayerPosition(LorePlay.player)
	EVENT_MANAGER:RegisterForUpdate("EmoteTimeReached", 5000, function()
		LPEventHandler.FireEvent(EVENT_ON_SMART_EMOTE, false) 
		EVENT_MANAGER:UnregisterForUpdate("EmoteTimeReached")
		EVENT_MANAGER:UnregisterForUpdate("PlayerMovement")
		end)
	EVENT_MANAGER:RegisterForUpdate("PlayerMovement", 1050, function() 
			if CheckPlayerMovementWhileEmoting(x, y) then
				EVENT_MANAGER:UnregisterForUpdate("EmoteTimeReached")
			end
		end)
end


local function UpdateIsEmoting(index)
	local slashName = GetEmoteSlashNameByIndex(index)
	if LPEmotesTable.allEmotesTable[slashName]["doesLoop"] then
		ResolveLoopingEmote()
	else
		ResolveEmote()
	end
end


local function OnIdleEmote(eventCode)
	performedIdleEmote = true
	zo_callLater(function() performedIdleEmote = false end, 500)
	d("performed idle emote!")
end




local function OnSmartEmote(eventCode, isSmartEmoting, index)
	if eventCode ~= EVENT_ON_SMART_EMOTE then return end
	if isSmartEmoting then
		performedSmartEmote = true
		zo_callLater(function() performedSmartEmote = false end, 500)
		d("performed smart emote!")
	end

	--[[
	if isSmartEmoting then
		UpdateIsSmartEmoting(index)
	end
	]]--
end



--returns false to confirm this didn't handle the original ESO action
local function PreHookTest(index)
	if performedSmartEmote then
		UpdateIsEmoting(index)
	elseif performedIdleEmote then
		return false
	else
		UpdateIsEmoting(index)
	end
	return false
end

ZO_PreHook("PlayEmoteByIndex", PreHookTest)






LPEventHandler.RegisterForLocalEvent(EVENT_ON_SMART_EMOTE, OnSmartEmote)
LPEventHandler.RegisterForLocalEvent(EVENT_ON_IDLE_EMOTE, OnIdleEmote)