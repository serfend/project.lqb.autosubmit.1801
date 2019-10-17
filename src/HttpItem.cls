VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "HttpItem"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
'2018.1.6 v1.0
    Public url As String
    Public UserAgent As String
    Public Method As String
    Public Host As String
    Public Refer As String
    Public request As HttpContentItem
    Public response As HttpContentItem
    Public acceptLanguage As String
    Public IfModified As Boolean
    Private targetFile As clsFile
    Public keepHttpChild As Boolean
    Public TimeOut As Long
    Public TimeOutReloadTimeLimit As Long
    Public Property Get file() As clsFile
        Set file = targetFile
    End Property
    Public Property Let file(value As clsFile)
        Set targetFile = value
    End Property
    Public Function Clone() As HttpItem
        Set Clone = New HttpItem
        With Clone
            .Host = Me.Host
            .Method = Me.Method
            .Refer = Me.Refer
            Set .request = Me.request.Clone
            Set .response = Me.response.Clone
            .url = Me.url
            .UserAgent = Me.UserAgent
            .acceptLanguage = Me.acceptLanguage
            .file = targetFile
            .TimeOut = TimeOut
            .TimeOutReloadTimeLimit = TimeOutReloadTimeLimit
            .keepHttpChild = keepHttpChild
        End With
    End Function

Private Sub Class_Initialize()
    Method = "get"
    Set request = New HttpContentItem
    Set response = New HttpContentItem
End Sub

Public Property Get ToString() As String
    Dim cs As New CString
    ToString = cs.Append("HttpItem:{").Append(vbCrLf). _
        Append("url:").Append(url).Append(vbCrLf). _
        Append("UserAgent:").Append(UserAgent).Append(vbCrLf). _
        Append("Method:").Append(Method).Append(vbCrLf). _
        Append("Host:").Append(Host).Append(vbCrLf). _
        Append("Referer:").Append(Refer).Append(vbCrLf). _
        Append("request:").Append(request.ToString).Append(vbCrLf). _
        Append("response:").Append(response.ToString).Append(vbCrLf). _
        Append("acceptLanguage:").Append(acceptLanguage).Append(vbCrLf). _
        Append("TimeOut:").Append(TimeOut).Append(vbCrLf). _
        Append("}").Append(vbCrLf).ToString
End Property
