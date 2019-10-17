VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "HttpResponseEventHandle"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Private pStatus As Long
Private pContentType As String
Public Sub Init(sStatus As Long, sContentType As String)
    pStatus = sStatus
    pContentType = sContentType
End Sub
Public Property Get Status() As Long
    Status = pStatus
End Property
Public Property Get ContentType() As String
    ContentType = pContentType
End Property
