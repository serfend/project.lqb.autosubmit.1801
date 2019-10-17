VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "ModelQuestionDataPair"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Private InputInfo() As String
Private OutPutInfo() As String
Private QuesTestNum As Long
Private idx As String
Private Const fileTypeInput As String = "inp"
Private Const fileTypeOutPut As String = "outp"
Public Function BuildCode(TIndex As String, TNum As Long) As String
On Error GoTo Err:
    QuesTestNum = TNum
    idx = TIndex
    If QuesTestNum = 0 Then
        xlsHdl.SetStatus TIndex & "异常的题目测试数据"
        Exit Function
    End If
    xlsHdl.SetStatus "生成代码:" & TIndex & ",总测试数据(" & TNum & ")"
    ReDim InputInfo(QuesTestNum)
    ReDim OutPutInfo(QuesTestNum)
    Dim i As Long
    For i = 1 To QuesTestNum
        If Not LoadTestData(i, fileTypeInput) Then Exit Function
        If Not LoadTestData(i, fileTypeOutPut) Then Exit Function
    Next
    BuildCode = HashCode 'NormalCode
    Exit Function
Err:
    Stop
    Resume
End Function
Private Function LoadTestData(index As Long, fileType As String) As Boolean
On Error GoTo Err:
    Dim AutoCodeFile As clsFile
    Set AutoCodeFile = New clsFile
    Dim cs As New CString
    AutoCodeFile.Init "\data\" & idx, fileType & index, "txt"
    AutoCodeFile.OpenFile
    If Not AutoCodeFile.Exist Then
        Debug.Print "居然没有这个文件2333"
        Exit Function
    End If
    While Not AutoCodeFile.EndOfFile
        cs.Append(Replace(AutoCodeFile.ReadLine, chr(10), "$")).Append ""
    Wend
    
    If fileType = fileTypeOutPut Then
        OutPutInfo(index) = cs.ToString()
        removeExtraLine OutPutInfo(index)
        'If InStr(1, chr(10) & chr(13), Mid(OutPutInfo(index), cs.length - 3)) > 0 Then
        '    If InStr(1, chr(10) & chr(13), Mid(OutPutInfo(index), cs.length - 2)) > 0 Then
        '        OutPutInfo(index) = cs.ToString(, cs.length - 3)
        '    End If
        'End If
    Else
        InputInfo(index) = cs.ToString '(, cs.Length - 1)
        removeExtraLine InputInfo(index)
        'If InStr(1, chr(10) & chr(13), Mid(InputInfo(index), cs.length - 3)) > 0 Then
        '    If InStr(1, chr(10) & chr(13), Mid(InputInfo(index), cs.length - 2)) > 0 Then
        '        InputInfo(index) = cs.ToString(, cs.length - 3)
        '    End If
        'End If
    End If
    LoadTestData = True
    Exit Function
Err:
    Stop
    Resume
End Function
Private Sub removeExtraLine(info As String)
    
End Sub
Private Property Get HashCode() As String
On Error GoTo Err:
    Dim cs As New CString
    cs.Append("#include<iostream>").Append vbCrLf
    cs.Append("#include<string.h>").Append vbCrLf
    cs.Append("using namespace std;").Append vbCrLf
    BuildHashInputInfo cs
    cs.Append("unsigned int h(const char *s){unsigned int a=5381;while(*s)a+=(a<<5)+(*s++);return (a&0x7FFFFFFF);}").Append vbCrLf '哈希算法
    cs.Append("int main(){").Append vbCrLf
    cs.Append("string t,r;").Append vbCrLf
    cs.Append("while(1){").Append vbCrLf
    cs.Append("if(!getline(cin,t))break;").Append vbCrLf
    cs.Append("r+=(t+'$');}").Append vbCrLf
    cs.Append("switch(h(r.c_str())){").Append vbCrLf
    BuildHashCompareCase cs
    cs.Append ("default:while(1){};break;")
    cs.Append("}}").Append vbCrLf
    cs.Append("//only used to test autoSubmit by serfend").Append vbCrLf
    cs.Append("//QuestionIndex:").Append(idx).Append vbCrLf
    If cs.Length > 70000 Then
        xlsHdl.SetStatus "生成代码数据量过大"
        
    Else
        HashCode = cs.ToString
    End If
    
Exit Property
Err:
    Stop
    Resume
End Property
Private Sub BuildHashInputInfo(cs As CString)
    Dim i As Long
    For i = 1 To QuesTestNum
        If Len(OutPutInfo(i)) < 30000 Then
            cs.Append("char info").Append(CStr(i)).Append("[]=""").Append(Replace(OutPutInfo(i), "$", "\n")).Append(""";").Append vbCrLf
        Else
            cs.Append("char info").Append(CStr(i)).Append("[]=""").Append("data is too big").Append(""";").Append vbCrLf
            xlsHdl.SetStatus "生成代码第" & i & "组数据输出过大"
        End If
    Next
End Sub
Private Sub BuildHashCompareCase(cs As CString)
    Dim i As Long, tmpCodeHash As Long
    Dim chr As New chrConvert
    For i = 1 To QuesTestNum
        RemoveTheSpaceFrontNewLine InputInfo(i)
        cs.Append("case ").Append(chr.Hash(InputInfo(i))).Append(":printf(""%s"",info").Append(CStr(i)).Append ");break;"
    Next
End Sub
Private Sub RemoveTheSpaceFrontNewLine(info As String)
Exit Sub
    Dim tmpPos As Long: tmpPos = 1
    Do
        tmpPos = InStr(tmpPos, info, "\n")
        If tmpPos > 0 Then
            Stop
        Else
            Exit Sub
        End If
    Loop
End Sub
#If 0 Then

#End If
Private Property Get NormalCode() As String
On Error GoTo Err:
    Dim cs As New CString
    cs.Append("#include<iostream>").Append vbCrLf
    cs.Append("#include<string.h>").Append vbCrLf
    cs.Append("#include<stack>").Append vbCrLf
    cs.Append("bool IsFit[").Append(CStr(QuesTestNum)).Append("]={true};").Append vbCrLf
    cs.Append("int nowLineIndex=0;").Append vbCrLf
    cs.Append("int TestDataNum=").Append(CStr(QuesTestNum)).Append(",FitTestDataNum=").Append(CStr(QuesTestNum)).Append(";").Append vbCrLf
    cs.Append("using namespace std;").Append vbCrLf
    cs.Append("stack<string>testData[").Append(CStr(QuesTestNum)).Append("];").Append vbCrLf
    cs.Append("stack<string>testOutData[").Append(CStr(QuesTestNum)).Append("];").Append vbCrLf
    cs.Append(" void CheckData(char info[],int index){").Append vbCrLf
    cs.Append("     if(testData[index].empty()){").Append vbCrLf
    cs.Append("         IsFit[index]=false;").Append vbCrLf
    cs.Append("         return;").Append vbCrLf
    cs.Append("     }").Append vbCrLf
    cs.Append("     if(testData[index].top()!=info){").Append vbCrLf
    cs.Append("         IsFit[index]=false;").Append vbCrLf
    cs.Append("         FitTestDataNum--;").Append vbCrLf
    cs.Append("     }").Append vbCrLf
    cs.Append("     testData[index].pop();").Append vbCrLf
    cs.Append(" }").Append vbCrLf
    cs.Append(" void OutPutData(int index){").Append vbCrLf
    cs.Append("     while(!testOutData[index].size()>1){").Append vbCrLf
    cs.Append("         printf(""%s\n"",testOutData[index].top().c_str());").Append vbCrLf
    cs.Append("     }").Append vbCrLf
    cs.Append("     printf(""%s"",testOutData[index].top().c_str());").Append vbCrLf
    cs.Append(" }").Append vbCrLf
    cs.Append(" void init(){").Append vbCrLf
    BuildInputData cs '原始数据
    cs.Append(" }").Append vbCrLf
    cs.Append(" int main(){").Append vbCrLf
    cs.Append("     init();").Append vbCrLf
    cs.Append("     do{").Append vbCrLf
    cs.Append("         char lineInfo[1024];").Append vbCrLf
    cs.Append("         scanf(""%[^\n]"", &lineInfo);").Append vbCrLf
    cs.Append("         for(int i=0;i<TestDataNum;i++){").Append vbCrLf
    cs.Append("             CheckData(lineInfo,i);").Append vbCrLf
    cs.Append("         }").Append vbCrLf
    cs.Append("     }while(FitTestDataNum>1);").Append vbCrLf
    cs.Append("     for(int i=0;i<TestDataNum;i++){").Append vbCrLf
    cs.Append("         if(IsFit[i]){").Append vbCrLf
    cs.Append("             OutPutData(i);").Append vbCrLf
    cs.Append("             break;").Append vbCrLf
    cs.Append("         }").Append vbCrLf
    cs.Append("     }").Append vbCrLf
    cs.Append(" return 0;").Append vbCrLf
    cs.Append("}").Append vbCrLf
    cs.Append("//only used to test autoSubmit by serfend").Append vbCrLf
    cs.Append("//QuestionIndex:").Append(idx).Append vbCrLf
    NormalCode = cs.ToString
    Exit Property
Err:
    Stop
End Property
Private Sub BuildInputData(cs As CString)
    Dim i As Long
    cs.Append("    for(int i=0;i<TestDataNum;i++){").Append(vbCrLf).Append("      IsFit[i]=true;}").Append vbCrLf
    For i = 1 To QuesTestNum
        BuildInputDataCase cs, i
    Next
End Sub
Private Sub BuildInputDataCase(cs As CString, index As Long)
    Dim tmp() As String
    tmp = Split(InputInfo(index), vbCrLf)
    Dim i As Long, tmpNum As Long
    tmpNum = UBound(tmp)
    For i = 0 To tmpNum
        cs.Append("     testData[").Append(index - 1).Append("].push(""").Append(tmp(tmpNum - i)).Append(""");").Append vbCrLf
    Next
    
    tmp = Split(OutPutInfo(index), vbCrLf)
    tmpNum = UBound(tmp)
    For i = 0 To tmpNum
        cs.Append("     testOutData[").Append(index - 1).Append("].push(""").Append(tmp(tmpNum - i)).Append(""");").Append vbCrLf
    Next
End Sub
#If 0 Then
    #include<iostream>
    #include<string.h>
    using namespace std;
    bool IsFit[10]=true
    int nowLineIndex=0;
    int TestDataNum={测试数据数量},FitTestDataNum={测试数据数量};
    stack<string>testData[{测试数据的量];
    void CheckData(char info[],int index){
        if(testData[index].empty()){
            IsFit[index]=false;
            return;
         }
        if(testData[index].top()!=info){
            IsFit[index]=false;
            FitTestDataNum--;
        }
        testData[index].pop();
    }
    void OutPutData(int index){
        while(!testOutData[index].size()>1){
            printf("%s\n",testOutData[index].top().c_str());
            testOutData[index].pop();
        }
        printf("%s",testOutData[index].top().c_str());
    }
    void init(){
        testData[{n}].push({倒序输入原始数据});
    }
    int main(){
        init();
        do{
            for(int i=0;i<TestDataNum;i++){
                CheckData(lineInfo,i);
            }
        }while(FitTestDataNum>1);
        for(int i=0;i<TestDataNum;i++){
            if(IsFit[i]){
                OutPutData(i);
                break;
            }
        }
        return 0;
    }
#End If
