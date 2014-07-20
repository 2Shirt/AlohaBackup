:: Aloha Backup
:: Copyright 2013 Alan Mason
:: 
:: This program is free software: you can redistribute it and/or modify
:: it under the terms of the GNU General Public License as published by
:: the Free Software Foundation, either version 3 of the License, or
:: (at your option) any later version.
:: 
:: This program is distributed in the hope that it will be useful,
:: but WITHOUT ANY WARRANTY; without even the implied warranty of
:: MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
:: GNU General Public License for more details.
:: 
:: You should have received a copy of the GNU General Public License
:: along with this program.  If not, see <http://www.gnu.org/licenses/>.

@echo off
Setlocal EnableDelayedExpansion

:GPLStuff
cls
title Aloha - Backup
color 1b
echo Aloha Backup  Copyright (C) 2013  Alan Mason
echo     This program comes with ABSOLUTELY NO WARRANTY.
echo     This is free software, and you are welcome to redistribute it
echo     under certain conditions; see COPYING.txt for details.

:Flags
set silent=
for %%f in (%*) do (
    if /i "%%f" == "/DEBUG" (@echo on)
    if /i "%%f" == "/S" (set silent=True)
)

:SetVariables
pushd %~dp0
set pd=%cd%
set backup=Aloha Backups
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
rem Not found
goto AlohaNotFound

:FindSevenZip
if exist "7za\7za.exe" (set sevenzip=%pd%\7za\7za.exe)
if exist "%PROGRAMFILES%\7-Zip\7z.exe" (set sevenzip=%PROGRAMFILES%\7-Zip\7z.exe)
if not defined sevenzip goto SevenZipNotFound

:GetMode
if /i "%1" == "nightly" goto Nightly
if /i "%1" == "weekly" goto Weekly
if /i "%1" == "monthly" goto Monthly
if /i "%1" == "yearly" goto Yearly
if /i "%1" == "full" goto Full
rem else
goto Usage

:Full
title Aloha - Full Backup
rem Warn user
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

rem Set filter = " " (set but empty)
set filter= 
set filename=%year%_%month%_%day%.7z
set subdir=Full Backups
goto CompressBackup

:Monthly
title Aloha - Monthly Backup
rem Warn user
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

:Nightly
title Aloha - Nightly Backup
rem Warn user
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
        goto NightlyFilter
    )
    if exist "%src%\%year%%month%30\*.*" (
        set day=30
        goto NightlyFilter
    )
    if exist "%src%\%year%%month%29\*.*" (
        set day=29
        goto NightlyFilter
    )
    if exist "%src%\%year%%month%28\*.*" (
        set day=28
        goto NightlyFilter
    )
)

if %day% lss 10 (
    set day=0%day%
)

if not exist "%src%\%year%%month%%day%\*.*" goto DayNotFound

:NightlyFilter
rem Set filter = yesterday
set filter=%year%%month%%day%
set filename=%year%_%month%_%day%.7z
set subdir=Nightly Backups
goto CompressBackup

:Weekly
title Aloha - Weekly Backup
rem Warn user
if not defined silent (
    echo Aloha - Weekly Backup
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

rem Set filter = 7-Zip switch to exclude all transaction data
echo 20*> "%tmp%\7z_switch"
set filter=-x^^@"%tmp%\7z_switch"
set filename=%year%_%month%_%day%.7z
set subdir=Program Backups
goto CompressBackup

:Yearly
title Aloha - Yearly Backup
rem Warn user
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

:Cleanup
del /q "%tmp%\%filename%"
del /q "%tmp%\7z_switch"
goto End

:AlohaNotFound
cls
color 0c
echo Aloha not found^^!
echo This backup script only works with the AlohaQS program.
goto End

:DayNotFound
cls
color 0c
echo No records found for date: %month%/%day%/%year%^^!
echo Skipping nightly backup.
goto End

:SevenZipNotFound
cls
color 0c
echo 7-Zip not found^^!
echo Please install 7-Zip and then try again.
goto End

:Usage
echo.
echo Usage: Aloha_Backup.cmd ^<mode^> ^(/s^)
echo.
echo Modes: Nightly ^(Backup yesterday^)
echo        Weekly  ^(Backup program files^)
echo        Monthly ^(Backup last month^)
echo        Yearly  ^(Backup last year^)
echo        Full    ^(Backup everything^)
echo /s     Suppress warnings
goto End

:End
if defined silent goto Done
echo.
echo Press any key to exit... 
pause>nul

:Done
popd
endlocal
color
