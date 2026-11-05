@echo off
setlocal
cd /d "%~dp0"

set "GODOT=%LOCALAPPDATA%\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64_console.exe"

if not exist "%GODOT%" (
    echo [Sector 9] Godot 4.7.2 console executable not found.
    echo Expected: %GODOT%
    pause
    exit /b 1
)

echo [Sector 9] Starting Godot with console output...
"%GODOT%" --path "%CD%"

echo.
echo [Sector 9] Game exited with code %ERRORLEVEL%.
pause
