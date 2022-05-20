@echo off
title [SERVE] Ubuntu Repository Cloner

set scriptdir=%~dp0

echo Serving patches via Aptly...

docker network create repo-net

docker run -it --rm ^
	--name repo_clone ^
	--net repo-net ^
	-v %scriptdir%/../repo:/root/.aptly/:rw ^
	-v %scriptdir%/../resources/packages.txt:/packages.txt:ro ^
	-p 8080:8080 ubunturepo aptly serve

pause
