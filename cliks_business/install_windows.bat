@echo off
echo ====================================================
echo       Cliks Business Windows App Installer
echo ====================================================
echo.

set INSTALL_DIR=%LOCALAPPDATA%\Programs\Cliks Business
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

echo [1/3] Copying application files and plugins...
xcopy /E /I /Y "build\windows\x64\runner\Release\*" "%INSTALL_DIR%\" >nul

echo [2/3] Registering Windows environment PATH...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$userPath = [System.Environment]::GetEnvironmentVariable('Path', [System.EnvironmentVariableTarget]::User); if ($userPath -notlike '*%INSTALL_DIR%*') { [System.Environment]::SetEnvironmentVariable('Path', \"$userPath;%INSTALL_DIR%\", [System.EnvironmentVariableTarget]::User) }"

echo [3/3] Creating Desktop and Start Menu shortcuts...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$WshShell = New-Object -ComObject WScript.Shell; $desktop = [System.Environment]::GetFolderPath('Desktop'); $s = $WshShell.CreateShortcut(\"$desktop\Cliks Business.lnk\"); $s.TargetPath = \"$env:LOCALAPPDATA\Programs\Cliks Business\Cliks Business.exe\"; $s.WorkingDirectory = \"$env:LOCALAPPDATA\Programs\Cliks Business\"; $s.IconLocation = \"$env:LOCALAPPDATA\Programs\Cliks Business\Cliks Business.exe,0\"; $s.Save(); $start = [System.Environment]::GetFolderPath('Programs'); $sm = $WshShell.CreateShortcut(\"$start\Cliks Business.lnk\"); $sm.TargetPath = \"$env:LOCALAPPDATA\Programs\Cliks Business\Cliks Business.exe\"; $sm.WorkingDirectory = \"$env:LOCALAPPDATA\Programs\Cliks Business\"; $sm.IconLocation = \"$env:LOCALAPPDATA\Programs\Cliks Business\Cliks Business.exe,0\"; $sm.Save();"

echo.
echo ====================================================
echo  SUCCESS! Cliks Business installed successfully.
echo  You can now launch the app from your Desktop.
echo ====================================================
echo.
pause

