VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "UtilNormal"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Private Const DateBegin As Date = #1/1/1970#
Public Property Get TimeStamp() As Long
    TimeStamp = TimeStampInner * 1000# + GetTickCount Mod 1000
End Property
Private Property Get TimeStampInner() As Double
    TimeStampInner = (Now - DateBegin) * 86400#
End Property
Public Function Random(Optional DBegin As Double = 0, Optional DEnd As Double = 1) As Double
    Dim tmpRand As Double
    tmpRand = Rnd
    Random = Rnd * DBegin + (1 - tmpRand) * DEnd
End Function

Private Sub Class_Initialize()
    Randomize
End Sub
