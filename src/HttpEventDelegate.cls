VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "HttpEventDelegate"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Public Sub DocumentReady(sender As HttpClientChild, e As HttpDocumentReadyEventHandle)
    
End Sub
Public Sub BadResponse(sender As HttpClientChild, e As HttpBadResponseEventHandle)

End Sub
Public Sub BadRequest(sender As HttpClientChild, e As HttpBadRequestEventHandle)

End Sub
Public Sub OnTimeOut(sender As HttpClientChild, e As HttpTimeOutEventHandle)

End Sub
