@echo off
:: ============================================================================
:: Wi-Fi_Optimization.bat - Practical Wi-Fi Tweaks for Windows
:: Author: Oblivion
:: Description: Applies network optimizations to improve Wi-Fi performance (maybe).
:: ============================================================================
:: Ensure admin privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] This script must be run as Administrator. (Because Windows *really* trusts you.)
    pause
    exit /b
)

:: Detect Wi-Fi adapter name
for /f "tokens=2 delims=:" %%i in ('netsh wlan show interfaces ^| findstr /c:"Name"') do set wifi_iface=%%i
set wifi_iface=%wifi_iface:~1%
if "%wifi_iface%"=="" (
    echo [ERROR] Could not detect Wi-Fi interface. (Guess you'll have to use Ethernet... *gasp*)
    pause
    exit /b
)

:: Show current interface details
echo [INFO] Displaying current Wi-Fi interface status... (Get ready for a wall of text!)
netsh wlan show interfaces
echo.

:: Reset adapter
echo [INFO] Restarting Wi-Fi adapter (%wifi_iface%)... (The classic "did you try turning it off and on again?")
netsh interface set interface "%wifi_iface%" admin=disable
timeout /t 5 >nul
netsh interface set interface "%wifi_iface%" admin=enable
echo.

:: Disable power saving for performance (requires manual adapter config for full effect)
echo [INFO] Disabling TCP/IP power throttling... (Because who needs battery life when you have *speed*?)
powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 100
powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTROTTLEMAX 100
powercfg -setactive SCHEME_CURRENT
echo.

:: Set Google DNS
echo [INFO] Setting Google DNS on %wifi_iface%... (Goodbye, ISP DNS! Hello, actual speed.)
netsh interface ip set dns "%wifi_iface%" static 8.8.8.8
netsh interface ip add dns "%wifi_iface%" 8.8.4.4 index=2
echo.

:: Disable TCP autotuning and LSO
echo [INFO] Disabling TCP autotuning and large offload features... (Because "auto" doesn't always mean "good".)
netsh interface tcp set global autotuning=disabled
netsh interface tcp set global chimney=disabled
netsh interface tcp set global rss=disabled
echo.

:: Set MTU to 1500
echo [INFO] Setting MTU to 1500... (The internet standard, unless your network is...special.)
netsh interface ipv4 set subinterface "%wifi_iface%" mtu=1500 store=persistent
echo.

:: Display suggestions for manual router tuning
echo [NOTE] For optimal performance: (Things your router should already be doing...)
echo   - Use Wi-Fi channel 1, 6, or 11 on 2.4GHz
echo   - Use channels 36-48 or 149+ on 5GHz
echo   - Use WPA2/WPA3 security and disable legacy modes (802.11b/g)
echo.

:: Show final status
echo [INFO] Verifying current interface status... (Just to be sure we didn't break anything... hopefully.)
netsh wlan show interfaces
echo.

echo [DONE] Wi-Fi optimization complete. Restart recommended. (And pray to the Wi-Fi gods that it actually helped.)
pause
