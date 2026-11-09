@echo off
setlocal
cd /d "%~dp0"

rem Preferred: Godot 4.7.2 installed through winget.
set "GODOT=%LOCALAPPDATA%\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64_console.exe"
if exist "%GODOT%" goto :run

rem Fallback: console build in Program Files.
if exist "C:\Program Files\Godot_v4.4.1-stable\Godot_v4.4.1-stable_win64_console.exe" (
    set "GODOT=C:\Program Files\Godot_v4.4.1-stable\Godot_v4.4.1-stable_win64_console.exe"
    goto :run
)

echo [Sector 9] Godot console executable not found.
echo Expected: %LOCALAPPDATA%\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64_console.exe
echo Or: C:\Program Files\Godot_v4.4.1-stable\Godot_v4.4.1-stable_win64_console.exe
pause
exit /b 1

:run
echo [Sector 9] Starting Godot with console output...
"%GODOT%" --path "%CD%"

echo.
echo [Sector 9] Game exited with code %ERRORLEVEL%.
pause
