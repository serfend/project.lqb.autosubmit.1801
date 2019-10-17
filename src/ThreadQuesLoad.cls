VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "ThreadQuesLoad"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Implements HttpEventDelegate
Implements HandleQuestionDelegate
Implements HandleStdsolutionComplete
Private http As HttpClient
Private QuesList() As String, nowCompleteInitNum As Long, sunQuestionNum As Long
Private quesModelList As Collection, nowCompleteQuesIndex As Long
Private quesCompleteModelList As Collection
Private quesCantComplete As Collection
Public Event AllQuestionListLoaded(listOfQuesToComplete As Collection, listOfQuesBeenComplete As Collection, listCantComplete As Collection)
Public Event CompleteQuestion(QuestionIndex As ModelQuestion)

Public Parent As ModelUser
Public NowHdlQuestion As ModelQuestion
Public Sub Init(QuesBegin As Long, par As ModelUser)
    nowCompleteQuesIndex = 0
    sunQuestionNum = 0
    nowCompleteInitNum = 0
    Set Parent = par
    LoadAllQuesList
End Sub
Private Sub LoadAllQuesList()
    Set quesCantComplete = New Collection
    Set quesModelList = New Collection
    Set quesCompleteModelList = New Collection
    xlsHdl.SetStatus "�������:" & Parent.MeName
    Dim cs As New CString
    'cs.Append "1"
    'http.InnerItem.request.headers.addValue "Upgrade-Insecure-Requests", cs
    http.GetHtml "http://lx.lanqiao.cn/problemsets.page", "get", , Parent.UserCookies, ClientId:="LoadAllList:0" ', Refer:="http://lx.lanqiao.cn/", Host:="lx.lanqiao.cn"
End Sub
Private Sub LoadAllListInit()
    Dim i As Long, dic As Object
    Set dic = CreateObject("scripting.dictionary")

    For i = 1 To UBound(QuesList)
        If dic(QuesList(i)) = "" Then
            dic(QuesList(i)) = "1"
            sunQuestionNum = sunQuestionNum + 1
            LoadQuesList QuesList(i)
        End If
    Next
        xlsHdl.SetStatus Parent.MeName & "������Ŀ������:" & sunQuestionNum
End Sub
Private Sub LoadQuesList(quesType As String)
    http.GetHtml "http://lx.lanqiao.cn/problem.TrainProblems.dt", "post", "code=" & quesType & "&userid=" & Parent.userId, _
            Parent.UserCookies, ClientId:="LoadList:" & quesType _
            , Refer:="http://lx.lanqiao.cn/"
End Sub
Private Sub LoadQuesListInit(info As String, quesType As String)
On Error GoTo Err:
    If app.justLogin Then Exit Sub
    
    If Len(info) < 20 Then Stop
    Dim json As New CJson, innerQuesList As Object
    Set innerQuesList = json.parse(info)
    Dim i As Long, tmpQues As ModelQuestion
    Dim NeedFlag As Boolean: NeedFlag = Parent.IsMainUser '��ע��Ҫ
    Dim QuesNedFlag As Boolean
    For i = 1 To innerQuesList.Count
        Dim thisQuesIndex As String
        thisQuesIndex = innerQuesList.key(i)
        If thisQuesIndex = "0" Or Val(thisQuesIndex) > 0 Then
            Set tmpQues = New ModelQuestion
            Set tmpQues.eventHandle = Me
            Dim QuesStatus As Long
            QuesStatus = tmpQues.Init(innerQuesList.item(i), Me, NeedFlag)
            QuesNedFlag = True
            Select Case QuesStatus
                Case 101:
                    quesCompleteModelList.Add tmpQues
                    QuesNedFlag = False
                Case -233:
                    quesCantComplete.Add tmpQues
                    'QuesNedFlag = False
                Case -1:
                
                Case Else:
                    quesModelList.Add tmpQues
            End Select
            
            Dim QuesLineIndex As Long
            QuesLineIndex = xlsQues.FindLine(tmpQues.tpid)
            If QuesLineIndex = 0 Then
                QuesLineIndex = xlsQues.UsedLine + 1
                xlsQues.setValue "���", tmpQues.tpid, QuesLineIndex
                xlsQues.setValue "����", tmpQues.lanqiaotitle, QuesLineIndex
            End If

            If NeedFlag Then
                xlsQues.setValue "���˺�״̬", IIf(QuesNedFlag, "�����", "����"), QuesLineIndex
            End If
            xlsQues.setValue Parent.UserName, tmpQues.score, QuesLineIndex
        End If
    Next
    nowCompleteInitNum = nowCompleteInitNum + 1
    If nowCompleteInitNum = sunQuestionNum Then
        RaiseEvent AllQuestionListLoaded(quesModelList, quesCompleteModelList, quesCantComplete)
    End If
    Exit Sub
Err:
    Stop
    Resume
End Sub
Public Sub Run()
On Error GoTo Err:
    nowCompleteQuesIndex = nowCompleteQuesIndex + 1
    If nowCompleteQuesIndex > quesModelList.Count Then
        xlsHdl.SetStatus "��ȫ�����"
        Stop
        Exit Sub
    End If
    'xlsHdl.SetStatus "-----------" & Me.Parent.MeName & "��ʼ����"
    Set NowHdlQuestion = quesModelList(nowCompleteQuesIndex)
    If app.codeMode = 0 Or Not Parent.IsMainUser Then  '������Ŀ��ԭʼ���� Or Not Parent.IsMainUser
        If NowHdlQuestion.CheckDataNum Then
            If NowHdlQuestion.NeedGetData Then
                xlsHdl.SetStatus "������Ŀ:" & NowHdlQuestion.tpid & " �Ĳ�������"
                NowHdlQuestion.Submit "2333" '�������Ѿ�������ȫ��ʱ��㲻��Ҫ������
            Else
                NowHdlQuestion.Skip '��Ϊ���˺���������������ύ
            End If
        Else
            '���˺�û�ύ���ģ�Ҫ�����������ˢ��һ��
            If app.ResetAllCode Then NowHdlQuestion.RefreshAutoCode
            NowHdlQuestion.Skip
        End If
    ElseIf app.codeMode = 1 Then
        xlsHdl.SetStatus "ͨ������Ա�˺Ż�ȡԴ��"
        If Parent.identityId = "2" Then '����Ա
            Dim stdQues As ModelStdSolution
            Set stdQues = New ModelStdSolution
            Set stdQues.eventHandle = Me
            stdQues.Run NowHdlQuestion
        Else
            xlsHdl.SetStatus Parent.MeName & "���ǹ���Ա,identityId:" & Parent.identityId
        End If
    ElseIf app.codeMode = 2 Then 'ֱ�ӽ��д���
        NowHdlQuestion.Submit "0000" 'ͨ��std����
    ElseIf app.codeMode = 3 Then '
        NowHdlQuestion.Submit "1111" 'ͨ��autoBuild����
    End If

    Exit Sub
Err:
    Stop
    Resume
End Sub
Private Sub Class_Initialize()
    Set http = New HttpClient
    http.eventHandle = Me
End Sub

Private Sub HandleQuestionDelegate_QuestionComplete(sender As ModelQuestion, submitId As String)
    Parent.UserQuestionComplete
    If InStr(1, "δ��¼", submitId) > 0 Then
        xlsHdl.SetStatus "���µ�¼" & Parent.MeName
        Parent.Login
        Exit Sub
    End If
    If InStr(1, "����δ��Ȩ", submitId) > 0 Then
        Application.OnTime Now + TimeValue("00:00:01"), "ResumeLastTimeInfo"
        Exit Sub
    End If
    If InStr(1, "������,δ�ύ,���ɴ���", submitId) <= 0 Then
        Pause app.WaitForLqbToJudge
        xlsHdl.SetStatus "���" & nowCompleteQuesIndex & "/" & quesModelList.Count & "-" & submitId & ",[" & sender.tpid & "]" & sender.lanqiaotitle
    End If
    Static RunTime As Long
    RunTime = RunTime + 1
    If RunTime > 100 Then
        RunTime = 0
        Set lastUser = Me.Parent
        Application.OnTime Now + TimeValue("00:00:01"), "ResumeLastTimeInfo"
    Else
        Me.Run
    End If
End Sub
Private Sub HandleQuestionDelegate_QuestionFirstSubmit(sender As ModelQuestion, submitId As String)
    Pause app.WaitForLqbToJudge
    sender.GetQuestionData submitId
End Sub

Private Sub HandleStdsolutionComplete_Complete(sender As ModelStdSolution, success As Boolean)
    Me.Run
End Sub

Private Sub HttpEventDelegate_BadRequest(sender As HttpClientChild, e As HttpBadRequestEventHandle)

End Sub

Private Sub HttpEventDelegate_BadResponse(sender As HttpClientChild, e As HttpBadResponseEventHandle)

End Sub

Private Sub HttpEventDelegate_DocumentReady(sender As HttpClientChild, e As HttpDocumentReadyEventHandle)
On Error GoTo Err:
    Dim tmp() As String
    tmp = Split(sender.ClientId, ":")
    Dim cs As CString
    
    Select Case tmp(0)
        Case "LoadAllList":
            Set cs = New CString
            cs.Append sender.GETstring
            QuesList = cs.GetAllElement("problemset.page?code=", "&")
            If UBound(QuesList) <= 0 Then
                xlsHdl.SetStatus "����Ŀ¼ʧ��,δ��¼" & Parent.MeName & ",cookies:" & Parent.UserCookies
                UserList.LoadUser Parent.index
                Exit Sub
            End If
            'Parent.userId = cs.GetElement("&userid=", """")
            Parent.LoginSuccessed = True '��¼�ɹ�����
            LoadAllListInit
        Case "LoadList":
            Dim ListTmpInfo As String
            ListTmpInfo = sender.GETstring
            If Len(ListTmpInfo) < 20 Then
                xlsHdl.SetStatus "��ȡ����б�:" & tmp(1) & ",��������(" & ListTmpInfo & ")"
                'Stop
                'LoadQuesList tmp(1)
                Exit Sub
            End If
            LoadQuesListInit sender.GETstring, tmp(1)
    End Select
    Exit Sub
Err:
    Stop
    Resume
End Sub

Private Sub HttpEventDelegate_OnTimeOut(sender As HttpClientChild, e As HttpTimeOutEventHandle)

End Sub