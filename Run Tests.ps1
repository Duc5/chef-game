$ErrorActionPreference = 'Stop'
$godotExecutable = 'C:\Users\Dell\Desktop\Godot_v4.7.2-stable_win64.exe'
$process = Start-Process -FilePath $godotExecutable -ArgumentList @('--headless', '--fixed-fps', '60', '--path', ('"' + $PSScriptRoot + '"'), 'res://tests/integration.tscn') -WindowStyle Hidden -PassThru -Wait
exit $process.ExitCode
