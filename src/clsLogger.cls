VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "clsLogger"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit
Private nowRecordTime As Long, thisLogIndex As String, loggerOption As Long
Private FSOLog As Object
Private Target As clsFile
Private Sub Class_Initialize()
    Set FSOLog = CreateObject("Scripting.FileSystemObject")
    Set Target = New clsFile
    thisLogIndex = getLogNowIndex
    Dim nowRecordTime As Long
    nowRecordTime = Val(GetInfo("Main\Setting\MainCoreSetting", "recordNum"))
    nowRecordTime = nowRecordTime + 1
    SetInfo CStr(nowRecordTime), "Main\Setting\MainCoreSetting", "recordNum"
    setAppVersion
    Dim tmp As String
    tmp = GetInfo("Main\Setting\MainCoreSetting", "loggerActive")
    Select Case tmp
        Case "active": loggerOption = 2
        Case "logError": loggerOption = 1
        Case Else: loggerOption = 0
    End Select
    Target.Init "log", Format(Now, "YYYYMMDD_hhmmss") & thisLogIndex, "txt"
End Sub
Public Static Sub SetLoggerOption(rank As Long)
    loggerOption = rank
End Sub
Public Static Sub setLogNowIndex(nowIndex As String)
    thisLogIndex = nowIndex
    SetInfo nowIndex, "Main\Setting\CoreSetting", "LogIndex"
End Sub
Public Static Function getLogNowIndex() As String
    getLogNowIndex = GetInfo("Main\Setting\CoreSetting", "LogIndex")
End Function
Public Static Sub setRunTime()
    SetInfo CStr(Now), "Main\Setting\MainCoreSetting\runTime", "run:" & nowRecordTime
    LogInfo "startMainThread"
End Sub
Public Static Sub setCloseTime()
    SetInfo CStr(Now), "Main\Setting\MainCoreSetting\closeTime", "close:" & nowRecordTime
    LogInfo "terminateMainThread"
End Sub
Private Static Sub setAppVersion()
    SetInfo app.Version, "Main\Setting\MainCoreSetting\version", "version:" & nowRecordTime
    LogInfo "mainThreadVersion:" & app.Version
End Sub
Public Static Function LogInfo(ByVal strInfo As String, Optional ByVal logRank As Long) As Boolean
    If loggerOption < 2 Then Exit Function
    Dim FileHandle As Long
    Dim strTxtName As String        '     '
    On Error GoTo WriteLogFileErr:
    LogInfo = True
    FileHandle = FreeFile
    Open Target.GetFileFullPath For Append As #FileHandle
    Lock #FileHandle
        Print #FileHandle, Space(logRank * 2) & Format(Time, "HH:MM:SS") & " :" & strInfo
    Unlock #FileHandle
    Close #FileHandle
    Exit Function

WriteLogFileErr:
        LogInfo = False
End Function


Public Static Function WriteErrLog(ByVal strErrLog As String, Optional ByVal strErrNumber As String, Optional ByVal strErrDesc As String) As Boolean
    Dim FileHandle As Long
    Dim strTxtName As String        '
           '
    If loggerOption = 0 Then Exit Function
    On Error GoTo WriteLogFileErr:
    FileHandle = FreeFile
    Open Target.GetFileFullPath For Append As #FileHandle
    Lock #FileHandle
        Print #FileHandle, "Date & Time: " & Format(Time, "HH:MM:SS")
        Print #FileHandle, "Error Number: " & strErrNumber
        Print #FileHandle, "Error Desc: " & strErrDesc
        Print #FileHandle, "Log: " & strErrLog
        Print #FileHandle, vbNewLine
    Unlock #FileHandle
    Close #FileHandle
    Exit Function

WriteLogFileErr:
        WriteErrLog = False
End Function

