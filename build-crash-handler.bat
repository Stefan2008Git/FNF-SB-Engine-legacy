@echo off

cd crashHandler
echo Building crash dialog...
haxelib run lime build windows
copy build\openfl\windows\bin\SBCrashHandler.exe ..\export\release\windows\bin\SBCrashHandler.exe
cd ..

@echo on