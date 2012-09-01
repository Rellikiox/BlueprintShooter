@REM ------- BEGIN build.bat ----------------
@setlocal
@echo off
set path="%ProgramFiles(x86)%\LOVE\";%path%
set path="%ProgramFiles%\WinRAR";%path%

winrar.exe a -afzip -m5 -ed -r -ep1 lovegame-src.zip source\*

ren lovegame-src.zip lovegame-src.love

rem C:\games\LOVE\0.8.0\love.exe --console lovegame-src.love

rem love --console lovegame-src.love

rem ren lovegame-src.love lovegame-src.zip

del lovegame-src.zip

copy /b "release\love.exe"+lovegame-src.love game.exe

winrar.exe a -afzip -m5 -ed -r -ep1 release_files.zip game.exe release/DevIL.dll release/OpenAL32.dll release/SDL.dll

del game.exe

REM ------- END build.bat ------------------