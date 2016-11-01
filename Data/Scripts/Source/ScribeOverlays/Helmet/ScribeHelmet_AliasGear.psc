ScriptName ScribeHelmet_AliasGear Extends ScribeHelmet_Alias


; Fields
;..................................................
string current
int HEAD_SLOTMASK
int HAIR_SLOTMASK


; Alias Implementation
;---------------------------------------------------------------------------------------------------

;@implement
Event OnGameReload()
	ScribeOverlay.Log("OnGameReload()", self)
	HEAD_SLOTMASK = 0x00000001
	HAIR_SLOTMASK = 0x00000002
EndEvent

;@implement
Event OnAliasReload()
	ScribeOverlay.Log("OnAliasReload()", self)
	RegisterForModEvent(Helmet.EventArtLoaded, "OnArtLoaded") 	;@AS2
	RegisterForModEvent(Helmet.EventArtError, "OnArtError") 	;@AS2
EndEvent


;@implement
Event OnAliasReady()
	ScribeOverlay.Log("OnAliasReady()", self)
	SetActive()
	GearChanged(GetEquipped())
EndEvent


; Active State
;---------------------------------------------------------------------------------------------------

State ACTIVESTATE
	Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
		Utility.Wait(0.01)
		Armor kArmor = GetEquipped()
		If(kArmor == akBaseObject)
			GearChanged(kArmor)
		EndIf
	EndEvent


	Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
		If(GetEquipped() == none)
			GearChanged(none)
		EndIf
	EndEvent


	Event OnArtError(string asEventName, string asPathKey, float afArgNumber, form akSender)
		ScribeOverlay.Log("OnArtError() :: asPathKey="+asPathKey, self)
		current = ""
	EndEvent


	Event OnArtLoaded(string asEventName, string asPathKey, float afArgNumber, form akSender)
		ScribeOverlay.Log("OnArtLoaded() :: asPathKey="+asPathKey, self)
		current = asPathKey
	EndEvent


	Event OnEndState()
		ScribeOverlay.Log("OnEndState()", self)
		current = ""
	EndEvent
EndState


; Empty State
;---------------------------------------------------------------------------------------------------

Event OnArtError(string asEventName, string asPathKey, float afArgNumber, form akSender)
	{Empty State}
EndEvent

Event OnArtLoaded(string asEventName, string asPathKey, float afArgNumber, form akSender)
	{Empty State}
EndEvent


; Methods
;---------------------------------------------------------------------------------------------------

Armor Function GetEquipped()
	Armor hair = Player.GetWornForm(HAIR_SLOTMASK) as Armor
	If(hair)
		return hair
	Else
		return Player.GetWornForm(HEAD_SLOTMASK) as Armor
	EndIf
EndFunction


Function GearChanged(Armor akArmor)
	If(akArmor)
		string[] keys = GetKeys(akArmor)
		SendEvent_GearChanged(akArmor, keys[0], keys[1])
	Else
		current = ""
		SendEvent_GearChanged(none, none, none)
	EndIf
EndFunction


Function SendEvent_GearChanged(Form akForm, string asPathKeyA, string asPathKeyB)
	ScribeOverlay.Log("SendEvent_GearChanged(akForm="+akForm+", asPathKeyA="+asPathKeyA+", asPathKeyB="+asPathKeyB+")", self)
	int ihandle = ModEvent.Create(EventGearChanged)
	If(ihandle)
		ModEvent.PushForm(ihandle, akForm)
		ModEvent.PushString(ihandle, asPathKeyA)
		ModEvent.PushString(ihandle, asPathKeyB)
		ModEvent.Send(ihandle)
	EndIf
EndFunction



; Generate PathKeys
;---------------------------------------------------------------------------------------------------

string[] Function GetKeys(Armor akArmor)
	If(akArmor)
		string[] keys = new string[2]
		ArmorAddon addon = akArmor.GetNthArmorAddon(0)
		If(addon)
			keys[0] = ToKey(addon.GetModelPath(false, false))
		EndIf
		keys[1] = ToKey(akArmor.GetModelPath(false))
		return keys
	EndIf
	return none
EndFunction


string Function ToKey(string asFilePath)
	string filepath = ScribeOverlay.ToPath(asFilePath)	; flip path seperator
	return ScribeOverlay.TrimEnd(filepath, 4)					; remove file extension
EndFunction




; Heavy-ish, Searches the Player for armor forms
string[] Function FindKeys()
	Form[] forms = Player.GetContainerForms()
	String[] strings = Utility.CreateStringArray(forms.length)

	int i = 0
	while (i < forms.length)
		Armor k = forms[i] as Armor
		If(k)
			string newValue = GetKeys(k)[1] + ".dds" ; normally uses key only
			strings[i] = newValue
		Else
			strings[i] = ""
		EndIf
		i += 1
	endWhile

	strings = PapyrusUtil.ClearEmpty(strings)
	strings = PapyrusUtil.MergeStringArray(strings, strings, true)
	return strings
EndFunction




; Heavy, Searches entire plugin for armor forms
string[] Function FindKeysFor(string asPluginName)
	Form[] forms = GameData.GetAllArmor(asPluginName)
	String[] strings = Utility.CreateStringArray(forms.length)

	int i = 0
	while (i < forms.length)
		Armor k = forms[i] as Armor
		Player.AddItem(k, 1, true)
		If(k)
			string newValue = GetKeys(k)[1] + ".dds"
			strings[i] = newValue
		Else
			strings[i] = ""
		EndIf
		i += 1
	endWhile

	strings = PapyrusUtil.ClearEmpty(strings)
	strings = PapyrusUtil.MergeStringArray(strings, strings, true)
	return strings
EndFunction


; Properties
;---------------------------------------------------------------------------------------------------

string Property EventGearChanged Hidden
	string Function Get()
		return "ScribeHelmet_EventGearChanged"
	EndFunction
EndProperty


string Property CurrentKey Hidden
	string Function Get()
		return current
	EndFunction
EndProperty


GlobalVariable Property ScribeHelmet_OptionArtSize Auto
float Property SizeDefault = 0.0 AutoReadOnly
float Property Size Hidden
	float Function Get()
		return ScribeHelmet_OptionArtSize.GetValue()
	EndFunction
	Function Set(float aValue)
		If(aValue < 0)
			aValue = 0
		ElseIf(aValue > 2000)
			aValue = 2000
		EndIf
		ScribeHelmet_OptionArtSize.SetValue(aValue)
	EndFunction
EndProperty


GlobalVariable Property ScribeHelmet_OptionArtAlpha Auto
float Property AlphaDefault = 100.0 AutoReadOnly
float Property Alpha Hidden
	float Function Get()
		return ScribeHelmet_OptionArtAlpha.GetValue()
	EndFunction
	Function Set(float aValue)
		If(aValue < 1)
			aValue = 1
		ElseIf(aValue > 100)
			aValue = 100
		EndIf
		ScribeHelmet_OptionArtAlpha.SetValue(aValue)
	EndFunction
EndProperty
















; Test Equipment
;---------------------------------------------------------------------------------------------------

Function DebugFunction()
	Utility.Wait(1.0)
	Player.AddItem(Game.GetFormEx(0x00012E4D), 1, true) ; Iron Helmet
	Player.AddItem(Game.GetFormEx(0x00013104), 1, true) ; Ragged Cap
	Player.AddItem(Game.GetFormEx(0x000136CF), 1, true) ; Imperial Officers Helmet
	Player.AddItem(Game.GetFormEx(0x00013913), 1, true) ; Hide Helmet
	Player.AddItem(Game.GetFormEx(0x0001391D), 1, true) ; Elven Helmet
	Player.AddItem(Game.GetFormEx(0x00013922), 1, true) ; Leather Helmet
	Player.AddItem(Game.GetFormEx(0x0001393B), 1, true) ; Glass Helmet
	Player.AddItem(Game.GetFormEx(0x00013940), 1, true) ; Dragonscale Helmet
	Player.AddItem(Game.GetFormEx(0x0001394F), 1, true) ; Dwarven Helmet
	Player.AddItem(Game.GetFormEx(0x00013954), 1, true) ; Steel Helmet
	Player.AddItem(Game.GetFormEx(0x00013959), 1, true) ; Orcish Helmet
	Player.AddItem(Game.GetFormEx(0x0001395E), 1, true) ; Steel Plate Helmet
	Player.AddItem(Game.GetFormEx(0x00013963), 1, true) ; Ebony Helmet
	Player.AddItem(Game.GetFormEx(0x00013969), 1, true) ; Dragonplate Helmet
	Player.AddItem(Game.GetFormEx(0x0001396D), 1, true) ; Daedric Helmet
	Player.AddItem(Game.GetFormEx(0x00013EDB), 1, true) ; Imperial Light Helmet
	Player.AddItem(Game.GetFormEx(0x00013EDC), 1, true) ; Imperial Helmet
	Player.AddItem(Game.GetFormEx(0x00017695), 1, true) ; Clothes
	Player.AddItem(Game.GetFormEx(0x00017696), 1, true) ; Cowl
	Player.AddItem(Game.GetFormEx(0x0001B3A1), 1, true) ; Scaled Helmet
	Player.AddItem(Game.GetFormEx(0x0001BCA7), 1, true) ; Chefs Hat
	Player.AddItem(Game.GetFormEx(0x0001FD77), 1, true) ; Ancient Nord Helmet
	Player.AddItem(Game.GetFormEx(0x0001FD7B), 1, true) ; Ancient Nord Helmet
	Player.AddItem(Game.GetFormEx(0x0001FD7C), 1, true) ; Ancient Nord Helmet
	Player.AddItem(Game.GetFormEx(0x000209AA), 1, true) ; Hat
	Player.AddItem(Game.GetFormEx(0x00021613), 1, true) ; Markarth Guard Helmet
	Player.AddItem(Game.GetFormEx(0x00021615), 1, true) ; Whiterun Guard Helmet
	Player.AddItem(Game.GetFormEx(0x00021619), 1, true) ; Falkreath Guard Helmet
	Player.AddItem(Game.GetFormEx(0x0002161B), 1, true) ; Hjaalmarch Guard Helmet
	Player.AddItem(Game.GetFormEx(0x0002161D), 1, true) ; Winterhold Guard Helmet
	Player.AddItem(Game.GetFormEx(0x0002161F), 1, true) ; Pale Guard Helmet
	Player.AddItem(Game.GetFormEx(0x00021622), 1, true) ; Riften Guard Helmet
	Player.AddItem(Game.GetFormEx(0x000295F3), 1, true) ; Helm of Yngol (Steel Plate Helmet)
	Player.AddItem(Game.GetFormEx(0x000330B3), 1, true) ; Hat
	Player.AddItem(Game.GetFormEx(0x000330BC), 1, true) ; Hat
	Player.AddItem(Game.GetFormEx(0x00036585), 1, true) ; Thieves Guild Hood
	Player.AddItem(Game.GetFormEx(0x00036A45), 1, true) ; Greybeards Hood
	Player.AddItem(Game.GetFormEx(0x0004223B), 1, true) ; Hat
	Player.AddItem(Game.GetFormEx(0x00047CBE), 1, true) ; Leather Hood (Torturer)
	Player.AddItem(Game.GetFormEx(0x000487D8), 1, true) ; Nightingale Hood
	Player.AddItem(Game.GetFormEx(0x0004B28F), 1, true) ; Blades Helmet
	Utility.Wait(1.0)
	Player.AddItem(Game.GetFormEx(0x0004C3CB), 1, true) ; Falmer Helmet
	Player.AddItem(Game.GetFormEx(0x0004C3D0), 1, true) ; Wolf Helmet
	Player.AddItem(Game.GetFormEx(0x0004F000), 1, true) ; Head Bandages
	Player.AddItem(Game.GetFormEx(0x00056A9E), 1, true) ; Ancient Nord Helmet
	Player.AddItem(Game.GetFormEx(0x0005A9DF), 1, true) ; Execution Hood
	Player.AddItem(Game.GetFormEx(0x0005A9E3), 1, true) ; Execution Hood (Dark Brotherhood)
	Player.AddItem(Game.GetFormEx(0x0005ABC4), 1, true) ; Shrouded Cowl Maskless
	Player.AddItem(Game.GetFormEx(0x0005DB88), 1, true) ; Nightingale Hood
	Player.AddItem(Game.GetFormEx(0x00061C8B), 1, true) ; Morokei (Dragon Mask)
	Player.AddItem(Game.GetFormEx(0x00061CA5), 1, true) ; Nahkriin (Dragon Mask)
	Player.AddItem(Game.GetFormEx(0x00061CAB), 1, true) ; Volsung (Dragon Mask)
	Player.AddItem(Game.GetFormEx(0x00061CB9), 1, true) ; Krosis (Dragon Mask)
	Player.AddItem(Game.GetFormEx(0x00061CC0), 1, true) ; Rahgot (Dragon Mask)
	Player.AddItem(Game.GetFormEx(0x00061CC1), 1, true) ; Hevnoraak (Dragon Mask)
	Player.AddItem(Game.GetFormEx(0x00061CC2), 1, true) ; Otar (Dragon Mask)
	Player.AddItem(Game.GetFormEx(0x00061CC9), 1, true) ; Vokun (Dragon Mask)
	Player.AddItem(Game.GetFormEx(0x00061CCA), 1, true) ; Wooden Mask (Dragon Mask)
	Player.AddItem(Game.GetFormEx(0x00061CD6), 1, true) ; Konahrik (Dragon Mask)
	Player.AddItem(Game.GetFormEx(0x000646AB), 1, true) ; Mourners Hat
	Player.AddItem(Game.GetFormEx(0x0006492E), 1, true) ; Ciceros Hat
	Player.AddItem(Game.GetFormEx(0x00065B99), 1, true) ; Psiijic Hood
	Player.AddItem(Game.GetFormEx(0x0006F39E), 1, true) ; Fur Helmet
	Player.AddItem(Game.GetFormEx(0x0006FE72), 1, true) ; Nosters Helmet
	Player.AddItem(Game.GetFormEx(0x0007BC1A), 1, true) ; Alik'r Hood
	Player.AddItem(Game.GetFormEx(0x00086985), 1, true) ; Stormcloak Officer Helmet
	Player.AddItem(Game.GetFormEx(0x00088954), 1, true) ; Nocturnals Hat
	Player.AddItem(Game.GetFormEx(0x000940D5), 1, true) ; Helm of Winterhold
	Player.AddItem(Game.GetFormEx(0x0009610D), 1, true) ; Imperial Helmet
	Player.AddItem(Game.GetFormEx(0x000A6D79), 1, true) ; Stormcloak Helmet
	Player.AddItem(Game.GetFormEx(0x000B144D), 1, true) ; Mythic Dawn Robes
	Player.AddItem(Game.GetFormEx(0x000B8837), 1, true) ; Iron Helmet (DEMO)
	Player.AddItem(Game.GetFormEx(0x000C5D10), 1, true) ; Black Mage Hood
	Player.AddItem(Game.GetFormEx(0x000C7F5C), 1, true) ; Solitude Guard Helmet
	Player.AddItem(Game.GetFormEx(0x000CEE72), 1, true) ; Jesters Hat
	Player.AddItem(Game.GetFormEx(0x000CEE84), 1, true) ; Fine Hat
	Player.AddItem(Game.GetFormEx(0x000CF8A1), 1, true) ; Shrouded Hood
	Player.AddItem(Game.GetFormEx(0x000CF8B2), 1, true) ; Executioners Hood
	Player.AddItem(Game.GetFormEx(0x000D2842), 1, true) ; Shrouded Cowl
	Player.AddItem(Game.GetFormEx(0x000D2846), 1, true) ; Masque of Clavicus Vile
	Player.AddItem(Game.GetFormEx(0x000D3AC5), 1, true) ; Thieves Guild Hood
	Player.AddItem(Game.GetFormEx(0x000D3ACE), 1, true) ; Thieves Guild Hood
	Utility.Wait(1.0)
	Player.AddItem(Game.GetFormEx(0x000D3DE8), 1, true) ; Mage Hood
	Player.AddItem(Game.GetFormEx(0x000D3EAA), 1, true) ; Penitus Oculatus Helmet
	Player.AddItem(Game.GetFormEx(0x000D8D52), 1, true) ; Forsworn Headdress
	Player.AddItem(Game.GetFormEx(0x000DA750), 1, true) ; Jagged Crown
	Player.AddItem(Game.GetFormEx(0x000E0DD2), 1, true) ; Redguard Hood
	Player.AddItem(Game.GetFormEx(0x000E1F17), 1, true) ; Ancient Shrouded Hood
	Player.AddItem(Game.GetFormEx(0x000E35D9), 1, true) ; Guild Masters Hood
	Player.AddItem(Game.GetFormEx(0x000E35DD), 1, true) ; Thieves Guild Variant Hood
	Player.AddItem(Game.GetFormEx(0x000E35DF), 1, true) ;Thieves Guild Hood Alt
	Player.AddItem(Game.GetFormEx(0x000E35EA), 1, true) ; Karliahs Hood
	Player.AddItem(Game.GetFormEx(0x000EAFD1), 1, true) ; Helmet of the Old Gods
	Player.AddItem(Game.GetFormEx(0x000EE5C0), 1, true) ; Torturers Hood
	Player.AddItem(Game.GetFormEx(0x000F6F24), 1, true) ; Steel Horned Helmet
	Player.AddItem(Game.GetFormEx(0x000FCC12), 1, true) ; Nightingale Hood
	Player.AddItem(Game.GetFormEx(0x000FCC13), 1, true) ; Nightingale Hood
	Player.AddItem(Game.GetFormEx(0x001019CA), 1, true) ; Ancient Nord Helmet
	Player.AddItem(Game.GetFormEx(0x0010559D), 1, true) ; Eastmarch Guard Helmet
	Player.AddItem(Game.GetFormEx(0x00105969), 1, true) ; Worn Shrouded Cowl
	Player.AddItem(Game.GetFormEx(0x00105F14), 1, true) ; Elven Light Helmet
	Player.AddItem(Game.GetFormEx(0x00107106), 1, true) ; Hooded Monk Robes
	Player.AddItem(Game.GetFormEx(0x00107108), 1, true) ; Hooded Black Robes
	Player.AddItem(Game.GetFormEx(0x00107109), 1, true) ; Hooded Mage Robes
	Player.AddItem(Game.GetFormEx(0x0010710A), 1, true) ; Hooded Blue Robes
	Player.AddItem(Game.GetFormEx(0x0010710B), 1, true) ; Hooded Blue Robes (Template)
	Player.AddItem(Game.GetFormEx(0x0010710C), 1, true) ; Hooded Black Mage Robes
	Player.AddItem(Game.GetFormEx(0x0010710D), 1, true) ; Hooded Necromancer Robes
	Player.AddItem(Game.GetFormEx(0x00108542), 1, true) ; Summerset Shadows Hood
	Player.AddItem(Game.GetFormEx(0x00108546), 1, true) ; Linwes Hood
	Player.AddItem(Game.GetFormEx(0x0010C698), 1, true) ; Hooded Thalmor Robes
	Player.AddItem(Game.GetFormEx(0x0010CEE6), 1, true) ; Adept Hood
	Player.AddItem(Game.GetFormEx(0x0010CEE8), 1, true) ; Novice Hood
	Player.AddItem(Game.GetFormEx(0x0010CFE4), 1, true) ; Hooded Brown Robes
	Player.AddItem(Game.GetFormEx(0x0010CFEA), 1, true) ; Hooded Grey Robes
	Player.AddItem(Game.GetFormEx(0x0010CFEB), 1, true) ; Hooded Red Robes
	Player.AddItem(Game.GetFormEx(0x0010CFEC), 1, true) ; Hooded Green Robes
	Player.AddItem(Game.GetFormEx(0x0010D2B5), 1, true) ; Apprentice Hood (Template)
	Player.AddItem(Game.GetFormEx(0x0010D6A6), 1, true) ; Mage Hood
	Player.AddItem(Game.GetFormEx(0x0010D6A7), 1, true) ; Mage Hood
	Player.AddItem(Game.GetFormEx(0x0010EB5D), 1, true) ; Worn Shrouded Hood
	Player.AddItem(Game.GetFormEx(0x0010F570), 1, true) ; Archmages Robe
	Player.AddItem(Game.GetFormEx(0x0010F75F), 1, true) ; Daedric Helmet
	Utility.Wait(1.0)
	If(Game.GetModByName("Dawnguard.esm"))
		Player.AddItem(Game.GetFormEx(0x0004C3CB), 1, true) ; Falmer Helmet
		Player.AddItem(Game.GetFormEx(0x020023EB), 1, true) ; Falmer Heavy Helmet
		Player.AddItem(Game.GetFormEx(0x020047DA), 1, true) ; Moth Priest Blindfold
		Player.AddItem(Game.GetFormEx(0x020050D0), 1, true) ; Dawnguard Full Helmet
		Player.AddItem(Game.GetFormEx(0x0200E6A0), 1, true) ; Serana Hood
		Player.AddItem(Game.GetFormEx(0x0200E8E0), 1, true) ; Falmer Hardened Helm
		Player.AddItem(Game.GetFormEx(0x02012E8A), 1, true) ; Shellbug Helmet
		Player.AddItem(Game.GetFormEx(0x02017E9B), 1, true) ; Black Mage Hood
		Player.AddItem(Game.GetFormEx(0x0201989E), 1, true) ; Dawnguard Helmet
		Player.AddItem(Game.GetFormEx(0x02019ADE), 1, true) ; Vampire Hood
		Player.AddItem(Game.GetFormEx(0x0201A73F), 1, true) ; Reapers Hood
	EndIf

	Utility.Wait(1.0)
	If(Game.GetModByName("Dragonbron.esm"))
		Player.AddItem(Game.GetFormEx(0x0401A576), 1, true) ; Imperial Helmet
		Player.AddItem(Game.GetFormEx(0x0401CD89), 1, true) ; Chitin Helmet
		Player.AddItem(Game.GetFormEx(0x0401CD8C), 1, true) ; Chitin Heavy Helmet
		Player.AddItem(Game.GetFormEx(0x0401CD95), 1, true) ; Bonemold Helmet
		Player.AddItem(Game.GetFormEx(0x0401CD99), 1, true) ; Nordic Carved Helmet
		Player.AddItem(Game.GetFormEx(0x0401CDA1), 1, true) ; Stalhrim Helmet
		Player.AddItem(Game.GetFormEx(0x0401CDA7), 1, true) ; Mirraks Robes
		Player.AddItem(Game.GetFormEx(0x0401CDA9), 1, true) ; Skaal Villagers Outfit
		Player.AddItem(Game.GetFormEx(0x0401CDAA), 1, true) ; Dunmer Outfit
		Player.AddItem(Game.GetFormEx(0x0401DB98), 1, true) ; Ahzidals Helm of Vision
		Player.AddItem(Game.GetFormEx(0x0402401D), 1, true) ; Deathbrand Helm
		Player.AddItem(Game.GetFormEx(0x04024037), 1, true) ; Zahkriisos (Dragon Mask)
		Player.AddItem(Game.GetFormEx(0x040240FE), 1, true) ; Ahzidal (Dragon Mask)
		Player.AddItem(Game.GetFormEx(0x040240FF), 1, true) ; Dukaan (Dragon Mask)
		Player.AddItem(Game.GetFormEx(0x040292AE), 1, true) ; Morah Tong Hood
		Player.AddItem(Game.GetFormEx(0x04029A62), 1, true) ; Miraak (Dragon Mask)
		Player.AddItem(Game.GetFormEx(0x0402AD31), 1, true) ; Blackguards Hood
		Player.AddItem(Game.GetFormEx(0x04037065), 1, true) ; Dunmer Outfit (Blue)
		Player.AddItem(Game.GetFormEx(0x04037066), 1, true) ; Dunmer Outfit (Red)
		Player.AddItem(Game.GetFormEx(0x04037B88), 1, true) ; Cultist Mask
		Player.AddItem(Game.GetFormEx(0x04037FF1), 1, true) ; Deathbrand Helm
		Player.AddItem(Game.GetFormEx(0x04038ADD), 1, true) ; Visage of Mzund
		Player.AddItem(Game.GetFormEx(0x04039114), 1, true) ; Skaal Hat
		Player.AddItem(Game.GetFormEx(0x04039D2B), 1, true) ; Miraak (Dragon Mask)
		Player.AddItem(Game.GetFormEx(0x04039D2E), 1, true) ; Miraak (Dragon Mask)
		Player.AddItem(Game.GetFormEx(0x04039D2F), 1, true) ; Miraak (Dragon Mask)
		Player.AddItem(Game.GetFormEx(0x04039FA1), 1, true) ; Miraak (Dragon Mask)
		Player.AddItem(Game.GetFormEx(0x04039FA2), 1, true) ; Miraak (Dragon Mask)
		Player.AddItem(Game.GetFormEx(0x04039FA3), 1, true) ; Miraak (Dragon Mask)
		Player.AddItem(Game.GetFormEx(0x0400AB23), 1, true) ; Improved Bonemold Helmet
		Player.AddItem(Game.GetFormEx(0x0403B04E), 1, true) ; Temple Priest Hood
		Player.AddItem(Game.GetFormEx(0x0403C0F1), 1, true) ; Miraak Mask
		Player.AddItem(Game.GetFormEx(0x0403C0F2), 1, true) ; Miraak Mask
		Player.AddItem(Game.GetFormEx(0x0403C0F3), 1, true) ; Miraak Mask
		Player.AddItem(Game.GetFormEx(0x0403C0F4), 1, true) ; Miraak Mask
		Player.AddItem(Game.GetFormEx(0x0403C0F5), 1, true) ; Miraak Mask
		Player.AddItem(Game.GetFormEx(0x0403C0F6), 1, true) ; Miraak Mask
	EndIf

	Utility.Wait(1.0)
	If(Game.GetModByName("Hothtrooper44_ArmorCompilation.esp"))
		Player.AddItem(Game.GetFormEx(0x1A000D66), 1, true) ; Falkreath Helmet
		Player.AddItem(Game.GetFormEx(0x1A000D69), 1, true) ; Redguard Knight Light Coif
		Player.AddItem(Game.GetFormEx(0x1A000D80), 1, true) ; Vagabond Helmet
		Player.AddItem(Game.GetFormEx(0x1A000D86), 1, true) ; Vagabond Plate Helmet
		Player.AddItem(Game.GetFormEx(0x1A000D87), 1, true) ; Vagabond Plate Helmet Closed
		Player.AddItem(Game.GetFormEx(0x1A000D88), 1, true) ; Warchief Heavy Battlecrown
		Player.AddItem(Game.GetFormEx(0x1A000D89), 1, true) ; Warchief Light Battlecrown
		Player.AddItem(Game.GetFormEx(0x1A000D90), 1, true) ; Warchief Heavy Headdress
		Player.AddItem(Game.GetFormEx(0x1A000D91), 1, true) ; Warchief Light Headdress
		Player.AddItem(Game.GetFormEx(0x1A000D98), 1, true) ; Hedge Knight Helmet
		Player.AddItem(Game.GetFormEx(0x1A0012C7), 1, true) ; Seadog Tricorne
		Player.AddItem(Game.GetFormEx(0x1A0012D3), 1, true) ; Einherjar Plate Light Hood
		Player.AddItem(Game.GetFormEx(0x1A001829), 1, true) ; Armored Fur Mantle - White
		Player.AddItem(Game.GetFormEx(0x1A001D8E), 1, true) ; Fur Mantle - White
		Player.AddItem(Game.GetFormEx(0x1A001D8F), 1, true) ; Padded Fur Mantle - White
		Player.AddItem(Game.GetFormEx(0x1A001D93), 1, true) ; Seadog Feathered Tricorne
		Player.AddItem(Game.GetFormEx(0x1A0022F5), 1, true) ; Armored Fur Mantle - Black
		Player.AddItem(Game.GetFormEx(0x1A0022FC), 1, true) ; Fur Mantle - Black
		Player.AddItem(Game.GetFormEx(0x1A0022FD), 1, true) ; Padded Fur Mantle - Black
		Player.AddItem(Game.GetFormEx(0x1A00285F), 1, true) ; Eyepatch
		Player.AddItem(Game.GetFormEx(0x1A003DED), 1, true) ; Paladin Great Helm
		Player.AddItem(Game.GetFormEx(0x1A003E31), 1, true) ; Einherjar Brigandine Dark Hood
		Player.AddItem(Game.GetFormEx(0x1A003E32), 1, true) ; Einherjar Brigandine Light Hood
		Player.AddItem(Game.GetFormEx(0x1A003EC7), 1, true) ; Nord Mail Heavy Coif
		Player.AddItem(Game.GetFormEx(0x1A003EC8), 1, true) ; Nord Heavy Spectacle Helmet
		Player.AddItem(Game.GetFormEx(0x1A003EC9), 1, true) ; Nord Mail Light Helmet
		Player.AddItem(Game.GetFormEx(0x1A003ECA), 1, true) ; Nord Light Spectacle Helmet
		Player.AddItem(Game.GetFormEx(0x1A004356), 1, true) ; Apotheus Hood
		Player.AddItem(Game.GetFormEx(0x1A0048D8), 1, true) ; Fur Hood
		Player.AddItem(Game.GetFormEx(0x1A0048D9), 1, true) ; Fur Hood - Black
		Player.AddItem(Game.GetFormEx(0x1A0048DA), 1, true) ; Armored Fur Hood
		Player.AddItem(Game.GetFormEx(0x1A0048DB), 1, true) ; Armored Fur Hood - Black
		Player.AddItem(Game.GetFormEx(0x1A0048DC), 1, true) ; Armored Fur Hood - White
		Player.AddItem(Game.GetFormEx(0x1A0048DD), 1, true) ; Padded Fur Hood
		Player.AddItem(Game.GetFormEx(0x1A0048DE), 1, true) ; Padded Fur Hood - Black
		Player.AddItem(Game.GetFormEx(0x1A0048DF), 1, true) ; Padded Fur Hood - White
		Player.AddItem(Game.GetFormEx(0x1A0048E0), 1, true) ; Fur Hood - White
		Player.AddItem(Game.GetFormEx(0x1A004F24), 1, true) ; Akaviri Samurai Helmet
		Player.AddItem(Game.GetFormEx(0x1A004F3B), 1, true) ; Dragonhide Heavy Hood
		Player.AddItem(Game.GetFormEx(0x1A005A1B), 1, true) ; Heroic Imperial Helmet
		Player.AddItem(Game.GetFormEx(0x1A005A29), 1, true) ; Dwarven Mage Heavy Hood
		Player.AddItem(Game.GetFormEx(0x1A005A40), 1, true) ; Primitive Nord Heavy Helmet
		Player.AddItem(Game.GetFormEx(0x1A000A44), 1, true) ; Primitive Nord Light Helmet
		Player.AddItem(Game.GetFormEx(0x1A005A5E), 1, true) ; Barbarian Helmet
		Player.AddItem(Game.GetFormEx(0x1A005A71), 1, true) ; Ranger Hood
		Player.AddItem(Game.GetFormEx(0x1A00803F), 1, true) ; Einherjar Plate Dark Hood
		Player.AddItem(Game.GetFormEx(0x1A008041), 1, true) ; Redguard Knight Heavy Coif
		Player.AddItem(Game.GetFormEx(0x1A00AB60), 1, true) ; Paladin Barbut
		Player.AddItem(Game.GetFormEx(0x1A00AB64), 1, true) ; Heroic Stormcloak Helmet
		Player.AddItem(Game.GetFormEx(0x1A00B64D), 1, true) ; Apotheus Helm
		Player.AddItem(Game.GetFormEx(0x1A00C694), 1, true) ; Witchplate Hood
		Player.AddItem(Game.GetFormEx(0x1A00D16D), 1, true) ; Spellbinder Crimson Helmet
		Player.AddItem(Game.GetFormEx(0x1A00D174), 1, true) ; Spellbinder Runic Helmet
		Player.AddItem(Game.GetFormEx(0x1A021F7E), 1, true) ; Orcish Masked Helmet
		Player.AddItem(Game.GetFormEx(0x1A021F8F), 1, true) ; Ritual Helm Boethiah
		Player.AddItem(Game.GetFormEx(0x1A021F90), 1, true) ; Ritual Mask of Boethiah
	EndIf
EndFunction





; notes
;---------------------------------------------------------------------------------------------------

; ; not implemented
; bool Function HasMask(int aiSlotMask, int aiSlot)
; 	; does the slot mask contain the given slot?
; 	return false
; EndFunction


; ; not implemented
; bool Function HasEquipSlot(Armor kArmor)
; 	; -Does this armor have the right EquipSlots flagged?  eg Head and Hair
; 	return false
; EndFunction


; ; not implemented
; bool Function IsHeadItem(Armor kArmor)
; 	; Note: ClothesMonkRobesHooded has no keyword for head items
; 	; -Is not null
; 	; -Is this a playable armor?
; 	; -Does it have the right keywords?
; 	; -Does it have the right EquipSlot (slotmask?) eg Head and Hair

; 	If(kArmor)
; 		bool b0 = kArmor.IsPlayable()
; 		bool b1 = kArmor.IsHelmet() || kArmor.IsClothingHead()
; 	EndIf

; 	return false
; EndFunction
