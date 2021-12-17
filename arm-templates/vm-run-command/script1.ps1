New-Item -Path C:\test -ItemType Directory -ea SilentlyContinue
"$(get-date -format s) - before reboot" | Add-Content -Path C:\test\test.txt
Restart-Computer -Force
