#Requires AutoHotkey v2.0
#SingleInstance Force

; ============================================
; JokeAPI Integration
; ============================================
; - Press CapsLock + J to open joke generator
; - Select categories, flags, language, etc.
; - Get random jokes from JokeAPI
; ============================================

; Global variables for joke data
global CurrentJoke := ""
global JokeOptionsGui := ""
global JokeResultGui := ""

; URI Encode function
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
    JokeOptionsGui.SetFont("s10 Normal", "Segoe UI")
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
    global ddlLanguage := JokeOptionsGui.Add("DropDownList", "x+10 w100", ["English|cs|de|en|es|fr|pt"])
    ddlLanguage.Choose(4)  ; Default to English (en)
    
    JokeOptionsGui.Add("Text", "x+20", "Type:")
    global ddlType := JokeOptionsGui.Add("DropDownList", "x+10 w100", ["Any|single|twopart"])
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
    jokeEdit := JokeResultGui.Add("Edit", "xm y+10 w450 h200 ReadOnly Multi -WantReturn", jokeText)
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

; Show startup notification
ToolTip("🎭 Joke Generator Active`nPress CapsLock+J for jokes")
SetTimer(() => ToolTip(), -3000)
