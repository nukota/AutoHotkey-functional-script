#Requires AutoHotkey v2.0
#SingleInstance Force

; Include configuration file
#Include config.ahk

; =========================
; Browser & App Shortcuts
; - Quick website opening
; - Application shortcuts
; - Search functions
; =========================

; URI Encode function (needed for search)
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
; Open URL in preferred browser
; =========================
; (Function defined in config.ahk)

; =========================
; WEBSITE HOTKEYS
; =========================

; Gmail
!q:: OpenInBrowser("https://mail.google.com/")

; ChatGPT
!c:: OpenInBrowser("https://chat.openai.com/")

; Facebook
!w:: OpenInBrowser("https://www.facebook.com/")

; Spotify WEB
!s:: OpenInBrowser("https://open.spotify.com/")

; Gemini
!g:: OpenInBrowser("https://gemini.google.com/")

; Reddit
!r:: OpenInBrowser("https://reddit.com/")

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
    ; Open meet.new in preferred browser
    OpenInBrowser("https://meet.new")
    
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

    OpenInBrowser("https://www.google.com/search?q=" . query)
}

; =========================
; Alt + 2: Google Search "explain" + selected text
; =========================
!2:: {
    oldClip := A_Clipboard
    A_Clipboard := ""

    Send("^c")
    if !ClipWait(0.3) {
        A_Clipboard := oldClip
        return
    }

    query := UriEncode("explain " . A_Clipboard)
    A_Clipboard := oldClip

    OpenInBrowser("https://www.google.com/search?q=" . query)
}

; ===============================
; Alt + A → Go to website in preferred browser
; ===============================
!a:: {
    result := InputBox("Where you going huh?:", "(?_?)")

    if result.Result = "OK" && result.Value != "" {

        if !WinExist(BrowserWindowClass) {
            Run PreferredBrowser
            WinWait BrowserWindowClass
        }

        WinActivate BrowserWindowClass
        Sleep 500

        Send "^t"
        Sleep 100

        ; Force Google search (prevents address-bar autocomplete navigation) 
        SendText result.Value
        Send "{Enter}"
    }
}
