VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "ModelQuestion"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False

Implements HttpEventDelegate
Implements HandleQuestionDataDelegate
Public score As String
Public lanqiaotitle As String
Public tpid As String
Public checkpoint As String
Public updatetime As String
Public title As String
Private http As HttpClient
Public eventHandle As HandleQuestionDelegate
Private AllDataSetNum As Long, nowCompleteDataSetNum As Long
Public Parent As ThreadQuesLoad

Private QuestionLineIndex As Long, QuestionDataNum As Long
Private lastSubmitInfo As String
Public QuestionBeenComplete As Boolean
Public Function Init(item As Object, par As ThreadQuesLoad, SenderIsMainUser As Boolean) As Long
    score = item.getValue("score").ToString
    Set Parent = par
    lanqiaotitle = item.getValue("lanqiaotitle").ToString
    title = item.getValue("title").ToString
    tpid = item.getValue("gpid").ToString
    checkpoint = item.getValue("checkpoint").ToString
    updatetime = item.getValue("updatetime").ToString
    Init = Val(score)
    If Not SenderIsMainUser And app.MainUserName <> "" Then
        If Not Me.NeedGetData Then Init = 100
    End If
    Select Case GetInfo("", "Main\history\" & questionId & "\submit")
        Case "CodeBuiltTooFatToSubmit": Init = -233
        Case "submitButNotSuccess": Init = -1
    End Select
    QuestionLineIndex = xlsQues.FindLine(tpid) '初始化ques位置
    QuestionDataNum = GetDataNum
End Function
Public Sub RefreshDataNum(TotalData As Long)
    xlsQues.setValue "数据总量", CStr(TotalData), QuestionLineIndex
    
End Sub
Public Function GetDataNum() As Long
    GetDataNum = Sheets(SheetQuestion).Cells(QuestionLineIndex, 3)
End Function
Public Property Get NeedGetData() As Boolean
    Dim quesIndex As Long
    quesIndex = QuestionLineIndex
    If quesIndex = 0 Then
        quesIndex = xlsQues.UsedLine + 1
        NeedGetData = True
    Else
        Dim nowStatus As String, QuestionTotalNum As Long
        QuestionTotalNum = Me.GetDataNum()
        If QuestionTotalNum > 0 Then
            NeedGetData = CheckDataNum
            If Not NeedGetData Then Exit Property
        End If
        NeedGetData = CheckStatus '如果状态是已完成则无需继续获取
    End If
End Property
Public Function CheckStatus() As Boolean
    CheckStatus = Sheets(SheetQuestion).Cells(QuestionLineIndex, 4) = "待完成"
End Function
Public Function CheckDataNum() As Boolean
    Dim fileInfo As clsFile, lostFileNum As Long
    Dim i As Long
    Dim QuesDataNum As Long
    QuesDataNum = Me.GetDataNum
    If QuesDataNum = 0 Then
        '无数据
        CheckDataNum = True
        Exit Function
    End If
    For i = 1 To QuesDataNum
        Set fileInfo = New clsFile
        fileInfo.Init "Data\" & tpid, "inp" & i, "txt"
        If Not fileInfo.Exist Then
            CheckDataNum = True
            Exit Function
        End If
        fileInfo.Init "Data\" & tpid, "outp" & i, "txt"
        If Not fileInfo.Exist Then
            CheckDataNum = True
            Exit Function
        End If
    Next
End Function
Public Sub GetQuestionData(DataId As String)
    http.GetHtml "http://lx.lanqiao.cn/detail.page?submitid=" & DataId, "get", cookies:=Parent.Parent.UserCookies, ClientId:="GetQuestionData:" & DataId
End Sub
Public Sub SubmitFirstTime()
    Submit "2333"
End Sub
Private Property Get questionId() As String
    questionId = tpid
End Property
Public Sub Skip()
    Parent.Parent.UserQuestionBegin
    OnQuesComplete questionId, "已跳过"
End Sub
Public Sub Submit(code As String)
    If Parent.Parent.UserIsRunning Then
        Debug.Print "233333333mdzz有一个号发疯了:" & Me.MeName
        Exit Sub
    End If
    Parent.Parent.UserQuestionBegin
    lastSubmitInfo = code
On Error GoTo Err:
    If tpid = "" Then Exit Sub
    Dim ques As String
    ques = questionId
    Dim codelength As Long: codelength = LenB(ques) + LenB(code) + 20
    BuildItem codelength
    If codelength / 2 > 64000 Then
        SetInfo "CodeBuiltTooFatToSubmit", "Main\history\" & questionId & "\submit"
    Else
        Dim tmp As String
        If code = "2333" Then
            tmp = "Get:" & ques
            Dim tmpDatasetInfo As String, tmpDatasetId As String, tmpAllowUser As String
            tmpDatasetId = GetInfo("", "Main\Data\DatasetBase\" & ques & "\DataId\" & Parent.Parent.UserName)

            If tmpDatasetId <> "" Then
                tmpDatasetInfo = GetInfo("", "Main\Data\DatasetBase\" & ques & "\DataId\" & tmpDatasetId & "\value")
                If tmpDatasetInfo <> "" Then
                    LoadQuestionData tmpDatasetInfo, tmpDatasetId, True
                    Exit Sub
                Else
                    SetInfo "", "Main\Data\DatasetBase\" & ques & "\DataId\" & Parent.Parent.UserName
                End If
            End If
        ElseIf code = "0000" Then '使用std进行答题
            code = StdCodes
            'If code = "" Then Exit Sub
            tmp = "Post:" & ques
        ElseIf code = "1111" Then '使用自动生成的代码答题
            code = AutoBuildCode
            If code = "" Then Exit Sub
            If InStr(1, code, "data is too big") > 0 Then '存在不能做的数据
                SetInfo "CodeBuiltTooFatToSubmit", "Main\history\" & questionId & "\submit"
            End If
            tmp = "Post:" & ques
        Else
            
        End If
        
        
        http.GetHtml "http://lx.lanqiao.cn/test.SubmitCode.dt", "post", GetPostData(ques, code), Parent.Parent.UserCookies, ClientId:=tmp
        
    End If
    Exit Sub
Err:
    Stop
    Resume
End Sub
Public Function StdCodes() As String
    Dim stdFile As clsFile: Set stdFile = New clsFile
    Dim StdCode As New CString, tmpStdCode As String
    stdFile.Init "\Data\" & questionId, "stdSolution", "txt"
    If Not stdFile.OpenFile Then
        xlsHdl.SetStatus "无标程"
        code = AutoBuildCode
        Exit Function
    End If
    While Not stdFile.EndOfFile
        tmpStdCode = stdFile.ReadLine
        Dim nowTmp() As String, i As Long
        If tmpStdCode <> "" Then
            nowTmp = Split(tmpStdCode, chr(10))
            For i = 0 To UBound(nowTmp)
                Dim ThisAddInPos As Long
                ThisAddInPos = InStr(1, nowTmp(i), "//")
                If ThisAddInPos > 0 Then
                    nowTmp(i) = Mid(nowTmp(i), 1, ThisAddInPos - 1)
                End If
                StdCode.Append(nowTmp(i)).Append vbCrLf
            Next
        End If
    Wend
    If InStr(1, StdCode.ToString, "暂时没有人完全正确") > 0 Then
        xlsHdl.SetStatus "标答不可靠"
        StdCode.SetInfo AutoBuildCode
        If StdCode.Length = 0 Then Exit Function
    End If
    StdCode.Append("//Only used for test auto submit ").Append(questionId).Append(" by serfend").Append vbCrLf
    StdCode.Append "//why i cant download the testData stable!!!"
    StdCodes = StdCode.ToString
    'Debug.Print StdCodes
End Function
Public Function AutoBuildCode() As String
    If app.ResetAllCode Then RefreshAutoCode
    Dim CodeFile As New clsFile
    CodeFile.Init "Data\" & questionId, "solution", "txt"
    If Not CodeFile.OpenFile Then
        xlsHdl.SetStatus "本题暂无生成的代码,需先下载题目测试数据"
        OnQuesComplete questionId, "未提交"
        Exit Function
    End If
    AutoBuildCode = CodeFile.ReadToEnd
    xlsHdl.SetStatus "采用自生成代码提交"
End Function
Private Function GetPostData(ques As String, code As String) As String
    Dim item As HttpContentItem
    Set item = New HttpContentItem
    item.AddPostData "gpid", ques
    item.AddPostData "lang", "CPP"
    Dim tmp As New chrConvert
    If code = "2333" Then
        code = BuildFakeCode
    End If
    item.AddPostData "code", tmp.UrlEncode_GBToUtf8(code)
    GetPostData = item.PostData
End Function
Private Function BuildFakeCode() As String
    Dim cs As New CString
    cs.Append("#include <iostream>").Append vbCrLf
    cs.Append("int main(){").Append vbCrLf
    cs.Append("int tmp;").Append vbCrLf
    Dim i As Long
    For i = 1 To 20
        cs.Append("scanf(""%d"",").Append("&tmp);233").Append vbCrLf
        cs.Append("printf(""%d"",").Append(CInt(10000 * Rnd)).Append(");").Append vbCrLf
    Next
    cs.Append("return 0;").Append vbCrLf
    cs.Append("}").Append vbCrLf
    cs.Append "//TestForNormalCode by serfend"
    BuildFakeCode = cs.ToString
End Function
Private Sub Class_Initialize()
    Set http = New HttpClient
    http.eventHandle = Me
End Sub

Private Sub HandleQuestionDataDelegate_FileDownloaded(sender As ThreadQuestionDataDownLoad)
On Error GoTo Err:
     nowCompleteDataSetNum = nowCompleteDataSetNum + 1
     If nowCompleteDataSetNum = 2 * AllDataSetNum Then
        Me.RefreshAutoCode '重新生成了代码
        If Not eventHandle Is Nothing Then
            eventHandle.QuestionComplete Me, "生成代码"
        Else
            Stop
        End If
        'Submit tmpCode
     ElseIf 2 * AllDataSetNum < nowCompleteDataSetNum Then
        xlsHdl.SetStatus "异常的数据下载"
        Stop
     End If
     Exit Sub
Err:
     Stop
     Resume
End Sub

Private Sub HttpEventDelegate_BadRequest(sender As HttpClientChild, e As HttpBadRequestEventHandle)
    xlsHdl.SetStatus "HttpEventDelegate_BadRequest:" & e.ExceptionInfo
End Sub

Private Sub HttpEventDelegate_BadResponse(sender As HttpClientChild, e As HttpBadResponseEventHandle)
    xlsHdl.SetStatus "HttpEventDelegate_BadRequest:" & e.ExceptionInfo
End Sub

Private Sub HttpEventDelegate_DocumentReady(sender As HttpClientChild, e As HttpDocumentReadyEventHandle)
    Dim tmp() As String
    tmp = Split(sender.ClientId, ":")
    Dim cs As New CString
    cs.Append sender.GETstring
    Select Case tmp(0)
        Case "Post":
            xlsHdl.SetStatus Me.MeName & sender.GETstring
            If cs.GetElement("ret"":""", """") = "1" Then '{"itemid":"2011001","msg":"提交成功。","ret":"1"}
                OnQuesComplete tmp(1), cs.GetElement("itemid"":""", """")
            ElseIf cs.GetElement("msg"":""", """") = "5秒钟内只能提交一个代码。" Then
                Pause app.WaitForLqbToJudge
                Submit lastSubmitInfo
            Else
                Pause app.WaitForLqbToAllowMeGoDie
                Submit lastSubmitInfo
            End If
        Case "Get":
            xlsHdl.SetStatus Me.MeName & sender.GETstring
            If cs.GetElement("ret"":""", """") = "1" Then '{"itemid":"2011001","msg":"提交成功。","ret":"1"}
                OnSetQues tmp(1), cs.GetElement("itemid"":""", """")
            ElseIf cs.GetElement("msg"":""", """") = "您不是VIP用户，不能提交此题。" Then
                OnQuesComplete tpid, "VIP专有"
            ElseIf cs.GetElement("msg"":""", """") = "未登录。" Then
                OnQuesComplete tpid, "未登录"
            Else
                Stop
            End If
        Case "GetQuestionData": '获取题目信息
            LoadQuestionData cs.ToString, tmp(1)
    End Select
End Sub
Private Function LoadQuestionData(info As String, DataId As String, Optional fromLocal As Boolean = False) As Boolean
On Error GoTo Err:
    Dim cs As New CString
    nowCompleteDataSetNum = 0
    cs.Append info
    Dim dataInInfo() As String, dataOutInfo() As String
    If fromLocal Then
        dataInInfo = cs.GetAllElement("i(", ")")
        dataOutInfo = cs.GetAllElement("o(", ")")
    Else
        dataInInfo = cs.GetAllElement("onclick=downinp(", ")")
        dataOutInfo = cs.GetAllElement("onclick=downoup(", ")")
        Dim newCs As New CString
        Dim i As Long
        For i = 1 To UBound(dataInInfo)
            newCs.Append("i(").Append(dataInInfo(i)).Append ")"
        Next
        For i = 1 To UBound(dataOutInfo)
            newCs.Append("o(").Append(dataOutInfo(i)).Append ")"
        Next
        SetInfo DataId, "Main\Data\DatasetBase\" & questionId & "\DataId\" & Parent.Parent.UserName
        SetInfo newCs.ToString, "Main\Data\DatasetBase\" & questionId & "\DataId\" & DataId & "\value"
    End If
    
    LoadQuestionData = DownloadAllFile(dataInInfo, dataOutInfo, DataId)
    If Not Parent.Parent.CanGetData And Not LoadQuestionData Then '只有当数据加载失败时才检查
        Dim MinWaitTime As Long
        xlsHdl.SetStatus Parent.Parent.MeName & "不可继续获取数据:"
        Parent.Parent.UserQuestionComplete
        Application.OnTime Now + TimeValue("00:00:05"), "RunNextUser"
    End If
    Exit Function
Err:
    Stop
    Resume
End Function

Public Sub RefreshAutoCode()  '更新自动生成的代码
    Dim quesSubmitCode As New ModelQuestionDataPair
    Dim tmpCode As String, dataNum As Long
    If AllDataSetNum = 0 Then
        dataNum = GetDataNum
    Else
        dataNum = AllDataSetNum
    End If
    tmpCode = quesSubmitCode.BuildCode(questionId, dataNum)
    Dim tmpCodeFile As clsFile
    If tmpCode = "" Then
        
        tmpCode = "no solution because the code is too big"
    End If
    Set tmpCodeFile = New clsFile
    tmpCodeFile.Init "Data\" & questionId, "solution", "txt"
    tmpCodeFile.content = tmpCode
    tmpCodeFile.Save
End Sub
Private Function DownloadAllFile(inInfo() As String, outInfo() As String, submitId As String) As Boolean
On Error GoTo Err:
    Dim tmpDownloader As ThreadQuestionDataDownLoad
    Dim i As Long, cs As New CString
    AllDataSetNum = UBound(inInfo)
    'xlsHdl.SetStatus "DownloadAllFile:" & MeName & submitId & ",共计" & AllDataSetNum & "组测试数据"
    RefreshDataNum AllDataSetNum
    If AllDataSetNum <> UBound(outInfo) Then
        xlsHdl.SetStatus MeName & "DownloadAllFile()异常的数据源."
        Stop
    End If
    For i = 1 To UBound(inInfo)
        If QuestionBeenComplete Then Exit Function
        Set tmpDownloader = New ThreadQuestionDataDownLoad
        Set tmpDownloader.eventHandle = Me
        cs.SetInfo inInfo(i)
        If tmpDownloader.Run(cs.GetElementLeft(","), cs.GetElement("'", "'"), questionId, submitId, "inp", Parent) Then
            Exit Function
        End If
    Next
    For i = 1 To UBound(outInfo)
        If QuestionBeenComplete Then Exit Function
        Set tmpDownloader = New ThreadQuestionDataDownLoad
        Set tmpDownloader.eventHandle = Me
        cs.SetInfo outInfo(i)
        If tmpDownloader.Run(cs.GetElementLeft(","), cs.GetElement("'", "'"), questionId, submitId, "outp", Parent) Then
            Exit Function
        End If
    Next
    DownloadAllFile = True
    Exit Function
Err:
    Stop
    Resume
End Function
Public Sub OnQuesComplete(ques As String, submitId As String)
    QuestionBeenComplete = True
    eventHandle.QuestionComplete Me, submitId
End Sub
Private Sub OnSetQues(ques As String, submitId As String)
    If Not eventHandle Is Nothing Then
        eventHandle.QuestionFirstSubmit Me, submitId
    End If
End Sub
Private Sub HttpEventDelegate_OnTimeOut(sender As HttpClientChild, e As HttpTimeOutEventHandle)

End Sub
Private Sub BuildItem(Length As Long)

    Dim item As HttpItem, cs As CString
    Set item = http.InnerItem
    Set cs = New CString: cs.Append CStr(Length)
    item.request.headers.setValue "Content-Length", cs
    Exit Sub
    Set cs = New CString: cs.Append "http://lx.lanqiao.cn"
    
    item.request.headers.setValue "Origin", cs
    Set cs = New CString: cs.Append "XMLHttpRequest"
    item.request.headers.setValue "X-Requested-With", cs
    Set cs = New CString: cs.Append "lx.lanqiao.cn"
    item.request.headers.setValue "Host", cs
End Sub

Public Property Get MeName() As String
    MeName = Parent.Parent.MeName & "[" & Me.tpid & "]" & Me.lanqiaotitle & ":"
End Property
