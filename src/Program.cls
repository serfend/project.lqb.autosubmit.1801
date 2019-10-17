VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Program"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit
Implements HttpEventDelegate
#If VBA7 Then
    Private Declare PtrSafe Function GetTickCount Lib "kernel32" () As Long
#Else
    Private Declare Function GetTickCount Lib "kernel32" () As Long
#End If
Private http As HttpClient

Public Sub Run(DefaultIndex As Long)
Dim NowRunUser As Long
    If UserList.list.Count = 0 Then
        If DefaultIndex = -1 Then
            MsgBox "无任何用户可用"
        End If
        NewThread
        Run -1
        Exit Sub
    End If
    If DefaultIndex <= 0 Then
        NowRunUser = Val(InputBox("账号开始Index(1-" & UserList.list.Count & ")", "启动账号", 1))
    ElseIf DefaultIndex > UserList.list.Count Then
        NowRunUser = 1
    Else
        NowRunUser = DefaultIndex
    End If
    If NowRunUser = 0 Then
        xlsHdl.SetStatus "运行所有账号"
        For NowRunUser = 1 To UserList.list.Count
            UserList.list.item(NowRunUser).LoadQues
        Next
    Else
        UserList.list.item(NowRunUser).LoadQues
    End If
End Sub
Private Sub Class_Initialize()
    Set http = New HttpClient
    http.eventHandle = Me
End Sub

Private Sub HttpEventDelegate_BadRequest(sender As HttpClientChild, e As HttpBadRequestEventHandle)
    xlsHdl.SetStatus "HttpEventDelegate_BadRequest" & e.ExceptionInfo
End Sub

Private Sub HttpEventDelegate_BadResponse(sender As HttpClientChild, e As HttpBadResponseEventHandle)
    xlsHdl.SetStatus "HttpEventDelegate_BadResponse" & e.ExceptionInfo
End Sub

Private Sub HttpEventDelegate_DocumentReady(sender As HttpClientChild, e As HttpDocumentReadyEventHandle)
    
End Sub

Private Sub HttpEventDelegate_OnTimeOut(sender As HttpClientChild, e As HttpTimeOutEventHandle)

End Sub



