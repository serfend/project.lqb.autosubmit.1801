VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "XlsDataAnalyse"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Private Const SheetTarget As String = "Analyse"
Public Sub Run()
    Dim i As Long
    For i = 2 To Sheets(SheetTarget).UsedRange.rows.Count
        HdlTitle i
        HdlLoc i
    Next
End Sub
Public Sub HdlTitle(index As Long)
    Dim tmp As String
    tmp = Sheets(SheetTarget).Cells(index, 9)
    Dim cs As New CString
    cs.Append tmp
    Debug.Print tmp
    Dim tmpRel As String, i As Long
    Do
        i = i + 1
        tmpRel = cs.GetElementLeft(Choose(i, "KG", "kg"))
    Loop Until tmpRel <> ""
    For i = Len(tmpRel) To 1 Step -1
        Dim thisChr As Long
        thisChr = Asc(Mid(tmpRel, i, 1))

    Next
    Sheets(SheetTarget).Cells(index, 10) = Mid(tmpRel, i + 1)
End Sub
 
Public Sub HdlLoc(index As Long)
    Dim tmp As String
    tmp = Sheets(SheetTarget).Cells(index, 16)
    Dim tmp2() As String
    tmp2 = Split(tmp, " ")
    If UBound(tmp2) = 1 Then
        Sheets(SheetTarget).Cells(index, 17) = tmp2(0)
        Sheets(SheetTarget).Cells(index, 18) = tmp2(1)
    Else
        Sheets(SheetTarget).Cells(index, 17) = tmp2(0)
        Sheets(SheetTarget).Cells(index, 18) = tmp2(0)
    End If

End Sub
Private Function IsNumber(chr As String) As Boolean
        Dim thisChr As Long
        thisChr = Asc(chr)
        If Not (thisChr >= 46 And thisChr <= 57) Then
            IsNumber = True
        End If
End Function

