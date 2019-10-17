VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "HttpBadRequestEventHandle"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Private pHttp As winHttp.WinHttpRequest
Private eN As Long, eD As String
Public Sub Init(http As winHttp.WinHttpRequest, errorNum As Long, errorDes As String)
    Set pHttp = http
End Sub
Public Property Get InnerHttp() As winHttp.WinHttpRequest
    Set InnerHttp = pHttp
End Property

Public Property Get ExceptionNumber() As Long
    ExceptionNumber = eN
End Property
Public Property Get ExceptionInfo() As String
    ExceptionInfo = eD
End Property


