VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "ModelStdSolution"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Implements HttpEventDelegate
Private http As HttpClient
Private par As ModelQuestion
Public eventHandle As HandleStdsolutionComplete
    Dim file As New clsFile
    
Public Sub Run(Parent As ModelQuestion)  '获取标程
    Set par = Parent
    file.Init "Data\" & par.tpid, "stdSolution", "txt"
    If file.Exist Then
        eventHandle.Complete Me, True
        Exit Sub
    End If
    http.GetHtml "http://lx.lanqiao.cn/refcode.page?gpid=" & Parent.tpid, cookies:=par.Parent.Parent.UserCookies
    
End Sub

Private Sub Class_Initialize()
    Set http = New HttpClient
    http.eventHandle = Me
End Sub

Private Sub HttpEventDelegate_BadRequest(sender As HttpClientChild, e As HttpBadRequestEventHandle)
    xlsHdl.SetStatus "HttpEventDelegate_BadRequest()" & e.ExceptionInfo
End Sub

Private Sub HttpEventDelegate_BadResponse(sender As HttpClientChild, e As HttpBadResponseEventHandle)
    xlsHdl.SetStatus "HttpEventDelegate_BadResponse()" & e.ExceptionInfo
End Sub

Private Sub HttpEventDelegate_DocumentReady(sender As HttpClientChild, e As HttpDocumentReadyEventHandle)
    On Error GoTo Err:
    Dim cs As New CString
    cs.Append sender.GETstring

    file.content = cs.GetElement("<textarea id=""codelinescpp"">", "</textarea>")
    If Len(file.content) > 10 Then
        file.Save
        xlsHdl.SetStatus "标程已保存:" & par.MeName
    Else
        xlsHdl.SetStatus "获取标程失败:" & par.MeName
    End If
    If Not eventHandle Is Nothing Then
        eventHandle.Complete Me, Len(file.content) > 10
    End If
    Exit Sub
Err:
    Stop
    Resume
End Sub

Private Sub HttpEventDelegate_OnTimeOut(sender As HttpClientChild, e As HttpTimeOutEventHandle)

End Sub
