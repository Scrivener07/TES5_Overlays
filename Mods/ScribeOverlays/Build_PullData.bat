@ECHO off

REM Directories
SET skyrimDirectory=D:\Games\Steam\SteamApps\common\Skyrim\Data\
SET wryeDirectory=M:\DataShare\TES5\Bash Installers\Helmet Overlays\

REM Folders
SET modFolder=%wryeDirectory%\.Data\
SET helmetFolder=%wryeDirectory%\Helmet\
SET magicFolder=%wryeDirectory%\Magic\
SET sampleFolder=%wryeDirectory%\Sample\

ECHO Update Helmet Overlays
ECHO Skyrim  - %skyrimDirectory%
ECHO Mod 	 - %modFolder%
ECHO Helmet  - %helmetFolder%
ECHO Magic   - %magicFolder%
ECHO Sample  - %sampleFolder%

ECHO.
ECHO.
ECHO Update Overlays
SET plugin1=ScribeOverlays.esp
SET pex01=Scripts\ScribeOverlay.pex
SET pex02=Scripts\ScribeOverlay_Quest.pex
SET pex03=Scripts\ScribeOverlay_Reload.pex
SET pex04=Scripts\ScribeOverlay_ViewBase.pex
SET pex05=Scripts\ScribeOverlay_ViewManager.pex
ECHO f | xcopy /f /y "%skyrimDirectory%%plugin1%" "%modFolder%%plugin1%"
ECHO f | xcopy /f /y "%skyrimDirectory%%pex01%" "%modFolder%%pex01%"
ECHO f | xcopy /f /y "%skyrimDirectory%%pex02%" "%modFolder%%pex02%"
ECHO f | xcopy /f /y "%skyrimDirectory%%pex03%" "%modFolder%%pex03%"
ECHO f | xcopy /f /y "%skyrimDirectory%%pex04%" "%modFolder%%pex04%"
ECHO f | xcopy /f /y "%skyrimDirectory%%pex05%" "%modFolder%%pex05%"

ECHO.
ECHO.
ECHO Update Helmet
SET helmetPlugin=HelmetView.esp
SET helmet01=Scripts\ScribeHelmet.pex
SET helmet02=Scripts\ScribeHelmet_Alias.pex
SET helmet03=Scripts\ScribeHelmet_AliasCamera.pex
SET helmet04=Scripts\ScribeHelmet_AliasGear.pex
SET helmet05=Scripts\ScribeHelmet_AliasLight.pex
SET helmet06=Scripts\ScribeHelmet_AliasMenu.pex
SET helmet07=Scripts\ScribeHelmet_AliasMotion.pex
SET helmet08=Scripts\ScribeHelmet_MCM.pex
ECHO f | xcopy /f /y "%skyrimDirectory%%helmetPlugin%" "%helmetFolder%%helmetPlugin%"
ECHO f | xcopy /f /y "%skyrimDirectory%%helmet01%" "%helmetFolder%%helmet01%"
ECHO f | xcopy /f /y "%skyrimDirectory%%helmet02%" "%helmetFolder%%helmet02%"
ECHO f | xcopy /f /y "%skyrimDirectory%%helmet03%" "%helmetFolder%%helmet03%"
ECHO f | xcopy /f /y "%skyrimDirectory%%helmet04%" "%helmetFolder%%helmet04%"
ECHO f | xcopy /f /y "%skyrimDirectory%%helmet05%" "%helmetFolder%%helmet05%"
ECHO f | xcopy /f /y "%skyrimDirectory%%helmet06%" "%helmetFolder%%helmet06%"
ECHO f | xcopy /f /y "%skyrimDirectory%%helmet07%" "%helmetFolder%%helmet07%"
ECHO f | xcopy /f /y "%skyrimDirectory%%helmet08%" "%helmetFolder%%helmet08%"

ECHO.
ECHO.
ECHO Update Magic
SET magicPlugin=MagicView.esp
SET magic01=Scripts\ScribeMagic_View.pex
ECHO f | xcopy /f /y "%skyrimDirectory%%magicPlugin%" "%magicFolder%%magicPlugin%"
ECHO f | xcopy /f /y "%skyrimDirectory%%magic01%" "%magicFolder%%magic01%"

ECHO.
ECHO.
ECHO Update Sample
SET samplePlugin=SampleView.esp
SET sample01=Scripts\ScribeSample_View.pex
ECHO f | xcopy /f /y "%skyrimDirectory%%samplePlugin%" "%sampleFolder%%samplePlugin%"
ECHO f | xcopy /f /y "%skyrimDirectory%%sample01%" "%sampleFolder%%sample01%"

PAUSE
