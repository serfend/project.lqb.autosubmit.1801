VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "clsFile"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Private thisPath As String, thisFileType As String
Private thisFileName As String, thisContent As String, thisData() As Byte
Private thisFileNum As Long
Public Property Get path() As String
    thisPath = SciFilePath(path)
End Property
Public Property Let path(value As String)
    thisPath = SciFilePath(value)
End Property
Public Property Get fileName() As String
    fileName = thisFileName
End Property
Public Property Let fileName(value As String)
    thisFileName = SciFilePath(value)
    thisFileName = Replace(thisFileName, "\", ".") '文件名不允许出现路径
    If Len(thisFileName) > 32 Then thisFileName = Left(thisFileName, 32)
End Property
Public Property Get content() As String
    content = thisContent
End Property
Public Property Let content(value As String)
    thisContent = value
End Property
Public Property Get data() As Byte()
    data = thisData
End Property
Public Property Let data(value() As Byte)
    thisData = value
End Property
Public Sub Init(filePath As String, fileNames As String, fileType As String, Optional saveNow As Boolean = False)
    
    thisContent = content
    thisFileType = fileType
    path = filePath
    fileName = fileNames
    
    CreatePath thisPath

    If saveNow Then Save
End Sub
Public Sub Show()
On Error GoTo Err:
    Shell "explorer.exe " & Me.GetFileFullPath, vbNormalFocus
    Exit Sub
Err:
    MsgBox "打开文件失败:" & Err.Description
End Sub
Public Property Get Exist() As Boolean
    Exist = Dir(GetFileFullPath, vbNormal) <> ""
End Property
Public Function OpenFile() As Boolean
    On Error GoTo Err:
        If Not Exist Then Exit Function
        thisFileNum = getFreeFileNum
        Open Me.GetFileFullPath For Input As #thisFileNum
        OpenFile = True
    Exit Function
Err:
    Stop
    Resume
End Function
Public Function ReadLine() As String
    If thisFileNum > 0 Then Line Input #thisFileNum, ReadLine
End Function
Public Function ReadToEnd() As String
    If thisFileNum = 0 Then Exit Function
    Dim cs As New CString, tmp As String
    While Not EOF(thisFileNum)
        Line Input #thisFileNum, tmp
        cs.Append(tmp).Append vbCrLf
    Wend
    ReadToEnd = cs.ToString
End Function
Public Function EndOfFile() As Boolean
    EndOfFile = EOF(thisFileNum)
End Function
Public Sub CloseFile()
    If thisFileNum = 0 Then Exit Sub
    Close #thisFileNum
    thisFileNum = 0
End Sub
Public Sub Save()
On Error GoTo Err:
    Dim thisTmpFile As Long
    thisTmpFile = getFreeFileNum
    Open GetFileFullPath For Output As #thisTmpFile
        Print #thisTmpFile, thisContent
    Close #thisTmpFile
    Exit Sub
Err:
    MsgBox "CFile().Save(" & GetFileFullPath & ")" & Err.Description
    Stop
    Resume
End Sub
Public Sub SaveBinary()
    Dim thisTmpFile As Long
    thisTmpFile = getFreeFileNum
    Open GetFileFullPath For Binary As #thisTmpFile
        Seek thisTmpFile, 1
        Put #thisTmpFile, , thisData
    Close #thisTmpFile
End Sub
Public Function GetFileFullPath() As String
    GetFileFullPath = Application.ThisWorkbook.path & "\" & thisPath & "\" & thisFileName & "." & thisFileType
End Function
Public Function GetFullPath() As String
    GetFullPath = Application.ThisWorkbook.path & "\" & thisPath
End Function
Public Sub CreatePath(path As String)
On Error GoTo Err:
    path = Replace(path, " ", ".")
    Dim tmp() As String
    Dim nowPath As New CString
    tmp = Split(path, "\")
    Dim i As Long
    nowPath.Append Application.ThisWorkbook.path
    For i = 0 To UBound(tmp)
        nowPath.Append("\").Append tmp(i)
        If Dir(nowPath.ToString, vbDirectory) = Empty Then
            MkDir nowPath.ToString
        End If
    Next
    Exit Sub
Err:
    MsgBox "CFile.CreatePath()" & Err.Description
    Stop
    Resume
End Sub

Private Function getFreeFileNum() As Long
    getFreeFileNum = FreeFile()
End Function



Private Function SciFilePath(ini As String) As String
    SciFilePath = StrConv(ini, vbNarrow)
    SciFilePath = SciReplace(SciFilePath, ":*""/<>|?", "")
    SciFilePath = RemoveInvalidChar(SciFilePath)
End Function
Private Function SciReplace(ini As String, Target As String, replaceInfo As String) As String
    Dim i As Long
    For i = 1 To Len(Target)
        ini = Replace(ini, Mid(Target, i, 1), replaceInfo)
    Next
    SciReplace = ini
End Function
Private Function RemoveInvalidChar(ini As String) As String
    Dim i As Long, cs As New CString
    Dim thisChar As String
    
    For i = 1 To Len(ini)
        thisChar = Mid(ini, i, 1)
        If RemoveInvalidByChar(thisChar) Then cs.Append thisChar
    Next
    RemoveInvalidChar = cs.ToString
End Function
Private Function RemoveInvalidByChar(ini As String) As Boolean
    Dim thisIndex As Long
    thisIndex = Asc(ini)
    RemoveInvalidByChar = True
    If thisIndex < 0 Then Exit Function
    If thisIndex >= 32 And thisIndex <= 57 Then Exit Function
    If thisIndex >= 65 And thisIndex <= 127 Then Exit Function
    RemoveInvalidByChar = False
End Function

Private Sub Class_Terminate()
    Me.CloseFile
End Sub
