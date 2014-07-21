:: Aloha Backup
:: Copyright 2014 Alan Mason
:: 
:: This file is part of Aloha Backup.
:: 
::  Aloha Backup is free software: you can redistribute it and/or modify
::  it under the terms of the GNU General Public License as published by
::  the Free Software Foundation, either version 3 of the License, or
::  (at your option) any later version.
:: 
::  Aloha Backup is distributed in the hope that it will be useful,
::  but WITHOUT ANY WARRANTY; without even the implied warranty of
::  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
::  GNU General Public License for more details.
:: 
::  You should have received a copy of the GNU General Public License
::  along with Aloha Backup.  If not, see <http://www.gnu.org/licenses/>.

@echo off

:Init
setlocal EnableDelayedExpansion
title Aloha Backup
color 1b
pushd %~dp0

:Flags
set silent=
for %%f in (%*) do (
    if /i "%%f" == "/DEBUG" (@echo on)
    if /i "%%f" == "/H" (goto Usage)
    if /i "%%f" == "/HELP" (goto Usage)
    if /i "%%f" == "/S" (set silent=True)
)

: GetMode
set mode=
if /i "%1" == "nightly" (set mode=Nightly)
if /i "%1" == "monthly" (set mode=Monthly)
if /i "%1" == "yearly" (set mode=Yearly)
if /i "%1" == "program" (set mode=Program)
if /i "%1" == "full" (set mode=Full)
if not defined mode (goto Usage)

:GPLStuff
if not defined silent (
    echo Aloha Backup  Copyright ^(C^) 2014  Alan Mason
    echo     This program comes with ABSOLUTELY NO WARRANTY.
    echo     This is free software, and you are welcome to redistribute it
    echo     under certain conditions; see COPYING.txt for details.
    echo.
)

:SetVariables
pushd %~dp0
set pd=%cd%
set backup=Aloha Backups
set warnings=
set month=%date:~4,2%
set day=%date:~7,2%
set year=%date:~10,4%

:FindAloha
for %%d in (c d e f g h i j k l m n o p q r s t u v w x y z) do (
    dir %%d:>nul 2>nul
    if "!errorlevel!" equ "0" (
        if exist "%%d:\AlohaQS\*.*" (
            set src=%%d:\AlohaQS
            goto FindSevenZip
        )
    )
)
goto AlohaNotFound

:FindSevenZip
if exist "7za\7za.exe" (set sevenzip=%pd%\7za\7za.exe)
if exist "%PROGRAMFILES%\7-Zip\7z.exe" (set sevenzip=%PROGRAMFILES%\7-Zip\7z.exe)
if exist "%PROGRAMFILES86%\7-Zip\7z.exe" (set sevenzip=%PROGRAMFILES86%\7-Zip\7z.exe)
if not defined sevenzip goto SevenZipNotFound

:Main
goto %mode%Backup

:FullBackup
title Aloha Backup - Full Backup
if not defined silent (
    echo Aloha - Full Backup
    echo.
    echo This script will make a full backup of the Aloha System.
    echo This will take a long time to complete ^(90-180 minutes^).
    echo NOTE:  The computer might run very slowly during this time.
    echo.
    echo If you wish to abort then please press CTL+C ^(or just close the window^).
    echo.
    echo Press any key to continue... 
    pause>nul
)

set filter= 
set filename=%year%_%month%_%day%.7z
set subdir=Full Backups
goto CompressBackup

:MonthlyBackup
title Aloha Backup - Monthly Backup
if not defined silent (
    echo Aloha - Monthly Backup
    echo.
    echo This script will make a backup of last month's data from the Aloha System.
    echo This will take a some time to complete ^(10-30 minutes^).
    echo NOTE:  The computer might run very slowly during this time.
    echo.
    echo If you wish to abort then please press CTL+C ^(or just close the window^).
    echo.
    echo Press any key to continue... 
    pause>nul
)

rem set date vars to last month
if %month:~0,1% equ 0 (set month=%month:~1%)
set /a month=%month% - 1
if %month% equ 0 (
    set /a year=%year% - 1
    set month=12
)
if %month% lss 10 (
    set month=0%month%
)

rem Set filter = last month
set filter=%year%%month%*
set filename=%year%_%month%.7z
set subdir=Monthly Backups
goto CompressBackup

:NightlyBackup
title Aloha Backup - Nightly Backup
if not defined silent (
    echo Aloha - Nightly Backup
    echo.
    echo This script will make a backup of yesterdays's data from the Aloha System.
    echo This should take under a minute to complete.
    echo.
    echo If you wish to abort then please press CTL+C ^(or just close the window^).
    echo.
    echo Press any key to continue... 
    pause>nul
)

rem set date vars to yesterday
if %day:~0,1% equ 0 (set day=%day:~1%)
if %month:~0,1% equ 0 (set month=%month:~1%)

set /a day=%day% - 1
if %day% equ 0 (
    set /a month=%month% - 1
)

if %month% equ 0 (
    set /a year=%year% - 1
    set month=12
    set day=31
    goto FindSevenZip
)

if %month% lss 10 (
    set month=0%month%
)

if %day% equ 0 (
    if exist "%src%\%year%%month%31\*.*" (
        set day=31
        goto NightlyBackupFilter
    )
    if exist "%src%\%year%%month%30\*.*" (
        set day=30
        goto NightlyBackupFilter
    )
    if exist "%src%\%year%%month%29\*.*" (
        set day=29
        goto NightlyBackupFilter
    )
    if exist "%src%\%year%%month%28\*.*" (
        set day=28
        goto NightlyBackupFilter
    )
)

if %day% lss 10 (
    set day=0%day%
)

if not exist "%src%\%year%%month%%day%\*.*" goto DayNotFound

:NightlyBackupFilter
rem Set filter = yesterday
set filter=%year%%month%%day%
set filename=%year%_%month%_%day%.7z
set subdir=Nightly Backups
goto CompressBackup

:ProgramBackup
title Aloha Backup - Program Backup
if not defined silent (
    echo Aloha - Program Backup
    echo.
    echo This script will make a backup of the Aloha System program files.
    echo This should take only a few minutes to complete.
    echo NOTE:  This will not backup any transaction data.
    echo.
    echo If you wish to abort then please press CTL+C ^(or just close the window^).
    echo.
    echo Press any key to continue... 
    pause>nul
)

rem Set filter to exclude all transaction data
echo 20*> "%tmp%\7z_switch"
set filter=-x^^@"%tmp%\7z_switch"
set filename=%year%_%month%_%day%.7z
set subdir=Program Backups
goto CompressBackup

:YearlyBackup
title Aloha Backup - Yearly Backup
if not defined silent (
    echo Aloha - Yearly Backup
    echo.
    echo This script will make a backup of last year's data from the Aloha System.
    echo This will take a long time to complete ^(30-90 minutes^).
    echo NOTE:  The computer might run very slowly during this time.
    echo.
    echo If you wish to abort then please press CTL+C ^(or just close the window^).
    echo.
    echo Press any key to continue... 
    pause>nul
)

rem set date vars to last month
set /a year=%year% - 1
rem Set filter = last year
set filter=%year%*
set filename=%year%.7z
set subdir=Yearly Backups
goto CompressBackup

:CompressBackup
cd /d "%src%"
"%sevenzip%" a -t7z -mx=9 "%tmp%\%filename%" %filter%
if %errorlevel% equ 255 (goto Abort)
if %errorlevel% geq 2 (goto ErrorFatal)
if %errorlevel% equ 1 (set warnings=True)
goto CopyBackup

:CopyBackup
for %%d in (c d e f g h i j k l m n o p q r s t u v w x y z) do (
    dir %%d:>nul 2>nul
    if "!errorlevel!" equ "0" (
        if exist "%%d:\%backup%\*.*" (
            mkdir "%%d:\%backup%\%subdir%" 2>nul
            copy "%tmp%\%filename%" "%%d:\%backup%\%subdir%\%filename%" /y
        )
    )
)
if defined warnings (goto SevenZipWarning)
goto Done

:Abort
echo.
echo Aborted.
goto Exit

:AlohaNotFound
color 0c
echo.
echo ERROR: AlohaQS not found.
echo This backup script only works with the AlohaQS program.
set silent=
goto Exit

:DayNotFound
color 0c
echo.
echo ERROR: No records found for date: %month%/%day%/%year%.
set silent=
goto Exit

:SevenZipFatalError
color 0c
echo.
echo ERROR: %mode% Backup has failed.
set silent=
goto Exit

:SevenZipNotFound
color 0c
echo.
echo ERROR: 7-Zip not found.
echo Please install 7-Zip and then try again.
set silent=
goto Exit

:SevenZipWarning
color 0c
echo.
echo WARNING: Some files were not backed up.
echo     ^(Try rebooting and running a %mode% Backup again^).
set silent=
goto Exit

:Usage
echo.
echo Usage:
echo   Aloha_Backup.cmd mode [options]
echo   Aloha_Backup.cmd /help
echo.
echo Options:
echo   /h /help     Show this screen.
echo   /s           Silent ^(Suppress messages^).
echo.
echo Modes:
echo    Nightly     Backup yesterday
echo    Monthly     Backup last month
echo    Yearly      Backup last year
echo    Program     Backup program files
echo    Full        Backup everything
goto Done

:Done
echo.
echo Done.
goto Exit

:Exit
rem Cleanup
del /q "%tmp%\%filename%">nul 2>&1
del /q "%tmp%\7z_switch">nul 2>&1

if not defined silent (
    echo.
    echo Press any key to exit...
    pause>nul
)
popd
color
endlocal
title %cd%