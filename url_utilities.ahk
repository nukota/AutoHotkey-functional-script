#Requires AutoHotkey v2.0
#SingleInstance Force

; =========================
; URL Utilities
; - URL validation
; - URL shortening
; - URI encoding
; =========================

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
