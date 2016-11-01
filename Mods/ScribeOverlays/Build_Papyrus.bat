@ECHO off
VERIFY > nul

REM Directories
SET modDirectory=E:\Lab\Bethesda\TES5\Scrivener07\Overlays\
SET skyrimDirectory=D:\Games\Steam\SteamApps\common\Skyrim\
SET compilerApp=%skyrimDirectory%Papyrus Compiler\PapyrusCompiler.exe

REM Imports
SET Output=%skyrimDirectory%Data\Scripts
SET Import=%skyrimDirectory%Data\Scripts\Source\

SET import00=%modDirectory%Papyrus
SET import01=%modDirectory%Papyrus\View
SET import02=%modDirectory%Papyrus\Helmet
SET import03=%modDirectory%Papyrus\Magic
SET import04=%modDirectory%Papyrus\Sample

SET Imports=%Import%;%import00%;%import01%;%import02%;%import03%;%import04%


start "PapyrusCompiler" /B "%compilerApp%" "%import00%" -f="TESV_Papyrus_Flags.flg" -all -import="%Imports%" -output="%Output%"
start "PapyrusCompiler" /B "%compilerApp%" "%import01%" -f="TESV_Papyrus_Flags.flg" -all -import="%Imports%" -output="%Output%"
start "PapyrusCompiler" /B "%compilerApp%" "%import02%" -f="TESV_Papyrus_Flags.flg" -all -import="%Imports%" -output="%Output%"
start "PapyrusCompiler" /B "%compilerApp%" "%import03%" -f="TESV_Papyrus_Flags.flg" -all -import="%Imports%" -output="%Output%"
start "PapyrusCompiler" /B "%compilerApp%" "%import04%" -f="TESV_Papyrus_Flags.flg" -all -import="%Imports%" -output="%Output%"

:LOOP
timeout /t 1 /nobreak > nul
tasklist /fi "IMAGENAME eq PapyrusCompiler.exe" | find /i "PapyrusCompiler.exe" > nul
if errorlevel 1 goto Finish
if errorlevel 0 goto LOOP
ECHO ________________________________________________________________________________
:Finish
ECHO Press any key to exit.
PAUSE>NUL
goto :EOF
