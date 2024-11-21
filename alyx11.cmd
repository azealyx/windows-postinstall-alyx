@echo off
set timestamp=%DATE:/=-%_%TIME::=-%
set timestamp=%timestamp: =%
@powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0postinst-alyx.ps1" -include "%~dp0postinst-alyx.psm1" -preset "%~dpn0.preset" -log "%~dp0\logs\alyx-log_%timestamp%.txt"