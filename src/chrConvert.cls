VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "chrConvert"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
#If VBA7 Then
    Private Declare PtrSafe Function MultiByteToWideChar Lib "kernel32" (ByVal CodePage As Long, ByVal dwFlags As Long, ByVal lpMultiByteStr As LongPtr, ByVal cchMultiByte As Long, ByVal lpWideCharStr As LongPtr, ByVal cchWideChar As Long) As Long
    Private Declare PtrSafe Function WideCharToMultiByte Lib "kernel32" (ByVal CodePage As Long, ByVal dwFlags As Long, ByVal lpWideCharStr As LongPtr, ByVal cchWideChar As Long, ByRef lpMultiByteStr As Any, ByVal cchMultiByte As Long, ByVal lpDefaultChar As String, ByVal lpUsedDefaultChar As Long) As Long

#Else
    Private Declare Function WideCharToMultiByte Lib "kernel32" (ByVal CodePage As Long, ByVal dwFlags As Long, ByVal lpWideCharStr As Long, ByVal cchWideChar As Long, ByRef lpMultiByteStr As Any, ByVal cchMultiByte As Long, ByVal lpDefaultChar As String, ByVal lpUsedDefaultChar As Long) As Long
    Private Declare Function MultiByteToWideChar Lib "kernel32" (ByVal CodePage As Long, ByVal dwFlags As Long, ByVal lpMultiByteStr As Long, ByVal cchMultiByte As Long, ByVal lpWideCharStr As Long, ByVal cchWideChar As Long) As Long
#End If

Private Const CP_UTF8 = 65001
Public Function SciHtmlContent(info As String) As String
    SciHtmlContent = Replace(info, "&lt;", "<")
    SciHtmlContent = Replace(SciHtmlContent, "&gt;", ">")
    SciHtmlContent = Replace(SciHtmlContent, "&quot;", """")
    SciHtmlContent = Replace(SciHtmlContent, "&nbsp;", " ")
    SciHtmlContent = Replace(SciHtmlContent, "&ensp;", " ")
    Dim i As Long
    Dim tmp() As String, cs As New CString
    tmp = Split(SciHtmlContent, "&#")
    cs.Append tmp(0)
    For i = 1 To UBound(tmp)
        Dim thisLineValue As Long, linePos As Long
        linePos = InStr(1, tmp(i), ";")
        If linePos > 0 Then
            thisLineValue = Val(Mid(tmp(i), 1, linePos - 1))
            If thisLineValue > 0 Then
                cs.Append(chr(thisLineValue)).Append Mid(tmp(i), linePos + 1)
            Else
                cs.Append tmp(i)
            End If
        Else
            cs.Append tmp(i)
        End If
    Next
    SciHtmlContent = cs.ToString
End Function
Function URLDecode(ByVal What)
 'URL decode Function
'2001 Antonin Foller, PSTRUH Software, http://www.motobit.com
   Dim Pos, pPos

  'replace + To Space
   What = Replace(What, "+", " ")

  On Error Resume Next
  Dim Stream: Set Stream = CreateObject("ADODB.Stream")
  If Err = 0 Then 'URLDecode using ADODB.Stream, If possible
     On Error GoTo 0
    Stream.Type = 2 'String
     Stream.Open

    'replace all %XX To character
    Pos = InStr(1, What, "%")
    pPos = 1
    Do While Pos > 0
      Stream.WriteText Mid(What, pPos, Pos - pPos) + _
        chr(CLng("&H" & Mid(What, Pos + 1, 2)))
      pPos = Pos + 3
      Pos = InStr(pPos, What, "%")
    Loop
    Stream.WriteText Mid(What, pPos)

    'Read the text stream
    Stream.Position = 0
    URLDecode = Stream.ReadText

    'Free resources
    Stream.Close
  Else 'URL decode using string concentation
    On Error GoTo 0
    'UfUf, this is a little slow method.
    'Do Not use it For data length over 100k
    Pos = InStr(1, What, "%")
    Do While Pos > 0
      What = Left(What, Pos - 1) + _
        chr(CLng("&H" & Mid(What, Pos + 1, 2))) + _
        Mid(What, Pos + 3)
      Pos = InStr(Pos + 1, What, "%")
    Loop
    URLDecode = What
  End If
End Function
 Public Function UrlEncode(ByRef szString As String) As String
       Dim szChar   As String
       Dim szTemp   As String
       Dim szCode   As String
       Dim szHex    As String
       Dim szBin    As String
       Dim iCount1  As Integer
       Dim iCount2  As Integer
       Dim iStrLen1 As Integer
       Dim iStrLen2 As Integer
       Dim lResult  As Long
       Dim lAscVal  As Long
       szString = Trim$(szString)
       iStrLen1 = Len(szString)
       For iCount1 = 1 To iStrLen1
           szChar = Mid$(szString, iCount1, 1)
           lAscVal = AscW(szChar)
           If lAscVal >= &H0 And lAscVal <= &HFF Then
              If (lAscVal >= &H30 And lAscVal <= &H39) Or _
                 (lAscVal >= &H41 And lAscVal <= &H5A) Or _
                 (lAscVal >= &H61 And lAscVal <= &H7A) Then
                 szCode = szCode & szChar
              Else
                 szCode = szCode & "%" & Hex(AscW(szChar))
              End If
           Else
              szHex = Hex(AscW(szChar))
              iStrLen2 = Len(szHex)
              For iCount2 = 1 To iStrLen2
                  szChar = Mid$(szHex, iCount2, 1)
                  Select Case szChar
                         Case Is = "0"
                              szBin = szBin & "0000"
                         Case Is = "1"
                              szBin = szBin & "0001"
                         Case Is = "2"
                              szBin = szBin & "0010"
                         Case Is = "3"
                              szBin = szBin & "0011"
                         Case Is = "4"
                              szBin = szBin & "0100"
                         Case Is = "5"
                        szBin = szBin & "0101"
                         Case Is = "6"
                              szBin = szBin & "0110"
                         Case Is = "7"
                              szBin = szBin & "0111"
                         Case Is = "8"
                              szBin = szBin & "1000"
                         Case Is = "9"
                              szBin = szBin & "1001"
                         Case Is = "A"
                              szBin = szBin & "1010"
                         Case Is = "B"
                              szBin = szBin & "1011"
                         Case Is = "C"
                              szBin = szBin & "1100"
                         Case Is = "D"
                              szBin = szBin & "1101"
                         Case Is = "E"
                              szBin = szBin & "1110"
                         Case Is = "F"
                              szBin = szBin & "1111"
                         Case Else
                  End Select
              Next iCount2
              szTemp = "1110" & Left$(szBin, 4) & "10" & Mid$(szBin, 5, 6) & "10" & Right$(szBin, 6)
              For iCount2 = 1 To 24
                  If Mid$(szTemp, iCount2, 1) = "1" Then
                     lResult = lResult + 1 * 2 ^ (24 - iCount2)
                  Else: lResult = lResult + 0 * 2 ^ (24 - iCount2)
                  End If
              Next iCount2
              szTemp = Hex(lResult)
                    szCode = szCode & "%" & Left$(szTemp, 2) & "%" & Mid$(szTemp, 3, 2) & "%" & Right$(szTemp, 2)
           End If
szBin = vbNullString
           lResult = 0
       Next iCount1
       UrlEncode = szCode
End Function
'Url���룬Gb2312ҳ��֮�䴫�ݲ���
Function URLEncode_Gb(ByVal str)
    Dim i, s
    Dim b, bCode, gb, Hight8b, Low8b
    s = ""
    For i = 1 To Len(str)
        b = Mid(str, i, 1)
        bCode = Abs(Asc(b))
        If (bCode >= 48 And bCode <= 57) Or (bCode >= 65 And bCode <= 90) Or (bCode >= 97 And bCode <= 122) Or bCode = 42 Or bCode = 45 Or bCode = 46 Or bCode = 64 Or bCode = 95 Then
            '48 to 57����0~9;65 to 90����A~Z;97 to 122����a~z
            '42����*;46����.;64����@;45����-;95����_
            s = s & b
        ElseIf bCode = 32 Then '�ո�ת��+
            s = s & "+"
        ElseIf bCode < 128 Then  '����128��Asciiת��1���ֽ�
            s = s & "%" & Right("00" & Hex(bCode), 2)
        Else
            gb = Asc(b)
            If gb < 0 Then
                gb = gb + &H10000    'gb����Ϊ������Ҫ����65536
            End If
            Hight8b = (gb And &HFF00) / &H100     '�����Ƹ�8λ
            Low8b = gb And &HFF    '�����Ƶ�8λ
            s = s & "%" & Hex(Hight8b) & "%" & Hex(Low8b)
        End If
    Next
    URLEncode_Gb = s
End Function

'Url���룬Gb2312ҳ��֮�䴫�ݲ���
Function URLDecode_Gb(ByVal str)
    Dim i, s
    Dim b, bCode, gb, Hight8b, Low8b
    s = ""
    For i = 1 To Len(str)
        b = Mid(str, i, 1)
        Select Case b
            Case "+"
                s = s & " "
            Case "%"
                gb = Mid(str, i + 1, 2)
                bCode = CInt("&H" & gb)
                If bCode < 128 Then
                    i = i + 2
                Else
                    bCode = CInt("&H" & gb & Mid(str, i + 4, 2))
                    i = i + 5
                End If
                s = s & chr(bCode)
            Case Else
                s = s & b
        End Select
    Next
    URLDecode_Gb = s
End Function

'URL���룬Gb2312ҳ���ύ��Utf-8ҳ��
Function UrlEncode_GBToUtf8(ByVal str)
    Dim b                    '�����ַ�
    Dim ub                  '�����ֵ�Unicode��(2�ֽ�)
    Dim High8b, Low8b       'Unicode��ĸߵ�λ�ֽ�
    Dim UtfB1, UtfB2, UtfB3 'Utf-8��������ֽ�
    Dim i, s
    For i = 1 To Len(str)
        b = Mid(str, i, 1)
        ub = AscW(b)
        If (ub >= 48 And ub <= 57) Or (ub >= 65 And ub <= 90) Or (ub >= 97 And ub <= 122) Or ub = 42 Or ub = 45 Or ub = 46 Or ub = 64 Or ub = 95 Then
            '48 to 57����0~9;65 to 90����A~Z;97 to 122����a~z
            '42����*;46����.;64����@;45����-;95����_
            s = s & b
        ElseIf ub = 32 Then '�ո�ת��+
            s = s & "+"
        ElseIf ub < 128 Then  '����128��Asciiת��1���ֽ�
            s = s & "%" & Right("00" & Hex(ub), 2)
        Else
            High8b = (ub And &HFF00) / &H100 'Unicode���λ
            Low8b = ub And &HFF 'Unicode���λ
            UtfB1 = (High8b And &HF0) / &H10 Or &HE0 'ȡUnicode��λ�ֽڵĶ����Ƶ�ǰ4λ + 11100000
            UtfB2 = ((High8b And &HF) * &H4 + (Low8b And &HC0) / &H40) Or &H80 'ȡUnicode��λ�ֽڵĺ�4λ����λ�ֽڵ�ǰ2λ +10000000
            UtfB3 = (Low8b And &H3F) Or &H80 'ȡUnicode��λ�ֽڵĶ����ƺ�6λ + 10000000
            s = s & "%" & Hex(UtfB1) & "%" & Hex(UtfB2) & "%" & Hex(UtfB3)
        End If
    Next
    UrlEncode_GBToUtf8 = s
End Function



'��������AscW("��")=27721(ʮ����)    01101100 01001001(������)     6C49(ʮ������)
'��Gb2312��ת��Utf-8�루ʮ�����Ʊ�ʾ���ķ���Ϊ������AscW��Gb2312תΪUnicode��(2�ֽ�),��'��Unicode��Ķ������е�λ��utf-8(3�ֽڣ�ģ�������� x λ��

'URL���룬Gb2312ҳ���ύ��Utf-8ҳ��
Function UrlDecode_GBToUtf8(ByVal str)
    Dim b, ub   '�����ֵ�Unicode��(2�ֽ�)
    Dim UtfB    'Utf-8�����ֽ�
    Dim UtfB1, UtfB2, UtfB3 'Utf-8��������ֽ�
    Dim i, n, s
    n = 0
    ub = 0
    For i = 1 To Len(str)
        b = Mid(str, i, 1)
        Select Case b
            Case "+"
                s = s & " "
            Case "%"
                ub = Mid(str, i + 1, 2)
                UtfB = CInt("&H" & ub)
                If UtfB < 128 Then
                    i = i + 2
                    s = s & ChrW(UtfB)
                Else
                    UtfB1 = (UtfB And &HF) * &H1000   'ȡ��1��Utf-8�ֽڵĶ����ƺ�4λ
                    UtfB2 = (CInt("&H" & Mid(str, i + 4, 2)) And &H3F) * &H40      'ȡ��2��Utf-8�ֽڵĶ����ƺ�6λ
                    UtfB3 = CInt("&H" & Mid(str, i + 7, 2)) And &H3F      'ȡ��3��Utf-8�ֽڵĶ����ƺ�6λ
                    s = s & ChrW(UtfB1 Or UtfB2 Or UtfB3)
                    i = i + 8
                End If
            Case Else    'Ascii��
                s = s & b
        End Select
    Next
    UrlDecode_GBToUtf8 = s
End Function






Function Utf8ToUnicode(ByRef Utf() As Byte) As String
    Dim lRet As Long
    Dim lLength As Long
    Dim lBufferSize As Long
    lLength = UBound(Utf) - LBound(Utf) + 1
    If lLength <= 0 Then Exit Function
    lBufferSize = lLength * 2
    Utf8ToUnicode = String$(lBufferSize, chr(0))
    lRet = MultiByteToWideChar(CP_UTF8, 0, VarPtr(Utf(0)), lLength, StrPtr(Utf8ToUnicode), lBufferSize)
    If lRet <> 0 Then
        Utf8ToUnicode = Left(Utf8ToUnicode, lRet)
    End If
End Function

Function UnicodeToUtf8(ByVal UCS As String) As Byte()
    Dim lLength As Long
    Dim lBufferSize As Long
    Dim lResult As Long
    Dim abUTF8() As Byte
    lLength = Len(UCS)
    If lLength = 0 Then Exit Function
    lBufferSize = lLength * 3 + 1
    ReDim abUTF8(lBufferSize - 1)
    lResult = WideCharToMultiByte(CP_UTF8, 0, StrPtr(UCS), lLength, abUTF8(0), lBufferSize, vbNullString, 0)
    If lResult <> 0 Then
    lResult = lResult - 1
    ReDim Preserve abUTF8(lResult)
    UnicodeToUtf8 = abUTF8
    End If
End Function


Public Function getUnicodeConvert(iniUni As String) As String
    Dim tmp() As String, rel As New CString
    tmp = Split(iniUni, "\u")
    Dim i As Long
    getUnicodeConvert = tmp(0)
    For i = 1 To UBound(tmp)
        rel.Append(ChrW(CInt("&H" & Mid(tmp(i), 1, 4)))).Append Mid(tmp(i), 5)
    Next
    getUnicodeConvert = rel.ToString
End Function
Public Function Hash(str As String) As LongLong 'To DJB Hash
On Error GoTo Err:
    'unsigned int h(const char *s){unsigned int a=5381;while(*s)a+=(a<<5)+(*s++);return (a&0x7FFFFFFF);}
    Dim scource As LongLong: scource = 5381
    Dim i As Long
    For i = 1 To Len(str)
        Dim chr As Long, a As LongLong, b As LongLong, c As LongLong
        chr = Asc(Mid(str, i, 1))
        a = scource
        b = IIf(scource < 0, scource + 2147483648#, scource) * 32
        c = chr
        scource = scource + b 'a<<5
        scource = scource + chr
        While scource > 2147483647
            scource = scource - 4294967296#
        Wend
        'Debug.Print a & "+" & b & "+" & c & "=" & scource
    Next
    Hash = scource And 2147483647
    Exit Function
Err:
    Stop
    Resume
End Function
Public Sub PackBytes(ByteArray() As Byte, ByVal PostData As String)
        Dim iNewBytes As Long     '����Ԥ�賤��
        Dim intAscii As Integer     'һ���ַ�(Unicode)��Asc���룬�����ַ�ʱ��ֵС��0
        Dim mCurNo As Integer    '��ǰ������Byte�����±�
        Dim CharHex As String    '��ǰ�����ַ���ʮ�������ַ���
        mCurNo = 0
        iNewBytes = LenB(PostData) - 1     '�ַ�������Len(str)������ע���õ���LenB()�����������±��0��ʼ��Ҫ��ȥ1
        If iNewBytes < 0 Then
          Exit Sub
        End If
        ReDim ByteArray(iNewBytes)
        For i = 0 To Len(PostData)
          CH = Mid(PostData, i + 1, 1)    '��ȡһ���ַ�
          If CH = Space(1) Then '����ǿ�����
                CH = "+"
          End If
          If CH <> "" Then
              intAscii = Asc(CH)        'ȡ��Asc��
              If intAscii > 0 Then        '<0��Ϊ����
                  ByteArray(mCurNo) = Asc(CH)    'Ӣ�ģ�ֱ��ȡ��Asc��
                  mCurNo = mCurNo + 1    '���ü�����
              Else
                    Stop
                  'CharHex = Hex(intAscii)    '����ʱ��תΪʮ������
                  'ByteArray(mCurNo) = HEX_to_DEC(Left(CharHex, 2))        '��ǰ��λת��Ϊʮ���ƣ�ע�����ﲻ��Cbyte()����ת������ΪһЩ�������ַ�ʱ����ִ���
                  'ByteArray(mCurNo + 1) = HEX_to_DEC(Right(CharHex, 2))    '������λת��Ϊʮ����
                  'mCurNo = mCurNo + 2    '���ü�����
              End If
          End If
        Next i
        ReDim Preserve ByteArray(mCurNo - 1) '�ص�����Ĳ���
    End Sub
