VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Test"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Implements HttpEventDelegate
Private http As HttpClient
Private tmpInfo(1000) As String, counter As Long
Private Sub Class_Initialize()
    Set http = New HttpClient
End Sub
Public Sub Test()
    http.eventHandle = Me
    
    'http.http.Open "get", "https://ext-mdskip.taobao.com/extension/seller_info.htm?callback=jsonpSellerInfo&user_num_id=725677994&user_tag=39391264&shop_start=1309243733000", True
    'http.GetHtml "https://chaoshi.detail.tmall.com/item.htm?id=44845773243&ns=1&abbucket=15", cookies:="cna=nsvPEvvBKGkCAd9oGeXfPKs9; __guid=11770470.419399647838862460.1515069728416.7324; hng=CN%7Czh-CN%7CCNY%7C156; t=38417fbb81742277138dbb0f13ad397a; _tb_token_=e840181c7fe80; cookie2=10f2c341a2a87f796eb73ce398976541; JSESSIONID=E62B161B51C7C33B0B5B15E39D1ECC48; monitor_count=8; _m_h5_tk=4ca6eedb036c1d11dbe892e17d1fe5bf_1515298193548; _m_h5_tk_enc=ff60330c9481bd16b5a2a6ab32896dd4; sm4=500100; pnm_cku822=098%23E1hvOvvUvbpvUvCkvvvvvjiPPL5UtjtURsFZ0j1VPmPZ0jDbRL5UQj1EnLMZQj3CiQhvCvvv9UUtvpvhvvvvvvGCvvpvvPMMvphvC9vhvvCvpbyCvm9vvvvvphvvvvvv9sYvpvs0vvm2phCvhRvvvUnvphvpgvvv96CvpC29kphvC99vvOClp8yCvv9vvUvQFkavUQyCvhQhHNvvCstlYExrVTtYpExr1WmKHkx%2F6jc6D40wjLVxfa3l5dUfbz7QD764d56Ofa3l%2BboJEcqpaNshV3rzLaL91WQ7RAYVyO2vqbVQ; cq=ccp%3D1; isg=At7eZUoGCFjFTFyjtVL-aUn5L3QqRRka1iRFAohm_CEpq3-F8C_yKQRR16hL"
    Dim i As Long, proxyNum As Long: proxyNum = 10
    For i = 1 To proxyNum
        http.GetHtml "https://s.taobao.com/api?callback=jsonp209&ajax=true&m=customized&q=ด๓รื&s=" & i, ClientId:=CStr(i)
    Next
    'Do
    '    DoEvents
    '    If counter = proxyNum Then Exit Do
    'Loop
    'Stop
End Sub

Private Sub HttpEventDelegate_BadRequest(sender As HttpClientChild, e As HttpBadRequestEventHandle)
    xlsHdl.SetStatus "HttpEventDelegate_BadRequest." & e.ExceptionInfo
End Sub

Private Sub HttpEventDelegate_BadResponse(sender As HttpClientChild, e As HttpBadResponseEventHandle)
    xlsHdl.SetStatus "HttpEventDelegate_BadResponse." & e.ExceptionInfo
End Sub

Private Sub HttpEventDelegate_DocumentReady(sender As HttpClientChild, e As HttpDocumentReadyEventHandle)
    tmpInfo(Val(sender.ClientId)) = sender.GETstring
    counter = counter + 1
    'xlshdl.SetStatus   counter; ".proxy " & sender.proxyTime & "ms"
End Sub

Private Sub HttpEventDelegate_OnTimeOut(sender As HttpClientChild, e As HttpTimeOutEventHandle)
    Dim cr As New chrConvert
    xlsHdl.SetStatus "HttpEventDelegate_OnTimeOut.after:" & e.ProxyTimeBefore & "ms,data:" & cr.Utf8ToUnicode(e.AvailableData)
End Sub
