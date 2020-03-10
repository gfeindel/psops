REM Uninstalls CCM once and drops a control file so it does not run again.

IF NOT EXIST "%TEMP%\ccm.dat" (
    cd %WINDIR%\ccmsetup
    ccmsetup.exe /Uninstall
    echo >"%WINDIR%\Temp\ccm.dat"
)