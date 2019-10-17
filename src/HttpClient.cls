VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "HttpClient"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Implements HttpEventDelegate
Private pEventHandle As HttpEventDelegate
Private Child() As HttpClientChild, freeChild() As Long
Private item As HttpItem
Private userAgentScorce As String, userAgentBase() As String
Private Enum ChildStatus
    NoElement = 1
    NotBuild = 2
    NotReady = 3
    Ready = 4
End Enum
    Public Property Get eventHandle() As HttpEventDelegate
        Set eventHandle = pEventHandle
    End Property
    Public Property Let eventHandle(value As HttpEventDelegate)
        Set pEventHandle = value
    End Property
    Public Property Get InnerItem() As HttpItem
        Set InnerItem = item
    End Property
    Public Property Let InnerItem(value As HttpItem)
        Set item = value
    End Property
    
    Public Sub SetItem(http As HttpItem)
        Set item = http.Clone
    End Sub
    Public Function GetItem() As HttpItem
        Set GetItem = item.Clone
    End Function
    Public Function CheckNet(url As String) As Boolean
        logger.LogInfo "HttpClient(" & item.url & ").CheckNet(" & url & ")"
        If MsgBox("请求检查网络状态,是否允许访问:" & vbCrLf & url, vbQuestion Or vbYesNo) = vbYes Then
            ShellExecute 0&, vbNullString, url, vbNullString, vbNullString, vbNormalFocus
            CheckNet = True
        End If
    End Function
    Public Function GetHtml(Optional url As String = "#null#", Optional Method As String = "#null#", Optional PostData As String = "#null#" _
    , Optional cookies As String = "#null#", Optional UserAgent As String = "#null#", Optional Host As String = "#null#", Optional Refer As String = "#null#" _
    , Optional ifMod As Boolean = False, Optional TimeOut As Long = -1, Optional KeepContext As Boolean = False, Optional ChildIndex As Long = -1, Optional ClientId As String = "") As Long
        If url <> "#null#" Then item.url = url
        If Method <> "#null#" Then item.Method = Method
        If PostData <> "#null#" Then item.request.PostData = PostData
        If UserAgent <> "#null#" Then item.UserAgent = UserAgent
        If cookies <> "#null#" Then item.request.CookiesString = cookies
        If Host <> "#null#" Then item.Host = Host
        If Refer <> "#null#" Then item.Refer = Refer
        item.IfModified = ifMod
        item.TimeOut = TimeOut
        item.keepHttpChild = KeepContext
        GetHtml = NewChild(ChildIndex, ClientId)
        If GetHtml = -1 Then
            logEvent "GetHtml(" & GetHtml & ")", "已取消加载:" & url
        Else
            'logEvent "GetHtml(" & GetHtml & ")", "加载:" & url
        End If
    End Function
    Public Sub AbortAll()
        Dim i As Long
        For i = 1 To UBound(Child)
            If Not Child(i) Is Nothing Then
                Child(i).InnerHttp.http.Abort
            End If
        Next
    End Sub
    Public Function GetLastUserAgent(index As Long) As String
        If GetChild(index) Is Nothing Then Exit Function
        GetLastUserAgent = GetChild(index).GetLastUserAgent
    End Function
    Public Function GetResultString(index As Long) As String
        If index = -1 Then Exit Function
        If GetChildStatus(index) <> Ready Then Exit Function
        GetResultString = Child(index).GETstring
        NewFreeChild index
    End Function
    Public Function GetResultByte(index As Long) As Byte()
        If GetChildStatus(index) <> Ready Then Exit Function
        GetResultByte = Child(index).GetByte
        NewFreeChild index
    End Function

    Public Function ChildIsReady(index As Long) As Boolean
        If index = -1 Then
           ChildIsReady = True
           Exit Function
        End If
        If GetChildStatus(index) = Ready Then ChildIsReady = True
    End Function
    Public Sub ChildReLoad(index As Long)
        If GetChild(index) Is Nothing Then Exit Sub
        While Not GetChild(index).Reload
            If MsgBox("网页获取失败:" & item.url & vbCrLf & "是否重新获取?", vbYesNo) = vbNo Then
                Exit Sub
            End If
        Wend
    End Sub

    Private Function GetChildStatus(index As Long) As ChildStatus
        If UBound(Child) < index Then
            GetChildStatus = NoElement
            logEvent "GetChildStatus(" & index & ")", "请求获取的元素超出范围"
            Exit Function
        End If
        If Child(index) Is Nothing Then
            GetChildStatus = NotBuild
            logEvent "GetChildStatus(" & index & ")", "请求获取的元素未被实例化"
            Exit Function
        End If
        If Child(index).DocumentReady Then
            GetChildStatus = Ready
            logEvent "GetChildStatus(" & index & ")", "请求获取的元素已完成,url:" & Child(index).item.url
        Else
            GetChildStatus = NotReady
            'logEvent "GetChildStatus(" & index & ")", "请求获取的元素未完成获取"
        End If
    End Function
    Private Function NewChild(Optional index As Long = -1, Optional ClientId As String) As Long
    On Error GoTo Err:
        If index = -1 Then
            NewChild = GetFreeChild
            If NewChild >= UBound(Child) Or NewChild = 0 Then
                Dim ChildNum As Long
                ChildNum = UBound(Child) + 1
                ReDim Preserve Child(ChildNum)
                
                NewChild = ChildNum
            End If
            Set Child(NewChild) = New HttpClientChild
            Set Child(NewChild).eventHandle = Me
        Else
            NewChild = index
        End If
        Child(NewChild).ClientId = ClientId
        While Not Child(NewChild).GetResponse(item)
            If MsgBox("网页获取失败:" & item.url & vbCrLf & "是否重新获取?", vbYesNo) = vbNo Then
                NewFreeChild NewChild
                NewChild = -1
                Exit Function
            End If
        Wend
        Exit Function
Err:
        Debug.Print Err.Description
        
        Stop
        Resume
    End Function
    Private Function GetChild(index As Long) As HttpClientChild
        If UBound(Child) < index Then
            logEvent "GetChildStatus(" & index & ")", "请求获取的元素超出范围"
            Exit Function
        End If
        If Child(index) Is Nothing Then
            logEvent "GetChildStatus(" & index & ")", "请求获取的元素未被实例化"
            Exit Function
        End If
        Set GetChild = Child(index)
    End Function
    
    Private Sub NewFreeChild(ChildIndex As Long)
        Set Child(ChildIndex) = Nothing
        ReDim Preserve freeChild(UBound(freeChild) + 1)
        freeChild(UBound(freeChild)) = ChildIndex
    End Sub
    Private Function GetFreeChild() As Long
        If UBound(freeChild) = 0 Then
            Exit Function
        Else
            GetFreeChild = freeChild(UBound(freeChild))
            ReDim Preserve freeChild(UBound(freeChild) - 1)
        End If
    End Function
    
        Private Sub logEvent(fromMethod As String, info As String)
            logger.LogInfo "HttpClient." & fromMethod & ": " & info
        End Sub
Private Sub Class_Initialize()
    Set item = New HttpItem
    ReDim Child(0)
    ReDim freeChild(0)
    initUserAgent
End Sub

Public Property Get RandomAgent() As String
    
End Property
Private Sub initUserAgent()
    userAgentScorce = ""
End Sub

Private Sub HttpEventDelegate_BadRequest(sender As HttpClientChild, e As HttpBadRequestEventHandle)
    If Not pEventHandle Is Nothing Then
        pEventHandle.BadRequest sender, e
    End If
End Sub

Private Sub HttpEventDelegate_BadResponse(sender As HttpClientChild, e As HttpBadResponseEventHandle)
    If Not pEventHandle Is Nothing Then
        pEventHandle.BadResponse sender, e
    End If
End Sub

Private Sub HttpEventDelegate_DocumentReady(sender As HttpClientChild, e As HttpDocumentReadyEventHandle)
On Error GoTo Err:
    If Not pEventHandle Is Nothing Then
        pEventHandle.DocumentReady sender, e
    End If
    Exit Sub
Err:
    Stop
    Resume
End Sub
 
Private Sub HttpEventDelegate_OnTimeOut(sender As HttpClientChild, e As HttpTimeOutEventHandle)
    If Not pEventHandle Is Nothing Then
        pEventHandle.OnTimeOut sender, e
    End If
End Sub
