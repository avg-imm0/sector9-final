@echo off
setlocal
cd /d "%~dp0"

set "GODOT=%LOCALAPPDATA%\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64.exe"

if not exist "%GODOT%" (
    echo [Sector 9] Godot 4.7.2 not found.
    echo Expected: %GODOT%
    pause
    exit /b 1
)

start "" "%GODOT%" --editor --path "%CD%"
