VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "HttpTimeOutEventHandle"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Private pData() As Byte
Private pProxyTime As Long
Public Sub Init(proxyTime As Long, data() As Byte)
    pData = data
    pProxyTime = proxyTime
End Sub
Public Property Get AvailableData() As Byte()
    AvailableData = pData
End Property
Public Property Get ProxyTimeBefore() As Long
    ProxyTimeBefore = pProxyTime
End Property
