#Requires AutoHotkey v2.0
#SingleInstance Force

; =========================
; CapsLock Utilities
; - CapsLock toggle with uppercase conversion
; - Ctrl+CapsLock for lowercase conversion
; =========================

; CapsLock pressed alone - Toggle CapsLock AND convert selected text to UPPERCASE
CapsLock:: {
    ; Try to copy selected text
    oldClip := A_Clipboard
    A_Clipboard := ""

    Send("^c")
    if !ClipWait(0.3) {
        ; No text selected, just toggle CapsLock
        A_Clipboard := oldClip
        if GetKeyState("CapsLock", "T")
            SetCapsLockState("Off")
        else
            SetCapsLockState("On")
        return
    }

    copiedText := A_Clipboard
    
    ; Check if text ends with line break (indicates auto-copied full line, not user selection)
    endsWithLineBreak := (SubStr(copiedText, -1) = "`n") || (SubStr(copiedText, -2) = "`r`n")
    
    if (endsWithLineBreak) {
        ; Count total line breaks in the text
        ; First replace `r`n with single marker to avoid double counting
        tempText := StrReplace(copiedText, "`r`n", "`n")
        lineBreakCount := StrLen(tempText) - StrLen(StrReplace(tempText, "`n", ""))
        
        if (lineBreakCount <= 1) {
            ; Auto-copied single line, just toggle CapsLock
            A_Clipboard := oldClip
            if GetKeyState("CapsLock", "T")
                SetCapsLockState("Off")
            else
                SetCapsLockState("On")
            return
        }
    }

    ; Real text selection, toggle CapsLock AND convert to uppercase
    if GetKeyState("CapsLock", "T")
        SetCapsLockState("Off")
    else
        SetCapsLockState("On")
    
    A_Clipboard := StrUpper(copiedText)
    Sleep 40
    Send("^v")

    Sleep 40
    A_Clipboard := oldClip
}

; Ctrl+CapsLock - Convert selected text to lowercase
^CapsLock:: {
    oldClip := A_Clipboard
    A_Clipboard := ""

    Send("^c")
    if !ClipWait(0.3) {
        A_Clipboard := oldClip
        return
    }

    A_Clipboard := StrLower(A_Clipboard)
    Sleep 40
    Send("^v")

    Sleep 40
    A_Clipboard := oldClip
}
