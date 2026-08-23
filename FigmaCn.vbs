' FigmaCn.vbs
' Minimalist startup script: only launches the proxy and cleans old versions. No shortcut hooking.
Set objShell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

currentDir = fso.GetParentFolderName(WScript.ScriptFullName)
exePath = currentDir & "\mitmdump.exe"
scriptPath = currentDir & "\figma_zh_cn.py"

Set objWMIService = GetObject("winmgmts:\\.\root\cimv2")

' ==========================================
' 0. Cleanup old background processes
' ==========================================
' Kill old mitmdump to prevent port conflicts
Set colProcessList = objWMIService.ExecQuery("Select * from Win32_Process Where Name = 'mitmdump.exe'")
For Each proc in colProcessList
    proc.Terminate()
Next
WScript.Sleep 500

' ==========================================
' 1. Start mitmdump proxy
' ==========================================
Set objStartup = objWMIService.Get("Win32_ProcessStartup")
Set objConfig = objStartup.SpawnInstance_
objConfig.ShowWindow = 0 
Set objProcess = GetObject("winmgmts:\\.\root\cimv2:Win32_Process")

strCommand = "cmd.exe /c """"" & exePath & """ -s """ & scriptPath & """ -p 8089 -q"""
errReturn = objProcess.Create(strCommand, currentDir, objConfig, intProcessID)

' ==========================================
' 2. Cleanup old Figma version folders
' ==========================================
localAppData = objShell.ExpandEnvironmentStrings("%LOCALAPPDATA%")
figmaDir = localAppData & "\Figma"

Function IsVersionGreater(v1, v2)
    If v2 = "" Then
        IsVersionGreater = True
        Exit Function
    End If
    str1 = Replace(LCase(v1), "app-", "")
    str2 = Replace(LCase(v2), "app-", "")
    arr1 = Split(str1, ".")
    arr2 = Split(str2, ".")
    maxLen = UBound(arr1)
    If UBound(arr2) > maxLen Then maxLen = UBound(arr2)
    For i = 0 To maxLen
        num1 = 0: num2 = 0
        If i <= UBound(arr1) Then num1 = CInt(arr1(i))
        If i <= UBound(arr2) Then num2 = CInt(arr2(i))
        If num1 > num2 Then
            IsVersionGreater = True
            Exit Function
        ElseIf num1 < num2 Then
            IsVersionGreater = False
            Exit Function
        End If
    Next
    IsVersionGreater = False
End Function

If fso.FolderExists(figmaDir) Then
    Set folder = fso.GetFolder(figmaDir)
    latestAppFolder = ""
    For Each subFolder In folder.SubFolders
        If LCase(Left(subFolder.Name, 4)) = "app-" Then
            If IsVersionGreater(subFolder.Name, latestAppFolder) Then
                latestAppFolder = subFolder.Name
            End If
        End If
    Next
    If latestAppFolder <> "" Then
        For Each subFolder In folder.SubFolders
            If LCase(Left(subFolder.Name, 4)) = "app-" And subFolder.Name <> latestAppFolder Then
                On Error Resume Next
                fso.DeleteFolder subFolder.Path, True
                On Error GoTo 0
            End If
        Next
    End If
End If

' Script finishes execution immediately. Zero resident memory.
