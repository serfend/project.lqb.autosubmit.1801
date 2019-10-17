VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "HttpContentItem"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
'2018.1.6 v1.0
Public content As String
Private byteContent() As Byte
Public PostDataPayload As CList
Public cookies As CList
Public headers As CList


Public Property Get PostData() As String
    Dim i As Long, cs As New CString
    For i = 1 To PostDataPayload.Count
        Dim key As String, value As CString
        key = PostDataPayload.key(i)
        Set value = PostDataPayload.item(i)
        If value.Length > 0 Then
            If cs.Length > 0 Then cs.Append "&"
            cs.Append(key).Append("=").Append value.ToString
        End If
    Next
    PostData = cs.ToString
End Property
Public Property Let PostData(value As String)
    Dim i As Long
    PostDataPayload.RemoveAll
    Dim tmp() As String, cs As New CString
    tmp = Split(value, "&")
    For i = 0 To UBound(tmp)
        cs.SetInfo tmp(i)
        Dim key As String, values As String
        key = cs.GetElementLeft("=")
        If key <> "" Then
            values = cs.GetElementRight("=")
            AddPostData key, values
        End If
    Next
End Property
Public Sub AddPostData(key As String, value As String)
    Dim cvalue As CString
    Set cvalue = New CString
    cvalue.Append value
    PostDataPayload.setValue key, cvalue
End Sub
Public Sub RemovePostData(key As String)
    PostDataPayload.Remove key
End Sub



Public Property Get CookiesString() As String
    Dim i As Long, cs As New CString
    For i = 1 To cookies.Count
        Dim key As String, value As CString
        key = cookies.key(i)
        Set value = cookies.item(i)
        If value.Length > 0 Then
            If cs.Length > 0 Then cs.Append ";"
            cs.Append(key).Append("=").Append value.ToString
        End If
    Next
    CookiesString = cs.ToString
End Property
Public Property Let CookiesString(ByVal value As String)
    Dim i As Long
    'cookies.RemoveAll
    Dim tmp() As String, cs As New CString
    tmp = Split(value, ";")
    For i = 0 To UBound(tmp)
        cs.SetInfo tmp(i)
        Dim key As String, values As String
        key = cs.GetElementLeft("=")
        If key <> "" Then
            values = cs.GetElementRight("=")
            AddCookies Trim(key), values
        End If
    Next
End Property
Public Sub AddCookies(key As String, value As String)
    Dim cvalue As CString
    Set cvalue = New CString
    cvalue.Append value
    cookies.setValue key, cvalue
End Sub
Public Sub RemoveCookies(key As String)
    cookies.Remove key
End Sub


Public Property Get data() As Byte()
    data = byteContent
End Property
Public Property Let data(value() As Byte)
    byteContent = value
End Property
Public Sub SetPostDataFromList(list As CList)
    Set PostDataPayload = list.Clone
End Sub
Public Function Clone() As HttpContentItem
    Set Clone = New HttpContentItem
    With Clone
        .content = Me.content
        Set .cookies = Me.cookies.Clone
        Set .PostDataPayload = Me.PostDataPayload.Clone
        Set .headers = Me.headers.Clone
    End With
End Function

Private Sub Class_Initialize()
    Set cookies = New CList
    Set PostDataPayload = New CList
    Set headers = New CList
End Sub

Public Property Get ToString() As String
    Dim cs As New CString
    ToString = cs.Append("HttpContentItem:{").Append(vbCrLf). _
                    Append("content:").Append(IIf(Len(content) > 10, Left(content, 7) & "...", content)).Append(vbCrLf). _
                    Append("postData:").Append(IIf(Len(PostData) > 35, Left(PostData, 35) & "...", PostData)).Append(vbCrLf).Append("}").Append(vbCrLf).ToString
                    
End Property
