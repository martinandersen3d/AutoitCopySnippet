#include <Date.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <StructureConstants.au3>
Opt("GUIOnEventMode", 1)

Global $frmMainForm = GUICreate("Copy Snippet", 300, 600, -1, -1)
GUISetOnEvent($GUI_EVENT_CLOSE, "ExitApplication")
Global $txtInput = GUICtrlCreateInput("", 8, 16, 284, 21)
GUICtrlSetFont(-1, 10, 400)
Global $lstListBox = GUICtrlCreateList("", 8, 45, 284, 557)
$hWndListBox = GUICtrlGetHandle($lstListBox)
GUICtrlSetFont(-1, 10, 400)
GUISetState(@SW_SHOW, $frmMainForm)

;~ GUIRegisterMsg($WM_KEYDOWN, "IsPressed")
GUIRegisterMsg($WM_COMMAND, "WM_COMMAND")
GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY")
GUIRegisterMsg($WM_ACTIVATE, "WM_ACTIVATE_Handler")
 HotKeySet("{Enter}","EnterPressed")
  HotKeySet("{Esc}","ExitApplication")
  
Func EnterPressed()
    ConsoleWrite("Enter Key is pressed!")
	CopySelectedItemToClipboard()
	Sleep(0.2)
	ExitApplication()
EndFunc


;~ Func DownPressed()
;~     ConsoleWrite("Down pressed!")
;~ 	
;~ 	If ControlGetFocus ( $lstListBox ) Then
;~         ConsoleWrite("Listbox has focus." & @CRLF)
;~     Else
;~         ConsoleWrite("Listbox does not have focus." & @CRLF)
;~ 		GUICtrlSetState($lstListBox, $GUI_FOCUS)
;~   
;~     EndIf
;~ EndFunc


; Read snippets from file and populate listbox
ReadSnippetsFromFile("snippets.txt")
$fAction = 0
$sLastSel = ""
While 1
    Sleep(100)
WEnd

Func ExitApplication()
    Exit
EndFunc

Func WM_COMMAND($hWnd, $iMsg, $wParam, $lParam)
    Local $hdlWindowFrom, $intMessageCode, $intControlID_From

    $intControlID_From = BitAND($wParam, 0xFFFF)
    $intMessageCode = BitShift($wParam, 16)

    Switch $intControlID_From
        Case $txtInput
            Switch $intMessageCode
                Case $EN_CHANGE
                    Local $filterText = GUICtrlRead($txtInput)
                    If StringLen($filterText) = 0 Then
                        ShowAllItems()
                    Else
                        FilterListBox($filterText)
                    EndIf
            EndSwitch
    EndSwitch

    Return $GUI_RUNDEFMSG
EndFunc


Func WM_NOTIFY($hWnd, $iMsg, $wParam, $lParam)
    Local $nmhdr = DllStructCreate("int;int;int", $lParam)
    Local $code = DllStructGetData($nmhdr, 3)

    Switch $code
        Case $EN_CHANGE
            ; EN_CHANGE for $txtInput handled in WM_COMMAND
            Return $GUI_RUNDEFMSG
        Case $EN_RETURN ; Enter key for $txtInput
            Local $focusedCtrl = ControlGetFocus($frmMainForm, "")
            If $focusedCtrl = $txtInput Then
                
				ConsoleWrite("Enter")
                Return $GUI_RUNDEFMSG
            EndIf
        Case $LBN_DBLCLK ; Double-click on listbox item
            Local $focusedCtrl = ControlGetFocus($frmMainForm, "")
            If $focusedCtrl = $lstListBox Then
                ; Handle double-click on listbox item (if needed)
                ConsoleWrite("Double click")
                Return $GUI_RUNDEFMSG
            EndIf
        Case $NM_RETURN ; Enter key for general control notification
            Local $focusedCtrl = ControlGetFocus($frmMainForm, "")
            If $focusedCtrl = $txtInput Then
                
                Return $GUI_RUNDEFMSG
            EndIf
        Case $NM_DOWN ; Down key
            Local $focusedCtrl = ControlGetFocus($frmMainForm, "")
            If $focusedCtrl = $txtInput Then
                GUICtrlSetState($lstListBox, $GUI_FOCUS)
				ConsoleWrite("Down")
                Return $GUI_RUNDEFMSG
            EndIf
    EndSwitch

    Return $GUI_RUNDEFMSG
EndFunc

Func ReadSnippetsFromFile($fileName)
    Local $fileContent = FileRead($fileName)
    If @error Then
        MsgBox(16, "Error", "Failed to read file 'snippets.txt'!")
        Return
    EndIf

    Local $arrSnippets = StringSplit($fileContent, @CRLF, 1)
    If IsArray($arrSnippets) Then
        For $i = 1 To $arrSnippets[0]
            GUICtrlSetData($lstListBox, $arrSnippets[$i])
        Next
    EndIf
	ControlCommand($frmMainForm, "", $lstListBox, "SetCurrentSelection", 0) 
	
EndFunc

Func ShowAllItems()
    GUICtrlSetData($lstListBox, "") ; Clear current listbox content

    Local $fileContent = FileRead("snippets.txt")
    If @error Then
        MsgBox(16, "Error", "Failed to read file 'snippets.txt'!")
        Return
    EndIf

    Local $arrSnippets = StringSplit($fileContent, @CRLF, 1)
    If IsArray($arrSnippets) Then
        For $i = 1 To $arrSnippets[0]
            GUICtrlSetData($lstListBox, $arrSnippets[$i], 1) ; Add each item to listbox without clearing
        Next
    EndIf
	 ControlCommand($frmMainForm, "", $lstListBox, "SetCurrentSelection", 0) 
EndFunc

Func FilterListBox($filterText)
    GUICtrlSetData($lstListBox, "") ; Clear current listbox content

    Local $fileContent = FileRead("snippets.txt")
    If @error Then
        MsgBox(16, "Error", "Failed to read file 'snippets.txt'!")
        Return
    EndIf

    Local $arrSnippets = StringSplit($fileContent, @CRLF, 1)
    If IsArray($arrSnippets) Then
        For $i = 1 To $arrSnippets[0]
            If StringInStr($arrSnippets[$i], $filterText) Then
                GUICtrlSetData($lstListBox, $arrSnippets[$i])
            EndIf
        Next
    EndIf
	ControlCommand($frmMainForm, "", $lstListBox, "SetCurrentSelection", 0) 
EndFunc

Func CopySelectedItemToClipboard()
    Local $selectedIndex = GUICtrlRead($lstListBox)
	ConsoleWrite("----")
	ConsoleWrite($selectedIndex)
	ConsoleWrite("----")
	   If $selectedIndex = "" Then
        ; If none is selected, select the first item
		;_GUICtrlListBox_ClickItem($lstListBox, 0)
		;_GUICtrlListBox_SetCurSel($lstListBox, 0) ; Select the first item
		ControlCommand($frmMainForm, "", $lstListBox, "SetCurrentSelection", 0) 
		;Sleep(5000)
        
        $selectedIndex = 0 ; Update the selected index to the first item
    EndIf
    If $selectedIndex = -1 Then
        Local $selectedItem = GUICtrlRead($lstListBox, $selectedIndex)
        ConsoleWrite("Selected item: " & $selectedItem & @CRLF)
    Else
        ; If none is selected, copy the first item
        Local $selectedItem = GUICtrlRead($lstListBox, 0) ; Assuming 0 is the index of the first item
        ConsoleWrite("No item selected, copying first item: " & $selectedItem & @CRLF)
    EndIf
    ClipPut($selectedItem)
    ConsoleWrite("Copied to clipboard: " & $selectedItem & @CRLF)
EndFunc

Func WM_ACTIVATE_Handler($hWnd, $Msg, $wParam, $lParam)
    Local $iState = BitAND($wParam, 0xFFFF)
    If $iState = 0 Then ; If losing focus
        ExitApplication()
    EndIf
    Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_ACTIVATE_Handler
