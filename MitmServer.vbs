' StartServer.vbs
Set objShell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

currentDir = fso.GetParentFolderName(WScript.ScriptFullName)
pyScript = currentDir & "\run_mitmdump.py"

Set objWMIService = GetObject("winmgmts:\\.\root\cimv2")
Set objStartup = objWMIService.Get("Win32_ProcessStartup")
Set objConfig = objStartup.SpawnInstance_
objConfig.ShowWindow = 0 

Set objProcess = GetObject("winmgmts:\\.\root\cimv2:Win32_Process")
strCommand = "cmd.exe /c python.exe """ & pyScript & """"
errReturn = objProcess.Create(strCommand, currentDir, objConfig, intProcessID)
