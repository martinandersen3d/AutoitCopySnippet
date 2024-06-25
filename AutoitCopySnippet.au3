#include <Date.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <StructureConstants.au3>
Opt("GUIOnEventMode", 1)

Global $frmMainForm = GUICreate("Copy Snippet", 300, 616, -1, -1)
GUISetOnEvent($GUI_EVENT_CLOSE, "ExitApplication")
Global $txtInput = GUICtrlCreateInput("", 8, 16, 284, 21)
GUICtrlSetFont(-1, 10, 400)
Global $lstListBox = GUICtrlCreateList("", 8, 45, 284, 557)
$hWndListBox = GUICtrlGetHandle($lstListBox)
GUICtrlSetFont(-1, 10, 400)

; Create a clickable label
$label = GUICtrlCreateLabel("Open snippets.txt", 100, 600, 200, 20)
GUICtrlSetFont($label, 10, 400, 0, "Arial")
GUICtrlSetColor($label, 0x0000FF) ; Blue color
GUICtrlSetCursor($label, 0) ; Hand cursor

; Register the label click event
GUICtrlSetOnEvent($label, "LabelClicked")

GUIRegisterMsg($WM_COMMAND, "WM_COMMAND")
GUIRegisterMsg($WM_ACTIVATE, "WM_ACTIVATE_Handler")
HotKeySet("{Enter}","EnterPressed")
HotKeySet("{Esc}","ExitApplication")
  
Func EnterPressed()
    ;~ ConsoleWrite("Enter Key is pressed!")
	CopySelectedItemToClipboard()
	Sleep(0.2)
	ExitApplication()
EndFunc

Func DownPressed()
    ;~ ConsoleWrite("Down pressed!")
    GUICtrlSetState($lstListBox, $GUI_FOCUS)
    ;~ Reset/disable hotkey
	HotKeySet("{Down}")
EndFunc

; Read snippets from file and populate listbox
ReadSnippetsFromFile("snippets.txt")
Global $sMsg1 = ""
GUISetState(@SW_SHOW, $frmMainForm)

While 1
    
    $msg = GUIGetMsg()
      Switch $msg
        Case $GUI_EVENT_CLOSE, $idOK
            GUIDelete()
            Exit
        Case Else
            $sFocus = ControlGetFocus($frmMainForm)
            $hFocus = ControlGetHandle($frmMainForm, "", $sFocus)
            $ctrlFocus = _WinAPI_GetDlgCtrlID($hFocus)
            $sMsg = "Focus:" & @CRLF & _
                    @TAB & "ClassNameNN = " & $sFocus & @CRLF & _
                    @TAB & "Hwnd = " & $hFocus & @CRLF & _
                    @TAB & "ID = " & $ctrlFocus
            ConsoleWrite($sMsg)
            If $sMsg <> $sMsg1 Then
                $sMsg1 = $sMsg
                ;~ If Edit Text Box Has Focus
                if $sFocus = "Edit1" Then
                    HotKeySet("{Down}","DownPressed")
                EndIf
                ;~ If ListBox Has Focus
                if $sFocus = "ListBox1" Then
                    ;~ Reset/disable hotkey
                    HotKeySet("{Down}")
                EndIf
            EndIf
    EndSwitch

    Sleep(50)
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


Func LabelClicked()
    ; Define the file path
    Local $filePath = "snippets.txt"

    ; Check if the file exists
    If FileExists($filePath) Then
        ; Open the file in Notepad
        ShellExecute("notepad.exe", $filePath)
    Else
        ; Display an error message if the file does not exist
        MsgBox(16, "Error", "The file 'snippets.txt' does not exist.")
    EndIf
EndFunc