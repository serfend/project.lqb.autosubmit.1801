VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "ModelUserList"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Public list As New CList
Public LastRunIndex As Long
Public Sub InitUser()
    Dim i As Long
    i = 1
    Do
        i = i + 1
        If Sheets(SheetUser).Cells(i, 1) = "" Then Exit Sub
        LoadUser i - 1, False
    Loop
End Sub
Public Sub LoadUser(userIndex As Long, Optional loginNow As Boolean = True)
On Error GoTo Err:
    Dim i As Long, NowUserNameTarget As String
    Dim user As ModelUser
    'For i = 2 To Sheets(sheetuser).UsedRange.rows.Count
        Set user = New ModelUser
        user.index = userIndex
        NowUserNameTarget = Sheets(SheetUser).Cells(userIndex + 1, 1)
        If NowUserNameTarget = "" Then Exit Sub
        
        user.identityId = Sheets(SheetUser).Cells(userIndex + 1, 6)
        user.Login NowUserNameTarget, Sheets(SheetUser).Cells(userIndex + 1, 2), Sheets(SheetUser).Cells(userIndex + 1, 4), Sheets(SheetUser).Cells(userIndex + 1, 5), loginNow
        
        list.setValue NowUserNameTarget, user
    'Next
    Exit Sub
Err:
    Stop
    Resume
End Sub
Public Sub UserLoginSuccess(UserName As String)
    Run list.getValue(UserName).index
End Sub
