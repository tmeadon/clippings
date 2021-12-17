"$(get-date -format s) - after reboot - last bootup time $((gcim Win32_OperatingSystem).LastBootUpTime)" | Add-Content -Path C:\test\test.txt
