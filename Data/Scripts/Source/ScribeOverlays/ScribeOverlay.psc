ScriptName ScribeOverlay Hidden


; Modification
;---------------------------------------------------------------------------------------------------

string Function GetName() Global
	return "Helmet Overlays"
EndFunction


ScribeOverlay_ViewManager Function GetViewManager() Global
	return Quest.GetQuest("ScribeOverlay_ViewManager") as ScribeOverlay_ViewManager
EndFunction




ScribeHelmet Function GetHelmet() Global
	return Quest.GetQuest("ScribeHelmet") as ScribeHelmet
EndFunction


Function Log(string aMessage, string aScriptSite = "", bool abNotification = false, bool abMessageBox = false) Global
	If(abMessageBox)
		Debug.MessageBox(aScriptSite + "\n" + aMessage)
	ElseIf(abNotification)
		Debug.Notification(aMessage)
	EndIf

	string sLogName = GetName()
	string sVerbose = aScriptSite + " :: " + aMessage
	If(Debug.TraceUser(sLogName, sVerbose))
		return
	Else
		Debug.OpenUserLog(sLogName)
		Debug.TraceUser(sLogName, sVerbose)
	EndIf
EndFunction











; Global Variables
;---------------------------------------------------------------------------------------------------

bool Function GlobalAsBool(GlobalVariable akGlobalVariable) Global
	If(akGlobalVariable == none)
		return false
	ElseIf(akGlobalVariable.GetValue() <= 0)
		return false
	Else
		return true
	EndIf
EndFunction


Function GlobalToBool(GlobalVariable akGlobalVariable, bool abValue) Global
	If(akGlobalVariable == none)
		return
	ElseIf(abValue)
		akGlobalVariable.SetValue(1)
	Else
		akGlobalVariable.SetValue(0)
	EndIf
EndFunction



; Strings
;---------------------------------------------------------------------------------------------------

string Function TrimEnd(string asText, int aiTrim) Global
	int len = StringUtil.GetLength(asText)
	return StringUtil.Substring(asText, 0, len - aiTrim)
EndFunction


string Function GetDelimiter(int aiDelimiter = 1) Global
{DEPRECIATE - Sublime Papyrus has been fixed}
	If(aiDelimiter == 1)
		return "\n"
	ElseIf(aiDelimiter == 2)
		return "\t"
	ElseIf(aiDelimiter == 3)
		return "\""
	ElseIf(aiDelimiter == 4)
		return "\\"
	Else
		return ""
	EndIf
EndFunction


; does not support 4 char file extensions like filename.json
; measure the length of the provided extension
string Function ConvertFileExtension(string asFilePath, string asExtension) Global
	int len = StringUtil.GetLength(asFilePath)
	return StringUtil.Substring(asFilePath, 0, len - 3) + asExtension
EndFunction


; does not support 4 char file extensions like filename.json
string Function GetFileExtension(string asFilePath) Global
	int len = StringUtil.GetLength(asFilePath)
	return StringUtil.Substring(asFilePath, len - 3, len)
EndFunction


string Function ToPath(string asPath) Global
	string[] folders = StringUtil.Split(asPath, GetDelimiter(4))
	string newFolder
	Int idx = 0
	While(idx < folders.Length)
		newFolder += folders[idx] + "/"
		idx += 1
	EndWhile
	newFolder = TrimEnd(newFolder, 1)
	return newFolder
EndFunction
