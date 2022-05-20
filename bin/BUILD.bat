@echo off
title [BUILD] Ubuntu Repository Cloner
echo Building Ubuntu Repository Cloner...
cd ..

docker build -t ubunturepo:latest .

if %errorlevel% NEQ 0 (
	echo.
	echo [ERROR] Container did not build successfully.
) else (
	echo.
	echo [SUCCESS] Container was successfully built.
)

pause
