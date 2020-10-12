@echo off
setlocal enabledelayedexpansion

REM Definitions
SET project_path=%~dp0
SET tool_path=%project_path%tools/
SET ca65="%tool_path%ca65.exe"
SET ld65="%tool_path%ld65.exe"
SET source_path=%project_path%src
SET memory_map=_memory_map.cfg
SET memory_map_path=%source_path%\%memory_map%
SET object_path=%project_path%build\obj
SET binaries_path=%project_path%build\bin
SET rom=Venture Below.smc
SET rom_path=%binaries_path%\%rom%
SET data_path=%project_path%data

REM Jump to the relevant recipe based on what input was given
IF /i "%1"=="help" GOTO HELP
IF /i "%1"=="clean" GOTO CLEAN
REM Default behaviour is to just make the ROM file
GOTO MAKEROM

:HELP
REM Give info about how to use this file
ECHO Usage Instructions:
ECHO win-make [command]
ECHO Command Options: (default 'make')
ECHO help  - displays this message
ECHO clean - removes file generated from build
ECHO make  - build '%rom%'
GOTO END

:CLEAN
REM Remove all files generated from making the ROM file
ECHO Starting Cleaning...
IF EXIST "%object_path%" DEL /f /q "%object_path%"
IF EXIST "%object_path%" DEL /f /q "%binaries_path%"
ECHO Cleaning Complete!
GOTO END

:MAKEROM
REM Compile all assembly files into object files
ECHO Starting Code Compilation...
REM Create build directories if they don't already exist
IF NOT EXIST "%object_path%" (
	ECHO No object directory exists - one will be created
	md "%object_path%"
)
IF NOT EXIST "%binaries_path%" (
	ECHO No binaries directory exists - one will be created
	md "%binaries_path%"
)

FOR /f "delims=" %%f IN ('dir /b "%source_path%\*.s"') DO (
	SET source_file=%%f
	SET source_file_path=%source_path%\!source_file!
	SET object_file=!source_file:.s=.o!
	SET object_file_path=%object_path%\!object_file!
	
	ECHO - Compiling '!source_file!' into '!object_file!'
	START "CA65" /w /b %ca65% --cpu 65816 -s -o "!object_file_path!" "!source_file_path!"
)
ECHO Code Compilation Done
ECHO.

REM Compile all data files into object files
ECHO Starting Data Compilation...
REM Create a data directory if one doesn't already exist
IF NOT EXIST "%data_path%" (
	ECHO No data directory exists - one will be created
	md "%data_path%"
)

FOR /f "delims=" %%f IN ('dir /b "%data_path%\*.s"') DO (
	SET data_file=%%f
	SET data_file_path=%data_path%\!data_file!
	SET object_file=!data_file:.s=.o!
	SET object_file_path=%object_path%\!object_file!
	
	ECHO - Compiling '!data_file!' into '!object_file!'
	START "CA65" /w /b %ca65% --cpu 65816 -s -o "!object_file_path!" "!data_file_path!"
)
ECHO Data Compilation Done
ECHO.

REM Link all the object files and load them together into a 'ROM' file
ECHO Starting Linking...
ECHO - Using '%memory_map%' as the memory map

REM Make a list of all object files to link
FOR /f "delims=" %%f IN ('dir /b "%object_path%\*.o"') DO (
	SET object_file=%%f
	SET object_file_path=%object_path%\!object_file!
	SET object_file_list=!object_file_list! "!object_file_path!"
	
	ECHO - Using '!object_file!'
)
START "LD65" /w /b %ld65% -C "%memory_map_path%" -o "%rom_path%" !object_file_list!

ECHO Linking Done
ECHO.
ECHO If all went well, you should now have '%rom%' in '%binaries_path%'
GOTO END

:END
