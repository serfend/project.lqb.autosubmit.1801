VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "HttpAPI"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
#If VBA7 Then
    Private Declare PtrSafe Function GetTickCount Lib "kernel32" () As Long
    Private Declare PtrSafe Sub CopyMemory Lib "ntdll" Alias "RtlMoveMemory" (Destination As Any, Source As Any, ByVal Length As Long)
    Private m_lpBuffer As LongPtr
#Else
    Private Declare Function GetTickCount Lib "kernel32" () As Long
    Private Declare Sub CopyMemory Lib "ntdll" Alias "RtlMoveMemory" (Destination As Any, Source As Any, ByVal Length As Long)
    Private m_lpBuffer As Long
#End If
Public WithEvents http As winHttp.WinHttpRequest
Attribute http.VB_VarHelpID = -1
Private pEventHandle As HttpApiEventDelegate
Private DataCollection As New Collection

Public Property Let eventHandle(value As HttpApiEventDelegate)
    Set pEventHandle = value
End Property
Public Property Get data() As Byte()
    Dim i As Long, dataLen As Long
    For i = 1 To DataCollection.Count
        dataLen = dataLen + UBound(DataCollection(i).data)
    Next
    Dim tmp() As Byte, sourceTmp() As Byte
    ReDim tmp(dataLen)
    
    dataLen = 0
    For i = 1 To DataCollection.Count
        sourceTmp = DataCollection(i).data
        m_lpBuffer = VarPtr(tmp(dataLen))
        Call CopyMemory(ByVal m_lpBuffer, ByVal VarPtr(sourceTmp(0)), UBound(sourceTmp))
        dataLen = dataLen + UBound(sourceTmp)
    Next
    data = tmp
End Property
Private Sub Class_Initialize()
    Set http = New winHttp.WinHttpRequest
End Sub

Private Sub http_OnError(ByVal ErrorNumber As Long, ByVal ErrorDescription As String)
    If Not pEventHandle Is Nothing Then
        Dim e As HttpExceptionEventHandle
        Set e = New HttpExceptionEventHandle
        e.Init ErrorNumber, ErrorDescription
        pEventHandle.OnError Me, e
    End If
End Sub

Private Sub http_OnResponseDataAvailable(data() As Byte)
    Dim e As HttpDataAvilableEventHandle
    Set e = New HttpDataAvilableEventHandle
    e.Init data
    DataCollection.Add e
    If Not pEventHandle Is Nothing Then
        pEventHandle.OnResponseDataAvailable Me, e
    End If
End Sub

Private Sub http_OnResponseFinished()
    If Not pEventHandle Is Nothing Then
        pEventHandle.OnResponseFinished Me
    End If
End Sub

Private Sub http_OnResponseStart(ByVal Status As Long, ByVal ContentType As String)
    Set DataCollection = New Collection
    If Not pEventHandle Is Nothing Then
        Dim e As HttpResponseEventHandle
        Set e = New HttpResponseEventHandle
        e.Init Status, ContentType
        pEventHandle.OnResponseStart Me, e
    End If
End Sub
