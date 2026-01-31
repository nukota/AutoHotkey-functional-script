#Requires AutoHotkey v2.0
#SingleInstance Force

; ============================================
; Clipboard History Manager
; ============================================
; - Automatically remembers everything you copy
; - Press CapsLock+V to see your clipboard history
; - Click an item to paste it instantly
; ============================================

; Configuration
global MaxHistoryItems := 25        ; Maximum items to remember
global MaxDisplayLength := 60       ; Max characters shown per item in menu
global ClipboardHistory := []       ; Array to store clipboard history
global LastClipboard := ""          ; Track last clipboard to avoid duplicates
global IsShowingMenu := false       ; Prevent multiple menus

; Monitor clipboard changes
OnClipboardChange(ClipboardChanged)

ClipboardChanged(DataType) {
    global ClipboardHistory, LastClipboard, MaxHistoryItems, IsShowingMenu
    
    ; Only process text (DataType = 1)
    if (DataType != 1)
        return
    
    ; Don't capture while showing menu (prevents capturing our own pastes)
    if (IsShowingMenu)
        return
    
    ; Get current clipboard text
    try {
        CurrentClip := A_Clipboard
    } catch {
        return
    }
    
    ; Skip empty or duplicate
    if (CurrentClip = "" || CurrentClip = LastClipboard)
        return
    
    ; Skip if it's just whitespace
    if (Trim(CurrentClip) = "")
        return
    
    ; Remove if this item already exists in history (to move it to top)
    for index, item in ClipboardHistory {
        if (item = CurrentClip) {
            ClipboardHistory.RemoveAt(index)
            break
        }
    }
    
    ; Add to beginning of history
    ClipboardHistory.InsertAt(1, CurrentClip)
    
    ; Trim history if too long
    while (ClipboardHistory.Length > MaxHistoryItems) {
        ClipboardHistory.Pop()
    }
    
    ; Update last clipboard
    LastClipboard := CurrentClip
}

; CapsLock+V - Show clipboard history menu
CapsLock & v:: {
    global ClipboardHistory, IsShowingMenu
    
    ; Check if we have any history
    if (ClipboardHistory.Length = 0) {
        ToolTip("Clipboard history is empty")
        SetTimer(() => ToolTip(), -2000)
        return
    }
    
    IsShowingMenu := true
    
    ; Create the menu
    HistoryMenu := Menu()
    
    ; Add items to menu
    for index, item in ClipboardHistory {
        ; Create display text (shortened and cleaned)
        DisplayText := FormatMenuItem(item, index)
        
        ; Create a closure to capture the correct item
        BoundFunc := PasteItem.Bind(item)
        HistoryMenu.Add(DisplayText, BoundFunc)
    }
    
    ; Add separator and clear option
    HistoryMenu.Add()
    HistoryMenu.Add("🗑️ Clear History", ClearHistory)
    
    ; Get mouse position and show menu there
    MouseGetPos(&mouseX, &mouseY)
    
    try {
        HistoryMenu.Show(mouseX, mouseY)
    } catch as err {
        ; Menu was cancelled or error occurred
    }
    
    IsShowingMenu := false
}

FormatMenuItem(Text, Index) {
    global MaxDisplayLength
    
    ; Replace newlines with symbol for display
    DisplayText := StrReplace(Text, "`r`n", " ↵ ")
    DisplayText := StrReplace(Text, "`n", " ↵ ")
    DisplayText := StrReplace(Text, "`r", " ↵ ")
    
    ; Replace tabs with spaces
    DisplayText := StrReplace(DisplayText, "`t", " ")
    
    ; Collapse multiple spaces
    while (InStr(DisplayText, "  ")) {
        DisplayText := StrReplace(DisplayText, "  ", " ")
    }
    
    ; Trim whitespace
    DisplayText := Trim(DisplayText)
    
    ; Truncate if too long
    if (StrLen(DisplayText) > MaxDisplayLength) {
        DisplayText := SubStr(DisplayText, 1, MaxDisplayLength) . "..."
    }
    
    ; Add number prefix for easy identification
    return Index . ". " . DisplayText
}

PasteItem(ItemText, *) {
    global LastClipboard, IsShowingMenu
    
    ; Small delay to let menu close
    Sleep(50)
    
    ; Set clipboard to selected item
    LastClipboard := ItemText
    A_Clipboard := ItemText
    
    ; Small delay to ensure clipboard is set
    Sleep(50)
    
    ; Paste it
    Send("^v")
}

ClearHistory(*) {
    global ClipboardHistory, LastClipboard
    
    ClipboardHistory := []
    LastClipboard := ""
    
    ToolTip("Clipboard history cleared")
    SetTimer(() => ToolTip(), -1500)
}

; Show startup notification
ToolTip("📋 Clipboard History Active`nPress CapsLock+V to view history")
SetTimer(() => ToolTip(), -3000)
