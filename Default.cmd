@echo off
set timestamp=%DATE:/=-%_%TIME::=-%
set timestamp=%timestamp: =%
@powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Win10.ps1" -include "%~dp0Win10.psm1" -preset "%~dpn0.preset" -log alyx-log_%timestamp%.txt