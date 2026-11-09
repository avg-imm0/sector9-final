@echo off
setlocal
cd /d "%~dp0"

rem Preferred: Godot 4.7.2 installed through winget.
set "GODOT=%LOCALAPPDATA%\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64.exe"
if exist "%GODOT%" goto :run

rem Fallback: portable build in Program Files (works with 4.x).
if exist "C:\Program Files\Godot_v4.4.1-stable\Godot_v4.4.1-stable_win64.exe" (
    set "GODOT=C:\Program Files\Godot_v4.4.1-stable\Godot_v4.4.1-stable_win64.exe"
    goto :run
)

rem Last resort: anything called godot on PATH.
for /f "delims=" %%G in ('where godot 2^>nul') do (
    set "GODOT=%%G"
    goto :run
)

echo [Sector 9] Godot not found.
echo Install it with: winget install GodotEngine.GodotEngine
echo Or put any Godot 4.x executable on PATH.
pause
exit /b 1

:run
start "" "%GODOT%" --path "%CD%"
