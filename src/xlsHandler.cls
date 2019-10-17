VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "xlsHandler"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
'20171221
'用于设置和更新表格内容
Private nowRowIndex As Long
Private mDic As Object
Private Status(5) As String

Private mutexDic As Object
Private hdlSheet As String
Public Property Get SheetTarget() As String
    If hdlSheet = "" Then
        SheetTarget = SheetData
    Else
        SheetTarget = hdlSheet
    End If
End Property
Public Property Let SheetTarget(value As String)
On Error GoTo Err:
    Dim tmp As String: tmp = Sheets(value).Cells(1, 1)
    hdlSheet = value
Err:
End Property
Public Property Get UsedLine() As Long
    UsedLine = Sheets(SheetTarget).UsedRange.rows.Count
End Property
Public Property Let LineIndex(value As Long)
    If value <= 0 Then Exit Property
    nowRowIndex = value
End Property
Public Property Get LineIndex() As Long
    LineIndex = nowRowIndex
End Property
Public Function FindLine(key As String) As Long
    '先实现功能，以后再优化~
    Dim i As Long
    For i = 2 To UsedLine
        If Sheets(SheetTarget).Cells(i, 1) = key Then
            FindLine = i
            Exit Function
        End If
    Next
End Function
Public Function GetStatus(Optional rank As Byte = 0) As String
    If rank < 0 Or rank > UBound(Status) Then Exit Function
    GetStatus = Status(rank)
End Function
Public Sub SetStatus(info As String, Optional rank As Byte = 0, Optional showNow As Boolean = True)
    Status(rank) = info
    If showNow Then ShowStatus rank
End Sub
Private Sub ShowStatus(rank As Byte)
    Dim i As Byte, t As New CString
    For i = 0 To rank
        t.Append(Status(i)).Append " "
    Next
    Sheets(SheetSys).Cells(2, 2) = t.ToString
    logger.LogInfo "xls.Status:" & t.ToString, rank
    Debug.Print Format(Now, "hh:mm:ss.") & Format(GetTickCount Mod 1000, "000") & ":" & t.ToString
End Sub
Private Function CheckMutex(info As String) As Boolean
        If mutexDic(info) <> "" Then
            logger.LogInfo "重复:" & info
            Stop
        End If
        mutexDic(t.ToString) = "ex"
End Function


Private Function getColIndexByName(colName As String) As Long
On Error GoTo Err:
    Dim tmp As Range
    getColIndexByName = mDic(colName)
    If getColIndexByName > 0 Then Exit Function
    Dim i As Long
    For i = 1 To Sheets(Me.SheetTarget).UsedRange.Columns.Count
        If Sheets(SheetTarget).Cells(1, i) = colName Then
            Set tmp = Sheets(SheetTarget).Cells(1, i)
            Exit For
        End If
    Next
    If Not tmp Is Nothing Then
        getColIndexByName = tmp.Column
        mDic(colName) = getColIndexByName
    Else
        getColIndexByName = NewColumn(colName)
    End If
    Exit Function
Err:
    
    If Err.Number = 50290 Then
        Exit Function
    End If
    Stop
End Function
Public Sub setValue(colName As String, info As String, Optional index As Long = 0)
    Dim colIndex As Long
    colIndex = getColIndexByName(colName)
    If colIndex > 0 Then setValueByIndex colIndex, info, index
End Sub
Public Sub setValueByIndex(colIndex As Long, info As String, Optional index As Long = 0)
    If colIndex = 1 And index = 0 Then
        initRowIndex
    End If
    If colIndex > 0 Then Sheets(SheetTarget).Cells(IIf(index > 0, index, nowRowIndex), colIndex) = info
End Sub
Public Sub setHeightLight(hightLightColor As Long)
    Sheets(SheetTarget).Cells(nowRowIndex, 1).Interior.Color = hightLightColor
End Sub
Private Sub initRowIndex()
    nowRowIndex = UsedRange + 1
End Sub
Private Function NewColumn(colName As String) As Long
    Dim nowColIndex As Long
    nowColIndex = Sheets(Me.SheetTarget).UsedRange.Columns.Count
    If nowColIndex = 1 Then
        If Sheets(SheetTarget).Cells(1, 1) = "" Then nowColIndex = 0
    End If
    nowColIndex = nowColIndex + 1
    Sheets(SheetTarget).Cells(1, nowColIndex) = colName
    NewColumn = nowColIndex
End Function
Public Sub Clear()
    initRowIndex
    Sheets(SheetTarget).rows("2:" & nowRowIndex).Delete Shift:=xlUp
    initRowIndex
End Sub

Private Sub Class_Initialize()
    Set mDic = CreateObject("scripting.dictionary")
    Set mutexDic = CreateObject("scripting.dictionary")
    
End Sub


