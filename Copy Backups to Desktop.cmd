:: Aloha Backups - Copy to Desktop
:: Copyright 2014 Alan Mason
:: 
:: This file is part of Aloha Backups.
:: 
::  Aloha Backups is free software: you can redistribute it and/or modify
::  it under the terms of the GNU General Public License as published by
::  the Free Software Foundation, either version 3 of the License, or
::  (at your option) any later version.
:: 
::  Aloha Backups is distributed in the hope that it will be useful,
::  but WITHOUT ANY WARRANTY; without even the implied warranty of
::  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
::  GNU General Public License for more details.
:: 
::  You should have received a copy of the GNU General Public License
::  along with Aloha Backups.  If not, see <http://www.gnu.org/licenses/>.

@echo off

:Init
setlocal EnableDelayedExpansion
title Aloha Backups - Copy to Desktop
color 1b
pushd %~dp0

:GPLStuff
echo Aloha Backups  Copyright (C) 2014  Alan Mason
echo     This program comes with ABSOLUTELY NO WARRANTY.
echo     This is free software, and you are welcome to redistribute it
echo     under certain conditions; see COPYING.txt for details.
echo.

:Flags
for %%f in (%*) do (
    if /i "%%f" == "/DEBUG" (@echo on)
)

:Main
mkdir "%USERPROFILE%\Desktop\Aloha Backups">nul 2>&1
robocopy . . /L>nul 2>&1
if %errorlevel% equ 9009 (goto Xcopy)
goto Robocopy

:Robocopy
robocopy "Aloha Backups" "%USERPROFILE%\Desktop\Aloha Backups" /e /r:3 /w:10
if %errorlevel% geq 16 (goto SeriousError)
if %errorlevel% geq 8 (goto IncompleteCopy)
goto Done

:Xcopy
xcopy "Aloha Backups" "%USERPROFILE%\Desktop\Aloha Backups" /e /c /h /r /y
if %errorlevel% equ 5 (goto WriteError)
if %errorlevel% equ 2 (goto Abort)
if %errorlevel% geq 1 (goto SeriousError)
goto Done

:IncompleteCopy
color 0c
echo.
echo ERROR: Some files or directories could not be copied.
goto Exit

:SeriousError
color 0c
echo.
echo ERROR: Could not copy any files.
goto Exit

:WriteError
color 0c
echo.
echo ERROR: Disk write error occurred.
goto Exit

:Abort
echo.
echo Aborted.
goto Exit

:Done
echo.
echo Done.
goto Exit

:Exit
echo.
echo Press any key to exit...
pause>nul
popd
color
endlocal
title %cd%