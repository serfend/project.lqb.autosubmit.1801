VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "ThreadQuestionDataDownLoad"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Implements HttpEventDelegate
Public DataId As String
Public tid As String
Public idx As String
Public datahash As String
Public ttype As String
Private http As HttpClient
Private file As New clsFile
Public eventHandle As HandleQuestionDataDelegate
Public Parent As ThreadQuesLoad

Private thisDataDownloadException As String
Public Function Run(index As String, code As String, QuesId As String, submitId As String, DataType As String, par As ThreadQuesLoad) As Boolean  'true表示加载失败，请停止
On Error GoTo Err:
    Set Parent = par

    idx = index
    tid = QuesId
    DataId = submitId
    datahash = code
    ttype = DataType
    file.Init "\Data\" & tid, ttype & idx, "txt"
    If file.Exist Then
        OnFileExistToDisk
    Else
        If Parent.Parent.CanGetData Then
            http.GetHtml "http://lx.lanqiao.cn/lanqiao.DownloadData.dt", "post", GetPostData, Parent.Parent.UserCookies, ClientId:="Get:" & submitId
            xlsHdl.SetStatus "下载题目数据:" & QuesId & "-" & index & "." & DataType
            Pause app.QuestionDataDownloadInterval '下载一个数据停一会
            If thisDataDownloadException <> "" Then
                Run = True
                xlsHdl.SetStatus "下载数据错误:" & thisDataDownloadException
            End If
        Else
            Run = True
            Exit Function
        End If
    End If
    Exit Function
Err:
    Stop
    Resume
End Function
Private Function GetPostData() As String
    Dim item As New HttpContentItem
    item.AddPostData "type", ttype
    item.AddPostData "gpid", tid
    item.AddPostData "idx", idx
    item.AddPostData "datahash", datahash
    GetPostData = item.PostData
End Function
Private Sub Class_Initialize()
    Set http = New HttpClient
    http.eventHandle = Me
End Sub

Private Sub HttpEventDelegate_BadRequest(sender As HttpClientChild, e As HttpBadRequestEventHandle)
    xlsHdl.SetStatus "HttpEventDelegate_BadResponse:" & e.ExceptionInfo
End Sub

Private Sub HttpEventDelegate_BadResponse(sender As HttpClientChild, e As HttpBadResponseEventHandle)
    xlsHdl.SetStatus "HttpEventDelegate_BadResponse:" & e.ExceptionInfo
End Sub

Private Sub HttpEventDelegate_DocumentReady(sender As HttpClientChild, e As HttpDocumentReadyEventHandle)
On Error GoTo Err:
    Dim tmp() As String
    tmp = Split(sender.ClientId, ":")
    Select Case tmp(0)
        Case "Get":
            http.InnerItem.file = file
            Dim cs As New CString
            cs.Append sender.GETstring '{"handle":"nGhhHeYmrBqj","ret":"1"}
            If cs.GetElement("ret"":""", """") = "1" Then
                http.GetHtml "http://lx.lanqiao.cn/web.RequireTempFile.do?handle=" & cs.GetElement("handle"":""", """"), "get", cookies:=Parent.Parent.UserCookies, ClientId:="Down:" & tmp(1)
            Else
                xlsHdl.SetStatus Parent.Parent.MeName & "下载测试数据:" & cs.ToString
                thisDataDownloadException = cs.ToString
                If cs.GetElement("info"":""", """") = "ERROR。" Then
                    Dim MinWaitTime As Long
                    Parent.Parent.BeenBan
                    Exit Sub
                ElseIf cs.GetElement("info"":""", """") = "未登录。" Then
                    xlsHdl.SetStatus Parent.Parent.MeName & "下载数据失败:未登录" & Parent.Parent.UserName & ",cookies:" & Parent.Parent.UserCookies
                    Parent.Parent.LoginSuccessed = False
                    'UserList.LoadUser UserList.NowUserIndex
                    Exit Sub
                ElseIf cs.GetElement("info"":""", """") = "未授权。" Then
                    xlsHdl.SetStatus Parent.Parent.MeName & tmp(1) & "授权码已过期,等待重新获取." & tid
                    SetInfo "", "Main\Data\DatasetBase\" & tid & "\DataId\" & Parent.Parent.UserName
                    Parent.NowHdlQuestion.OnQuesComplete "", "下载未授权" '重新获取
                    Exit Sub
                Else
                    Stop
                End If
            End If
        Case "Down":
            OnFileExistToDisk
    End Select
    Exit Sub
Err:
    Stop
    Resume
End Sub
Private Sub OnFileExistToDisk()
    If Not eventHandle Is Nothing Then
        eventHandle.FileDownloaded Me
    End If
End Sub
Private Sub HttpEventDelegate_OnTimeOut(sender As HttpClientChild, e As HttpTimeOutEventHandle)

End Sub
