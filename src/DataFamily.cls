VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "DataFamily"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit
Private pId As String, pParent As DataFamily, pNos As String, pName As String, pChild() As String, pInit As Boolean
Public Enum cst
    Nos = 2
    Name = 4
    Id = 14
    Parent = 15
    Child = 16
End Enum
'init 如果不存在则新建并实例化，如果存在则加载存在项
'
'
'
'

'公有方法
    '初始化 返回是否初始化成功
    Public Function Init(Nos As String, Optional sName As String = "") As Boolean
    On Error GoTo Err:
        If Nos = "" Then Exit Function
        
        pInit = True
        Dim targetRow As Long
        序号 = Nos
        targetRow = getRowByType(cst.Nos, Nos)
        If targetRow <= 1 Then
            createNew
            Init = True
        End If
        If sName <> "" Then 名称 = sName
        If Init Then Exit Function
        SynInfo targetRow
        
        If pId = "" Then
            Init = False
            Exit Function
        Else
            Init = True
        End If
        If pName = "" Then 名称 = "未命名"
        Exit Function
Err:
        Stop
        Resume
    End Function
    
    Public Sub addChild(Child As DataFamily)
    On Error GoTo Err:
        If Not Child.父项 Is Nothing Then
            Child.setParent Me
        Else
            Child.父项 = Me
        End If
        ownChild Child
        SynInfo getRowById(pId)
        Exit Sub
Err:
        Stop
        Resume
    End Sub
    Public Sub removeChild(Child As DataFamily)
    On Error GoTo Err:
        dropChild Child.systemId
        SynInfo getRowById(pId)
        Exit Sub
Err:
        Stop
        Resume
    End Sub
    Public Sub setParent(newParent As DataFamily)
    On Error GoTo Err:
        If Not pParent Is Nothing Then
            pParent.removeChild Me
        End If
        Set pParent = newParent
        SetInfo cst.Parent, getRowById(pId), newParent.systemId
        SynInfo getRowById(pId)
        Exit Sub
Err:
        Stop
        Resume
    End Sub
    Public Function ToString(Optional NowRank As Long = 0) As String
    On Error GoTo Err:
        Dim tmp As New CString
        tmp.Append(Space(NowRank * 2)).Append("[Id:").Append(pId).Append(",Name:").Append(pName).Append(",NO:").Append pNos
        If Not pParent Is Nothing Then tmp.Append(",parent:").Append pParent.systemId
        tmp.Append "]"
        If UBound(pChild) > 0 Then
            tmp.Append("{").Append vbCrLf
            Dim i As Long
            For i = 1 To UBound(pChild)
                If Not getData(Id, pChild(i)) Is Nothing Then tmp.Append(Space(NowRank * 2)).Append getData(Id, pChild(i)).ToString(NowRank + 1)
            Next
            tmp.Append(Space(NowRank * 2)).Append("}").Append vbCrLf
        Else
            tmp.Append vbCrLf
        End If
        ToString = tmp.ToString
        Exit Function
Err:
        Stop
        Resume
    End Function
    
    '属性
    Public Property Get rank() As Long
        If pParent Is Nothing Then Exit Property
        rank = 1 + pParent.rank
    End Property
    Public Property Get 名称() As String
        名称 = pName
    End Property
    Public Property Let 名称(value As String)
        SetInfo cst.Name, getRowById(pId), value
        pName = value
    End Property
    Public Property Get 序号() As String
        序号 = pNos
    End Property
    Public Property Let 序号(value As String)
        SetInfo cst.Nos, getRowById(pId), value
        pNos = value
    End Property
    Public Property Get inited() As Boolean
        inited = pInit
    End Property
    Public Sub setValue(colIndex As Long, value As String)
        If colIndex = cst.Id Then Exit Sub
        setInfoSys getRowById(pId), colIndex, value
    End Sub
    Public Property Get 子项() As String()
        子项 = pChild
    End Property
    Public Property Get 父项() As DataFamily
        Set 父项 = pParent
    End Property
    Public Property Let 父项(value As DataFamily)
        Set pParent = value
        SetInfo Parent, getRowById(pId), value.systemId
    End Property
    
'3 操作本类
    '实例化
    Public Function Clone() As DataFamily
        Dim tmp As New DataFamily
        tmp.systemNew pId, pName, pNos, pParent, pChild
    End Function
    'id/name/nos/
    Public Sub systemNew(var1 As String, var2 As String, var3 As String, varParent As DataFamily, varChild() As String)
    On Error GoTo Err:
        pId = var1
        pName = var2
        pNos = var3
        Set pParent = varParent
        pChild = varChild
        Exit Sub
Err:
        Stop
        Resume
    End Sub
    Private Sub createNew()
        Dim tarRow As Long
        tarRow = getFreeRowIndex
        SetInfo Nos, tarRow, pNos
        pId = createId
        SetInfo cst.Id, tarRow, pId
        SetInfo cst.Parent, tarRow, createId
    End Sub

'2 类数据
    Private Sub ownChild(Child As DataFamily)
    On Error GoTo Err:
        If ChildExist(Child) Then Exit Sub
        Dim childCount As Long
        childCount = UBound(pChild) + 1
        ReDim Preserve pChild(childCount)
        pChild(childCount) = Child.systemId
        SynChild
        Exit Sub
Err:
        Stop
        Resume
    End Sub
    Private Sub dropChild(childId As String)
    On Error GoTo Err:
        Dim i As Long
        For i = 1 To UBound(pChild)
            If getData(Id, pChild(i)).systemId = childId Then
                Dim j As Long
                For j = i To UBound(pChild) - 1
                    pChild(j) = pChild(j + 1)
                Next
                ReDim Preserve pChild(UBound(pChild) - 1)
                SynChild
                Exit Sub
            End If
        Next
        SynChild
        Exit Sub
Err:
        Stop
        Resume
    End Sub
    Private Sub SynInfo(index As Long)
        On Error GoTo Err:
        pId = GetInfo(Id, index)
        pName = GetInfo(Name, index)
        Set pParent = getData(cst.Id, GetInfo(Parent, index))
        Dim tmp() As String, i As Long
        tmp = Split(GetInfo(Child, index), ",")
        If UBound(tmp) > 0 Then
            ReDim pChild(UBound(tmp))
            For i = 1 To UBound(tmp)
                pChild(i) = tmp(i)
            Next
        End If
        pNos = GetInfo(Nos, index)

        Exit Sub
Err:
        Stop
        Resume
    End Sub
    Private Function getData(fromCompareCol As cst, value As String) As DataFamily
    On Error GoTo Err:
        If value = "" Then Exit Function
        Dim tmp As New DataFamily
        Dim targetRow As Long
        targetRow = getRowByType(fromCompareCol, value)
        If targetRow <= 1 Then Exit Function
        tmp.Init GetInfo(Nos, targetRow)
        Set getData = tmp
        Exit Function
Err:
        Stop
        Resume
    End Function
    Private Function getRowById(Id As String) As Long
        getRowById = getRowByType(cst.Id, Id)
    End Function

'1 数据获取与设置
    Private Function ChildExist(Child As DataFamily) As Boolean
    On Error GoTo Err:
        Dim i As Long
        For i = 1 To UBound(pChild)
            If getData(Id, pChild(i)).systemId = Child.systemId Then
                ChildExist = True
                Exit Function
            End If
        Next
        Exit Function
Err:
        Stop
        Resume
    End Function
    Private Sub SynChild()
        Dim tmp As New CString, i As Long
        For i = 1 To UBound(pChild)
            tmp.Append(",").Append getData(Id, pChild(i)).systemId
        Next
        SetInfo cst.Child, getRowById(pId), tmp.ToString
    End Sub
    Public Function getInfoByType(compareCol As cst, value As String, colIndex As Long) As String
        Dim tmp As Long
        tmp = getRowByType(compareCol, value)
        If tmp > 1 Then getInfoByType = Sheets(SheetData).Cells(tmp, colIndex)
    End Function
    Private Function getRowByType(compareCol As cst, value As String) As Long
        Dim i As Long
        For i = 2 To Sheets(SheetData).UsedRange.rows.Count
            If Sheets(SheetData).Cells(i, compareCol) = value Then
                getRowByType = i
                Exit Function
            End If
        Next
    End Function
    Private Sub SetInfo(colType As cst, index As Long, value As String)
        If index <= 1 Then Exit Sub
        setInfoSys index, colType, value
    End Sub
    Private Function GetInfo(colType As cst, index As Long) As String
        GetInfo = getInfoSys(index, colType)
    End Function
    Public Property Get systemId() As String
        systemId = pId
    End Property

'0 新建与底层
    Private Sub setInfoSys(RowIndex As Long, colIndex As Long, value As String)
        Sheets(SheetData).Cells(RowIndex, colIndex) = value
    End Sub
    Private Function getInfoSys(RowIndex As Long, colIndex As Long) As String
        getInfoSys = Sheets(SheetData).Cells(RowIndex, colIndex)
    End Function
    Private Function getFreeRowIndex() As Long
        Dim i As Long
        For i = 2 To Sheets(SheetData).UsedRange.rows.Count + 1
            If Sheets(SheetData).Cells(i, 2) = "" Then
                getFreeRowIndex = i
                Exit Function
            End If
        Next
    End Function
    Private Function createId() As String
        Dim tmp As String
        Dim i As Long
        Do
            tmp = tmp & getAChr()
        Loop Until getRowByType(cst.Id, tmp) = 0 And getRowByType(cst.Parent, tmp) = 0
        createId = tmp
    End Function
    Private Function getAChr() As String
        Dim t As Long
        t = (Rnd * 26 + 0.5)
        getAChr = chr(64 + t)
    End Function

'-1 基础数据
    Private Function getClassInfo(key As String) As String
        Dim tmp As Object
        Set tmp = RecorderDic.getValue("dataFamily", key)
        If tmp Is Nothing Then
            getClassInfo = ""
        Else
            getClassInfo = tmp.ToString
        End If
    End Function
    Private Sub setClassInfo(key As String, value As Variant)
        Dim tmp As Object
        Set tmp = New CString
        tmp.Append (value)
        RecorderDic.setValue "dataFamily", key, tmp
    End Sub
Private Sub Class_Initialize()
    ReDim pChild(0)
End Sub
