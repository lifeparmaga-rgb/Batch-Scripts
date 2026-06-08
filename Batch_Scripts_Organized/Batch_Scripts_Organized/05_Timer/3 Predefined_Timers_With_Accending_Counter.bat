:: ==============================
:: العد للأمام بعد المؤقت الثالث
:: ==============================
set OVER_SECONDS=0
:OVERRUN_LOOP
set /a OVER_MINS=OVER_SECONDS/60
set /a OVER_SECS=OVER_SECONDS%%60
cls
echo ================================
echo         THIRD TIMER
echo ================================
echo.
if !OVER_SECS! LSS 10 (
    echo Time: !OVER_MINS!:0!OVER_SECS!
) else (
    echo Time: !OVER_MINS!:!OVER_SECS!
)
echo.
echo [Press ENTER to go to next cycle]

:: فحص إذا في ضغطة على الكيبورد
powershell -command "if ([Console]::KeyAvailable) { $k=[Console]::ReadKey($true); if ($k.Key -eq 'Enter') { exit 0 } else { exit 1 } } else { exit 1 }" >nul 2>&1
if !errorlevel! EQU 0 goto OVERRUN_DONE

set /a OVER_SECONDS+=1
timeout /t 1 /nobreak >nul
goto OVERRUN_LOOP
:OVERRUN_DONE
echo.
echo All Timers Finished!
goto START