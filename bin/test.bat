@echo off
title [TEST] Ubuntu Repository Cloner
set scriptdir=%~dp0

docker run -it --rm  ^
	--net repo-net ^
	--name repo_test ^
	-v %scriptdir%/../resources/sources.list:/etc/apt/sources.list:ro ^
	ubuntu:22.04 /bin/bash
