#Requires AutoHotkey v2.0
#SingleInstance Force

; ============================================
; Main Launcher Script
; ============================================
; This script launches all other AHK scripts
; and then terminates itself.
; ============================================

; Get the script directory
scriptDir := A_ScriptDir

; List of scripts to run
scripts := [
    "url_utilities.ahk",
    "browser_shortcuts.ahk",
    "capslock_utilities.ahk",
    "clipboard_history.ahk",
    "hotstring_manager.ahk",
    "joke_generator.ahk"
]

; Launch each script
launchedCount := 0
for script in scripts {
    scriptPath := scriptDir . "\" . script
    
    ; Check if file exists
    if FileExist(scriptPath) {
        try {
            Run('"' . scriptPath . '"')
            launchedCount++
            ; Small delay between launches
            Sleep(200)
        } catch as err {
            ; Continue to next script if one fails
        }
    }
}

; Show notification
if (launchedCount > 0) {
    ToolTip("✅ Launched " . launchedCount . " AHK scripts!`nMain launcher terminating...")
    Sleep(2000)
    ToolTip()
}

; Exit the launcher script
ExitApp()
