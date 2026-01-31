; ============================================
; BROWSER EXECUTABLE
; ============================================
; Set your preferred browser (name or full path)
; Examples: "msedge.exe", "chrome.exe", "firefox.exe", "brave.exe"
; Or full path: "C:\Program Files\Google\Chrome\Application\chrome.exe"
global PreferredBrowser := "chrome.exe"

global BrowserWindowClass := "ahk_exe " . StrReplace(PreferredBrowser, ".exe", "") . ".exe"

; CLIPBOARD HISTORY SETTINGS
; Maximum number of items to store in clipboard history
global MaxHistoryItems := 25
; Maximum characters to display per item in the menu
global MaxDisplayLength := 60

; BROWSER LAUNCH FUNCTION
OpenInBrowser(url) {
    Run(PreferredBrowser ' "' url '"')
}