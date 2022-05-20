@echo off
title [SYNC] Ubuntu Repository Cloner
set scriptdir=%~dp0

echo Performing repository synchronization...

docker network create repo-net

docker run -it --rm ^
	--name repo_clone ^
	--net repo-net ^
	-v %scriptdir%/../repo:/root/.aptly/:rw ^
	-v %scriptdir%/../resources/packages.txt:/packages.txt:ro ^
	ubunturepo /sync.sh

if %errorlevel% NEQ 0 (
	echo.
	echo [ERROR] Synchronization encountered an error.
) else (
	echo.
	echo [SUCCESS] Synchronization complete.
)

pause
