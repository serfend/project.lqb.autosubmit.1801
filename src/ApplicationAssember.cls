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
    justLogin = Sheets(SheetSys).Cells(12, 2) = "����"
End Property
Public Property Get ResetAllCode() As Boolean
    ResetAllCode = Sheets(SheetSys).Cells(11, 2) = "����"
    If ResetAllCode Then xlsHdl.SetStatus "������������,�Ҵ����������ɹ��ܿ���,��������ing~~"
End Property
Public Property Get codeMode() As Long
    codeMode = IIf(Sheets(SheetSys).Cells(6, 2) = "����", 1, 0)
    If codeMode = 1 Then '�Զ�����
        'ʹ�ñ��/ʹ���Զ�����
        codeMode = IIf(Sheets(SheetSys).Cells(9, 2) = "����", 2, 3)
    Else '�ɼ����/�ɼ���������
        codeMode = IIf(Sheets(SheetSys).Cells(9, 2) = "����", 1, 0)
    End If
End Property
Public Property Get AutoSwitchUser() As Boolean
    AutoSwitchUser = Sheets(SheetSys).Cells(7, 2) = "����"
End Property
Public Property Get MainUserName() As String
    MainUserName = Sheets(SheetSys).Cells(5, 2)
End Property
Public Property Get UserLoginWait() As Long
    UserLoginWait = 5000
    xlsHdl.SetStatus "�û���¼�ȴ���������Ӧ..." & UserLoginWait & "ms"
End Property
Public Property Get getBeenBanInterval() As Long
    '����������ָܻ��أ�6Сʱ��
    getBeenBanInterval = 6 * 3600000
End Property
Public Property Get GetDataInterval() As Long
    '�ﵽ������������Ϣ�ļ�����Է�ban
    GetDataInterval = 300000 '5����
End Property
Public Property Get GetDataMaxSingleNum() As Long
    'ÿ���˺�ÿ������ȡ���ݴε���
    GetDataMaxSingleNum = 3
End Property
Public Property Get QuestionDataDownloadInterval() As Long
    QuestionDataDownloadInterval = 2000
    xlsHdl.SetStatus "�������ݷ�ban���..." & QuestionDataDownloadInterval & "ms"
End Property
Public Property Get WaitForLqbToJudge() As Long
    WaitForLqbToJudge = 5000
    xlsHdl.SetStatus "�ȴ����ű���վ���н��and��ban..." & WaitForLqbToJudge & "ms"
End Property
Public Property Get WaitForLqbToAllowMeGoDie() As Long
    WaitForLqbToAllowMeGoDie = 30000
    xlsHdl.SetStatus "�ȴ����ű���վ�����ύ..." & WaitForLqbToAllowMeGoDie & "ms"
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
    'Sheets(SheetData).Cells(1, 1) = "����"
End Sub
