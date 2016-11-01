ScriptName ScribeOverlay_Reload Extends ReferenceAlias
{Invokes alias events on ScribeOverlay_Quest}


Event OnPlayerLoadGame()
	{Sent when the player loads a save game. This event will not be sent when starting a new game}
	; http://www.creationkit.com/OnPlayerLoadGame_-_Actor
	(GetOwningQuest() as ScribeOverlay_Quest).OnGameReload()
EndEvent
