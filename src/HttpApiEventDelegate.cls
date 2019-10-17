VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "HttpApiEventDelegate"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Public Sub OnError(sender As HttpAPI, e As HttpExceptionEventHandle)
    
End Sub

Public Sub OnResponseDataAvailable(sender As HttpAPI, e As HttpDataAvilableEventHandle)
    
End Sub

Public Sub OnResponseFinished(sender As HttpAPI)
    
End Sub
 
Public Sub OnResponseStart(sender As HttpAPI, e As HttpResponseEventHandle)
    
End Sub

