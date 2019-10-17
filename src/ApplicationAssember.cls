VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "ApplicationAssember"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Private appPath As String
Private lastPageIndex As Long
Private lastKeywordIndex As Long
Private LanqiaoUserId As String
Public Property Get path() As String
    path = appPath
End Property
Public Property Get Version() As String
    Version = "1.0.0"
End Property
Private Sub Class_Initialize()
    appPath = ThisWorkbook.path
    lastKeywordIndex = 1
    lastPageIndex = 1
End Sub
Public Property Get justLogin() As Boolean
    justLogin = Sheets(SheetSys).Cells(12, 2) = "启用"
End Property
Public Property Get ResetAllCode() As Boolean
    ResetAllCode = Sheets(SheetSys).Cells(11, 2) = "启用"
    If ResetAllCode Then xlsHdl.SetStatus "数据下载跳过,且代码重新生成功能开启,重新生成ing~~"
End Property
Public Property Get codeMode() As Long
    codeMode = IIf(Sheets(SheetSys).Cells(6, 2) = "启用", 1, 0)
    If codeMode = 1 Then '自动答题
        '使用标程/使用自动生成
        codeMode = IIf(Sheets(SheetSys).Cells(9, 2) = "启用", 2, 3)
    Else '采集标程/采集测试数据
        codeMode = IIf(Sheets(SheetSys).Cells(9, 2) = "启用", 1, 0)
    End If
End Property
Public Property Get AutoSwitchUser() As Boolean
    AutoSwitchUser = Sheets(SheetSys).Cells(7, 2) = "启用"
End Property
Public Property Get MainUserName() As String
    MainUserName = Sheets(SheetSys).Cells(5, 2)
End Property
Public Property Get UserLoginWait() As Long
    UserLoginWait = 5000
    xlsHdl.SetStatus "用户登录等待服务器响应..." & UserLoginWait & "ms"
End Property
Public Property Get getBeenBanInterval() As Long
    '被封禁后多久能恢复呢？6小时吧
    getBeenBanInterval = 6 * 3600000
End Property
Public Property Get GetDataInterval() As Long
    '达到最大次数后需休息的间隔，以防ban
    GetDataInterval = 300000 '5分钟
End Property
Public Property Get GetDataMaxSingleNum() As Long
    '每个账号每次最大获取数据次的数
    GetDataMaxSingleNum = 3
End Property
Public Property Get QuestionDataDownloadInterval() As Long
    QuestionDataDownloadInterval = 2000
    xlsHdl.SetStatus "下载数据防ban间隔..." & QuestionDataDownloadInterval & "ms"
End Property
Public Property Get WaitForLqbToJudge() As Long
    WaitForLqbToJudge = 5000
    xlsHdl.SetStatus "等待蓝桥杯网站评判结果and防ban..." & WaitForLqbToJudge & "ms"
End Property
Public Property Get WaitForLqbToAllowMeGoDie() As Long
    WaitForLqbToAllowMeGoDie = 30000
    xlsHdl.SetStatus "等待蓝桥杯网站允许提交..." & WaitForLqbToAllowMeGoDie & "ms"
End Property
Public Property Get GetSettingPath() As String
    GetSettingPath = Sheets(SheetSys).Cells(2, 5)
End Property
Public Property Get MaxThread() As Long
    MaxThread = Sheets(SheetSys).Cells(3, 5)
End Property
Public Property Get MaxPageTaskNum() As Long
    MaxPageTaskNum = Sheets(SheetSys).Cells(4, 5)
End Property
Public Property Get TaskInterval() As Long
    TaskInterval = Sheets(SheetSys).Cells(5, 5)
End Property

Public Function GetHistoryId() As String
    GetHistoryId = Sheets(SheetSys).Cells(1, 6)
End Function
Public Function NewHistoryId() As String
    Sheets(SheetSys).Cells(1, 6) = Format(Now, "yyyyMMddhhmmss")
    LastPageLoadIndex = 1
    lastKeywordSearchIndex = 1
End Function
Public Sub ClearAllDataset()
    xlsHdl.Clear
    xlsData.Clear
    'Sheets(SheetData).Cells.Delete Shift:=xlUp
    'Sheets(SheetData).Cells(1, 1) = "类型"
End Sub

