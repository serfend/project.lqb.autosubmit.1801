VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "CList"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Private Type pair
    key As String
    value As Object
End Type
Private dic() As pair, lastExistQueryIndex As Long
Public Property Get item(index As Long) As Object
    Set item = dic(index).value
End Property
Public Property Get key(index As Long) As String
    key = dic(index).key
End Property
Public Function getValue(key As String) As Object
    If Not Exist(key) Then
        Set getValue = Nothing
        Exit Function
    End If
    Set getValue = dic(lastExistQueryIndex).value
End Function

Public Sub setValue(key As String, value As Object)
    If Not Exist(key) Then
        NewPair key, value
    Else
        Set dic(lastExistQueryIndex).value = value
    End If
End Sub
Public Sub addValue(key As String, value As Object)
    If Not Exist(key) Then
        NewPair key, value
    End If
End Sub
Public Sub resetKey(oldKey As String, NewKey As String)
    dic(GetKeyIndex(oldKey)).key = NewKey
End Sub
Public Function Exist(key As String) As Boolean
    lastExistQueryIndex = GetKeyIndex(key)
    Exist = lastExistQueryIndex > 0
End Function
Public Property Get Count() As Long
    Count = UBound(dic)
End Property
Public Sub Remove(key As String)
    RemoveKey key
End Sub
Public Sub RemoveAll()
    NewKey 0
End Sub
Public Function Clone() As CList
    Set Clone = New CList
    Dim thisCount As Long
    thisCount = Me.Count
    With Clone
        Dim i As Long
        For i = 1 To thisCount
            .addValue dic(i).key, dic(i).value
        Next
    End With
End Function

Private Sub NewPair(key As String, value As Object)
    NewKey Count + 1
    SetKeyValue Count, key
    SetValueValue Count, value
End Sub
Private Sub NewKey(newCapacity As Long)
    ReDim Preserve dic(newCapacity)
End Sub
Private Sub SetKeyValue(index As Long, key As String)
    dic(index).key = key
End Sub
Private Sub SetValueValue(index As Long, value As Object)
    Set dic(index).value = value
End Sub
Private Sub RemoveKey(key As String)
    RemoveKeyIndex GetKeyIndex(key)
End Sub
Private Sub RemoveKeyIndex(index As Long)
    If index <= 0 Then Exit Sub
    Dim i As Long
    For i = index To Count - 1
        dic(i) = dic(i + 1)
    Next
    NewKey Count - 1
End Sub
Private Function GetKeyIndex(key As String) As Long
    Dim i As Long
    For i = 1 To UBound(dic)
        If LCase(dic(i).key) = LCase(key) Then
            GetKeyIndex = i
            Exit Function
        End If
    Next
End Function

Private Sub Class_Initialize()
    ReDim dic(0)
End Sub
Public Function ToString(Optional rank As Long = 0) As String
    Dim cs As New CString
    cs.Append ("{")
    ToStringNextLine rank, cs
    Dim i As Long
    For i = 1 To UBound(dic)
        cs.Append(dic(i).key).Append ":"
        ExtractToString dic(i).value, cs, rank
    Next
    cs.Append "}"
    ToString = cs.ToString
End Function
Public Sub ExtractToString(item As Object, cs As CString, rank As Long)
        Select Case TypeName(item)
            Case "CList":
                cs.Append item.ToString(rank + 1)
                ToStringNextLine rank, cs
            Case "Collection":
                Dim j As Long
                For j = 1 To item.Count
                    ExtractToString item(j), cs, rank
                Next
                ToStringNextLine rank, cs
            Case "CString":
                cs.Append item.ToString
                ToStringNextLine rank, cs
            Case Else:
                Stop
        End Select
End Sub
Public Sub ToStringNextLine(rank As Long, cs As CString)
    cs.Append(vbCrLf).Append (Space((rank + 1) * 4))
End Sub
