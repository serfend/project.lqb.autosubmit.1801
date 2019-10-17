VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "HttpClientChild"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Implements HttpApiEventDelegate
Public eventHandle As HttpEventDelegate
Private winHttp As HttpAPI
Private targetItem As HttpItem
Public ClientId As String
#If VBA7 Then
    Private Declare PtrSafe Function GetTickCount Lib "kernel32" () As Long
#Else
    Private Declare Function GetTickCount Lib "kernel32" () As Long
#End If
Private documentLoaded As Boolean
Private lastUserAgent As String
Private proxyBeginTime As Long, proxyEndTime As Long
Public Property Get InnerHttp() As HttpAPI
    Set InnerHttp = winHttp
End Property
Public Property Get DocumentReady() As Boolean
    DocumentReady = documentLoaded
End Property
Public Property Get proxyTime() As Long
    If documentLoaded Then
        proxyTime = proxyEndTime - proxyBeginTime
    Else
        proxyTime = GetTickCount - proxyBeginTime
    End If
End Property

Public Function GetLastUserAgent() As String
    GetLastUserAgent = lastUserAgent
End Function
Public Property Get item() As HttpItem
    Set item = targetItem
End Property
Public Property Let item(value As HttpItem)
    Set targetItem = value
End Property
Public Sub OnBadRequest()
    If Not eventHandle Is Nothing Then
        Dim e As HttpBadRequestEventHandle
        Set e = New HttpBadRequestEventHandle
        e.Init winHttp.http, Err.Number, Err.Descriptio
        eventHandle.BadRequest Me, e
    End If
End Sub
Public Sub OnBadResponse()
    If Not eventHandle Is Nothing Then
        Dim e As HttpBadResponseEventHandle
        Set e = New HttpBadResponseEventHandle
        e.Init winHttp.http, Err.Number, Err.Descriptio
        eventHandle.BadResponse Me, e
    End If
End Sub
Public Sub OnDocumentReady()
    documentLoaded = True
    SetDocument
    If Not eventHandle Is Nothing Then
        Dim e As HttpDocumentReadyEventHandle
        Set e = New HttpDocumentReadyEventHandle
        e.Init winHttp.http
        eventHandle.DocumentReady Me, e
    End If
End Sub
Private Sub SetDocument()
On Error Resume Next
    proxyEndTime = GetTickCount
    
    targetItem.response.data = winHttp.http.ResponseBody
    targetItem.response.content = BytesToBstr(targetItem.response.data, "utf-8")
    If Not item.file Is Nothing Then
        item.file.data = winHttp.http.ResponseBody
        item.file.SaveBinary
    End If
    If targetItem.keepHttpChild Then
        targetItem.response.CookiesString = targetItem.request.CookiesString & ";" & GetAllSetCookies
    End If
End Sub
Private Function GetAllSetCookies() As String
    Dim cs As New CString
    Dim heades As String, tmp() As String
    heades = winHttp.http.GetAllResponseHeaders
    Dim i As Long
    tmp = Split(heades, chr(10))
    For i = 1 To UBound(tmp)
        If InStr(1, tmp(i), "Set-Cookie:") > 0 Then
            Dim thisCookies() As String
            thisCookies = Split(Replace(tmp(i), "Set-Cookie:", ""), ";")
            Dim j As Long
            For j = 0 To UBound(thisCookies)
                If InStr(1, thisCookies(j), "=") > 0 Then
                    If InStr(1, thisCookies(j), " Path=") <= 0 Then
                        cs.Append(thisCookies(j)).Append ";"
                    End If
                End If
            Next
        End If
    Next
    GetAllSetCookies = cs.ToString
End Function
Private Sub Class_Initialize()
    Set winHttp = New HttpAPI
    winHttp.eventHandle = Me
    'winHttp.http.setProxy 2, "127.0.0.1:8888"
End Sub

Public Function GETstring() As String
    If Not documentLoaded Then Exit Function
    GETstring = targetItem.response.content
End Function
Public Function GetByte() As Byte()
    If Not documentLoaded Then Exit Function
    GetByte = targetItem.response.data
End Function
Private Function GetRandomUserAgent() As String
    'GetRandomUserAgent = "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 Safari/537.36"
    'Exit Function
    Dim i  As Long
    Dim tmp As String
    tmp = "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_8; en-us) AppleWebKit/534.50 (KHTML, like Gecko) Version/5.1 Safari/534.50$Mozilla/5.0 (Windows; U; Windows NT 6.1; en-us) AppleWebKit/534.50 (KHTML, like Gecko) Version/5.1 Safari/534.50$Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0"
    'Mozilla/5.0 (Windows NT 6.1; rv:2.0.1) Gecko/20100101 Firefox/4.0.1$Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_3_3 like Mac OS X; en-us) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8J2 Safari/6533.18.5$MQQBrowser/26 Mozilla/5.0 (Linux; U; Android 2.3.7; zh-cn; MB200 Build/GRJ22; CyanogenMod-7) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1
    Dim tmps() As String
    tmps = Split(tmp, "$")
    Dim nums As Long
    nums = UBound(tmps)
    i = CInt(Rnd() * (1 + nums) - 0.5)
    GetRandomUserAgent = tmps(i)
    GetRandomUserAgent = GetRandomUserAgent & " " & CInt(Rnd() * 1000)
    lastUserAgent = GetRandomUserAgent
End Function
Public Sub setHeader(Optional item As HttpItem = Nothing)
    CheckItem item
    With winHttp.http
        'If item.TimeOut > 0 Then .setTimeouts
        '.setTimeouts 1000, 1000, 1000, 1000
        
        .SetRequestHeader "Content-Type", "application/x-www-form-urlencoded"
        If Not item.IfModified Then
            .SetRequestHeader "If-Modified-Since", "0"
        Else
            '.setRequestHeader "If-Modified-Since", "1"
        End If
        If item.UserAgent = "" Then
            .SetRequestHeader "User-Agent", GetRandomUserAgent
        Else
            .SetRequestHeader "User-Agent", item.UserAgent
        End If
        If Not item.request.cookies Is Nothing Then
            If item.request.cookies.Count > 0 Then
                .SetRequestHeader "Cookie", Replace(item.request.CookiesString, chr(13), "")
            End If
        End If
        Dim i As Long
        For i = 1 To item.request.headers.Count
            .SetRequestHeader item.request.headers.key(i), item.request.headers.item(i).ToString
        Next
        If item.Refer <> "" Then .SetRequestHeader "Referer", item.Refer
        If item.acceptLanguage <> "" Then .SetRequestHeader "Accept-Language", item.acceptLanguage
        If item.Host <> "" Then .SetRequestHeader "Host", item.Host
    End With
End Sub
Public Function Reload() As Boolean
    Reload = GetResponse
End Function
Public Function GetResponse(Optional item As HttpItem = Nothing, Optional syn As Boolean = True) As Boolean
On Error GoTo ErrHand:
    GetResponse = True
    CheckItem item
    With winHttp.http
        proxyBeginTime = GetTickCount
        .Open targetItem.Method, targetItem.url, syn
        setHeader targetItem
        If targetItem.Method = "get" Then
            .Send
        Else
            .Send targetItem.request.PostData
        End If
        
    End With
Exit Function
ErrHand:
    Select Case Err.Number
        Case -2146697212: '连接到服务器失败
            GetResponse = GetResponse(item, syn)
        Case 28:
            GetResponse = False
        Case Else:
            OnBadRequest
    End Select

End Function
Public Function GetResponseAsyn(Optional item As HttpItem = Nothing, Optional TimeOut As Long = 5000, Optional tryTime As Long = 3) As HttpContentItem
    If tryTime = 0 Then Exit Function
    GetResponse item, False
    proxyBeginTime = GetTickCount
    Do
        If GetTickCount - proxyBeginTime > TimeOut Then
            Set GetResponseAsyn = GetResponseAsyn(item, TimeOut, tryTime - 1)
            Exit Function
        End If
        DoEvents
    Loop Until documentLoaded
    Set GetResponseAsyn = item.response
End Function
Public Sub CheckItem(item As HttpItem)
    If Not item Is Nothing Then
        Set targetItem = item.Clone
    End If
    If targetItem.keepHttpChild Then
        Set item = targetItem
    End If
End Sub


Private Function BytesToBstr(Bytes, Unicode As String) As String

    Dim objstream As Object
    Set objstream = CreateObject("ADODB.Stream")
    With objstream
        .Type = 1
        .Mode = 3
        .Open
        .Write Bytes
        .Position = 0
        .Type = 2
        .Charset = Unicode
        BytesToBstr = .ReadText
       .Close
    End With
End Function

 '判断网页编码函数
Private Function IsUTF8(Bytes) As Boolean
        Dim i As Long, AscN As Long, Length As Long
        Length = UBound(Bytes) + 1
       
        If Length < 3 Then
            IsUTF8 = False
            Exit Function
        ElseIf Bytes(0) = &HEF And Bytes(1) = &HBB And Bytes(2) = &HBF Then
            IsUTF8 = True
            Exit Function
        Else '默认判断为utf-8
            IsUTF8 = True
            Exit Function
        End If

        Do While i <= Length - 1
            If Bytes(i) < 128 Then
                i = i + 1
                AscN = AscN + 1
            ElseIf (Bytes(i) And &HE0) = &HC0 And (Bytes(i + 1) And &HC0) = &H80 Then
                i = i + 2

            ElseIf i + 2 < Length Then
                If (Bytes(i) And &HF0) = &HE0 And (Bytes(i + 1) And &HC0) = &H80 And (Bytes(i + 2) And &HC0) = &H80 Then
                     i = i + 3
                Else
                    IsUTF8 = False
                    Exit Function
                End If
            Else
                IsUTF8 = False
                Exit Function
            End If
        Loop
               
        If AscN = Length Then
            IsUTF8 = False
        Else
            IsUTF8 = True
        End If

End Function
Private Sub OnTimeOut()
    documentLoaded = True
    proxyEndTime = GetTickCount
    If Not eventHandle Is Nothing Then
        Dim e As HttpTimeOutEventHandle
        Set e = New HttpTimeOutEventHandle
        e.Init proxyTime, InnerHttp.data
        eventHandle.OnTimeOut Me, e
    End If
End Sub
Private Sub HttpApiEventDelegate_OnError(sender As HttpAPI, e As HttpExceptionEventHandle)
    Select Case e.ErrorNumber
        Case -2147012894:
            OnTimeOut
        Case Else:
            Debug.Print "HttpApiEventDelegate_OnError." & e.ErrorNumber & ":" & e.ErrorDescription
    End Select
End Sub

Private Sub HttpApiEventDelegate_OnResponseDataAvailable(sender As HttpAPI, e As HttpDataAvilableEventHandle)
    '暂时不需要，或许以后用于提供访问效率
    'if getInfoINeed(e.data) then
    '   winhttp.http.Abort
    'end if
End Sub

Private Sub HttpApiEventDelegate_OnResponseFinished(sender As HttpAPI)
    OnDocumentReady
End Sub

Private Sub HttpApiEventDelegate_OnResponseStart(sender As HttpAPI, e As HttpResponseEventHandle)
    '已成功解析服务器
End Sub
