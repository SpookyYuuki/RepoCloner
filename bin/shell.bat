@echo off
title [SHELL] Ubuntu Repository Cloner

set scriptdir=%~dp0

docker network create repo-net

docker run -it --rm ^
	--name repo_clone ^
	--net repo-net ^
	-v %scriptdir%/../repo:/root/.aptly/:rw ^
	-v %scriptdir%/../resources/packages.txt:/packages.txt:ro ^
	ubunturepo /bin/bash
