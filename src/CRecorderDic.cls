VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "CRecorderDic"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Private thisDic() As CList, thisKeyDic As CList, pCount As Long
Public Property Get Count()
    Count = pCount
End Property
Private Sub Class_Initialize()
    ReDim thisDic(0)
    Set thisKeyDic = New CList
End Sub
Private Sub newDic(keyName As String)
    pCount = pCount + 1
    ReDim Preserve thisDic(pCount)
    Set thisDic(pCount) = New CList
    thisKeyDic.addValue keyName, thisDic(pCount)
End Sub
Public Function getDic(keyName As String) As CList
    If Not thisKeyDic.Exist(keyName) Then newDic keyName
    Set getDic = thisKeyDic.getValue(keyName)
End Function
Public Function getValue(dic As String, key As String) As Object
    Dim tmp As CList
    Set tmp = getDic(key)
    Set getValue = tmp.getValue(key)
End Function
Public Sub setValue(dic As String, key As String, value As Object)
    Dim tmp As CList
    Set tmp = getDic(key)
    tmp.setValue key, value
End Sub
