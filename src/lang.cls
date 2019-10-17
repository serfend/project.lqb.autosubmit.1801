VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "lang"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Private dic() As String
'Public Enum lang
'    en = "en"
'    zhCN = "zh-CN"
'    ∫´”Ô = "ko"
'    ∂Ì”Ô = "ru"
'    µ¬”Ô = "de"
'    ∑®”Ô = "fr"
'End Enum
Public Function lang(langIndex As lang) As String
    
End Function

Private Sub Class_Initialize()
    Init "en,zh-CN,ko,"
End Sub
Private Sub Init(info As String)

End Sub

