VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "ModelUser"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Implements VerifiesEventDelegate
Implements HttpEventDelegate
Public index As Long

Public IsMainUser As Boolean
Public UserName As String
Public UserPwd As String
Public UserNick As String
Public identityId As String
Public LoginSuccessed As Boolean
Public accountLoginname As String
Public accountNickname As String
Private innerUserCookies As String
Private initUserCookiesId As String

Public userId As String
Private nowGetDataNum As Long, lastGetDataTime As Long
Private Verifier As Verifier
Attribute Verifier.VB_VarHelpID = -1
Private http As HttpClient
Private UserHttpClient As Long

Public WithEvents ThreadQues As ThreadQuesLoad
Attribute ThreadQues.VB_VarHelpID = -1

Public loginNow As Boolean
Dim LineIndex  As Long 'UserLineIndex
Private NowRunningNum As Long
Public Function UserIsRunning() As Boolean
    UserIsRunning = NowRunningNum > 0
End Function
Public Sub UserQuestionBegin()
    NowRunningNum = NowRunningNum + 1
    RunningUserNum = RunningUserNum + 1
End Sub
Public Sub UserQuestionComplete()
    NowRunningNum = NowRunningNum - 1
    If NowRunningNum = 0 Then
        RunningUserNum = RunningUserNum - 1
    Else
        
    End If
End Sub

Public Sub LoadQues()
    UserList.LastRunIndex = Me.index
    xlsHdl.SetStatus "加载" & MeName
    Set ThreadQues = New ThreadQuesLoad
    ThreadQues.Init 1, Me
End Sub
Private Sub ThreadQues_AllQuestionListLoaded(listOfQuesToComplete As Collection, listOfQuesBeenComplete As Collection, listCantComplete As Collection)
    xlsHdl.SetStatus MeName & ".习题已全部加载完成  UA/AC/All=" & listCantComplete.Count & "/" & listOfQuesBeenComplete.Count & "/" & (listOfQuesBeenComplete.Count + listOfQuesToComplete.Count + listCantComplete.Count)
    If Not app.justLogin Then ThreadQues.Run
End Sub
Private Sub ThreadQues_CompleteQuestion(QuestionIndex As ModelQuestion)
    xlsHdl.SetStatus "完成" & QuestionIndex.MeName
End Sub



Private Sub InitUser()
    http.GetHtml "http://dasai.lanqiao.cn/pages/account/login_other.html?backqurl=http%3A//lx.lanqiao.cn/lqloginfinished.page%3Fredir%3D/problemsets.page", KeepContext:=True, ClientId:="Init:" & UserName
End Sub
Public Sub CheckLogin()
    http.GetHtml "http://lx.lanqiao.cn/problemsets.page", cookies:=UserCookies, ClientId:="CheckLogin", Refer:="http://lx.lanqiao.cn/"
End Sub
Public Sub BeenBan()
    lastGetDataTime = GetTickCount + app.getBeenBanInterval
    nowGetDataNum = app.GetDataMaxSingleNum + 1
End Sub
Public Sub ClearDataUsedNum()
    lastGetDataTime = 0
    nowGetDataNum = 0
End Sub
Public Property Get CanGetDataTime() As Long
    CanGetDataTime = app.GetDataInterval - GetTickCount
    CanGetDataTime = CanGetDataTime + lastGetDataTime
End Property
Public Property Get CanGetData() As Boolean
    If LoginSuccessed = False Then
        CanGetData = False
        Exit Property
    End If
    If nowGetDataNum < app.GetDataMaxSingleNum Then
        nowGetDataNum = nowGetDataNum + 1
        If nowGetDataNum = 1 Then lastGetDataTime = GetTickCount
        CanGetData = True
    Else
        If GetTickCount - lastGetDataTime > app.GetDataInterval Then
            nowGetDataNum = 0
            CanGetData = Me.CanGetData
        End If
    End If
End Property
Public Property Get UserCookies() As String
    UserCookies = innerUserCookies
End Property

Public Property Let UserCookies(value As String)
    Dim item As New HttpContentItem
    item.CookiesString = Me.UserCookies & ";" & value
    innerUserCookies = item.CookiesString
End Property
Public Sub Login(Optional un As String, Optional up As String, Optional initUserId As String, Optional initCookies As String, Optional loginNow As Boolean = True)
    Me.loginNow = loginNow
    Set Verifier = New Verifier
    Set Verifier.eventHandle = Me
    If un <> "" Then UserName = un
    If up <> "" Then UserPwd = up
    If initCookies <> "" Then innerUserCookies = initCookies
    If initUserId <> "" Then userId = initUserId
    Me.IsMainUser = (UserName = app.MainUserName Or app.MainUserName = "")
    If loginNow Then ' Or 1 Then
        xlsHdl.SetStatus "登陆到账号:" & UserName & ",userId:" & userId & ",cookies:" & innerUserCookies
        InitUser
    Else
        xlsHdl.SetStatus "切换到账号:" & UserName & ",userId:" & userId & ",cookies:" & innerUserCookies
        CheckLogin
    End If
End Sub

Private Sub SynUserCookiesID()
On Error Resume Next
    Dim cookiesList As New HttpContentItem
    cookiesList.CookiesString = Me.UserCookies
    initUserCookiesId = cookiesList.cookies.getValue("JSESSIONID").ToString
End Sub


Private Sub HttpEventDelegate_BadRequest(sender As HttpClientChild, e As HttpBadRequestEventHandle)
    Debug.Print "HttpEventDelegate_BadRequest:" & e.ExceptionInfo
End Sub

Private Sub HttpEventDelegate_BadResponse(sender As HttpClientChild, e As HttpBadResponseEventHandle)
    Debug.Print "HttpEventDelegate_BadResponse:" & e.ExceptionInfo
End Sub

Private Sub HttpEventDelegate_DocumentReady(sender As HttpClientChild, e As HttpDocumentReadyEventHandle)
On Error GoTo Err:
    Dim tmp() As String
    tmp = Split(sender.ClientId, ":")
    Select Case tmp(0)
        Case "Init":
            Me.UserCookies = sender.item.response.CookiesString
            SynUserCookiesID
            http.GetHtml "http://dasai.lanqiao.cn/pages/account/login_other.html?backurl=http%3A//lx.lanqiao.cn/lqloginfinished.page%3Fredir%3D/", cookies:=Me.UserCookies, KeepContext:=True, ClientId:="InitCookiesId"
        Case "InitCookiesId"
            'Me.UserCookies = sender.item.response.CookiesString
            http.GetHtml "http://dasai.lanqiao.cn/pages/account/login_other.html?backurl=http%3A//lx.lanqiao.cn/lqloginfinished.page%3Fredir%3D/", KeepContext:=True, cookies:=Me.UserCookies, ClientId:="InitSession"
        Case "InitSession":
            http.GetHtml "http://dasai.lanqiao.cn/api/action/account/current/sessionkey", KeepContext:=True, cookies:=Me.UserCookies, ClientId:="GetCode:未"
        Case "GetCode"
            Dim util As New UtilNormal
            Me.UserCookies = sender.item.response.CookiesString
            Verifier.GetVer "http://dasai.lanqiao.cn/api/action/directmail/vcode2?_" & util.TimeStamp, tmp(1) & "登录" & UserName, Me.UserCookies, "User:" & UserName
        Case "CheckCode":
            
            xlsHdl.SetStatus "验证码:" & sender.GETstring
            If InStr(1, sender.GETstring, "成功") > 0 Then
                UserHttpClient = http.GetHtml("http://dasai.lanqiao.cn/api/lx/login", "post", GetPostData(tmp(1)), UserCookies, KeepContext:=True, ClientId:="Login")
            Else
                http.GetHtml "http://dasai.lanqiao.cn/api/action/account/current/sessionkey", KeepContext:=True, cookies:=Me.UserCookies, ClientId:="GetCode:验证码错误,重新"
            End If
        Case "Login"
            Me.UserCookies = sender.item.response.CookiesString
            xlsHdl.SetStatus Me.UserCookies
            http.GetHtml "http://dasai.lanqiao.cn/api/action/account/current/user", "post", cookies:=UserCookies, ClientId:="User"
        Case "User":
            If LoginInfoCheck(sender.GETstring) Then
                http.GetHtml "http://lx.lanqiao.cn/lqloginfinished.page?redir=/", "get", cookies:=UserCookies, ClientId:="LoginFinish"
            End If
        Case "LoginFinish":
            LineIndex = xlsHdl.FindLine(UserName)
                'Dim cookiesList As New HttpContentItem, cookieId As New CString
                'cookieId.Append initUserCookiesId
                'cookiesList.CookiesString = Me.UserCookies
                'cookiesList.cookies.setValue "JSESSIONID", cookieId
                'innerUserCookies = cookiesList.CookiesString
            xlsHdl.setValue "UserId", Me.userId, LineIndex
            
            xlsHdl.setValue "UserName", Me.accountLoginname, LineIndex
            xlsHdl.setValue "identityId", Me.identityId, LineIndex
            
            http.GetHtml "http://lx.lanqiao.cn/", cookies:=Me.UserCookies, ClientId:="lx", KeepContext:=True, Refer:="http://dasai.lanqiao.cn/pages/account/login_other.html?backurl=http%3A//lx.lanqiao.cn/lqloginfinished.page%3Fredir%3D/"
        Case "lx":
            Me.UserCookies = sender.item.response.CookiesString
            Dim cs As CString: Set cs = New CString
            cs.Append sender.GETstring
            cs.SetInfo cs.GetElement("userblock", "vieworders")
            UserNick = cs.GetElement("<b>", "</b>")
            If UserNick = "" Then
                xlsHdl.SetStatus "登录失败" & MeName
                Stop
            Else
                xlsHdl.SetStatus "登录成功:" & MeName
                xlsHdl.setValue "SessionCookies", Me.UserCookies, LineIndex
                xlsHdl.setValue "UserNick", Me.UserNick, LineIndex
                If Me.loginNow Then UserList.UserLoginSuccess UserName
            End If
        Case "CheckLogin":
            If InStr(1, sender.GETstring, "problemset.page?code=") > 0 Then
                Me.LoginSuccessed = True
                xlsHdl.SetStatus "已登录" & Me.UserName
            Else
                xlsHdl.SetStatus "未登" & Me.UserName
                Me.LoginSuccessed = False
            End If
    End Select
    Exit Sub
Err:
    Stop
    Resume
End Sub

Private Function LoginInfoCheck(initInfo As String) As Boolean
    Dim json As CJson
    Set json = New CJson
    Dim info As Object
    Set info = json.parse(initInfo)
    Dim msg As String
    msg = info.getValue("resultmsg").ToString
    If msg = "成功" Then
        Dim resultData As Object
        Set resultData = info.getValue("resultData")
        userId = resultData.getValue("accountId").ToString
        accountLoginname = resultData.getValue("accountLoginname").ToString
        accountNickname = resultData.getValue("accountNickname").ToString
        identityId = resultData.getValue("identityId").ToString
        'xlsHdl.SetStatus resultData.ToString
        xlsHdl.SetStatus "欢迎您," & Me.MeName
        LoginSuccessed = True
        LoginInfoCheck = True
    Else
        xlsHdl.SetStatus "账号登录失败," & MeName & vbCrLf & info.ToString
        Stop
    End If
End Function

Private Sub HttpEventDelegate_OnTimeOut(sender As HttpClientChild, e As HttpTimeOutEventHandle)
End Sub
Private Function VerifiesEventDelegate_Cancel() As Long
    xlsHdl.SetStatus "登录请求被取消"
End Function
Private Function VerifiesEventDelegate_Verify(code As String, verName As String, cookies As String) As Long
    UserCookies = cookies
    http.GetHtml "http://dasai.lanqiao.cn/api/action/directmail/checkvcode", "post", "vcode=" & code, UserCookies, ClientId:="CheckCode:" & code
End Function



Private Function GetPostData(code As String) As String
    Dim item As HttpContentItem, cr As New chrConvert
    Set item = New HttpContentItem
    item.AddPostData "login", cr.UrlEncode_GBToUtf8(UserName)
    item.AddPostData "pwd", cr.UrlEncode_GBToUtf8(UserPwd)
    item.AddPostData "vcode", code
    GetPostData = item.PostData
End Function
Public Property Get MeName() As String
    MeName = "[" & index & "/" & UserList.list.Count & "]" & IIf(accountLoginname = "" Or accountLoginname = "null", accountNickname & "(" & UserName & ")", accountNickname & "(" & accountLoginname & ")") & "  " & Me.UserNick
End Property
Private Sub Class_Initialize()
    Set http = New HttpClient
    http.eventHandle = Me
End Sub
