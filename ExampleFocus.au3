#include <GUIConstantsEx.au3>
#Include <WinAPI.au3>

Example()

Func Example()
    Local $sMsg1 = ""
    ; Create a GUI with various controls.
    Local $hGUI = GUICreate("Example")
    Local $idOK = GUICtrlCreateButton("Print", 310, 370, 85, 25)
    Local $inp1 = GUICtrlCreateInput("Scan goes here then tabs to the next InputBox", 10, 35, 300, 20) ; will not accept drag&drop files
    Local $inp2 = GUICtrlCreateInput("I want to detect when this input box is active/curser is here", 10, 55, 300, 20) ; will not accept drag&drop files

    ; Display the GUI.
    GUISetState(@SW_SHOW, $hGUI)

    Local $hWnd = ControlGetHandle(WinGetHandle("Example"), "", "[CLASSNN:Edit2]")
    Local $MouseOver = False

    ; Loop until the user exits.
    While 1
        $tPoint = _WinAPI_GetMousePos()
        If _WinAPI_WindowFromPoint($tPoint) = $hWnd Then
            If Not $MouseOver Then
                ; Do something
                ConsoleWrite('MouseOver' & @CRLF)
                $MouseOver = 1
            EndIf
        Else
            If $MouseOver Then
                ; Do something
                ConsoleWrite('MouseOver Lost' & @CRLF)
                $MouseOver = 0
            EndIf
        EndIf

        Switch GUIGetMsg()
            Case $GUI_EVENT_CLOSE, $idOK
                GUIDelete()
                Exit
            Case Else
                $sFocus = ControlGetFocus($hGUI)
                $hFocus = ControlGetHandle($hGUI, "", $sFocus)
                $ctrlFocus = _WinAPI_GetDlgCtrlID($hFocus)
                $sMsg = "Focus:" & @CRLF & _
                        @TAB & "ClassNameNN = " & $sFocus & @CRLF & _
                        @TAB & "Hwnd = " & $hFocus & @CRLF & _
                        @TAB & "ID = " & $ctrlFocus
                If $sMsg <> $sMsg1 Then
                    ConsoleWrite($sMsg & @CRLF)
                    $sMsg1 = $sMsg
                EndIf
        EndSwitch
    WEnd
EndFunc   ;==>Example

Exit