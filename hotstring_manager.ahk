#Requires AutoHotkey v2.0
#SingleInstance Force

; ==============================
; Hotstring Manager
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
