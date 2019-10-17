VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "HttpDataAvilableEventHandle"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Private pData() As Byte
Public Sub Init(sData() As Byte)
    pData = sData
End Sub
Public Property Get data() As Byte()
    data = pData
End Property
