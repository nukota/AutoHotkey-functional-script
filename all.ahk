#Requires AutoHotkey v2.0
#SingleInstance Force

; ============================================
; ALL AHK FUNCTIONS - Combined Script
; ============================================
; This script contains all AHK utilities in one file
; ============================================

; ==============================
; URI ENCODE FUNCTION (Shared)
; ==============================
UriEncode(str) {
    out := ""
    Loop Parse, str {
        ch := A_LoopField
        if ch ~= "[A-Za-z0-9_.~-]"
            out .= ch
        else
            out .= "%" Format("{:02X}", Ord(ch))
    }
    return out
}

; =========================
; URL UTILITIES
; - URL validation
; - URL shortening
; =========================

; Check if string is a valid URL
IsValidUrl(str) {
    ; Check if string starts with http:// or https://
    return RegExMatch(str, "i)^https?://[^\s]+$")
}

; Shorten URL using is.gd API
ShortenUrl(url) {
    ; Use is.gd API (simple and reliable)
    apiUrl := "https://is.gd/create.php?format=simple&url=" . UriEncode(url)
    
    ; Create HTTP request
    http := ComObject("WinHttp.WinHttpRequest.5.1")
    
    ; Make GET request
    http.Open("GET", apiUrl, false)
    http.Send()
    
    ; Check response
    if (http.Status = 200) {
        shortUrl := Trim(http.ResponseText)
        ; Validate that we got a shortened URL
        if RegExMatch(shortUrl, "i)^https?://[^\s]+$")
            return shortUrl
    }
    
    return ""
}

; =========================
; CapsLock + C: Shorten URL
; =========================
CapsLock & c:: {
    ; Save current clipboard
    oldClip := A_Clipboard
    A_Clipboard := ""
    
    ; Copy selected text
    Send("^c")
    if !ClipWait(0.5) {
        ToolTip("⚠️ No text selected!")
        SetTimer(() => ToolTip(), -2000)
        A_Clipboard := oldClip
        return
    }
    
    url := Trim(A_Clipboard)
    
    ; Validate URL
    if !IsValidUrl(url) {
        ToolTip("⚠️ Selected text is not a valid URL!")
        SetTimer(() => ToolTip(), -2000)
        A_Clipboard := oldClip
        return
    }
    
    ; Show loading indicator
    ToolTip("🔄 Shortening URL...")
    
    ; Call API to shorten URL
    try {
        shortUrl := ShortenUrl(url)
        if (shortUrl != "") {
            ; Replace selected text with short URL
            A_Clipboard := shortUrl
            Send("^v")
            ToolTip("✅ URL shortened and copied!`n" shortUrl)
            SetTimer(() => ToolTip(), -3000)
        } else {
            ToolTip("❌ Failed to shorten URL!")
            SetTimer(() => ToolTip(), -2000)
            A_Clipboard := oldClip
        }
    } catch as err {
        ToolTip("❌ Error: " err.Message)
        SetTimer(() => ToolTip(), -3000)
        A_Clipboard := oldClip
    }
}

; =========================
; BROWSER & APP SHORTCUTS
; - Quick website opening
; - Application shortcuts
; - Search functions
; =========================

; =========================
; Open Edge with URL
; =========================
OpenEdgeInstant(url) {
    Run('msedge.exe "' url '"')
}

; =========================
; WEBSITE HOTKEYS
; =========================

; Gmail
!q:: OpenEdgeInstant("https://mail.google.com/")

; ChatGPT
!c:: OpenEdgeInstant("https://chat.openai.com/")

; Facebook
!w:: OpenEdgeInstant("https://www.facebook.com/")

; Spotify WEB
!s:: OpenEdgeInstant("https://open.spotify.com/")

; Gemini
!g:: OpenEdgeInstant("https://gemini.google.com/")

; Reddit
!r:: OpenEdgeInstant("https://reddit.com/")

; =========================
; Alt + V: VS Code
; =========================
!v:: {
    if WinExist("ahk_exe Code.exe")
        WinActivate
    else
        Run("code")
}

; =========================
; CapsLock + M: Start Google Meet
; =========================
CapsLock & m:: {
    ; Open meet.new in Edge
    Run('msedge.exe "https://meet.new"')
    
    ; Wait for page to load
    Sleep(3000)
    
    ; Copy the current URL to clipboard
    Send("^l")  ; Focus address bar
    Sleep(500)
    Send("^c")  ; Copy URL
    Sleep(500)
    
    ; Show success message
    ToolTip("✅ Google Meet started!`nURL copied to clipboard.")
    SetTimer(() => ToolTip(), -2000)
}

; =========================
; Alt + 1: Google Search selected text
; =========================
!1:: {
    oldClip := A_Clipboard
    A_Clipboard := ""
    
    Send("^c")
    if !ClipWait(0.3) {
        A_Clipboard := oldClip
        return
    }
    
    query := UriEncode(A_Clipboard)
    A_Clipboard := oldClip
    
    Run('msedge.exe "https://www.google.com/search?q=' query '"')
}

; =========================
; Alt + 2: Google Search "giai thich" + selected text
; =========================
!2:: {
    oldClip := A_Clipboard
    A_Clipboard := ""
    
    Send("^c")
    if !ClipWait(0.3) {
        A_Clipboard := oldClip
        return
    }
    
    query := UriEncode("giai thich " . A_Clipboard)
    A_Clipboard := oldClip
    
    Run('msedge.exe "https://www.google.com/search?q=' query '"')
}

; ===============================
; Alt + A → Go to website in Edge
; ===============================
!a:: {
    result := InputBox("Where you going huh?:", "(?_?)")
    
    if result.Result = "OK" && result.Value != "" {
        
        if !WinExist("ahk_exe msedge.exe")
            Run "msedge.exe"
        
        WinActivate "ahk_exe msedge.exe"
        Sleep 500
        
        Send "^t"
        Sleep 100
        
        ; Force Google search (prevents address-bar autocomplete navigation) 
        SendText result.Value
        Send "{Enter}"
    }
}

; =========================
; CAPSLOCK UTILITIES
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

; ============================================
; CLIPBOARD HISTORY MANAGER
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
    DisplayText := StrReplace(Text, "`t", " ")
    
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

; ==============================
; HOTSTRING MANAGER
; - Custom hotstrings with rich text support
; - GUI editor for managing hotstrings
; ==============================

; ==============================
; Hotstring Configuration
; ==============================
global HotstringPrefix := ";"

; ==============================
; Default hotstrings (without prefix)
; ==============================
; Markup: <b>bold</b> <i>italic</i> <u>underline</u> <br>=newline
global Hotstrings := Map(
    "brb",  "be right back",
    "omw",  "on my way",
    "ty",   "thank you",
    "np",   "no problem",
    "idk",  "I don't know",
    "afaik","as far as I know",
    "btw",  "by the way",
    "imo",  "in my opinion",
    "lol",  "laugh out loud",
    "thx",  "thanks",
    "yw",   "you're welcome",
    "fyi",  "for your information",
    "asap", "as soon as possible",
    "pls",  "please",
    "req",  "request",
    "eod",  "end of day",
    "eta",  "estimated time of arrival",
    "tbd",  "to be determined",
    "wip",  "work in progress",
    "mail", "<i>Thân chào </i>[Tên],<br><br><b>Trân trọng,</b><br><b>Thanh</b>"
)

global RegisteredHotstrings := []

; ==============================
; Register hotstrings
; ==============================
RegisterHotstrings() {
    global Hotstrings, RegisteredHotstrings, HotstringPrefix
    
    ; Clear old ones
    for hs in RegisteredHotstrings {
        try Hotstring("::" hs, "Off")
    }
    
    RegisteredHotstrings := []
    
    ; Register new ones with prefix
    for trigger, text in Hotstrings {
        fullTrigger := HotstringPrefix . trigger
        boundFunc := SendRichText.Bind(text)
        Hotstring(":*:" fullTrigger, boundFunc)
        RegisteredHotstrings.Push(fullTrigger)
    }
}

; ==============================
; Send Rich Text (parse markup)
; ==============================
SendRichText(text, *) {
    ; Parse and send text with formatting
    ; <b>...</b> = bold, <i>...</i> = italic, <u>...</u> = underline, <br> = newline
    
    pos := 1
    textLen := StrLen(text)
    
    while (pos <= textLen) {
        ; Check for tags
        if (SubStr(text, pos, 3) = "<b>") {
            Send "^b"
            pos += 3
            continue
        }
        if (SubStr(text, pos, 4) = "</b>") {
            Send "^b"
            pos += 4
            continue
        }
        if (SubStr(text, pos, 3) = "<i>") {
            Send "^i"
            pos += 3
            continue
        }
        if (SubStr(text, pos, 4) = "</i>") {
            Send "^i"
            pos += 4
            continue
        }
        if (SubStr(text, pos, 3) = "<u>") {
            Send "^u"
            pos += 3
            continue
        }
        if (SubStr(text, pos, 4) = "</u>") {
            Send "^u"
            pos += 4
            continue
        }
        if (SubStr(text, pos, 4) = "<br>") {
            Send "{Enter}"
            pos += 4
            continue
        }
        
        ; Send regular character
        SendText SubStr(text, pos, 1)
        pos += 1
    }
}

RegisterHotstrings()

; ==============================
; GUI
; ==============================
global myGui := Gui("+AlwaysOnTop +Resize", "Hotstring Editor")
myGui.SetFont("s10", "Segoe UI")

; Prefix setting
myGui.Add("Text", "Section", "Prefix:")
global prefixEdit := myGui.Add("Edit", "x+5 w40", HotstringPrefix)
myGui.Add("Button", "x+10 w120", "Apply Prefix").OnEvent("Click", ApplyPrefix)

; Hotstrings list
myGui.Add("Text", "xs y+15", "Hotstrings (double-click to edit):")
global lv := myGui.Add("ListView", "xs y+5 w500 r10 Grid", ["Trigger", "Expansion (with markup)"])
lv.ModifyCol(1, 80)
lv.ModifyCol(2, 400)
for k, v in Hotstrings
    lv.Add(, k, v)
lv.OnEvent("DoubleClick", EditHotstring)

; Buttons row
myGui.Add("Button", "xs y+10 w100", "Add New").OnEvent("Click", AddNewHotstring)
myGui.Add("Button", "x+10 w100", "Edit").OnEvent("Click", EditSelectedHotstring)
myGui.Add("Button", "x+10 w100", "Delete").OnEvent("Click", DeleteRow)
myGui.Add("Button", "x+10 w100", "Save All").OnEvent("Click", SaveHotstrings)

; Markup help
myGui.Add("Text", "xs y+15 cGray", "Markup: <b>bold</b>  <i>italic</i>  <u>underline</u>  <br>=newline")

myGui.OnEvent("Close", (*) => myGui.Hide())

; ==============================
; Editor GUI (for adding/editing)
; ==============================
global editorGui := Gui("+AlwaysOnTop +Owner" myGui.Hwnd, "Hotstring Editor")
editorGui.SetFont("s10", "Segoe UI")

editorGui.Add("Text", "Section", "Trigger (without prefix):")
global triggerEdit := editorGui.Add("Edit", "xs y+5 w300")

editorGui.Add("Text", "xs y+15", "Expansion text:")
global expansionEdit := editorGui.Add("Edit", "xs y+5 w400 h150 Multi")

; Formatting buttons with styled text
editorGui.Add("Text", "xs y+10", "Format:")
global btnBold := editorGui.Add("Button", "x+10 w40 h28", "B")
btnBold.SetFont("s11 Bold")
btnBold.OnEvent("Click", (*) => InsertTag("b"))

global btnItalic := editorGui.Add("Button", "x+5 w40 h28", "I")
btnItalic.SetFont("s11 Italic")
btnItalic.OnEvent("Click", (*) => InsertTag("i"))

global btnUnderline := editorGui.Add("Button", "x+5 w40 h28", "U")
btnUnderline.SetFont("s11 Underline")
btnUnderline.OnEvent("Click", (*) => InsertTag("u"))

editorGui.Add("Button", "x+10 w70 h28", "↵ Break").OnEvent("Click", (*) => InsertLineBreak())

; Save/Cancel
editorGui.Add("Button", "xs y+20 w100", "Ok").OnEvent("Click", SaveEditorHotstring)
editorGui.Add("Button", "x+10 w100", "Cancel").OnEvent("Click", (*) => editorGui.Hide())

editorGui.OnEvent("Close", (*) => editorGui.Hide())

global editingIndex := 0  ; 0 = adding new, >0 = editing existing row

; ==============================
; Hotkey: CapsLock + ;
; ==============================
CapsLock & `;::ToggleGui()

ToggleGui() {
    global myGui
    if WinExist("ahk_id " myGui.Hwnd)
        myGui.Hide()
    else
        myGui.Show()
}

; ==============================
; GUI actions
; ==============================

ApplyPrefix(*) {
    global HotstringPrefix, prefixEdit, myGui
    newPrefix := prefixEdit.Value
    HotstringPrefix := newPrefix
    RegisterHotstrings()
    if (newPrefix = "")
        ToolTip("✅ Prefix removed (no prefix)")
    else
        ToolTip("✅ Prefix changed to: " HotstringPrefix)
    SetTimer(() => ToolTip(), -2000)
}

AddNewHotstring(*) {
    global editingIndex, triggerEdit, expansionEdit, editorGui
    editingIndex := 0
    triggerEdit.Value := ""
    expansionEdit.Value := ""
    editorGui.Title := "Add New Hotstring"
    editorGui.Show()
}

EditSelectedHotstring(*) {
    global lv
    row := lv.GetNext()
    if (row = 0) {
        MsgBox("Please select a hotstring to edit.", "No Selection", "Icon!")
        return
    }
    EditHotstringByRow(row)
}

EditHotstring(ctrl, row) {
    if (row > 0)
        EditHotstringByRow(row)
}

EditHotstringByRow(row) {
    global lv, editingIndex, triggerEdit, expansionEdit, editorGui
    editingIndex := row
    trigger := lv.GetText(row, 1)
    expansion := lv.GetText(row, 2)
    triggerEdit.Value := trigger
    expansionEdit.Value := expansion
    editorGui.Title := "Edit Hotstring: " trigger
    editorGui.Show()
}

InsertTag(tag) {
    global expansionEdit
    
    ; Get selection info using Edit control messages
    ; EM_GETSEL = 0x00B0 - returns DWORD with start in LOWORD and end in HIWORD
    result := SendMessage(0x00B0, 0, 0, expansionEdit.Hwnd)
    startPos := result & 0xFFFF
    endPos := (result >> 16) & 0xFFFF
    
    currentText := expansionEdit.Value
    
    if (startPos != endPos) {
        ; Text is selected - wrap it
        beforeSel := SubStr(currentText, 1, startPos)
        selectedText := SubStr(currentText, startPos + 1, endPos - startPos)
        afterSel := SubStr(currentText, endPos + 1)
        
        expansionEdit.Value := beforeSel "<" tag ">" selectedText "</" tag ">" afterSel
        
        ; Move cursor after the closing tag
        newPos := endPos + StrLen("<" tag "></" tag ">")
        SendMessage(0x00B1, newPos, newPos, expansionEdit.Hwnd)  ; EM_SETSEL
    } else {
        ; No selection - insert empty tags at cursor
        beforeCursor := SubStr(currentText, 1, startPos)
        afterCursor := SubStr(currentText, startPos + 1)
        
        expansionEdit.Value := beforeCursor "<" tag "></" tag ">" afterCursor
        
        ; Place cursor between tags
        newPos := startPos + StrLen("<" tag ">")
        SendMessage(0x00B1, newPos, newPos, expansionEdit.Hwnd)  ; EM_SETSEL
    }
    
    expansionEdit.Focus()
}

InsertLineBreak() {
    global expansionEdit
    
    ; Get cursor position
    result := SendMessage(0x00B0, 0, 0, expansionEdit.Hwnd)  ; EM_GETSEL
    startPos := result & 0xFFFF
    endPos := (result >> 16) & 0xFFFF
    
    currentText := expansionEdit.Value
    beforeCursor := SubStr(currentText, 1, startPos)
    afterCursor := SubStr(currentText, endPos + 1)
    
    expansionEdit.Value := beforeCursor "<br>" afterCursor
    
    ; Move cursor after <br>
    newPos := startPos + 4
    SendMessage(0x00B1, newPos, newPos, expansionEdit.Hwnd)  ; EM_SETSEL
    
    expansionEdit.Focus()
}

SaveEditorHotstring(*) {
    global lv, editingIndex, triggerEdit, expansionEdit, editorGui, Hotstrings
    
    trigger := Trim(triggerEdit.Value)
    expansion := expansionEdit.Value
    
    if (trigger = "") {
        MsgBox("Trigger cannot be empty!", "Error", "Icon!")
        return
    }
    
    if (editingIndex = 0) {
        ; Adding new
        lv.Add(, trigger, expansion)
    } else {
        ; Editing existing
        lv.Modify(editingIndex, , trigger, expansion)
    }
    
    editorGui.Hide()
}

DeleteRow(*) {
    global lv
    row := lv.GetNext()
    if (row = 0) {
        MsgBox("Please select a hotstring to delete.", "No Selection", "Icon!")
        return
    }
    lv.Delete(row)
}

SaveHotstrings(*) {
    global lv, Hotstrings
    
    Hotstrings := Map()
    
    Loop lv.GetCount() {
        trigger := lv.GetText(A_Index, 1)
        expand  := lv.GetText(A_Index, 2)
        if (trigger != "")
            Hotstrings[trigger] := expand
    }
    
    RegisterHotstrings()
    ToolTip("✅ Saved! " lv.GetCount() " hotstrings active.")
    SetTimer(() => ToolTip(), -2000)
}

; ============================================
; JOKEAPI INTEGRATION
; ============================================
; - Press CapsLock + J to open joke generator
; - Select categories, flags, language, etc.
; - Get random jokes from JokeAPI
; ============================================

; Global variables for joke data
global CurrentJoke := ""
global JokeOptionsGui := ""
global JokeResultGui := ""

; ==============================
; Hotkey: CapsLock + J - Open Joke Generator
; ==============================
CapsLock & j:: ShowJokeOptionsGui()

ShowJokeOptionsGui() {
    global JokeOptionsGui
    
    ; Close existing GUI if open
    if (JokeOptionsGui != "") {
        try JokeOptionsGui.Destroy()
    }
    
    ; Create options GUI
    JokeOptionsGui := Gui("+AlwaysOnTop", "🎭 Joke Generator - JokeAPI")
    JokeOptionsGui.SetFont("s10", "Segoe UI")
    JokeOptionsGui.BackColor := "FFFFFF"
    
    ; Title
    JokeOptionsGui.SetFont("s14 Bold", "Segoe UI")
    JokeOptionsGui.Add("Text", "xm w400 Center", "🎭 Random Joke Generator")
    JokeOptionsGui.SetFont("s10 Norm", "Segoe UI")
    JokeOptionsGui.Add("Text", "xm w400 Center cGray", "Powered by JokeAPI v2")
    
    ; Categories Section
    JokeOptionsGui.Add("GroupBox", "xm y+15 w420 h100", "Categories (select at least one)")
    global chkAny := JokeOptionsGui.Add("Checkbox", "xm+10 yp+25 w90", "Any")
    chkAny.Value := 1
    chkAny.OnEvent("Click", ToggleAnyCategory)
    
    global chkProgramming := JokeOptionsGui.Add("Checkbox", "x+10 w100", "Programming")
    global chkMisc := JokeOptionsGui.Add("Checkbox", "x+10 w60", "Misc")
    global chkDark := JokeOptionsGui.Add("Checkbox", "x+10 w60", "Dark")
    global chkPun := JokeOptionsGui.Add("Checkbox", "xm+10 y+10 w60", "Pun")
    global chkSpooky := JokeOptionsGui.Add("Checkbox", "x+10 w70", "Spooky")
    global chkChristmas := JokeOptionsGui.Add("Checkbox", "x+10 w90", "Christmas")
    
    ; Blacklist Flags Section
    JokeOptionsGui.Add("GroupBox", "xm y+20 w420 h80", "Blacklist Flags (jokes with these will be excluded)")
    global chkNsfw := JokeOptionsGui.Add("Checkbox", "xm+10 yp+25 w70", "NSFW")
    global chkReligious := JokeOptionsGui.Add("Checkbox", "x+10 w80", "Religious")
    global chkPolitical := JokeOptionsGui.Add("Checkbox", "x+10 w70", "Political")
    global chkRacist := JokeOptionsGui.Add("Checkbox", "x+10 w60", "Racist")
    global chkSexist := JokeOptionsGui.Add("Checkbox", "xm+10 y+10 w60", "Sexist")
    global chkExplicit := JokeOptionsGui.Add("Checkbox", "x+10 w70", "Explicit")
    global chkSafeMode := JokeOptionsGui.Add("Checkbox", "x+20 w100", "🔒 Safe Mode")
    chkSafeMode.OnEvent("Click", ToggleSafeMode)
    
    ; Language & Type Section
    JokeOptionsGui.Add("GroupBox", "xm y+20 w420 h70", "Options")
    
    JokeOptionsGui.Add("Text", "xm+10 yp+25", "Language:")
    global ddlLanguage := JokeOptionsGui.Add("DropDownList", "x+10 w100", ["en", "cs", "de", "es", "fr", "pt"])
    ddlLanguage.Choose(1)  ; Default to English (en)
    
    JokeOptionsGui.Add("Text", "x+20", "Type:")
    global ddlType := JokeOptionsGui.Add("DropDownList", "x+10 w100", ["Any", "single", "twopart"])
    ddlType.Choose(1)  ; Default to Any
    
    ; Search String (optional)
    JokeOptionsGui.Add("GroupBox", "xm y+20 w420 h55", "Search (optional)")
    JokeOptionsGui.Add("Text", "xm+10 yp+22", "Contains:")
    global editSearch := JokeOptionsGui.Add("Edit", "x+10 w330")
    
    ; Buttons
    JokeOptionsGui.Add("Button", "xm y+25 w200 h40", "🎲 Get Random Joke").OnEvent("Click", FetchJoke)
    JokeOptionsGui.Add("Button", "x+20 w200 h40", "❌ Cancel").OnEvent("Click", (*) => JokeOptionsGui.Destroy())
    
    JokeOptionsGui.OnEvent("Close", (*) => JokeOptionsGui.Destroy())
    JokeOptionsGui.OnEvent("Escape", (*) => JokeOptionsGui.Destroy())
    
    JokeOptionsGui.Show("AutoSize")
}

ToggleAnyCategory(*) {
    global chkAny, chkProgramming, chkMisc, chkDark, chkPun, chkSpooky, chkChristmas
    
    if (chkAny.Value = 1) {
        ; If "Any" is checked, uncheck and disable others
        chkProgramming.Value := 0
        chkMisc.Value := 0
        chkDark.Value := 0
        chkPun.Value := 0
        chkSpooky.Value := 0
        chkChristmas.Value := 0
        chkProgramming.Enabled := false
        chkMisc.Enabled := false
        chkDark.Enabled := false
        chkPun.Enabled := false
        chkSpooky.Enabled := false
        chkChristmas.Enabled := false
    } else {
        ; Enable individual categories
        chkProgramming.Enabled := true
        chkMisc.Enabled := true
        chkDark.Enabled := true
        chkPun.Enabled := true
        chkSpooky.Enabled := true
        chkChristmas.Enabled := true
    }
}

ToggleSafeMode(*) {
    global chkSafeMode, chkNsfw, chkReligious, chkPolitical, chkRacist, chkSexist, chkExplicit
    
    if (chkSafeMode.Value = 1) {
        ; Safe mode - check all blacklist flags and disable them
        chkNsfw.Value := 1
        chkReligious.Value := 1
        chkPolitical.Value := 1
        chkRacist.Value := 1
        chkSexist.Value := 1
        chkExplicit.Value := 1
        chkNsfw.Enabled := false
        chkReligious.Enabled := false
        chkPolitical.Enabled := false
        chkRacist.Enabled := false
        chkSexist.Enabled := false
        chkExplicit.Enabled := false
    } else {
        ; Re-enable individual flags
        chkNsfw.Enabled := true
        chkReligious.Enabled := true
        chkPolitical.Enabled := true
        chkRacist.Enabled := true
        chkSexist.Enabled := true
        chkExplicit.Enabled := true
    }
}

FetchJoke(*) {
    global chkAny, chkProgramming, chkMisc, chkDark, chkPun, chkSpooky, chkChristmas
    global chkNsfw, chkReligious, chkPolitical, chkRacist, chkSexist, chkExplicit, chkSafeMode
    global ddlLanguage, ddlType, editSearch
    global JokeOptionsGui, CurrentJoke
    
    ; Build categories
    categories := ""
    if (chkAny.Value = 1) {
        categories := "Any"
    } else {
        cats := []
        if (chkProgramming.Value = 1)
            cats.Push("Programming")
        if (chkMisc.Value = 1)
            cats.Push("Misc")
        if (chkDark.Value = 1)
            cats.Push("Dark")
        if (chkPun.Value = 1)
            cats.Push("Pun")
        if (chkSpooky.Value = 1)
            cats.Push("Spooky")
        if (chkChristmas.Value = 1)
            cats.Push("Christmas")
        
        if (cats.Length = 0) {
            MsgBox("Please select at least one category!", "Error", "Icon!")
            return
        }
        
        ; Join categories with comma
        for i, cat in cats {
            if (i > 1)
                categories .= ","
            categories .= cat
        }
    }
    
    ; Build blacklist flags
    flags := []
    if (chkNsfw.Value = 1)
        flags.Push("nsfw")
    if (chkReligious.Value = 1)
        flags.Push("religious")
    if (chkPolitical.Value = 1)
        flags.Push("political")
    if (chkRacist.Value = 1)
        flags.Push("racist")
    if (chkSexist.Value = 1)
        flags.Push("sexist")
    if (chkExplicit.Value = 1)
        flags.Push("explicit")
    
    blacklistFlags := ""
    for i, flag in flags {
        if (i > 1)
            blacklistFlags .= ","
        blacklistFlags .= flag
    }
    
    ; Get language
    lang := ddlLanguage.Text
    
    ; Get type
    jokeType := ddlType.Text
    
    ; Get search string
    searchStr := Trim(editSearch.Value)
    
    ; Build URL
    url := "https://v2.jokeapi.dev/joke/" . categories . "?format=json"
    
    if (blacklistFlags != "")
        url .= "&blacklistFlags=" . blacklistFlags
    
    if (lang != "" && lang != "English")
        url .= "&lang=" . lang
    
    if (jokeType != "" && jokeType != "Any")
        url .= "&type=" . jokeType
    
    if (searchStr != "")
        url .= "&contains=" . UriEncode(searchStr)
    
    if (chkSafeMode.Value = 1)
        url .= "&safe-mode"
    
    ; Show loading
    ToolTip("🔄 Fetching joke...")
    
    ; Make HTTP request
    try {
        http := ComObject("WinHttp.WinHttpRequest.5.1")
        http.Open("GET", url, false)
        http.SetRequestHeader("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AutoHotkey/2.0")
        http.Send()
        
        ToolTip()
        
        if (http.Status = 200) {
            response := http.ResponseText
            ParseAndShowJoke(response)
        } else {
            MsgBox("API Error: HTTP " . http.Status, "Error", "Icon!")
        }
    } catch as err {
        ToolTip()
        MsgBox("Request failed: " . err.Message, "Error", "Icon!")
    }
}

ParseAndShowJoke(jsonResponse) {
    global CurrentJoke, JokeOptionsGui
    
    ; Simple JSON parsing
    ; Check for error
    if (InStr(jsonResponse, '"error": true') || InStr(jsonResponse, '"error":true')) {
        ; Extract error message
        errorMsg := "No joke found with these filters. Try different options."
        if RegExMatch(jsonResponse, '"message":\s*"([^"]+)"', &match)
            errorMsg := match[1]
        
        MsgBox(errorMsg, "No Joke Found", "Icon!")
        return
    }
    
    ; Parse joke type
    jokeType := ""
    if RegExMatch(jsonResponse, '"type":\s*"([^"]+)"', &match)
        jokeType := match[1]
    
    ; Parse category
    category := ""
    if RegExMatch(jsonResponse, '"category":\s*"([^"]+)"', &match)
        category := match[1]
    
    ; Parse joke content based on type
    jokeText := ""
    if (jokeType = "single") {
        if RegExMatch(jsonResponse, '"joke":\s*"((?:[^"\\]|\\.)*)"', &match) {
            jokeText := DecodeJsonString(match[1])
        }
    } else if (jokeType = "twopart") {
        setup := ""
        delivery := ""
        if RegExMatch(jsonResponse, '"setup":\s*"((?:[^"\\]|\\.)*)"', &match)
            setup := DecodeJsonString(match[1])
        if RegExMatch(jsonResponse, '"delivery":\s*"((?:[^"\\]|\\.)*)"', &match)
            delivery := DecodeJsonString(match[1])
        
        jokeText := setup . "`n`n" . delivery
    }
    
    if (jokeText = "") {
        MsgBox("Could not parse joke response.", "Error", "Icon!")
        return
    }
    
    CurrentJoke := jokeText
    
    ; Hide options GUI
    JokeOptionsGui.Hide()
    
    ; Show result GUI
    ShowJokeResultGui(jokeText, category)
}

DecodeJsonString(str) {
    ; Decode JSON escape sequences
    str := StrReplace(str, "\n", "`n")
    str := StrReplace(str, "\r", "`r")
    str := StrReplace(str, "\t", "`t")
    str := StrReplace(str, '\"', '"')
    str := StrReplace(str, "\\", "\")
    return str
}

ShowJokeResultGui(jokeText, category) {
    global JokeResultGui, CurrentJoke
    
    ; Close existing GUI if open
    if (JokeResultGui != "") {
        try JokeResultGui.Destroy()
    }
    
    ; Create result GUI
    JokeResultGui := Gui("+AlwaysOnTop", "🎭 Your Joke")
    JokeResultGui.SetFont("s10", "Segoe UI")
    JokeResultGui.BackColor := "FFFEF0"
    
    ; Category badge
    JokeResultGui.SetFont("s9", "Segoe UI")
    JokeResultGui.Add("Text", "xm w450 Center cGray", "Category: " . category)
    
    ; Joke text
    JokeResultGui.SetFont("s12", "Segoe UI")
    jokeEdit := JokeResultGui.Add("Edit", "xm y+10 w450 h200 ReadOnly Multi", jokeText)
    jokeEdit.SetFont("s12", "Consolas")
    
    ; Buttons
    JokeResultGui.SetFont("s10", "Segoe UI")
    JokeResultGui.Add("Button", "xm y+15 w140 h40", "📋 Copy to Clipboard").OnEvent("Click", CopyJoke)
    JokeResultGui.Add("Button", "x+10 w140 h40", "🎲 Try Another").OnEvent("Click", TryAnotherJoke)
    JokeResultGui.Add("Button", "x+10 w140 h40", "❌ Close").OnEvent("Click", (*) => JokeResultGui.Destroy())
    
    JokeResultGui.OnEvent("Close", (*) => JokeResultGui.Destroy())
    JokeResultGui.OnEvent("Escape", (*) => JokeResultGui.Destroy())
    
    JokeResultGui.Show("AutoSize")
}

CopyJoke(*) {
    global CurrentJoke
    
    A_Clipboard := CurrentJoke
    ToolTip("✅ Joke copied to clipboard!")
    SetTimer(() => ToolTip(), -2000)
}

TryAnotherJoke(*) {
    global JokeResultGui, JokeOptionsGui
    
    ; Close result GUI
    JokeResultGui.Destroy()
    
    ; Show options GUI again
    JokeOptionsGui.Show()
    
    ; Auto-fetch another joke
    FetchJoke()
}

; ============================================
; STARTUP NOTIFICATIONS
; ============================================

; Show startup notifications
ToolTip("📋 Clipboard History Active`nPress CapsLock+V to view history")
SetTimer(() => ToolTip(), -3000)

Sleep(1000)

ToolTip("🎭 Joke Generator Active`nPress CapsLock+J for jokes")
SetTimer(() => ToolTip(), -3000)

Sleep(1000)

ToolTip("✅ All AHK functions loaded!")
SetTimer(() => ToolTip(), -3000)
