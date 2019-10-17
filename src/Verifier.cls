VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Verifier"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Implements VerifiesEventDelegate
Implements HttpEventDelegate
Private http As HttpClient
Private frmVer As FrmVct
Private file As clsFile
Private thisCookies As String
Public eventHandle As VerifiesEventDelegate
Private thisHttpClient As Long
Private thisToShowOut As Boolean
Public Sub GetVer(url As String, verName As String, cookies As String, sender As String, Optional showOut As Boolean = True)
    xlsHdl.SetStatus "GetVer" & sender
    thisToShowOut = showOut
    Set file = New clsFile
    file.Init "Cache\Verifies", verName, "jpg"
    http.InnerItem.file = file
    thisHttpClient = http.GetHtml(url, cookies:=cookies, KeepContext:=True, ClientId:=verName)
End Sub

Private Sub Class_Initialize()
    Set http = New HttpClient
    http.eventHandle = Me
End Sub

Private Sub HttpEventDelegate_BadRequest(sender As HttpClientChild, e As HttpBadRequestEventHandle)
    xlsHdl.SetStatus "VerifierLoadFail:BadRequest" & e.ExceptionInfo
    
End Sub

Private Sub HttpEventDelegate_BadResponse(sender As HttpClientChild, e As HttpBadResponseEventHandle)
    xlsHdl.SetStatus "VerifierLoadFail:BadResponse" & e.ExceptionInfo
End Sub

Private Sub HttpEventDelegate_DocumentReady(sender As HttpClientChild, e As HttpDocumentReadyEventHandle)
    'sender.item.response.CookiesString = sender.item.response.CookiesString & sender.item.request.CookiesString
    thisCookies = sender.item.response.CookiesString
    If thisToShowOut Then
        Set frmVer = New FrmVct
        frmVer.Init file.GetFileFullPath, Me, file.fileName, thisCookies, sender.ClientId
    End If
End Sub

Private Sub HttpEventDelegate_OnTimeOut(sender As HttpClientChild, e As HttpTimeOutEventHandle)

End Sub

Private Function VerifiesEventDelegate_Cancel() As Long
    If Not eventHandle Is Nothing Then
        eventHandle.Cancel
    End If
End Function

Private Function VerifiesEventDelegate_Verify(code As String, verName As String, cookies As String) As Long
    If Not eventHandle Is Nothing Then
        eventHandle.Verify code, verName, thisCookies
    End If
End Function
