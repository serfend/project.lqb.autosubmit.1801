VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "HttpExceptionEventHandle"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Private pErrorNumber As Long
Private pErrorDescription As String
Public Sub Init(sErrorNumber As Long, sErrorDescription As String)
    pErrorNumber = sErrorNumber
    pErrorDescription = sErrorDescription
End Sub
Public Property Get ErrorNumber() As Long
    ErrorNumber = pErrorNumber
End Property
Public Property Get ErrorDescription() As String
    ErrorDescription = pErrorDescription
End Property

