VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "CString"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit
'*************************************************************************
'**模 块 名：CString
'**说    明：forVBA StringBuilder 版权所有2005 - 2006(C)
'**创 建 人：serfend
'**日    期：2011-11-11 19:50:20
'**修 改 人：
'**日    期：
'**描    述：这个字符串操作类的自增缓冲区的特点是：当缓冲区不够大时将
'            以128（128*2）的大小增加缓冲区大小
'**版    本：V1.0.0
'*************************************************************************
Private m_Buffer() As Byte   '缓冲区


Private m_AllocSize As Long  '实际分配的内存大小
Private m_Length As Long     '当前已经使用的内存大小
#If VBA7 Then
Private m_lpBuffer As LongPtr   '分配的内存块指针
Private Declare PtrSafe Sub CopyMemory Lib "ntdll" Alias "RtlMoveMemory" (Destination As Any, Source As Any, ByVal Length As Long)

Private Declare PtrSafe Function StrCSpn Lib "shlwapi.dll" Alias "StrCSpnW" (ByVal lpStr As LongPtr, ByVal lpCharacters As LongPtr) As Long
Private Declare PtrSafe Function StrCSpnI Lib "shlwapi.dll" Alias "StrCSpnIW" (ByVal lpStr As LongPtr, ByVal lpCharacters As LongPtr) As Long

Private Declare PtrSafe Function StrRStr Lib "shell32.dll" Alias "StrRStrW" (ByVal lpStart As LongPtr, ByVal lpEnd As LongPtr, ByVal lpSrch As LongPtr) As Long
Private Declare PtrSafe Function StrRStrI Lib "shell32.dll" Alias "StrRStrIW" (ByVal lpStart As LongPtr, ByVal lpEnd As LongPtr, ByVal lpSrch As LongPtr) As Long
#Else
Private m_lpBuffer As Long   '分配的内存块指针
Private Declare Sub CopyMemory Lib "ntdll" Alias "RtlMoveMemory" (Destination As Any, Source As Any, ByVal Length As Long)

Private Declare Function StrCSpn Lib "shlwapi.dll" Alias "StrCSpnW" (ByVal lpStr&, ByVal lpCharacters&) As Long
Private Declare Function StrCSpnI Lib "shlwapi.dll" Alias "StrCSpnIW" (ByVal lpStr&, ByVal lpCharacters&) As Long

Private Declare Function StrRStr Lib "shell32.dll" Alias "StrRStrW" (ByVal lpStart&, ByVal lpEnd&, ByVal lpSrch&) As Long
Private Declare Function StrRStrI Lib "shell32.dll" Alias "StrRStrIW" (ByVal lpStart&, ByVal lpEnd&, ByVal lpSrch&) As Long
#End If
Dim nLen As Long '新加入的字符串长度
Public Function SetInfo(info As String) As CString
    Me.Clear
    Set SetInfo = Me.Append(info)
End Function
'*************************************************************************
'   设置缓冲区容量大小
'*************************************************************************
Property Let Capacity(ByVal Size As Long)
    If Size < 1 Then Exit Property

    Size = Size + Size '由于vb的字符串是BSTR字符占2个字节所以分配2倍的内存
    If Size <= m_AllocSize Then Exit Property '内存块还够用

    '   分配一个缓冲区
    If m_AllocSize = 0 Or m_Length = 0 Then '没有数据或还没有分配过内存
        ReDim m_Buffer(0 To Size)
    Else
        ReDim Preserve m_Buffer(0 To Size)
    End If
    m_lpBuffer = VarPtr(m_Buffer(0))           '缓冲区指针

    m_AllocSize = Size
End Property

'*************************************************************************
'   获取当前字符串长度
'*************************************************************************
Property Get Length() As Long
    Length = m_Length / 2
End Property
Public Property Let Length(value As Long)
    m_Length = value * 2
End Property
'*************************************************************************
'   清空数据
'*************************************************************************
Public Sub Clear()
    m_Length = 0
End Sub

'*************************************************************************
'� 在字符串缓冲区的后面增加字符串
'   参  数：要增加的字符串
'   返回值：无
'*************************************************************************
Public Function Append(ByVal str As String) As CString
    Const IncreaseStep = 128

    nLen = Len(str)
    nLen = nLen + nLen

    '   如果m_AllocSize <= m_Length + nLen，则以 128+ nLen 个字符的增量增加内存
    If m_AllocSize <= m_Length + nLen Then
        Me.Capacity = (m_Length + nLen) / 2 + IncreaseStep
    End If

    '   拷贝数据到缓冲区
    Call CopyMemory(ByVal (m_lpBuffer + m_Length), ByVal StrPtr(str), nLen)
    m_Length = m_Length + nLen
    Set Append = Me
End Function

'*************************************************************************
'   转换为vb的字符串
'*************************************************************************
Property Get ToString(Optional StartIndex As Long = 1, Optional EndIndex As Long = -1) As String
    If EndIndex = -1 Then EndIndex = Length
    If m_Length > 1 And StartIndex <= m_Length Then
        ToString = Mid(m_Buffer, StartIndex, EndIndex - StartIndex + 1)  '注意不要用Left$
    End If
End Property

'*************************************************************************
'   寻找 str 在缓冲区中第一次出现的位置(字符位置从 1 数起)
'   参  数：要查找的字符串,[是否忽视大小写(默认忽视大小写)]
'   返回值：成功则不为-1
'*************************************************************************
Public Function IndexOf(ByVal str As String, Optional ByVal IsIgnoreCase As Boolean = True) As Long
    If m_Length < 1 Then
        IndexOf = -1
        Exit Function
    End If

    If IsIgnoreCase Then
        IndexOf = StrCSpnI(m_lpBuffer, StrPtr(str))
    Else
        IndexOf = StrCSpn(m_lpBuffer, StrPtr(str))
    End If

    If IndexOf >= 0 Then IndexOf = IndexOf + 1
End Function

'*************************************************************************
'   寻找 str 在缓冲区中最后一次出现的位置(字符位置从 1 数起)
'   参  数：要查找的字符串,[是否忽视大小写(默认忽视大小写)]
'   返回值：成功则不为-1
'*************************************************************************
Public Function LastIndexOf(ByVal str As String, Optional ByVal IsIgnoreCase As Boolean = True) As Long
    If m_Length < 1 Then
        LastIndexOf = -1
        Exit Function
    End If

    If IsIgnoreCase Then
        LastIndexOf = StrRStrI(m_lpBuffer, m_lpBuffer + m_Length, StrPtr(str))
    Else
        LastIndexOf = StrRStr(m_lpBuffer, m_lpBuffer + m_Length, StrPtr(str))
    End If

    If LastIndexOf >= m_lpBuffer Then
        LastIndexOf = (LastIndexOf - m_lpBuffer) / 2 + 1
    Else
        LastIndexOf = -1
    End If
End Function

Private Sub Class_Initialize()
    m_AllocSize = 0
    m_Length = 0
End Sub

Private Sub Class_Terminate()
    Erase m_Buffer
End Sub

Private Function GetNextPos(targetStr As String, Optional BeginIndex As Long = 1) As Long
    GetNextPos = InStr(BeginIndex, Me.ToString, targetStr)
End Function
Public Function GetElement(beginStr As String, endStr As String, Optional BeginIndex As Long = 1) As String
    Dim ContentBegin As Long
    ContentBegin = GetNextPos(beginStr, BeginIndex)
    If ContentBegin <= 0 Then
        BeginIndex = 0
        Exit Function
    End If
    ContentBegin = ContentBegin + Len(beginStr)
    BeginIndex = ContentBegin + 1
    Dim ContentEnd As Long
    ContentEnd = GetNextPos(endStr, BeginIndex)
    If ContentEnd <= 0 Then
        BeginIndex = 0
        Exit Function
    End If
    GetElement = ToString(ContentBegin, ContentEnd - 1)
    BeginIndex = ContentEnd + Len(endStr)
End Function
Public Function GetElementRight(endStr As String, Optional BeginIndex As Long = 1) As String
    Dim ContentBegin As Long
    ContentBegin = GetNextPos(endStr, BeginIndex)
    If ContentBegin <= 0 Then
        BeginIndex = 0
        Exit Function
    End If
    GetElementRight = ToString(ContentBegin + 1)
End Function
Public Function GetElementLeft(endStr As String, Optional BeginIndex As Long = 1) As String
    Dim ContentEnd As Long
    ContentEnd = GetNextPos(endStr, BeginIndex)
    If ContentEnd <= 0 Then
        BeginIndex = 0
        Exit Function
    End If
    GetElementLeft = ToString(, ContentEnd - 1)
End Function
Public Function GetAllElement(beginStr As String, endStr As String, Optional BeginIndex As Long = 1, Optional MaxElementNum As Long = -1) As String()
    Dim counter As Long
    Dim tmp As String, indexOfBegin As Long: indexOfBegin = BeginIndex
    Dim tmpSplit() As String
    Dim result() As String, tmpResult() As String
    ReDim result(0)
    tmpSplit = Split(ToString(BeginIndex), beginStr)
    If UBound(tmpSplit) = -1 Then Exit Function
    ReDim tmpResult(UBound(tmpSplit))
    Do
        If MaxElementNum <> -1 And MaxElementNum <= counter Then Exit Do
        indexOfBegin = BeginIndex
        tmp = GetElement(beginStr, endStr, BeginIndex)
        If tmp = "" And BeginIndex = 0 Then Exit Do
        counter = counter + 1
        If counter > UBound(tmpResult) Then ReDim Preserve tmpResult(UBound(result) * 2 + 1)
        tmpResult(counter) = tmp
    Loop
    If BeginIndex = 0 Then BeginIndex = indexOfBegin
    Dim i As Long
    ReDim result(counter)
    For i = 1 To counter
        result(i) = tmpResult(i)
    Next
    GetAllElement = result
End Function
Public Function GetElementByIndex(beginStr As String, endStr As String, index As Long, Optional BeginIndex As Long = 1) As String
    Dim tmp() As String
    tmp = GetAllElement(beginStr, endStr, BeginIndex, index)
    If UBound(tmp) < index Then
        Exit Function
    Else
        GetElementByIndex = tmp(index)
    End If
End Function
Public Function GetElementNum(beginStr As String, endStr As String, Optional BeginIndex As Long = 1) As Long
    GetElementNum = UBound(GetAllElement(beginStr, endStr, BeginIndex))
End Function
Public Function RemoveAll(items As String, Optional SplitChar As String = "$", Optional Des As String = "") As String
    Dim tmp() As String, i As Long
    RemoveAll = ToString
    tmp = Split(items, SplitChar)
    For i = 0 To UBound(tmp)
        RemoveAll = Replace(RemoveAll, tmp(i), Des)
    Next
End Function
