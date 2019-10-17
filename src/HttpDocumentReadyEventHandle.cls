VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "HttpDocumentReadyEventHandle"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Private pHttp As winHttp.WinHttpRequest
Public Sub Init(http As winHttp.WinHttpRequest)
    Set pHttp = http
End Sub
Public Property Get InnerHttp() As winHttp.WinHttpRequest
    Set InnerHttp = pHttp
End Property

