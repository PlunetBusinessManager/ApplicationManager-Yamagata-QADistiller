@echo off
:: SET UTF-8 encoding for special characters
chcp 65001

:: SET the CustomerFolder for the settings - the following folder can be customized
SET settingsfolder=QASettings

:: GET Paramater from the Call for the output folder (!_IN) (standard first parameter)
SET OutputFolder=%1
:: GET Parameter for the CustomerFolder
SET CustomerID=%2
:: GET Parameter for the Job Number
SET JobNo=%3

:: Calculate the actual folder based on flag [CustomerID] as second parameter
SET uncmainhelper=%~dp0
SET uncmain=%uncmainhelper:~0,-4%

SET Customerhelper=customer\%CustomerID:~1,-1%\%settingsfolder%
SET CustomerFolder=%uncmain%%Customerhelper%

::prepare the configfile
SET configfile=%OutputFolder%\%JobNo:~1,-1%.qadbatch

::set the folder where the original files are
SET InputFolder=%OutputFolder:!_In=!_Out%

:: this is for running the command
SET myFile=%configfile:"=%

:: Create the qadbatch configuration file
ECHO [qadbatch] > %configfile%
:: empty line for better reading
ECHO( >> %configfile%

:: Set the project folder - might have to be adjusted (Userlists Folder for Customer)
ECHO ProjectPath=%CustomerFolder%>> %configfile%
:: empty line for better reading
ECHO(>> %configfile%

::set the source files to check (may be ttx or xliff)
for %%i in (%Inputfolder%\*.ttx) do (ECHO InputFile=%%~di%%~pi%%~ni%%~xi)>> %configfile%
ECHO( >> %configfile%
for %%i in (%Inputfolder%\*.xliff) do (ECHO InputFile=%%~di%%~pi%%~ni%%~xi)>> %configfile%
ECHO( >> %configfile%
for %%i in (%Inputfolder%\*.sdlxliff) do (ECHO InputFile=%%~di%%~pi%%~ni%%~xi)>> %configfile%
ECHO( >> %configfile%
:: set the dictionary files if there are any in the Out Folder
for %%i in (%Inputfolder%\*.dict) do (ECHO DictionaryFile=%%~di%%~pi%%~ni%%~xi)>> %configfile%
ECHO( >> %configfile%

:: set the other configs
(ECHO OutputFormats=HTML,XML,PLAIN,CSV
 ECHO OutputContent=FULL,FULL,FULL,FULL
 ECHO ShowProgress=0)>>%configfile%

:: Call the Program
"%ProgramFiles(x86)%\Yamagata\QADistiller9\qadistiller.exe" --batch="%myFile%"


::Create a subfolder for the results
SET LookForFile="%OutputFolder%\%JobNo:~1,-1%.qadresult"

:: Look if the file exists
:CheckForFile
IF EXIST %LookForFile% GOTO FoundIt
:: if we get here we havent found the file yet
ping -n 10 127.0.0.1 >NUL
GOTO CheckForFile

:FoundIt
:: find error value in csv file // total genuine errors
for /F "delims=" %%a in ('find "Total" %OutputFolder%\%JobNo:~1,-1%.csv') do set "TotalOccurrences=%%a"
for %%i in (%TotalOccurrences%) do set "TotalValue=%%i"

:: create subfolder for detailed results and push files around for cleanup
md %OutputFolder%\QAResults
move /Y %OutputFolder%\*.* %OutputFolder%\QAResults\
copy %InputFolder%\*.* %OutputFolder%\
move /Y %OutputFolder%\QAResults\*.html %OutputFolder%\


:: write number of errors into result file
echo %TotalValue% > %OutputFolder%\result.txt
