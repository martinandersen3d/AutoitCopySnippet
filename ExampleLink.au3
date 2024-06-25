#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>

; Create a GUI window
GUICreate("Open Snippets", 300, 100)

; Create a clickable label
$label = GUICtrlCreateLabel("Open snippets.txt", 50, 40, 200, 20)
GUICtrlSetFont($label, 10, 400, 0, "Arial")
GUICtrlSetColor($label, 0x0000FF) ; Blue color
GUICtrlSetCursor($label, 0) ; Hand cursor

; Show the GUI
GUISetState(@SW_SHOW)

; Main event loop
While 1
    ; Get the GUI message
    $msg = GUIGetMsg()
    ConsoleWrite($msg)

    ; Check if the label was clicked
    If $msg = $label Then
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
    EndIf

    ; Check if the window was closed
    If $msg = $GUI_EVENT_CLOSE Then
        ExitLoop
    EndIf
WEnd

; Cleanup and exit
GUIDelete()
Exit
