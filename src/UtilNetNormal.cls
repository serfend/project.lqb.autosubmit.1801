VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "UtilNetNormal"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
    Private client As HttpClient



    Public Property Get HttpHandler() As HttpClient
        Set HttpHandler = client
    End Property
    Public Property Let HttpHandler(value As HttpClient)
        Set client = value
    End Property
    'ÓÊ¼þ
    Public Function EmailIsVilid(emailAdress As String) As Boolean
        Dim tmp As String
        
    End Function
    Public Function EmailParse(emailAdress As String) As Long
        EmailParse = client.GetHtml("http://tool.chacuo.net/mailverify", "post", "data=" & Cells(i, 1) & "&type=verify&arg=", Refer:="http://tool.chacuo.net/mailverify")
    End Function
    
    '¹È¸è·­Òë
    Public Function Translate(infos As String, fromLang As lang, toLang As lang) As Long
        Translate = client.GetHtml("https://translate.google.cn/m?hl=zh-CN&sl=" & fromLang & "&tl=" & toLang & "&ie=UTF-8&prev=_m&q=" & infos)
    End Function
    
