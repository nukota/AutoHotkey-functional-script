# AHK Utilities

AutoHotkey v2 script combining multiple productivity tools into one powerful utility suite.

---

## 📁 File Structure

| File                     | Description                                                             |
| ------------------------ | ----------------------------------------------------------------------- |
| `config.ahk`             | **Browser configuration** - Set your preferred browser                  |
| `all.ahk`                | **Main script** - Contains all functions in a single file (recommended) |
| `launcher.ahk`           | Runs all separate scripts and terminates                                |
| `url_utilities.ahk`      | URL validation and shortening functions                                 |
| `browser_shortcuts.ahk`  | Quick website/app access hotkeys                                        |
| `capslock_utilities.ahk` | Text case conversion utilities                                          |
| `clipboard_history.ahk`  | Clipboard history manager                                               |
| `hotstring_manager.ahk`  | Custom hotstring editor with rich text                                  |
| `joke_generator.ahk`     | JokeAPI integration with GUI                                            |

---

## 📋 Quick Start Guide

1. **Install AutoHotkey v2.0**: Download from [autohotkey.com](https://www.autohotkey.com/) and run the installer
2. **Configure browser** (optional): Edit `config.ahk` to set your preferred browser (default: Microsoft Edge)
3. **Get the script**: Download `all.ahk` (or all files) to your computer
4. **Run the script**: Double-click `all.ahk` to start (or run individual `.ahk` files for specific functions only)
5. **Customize**: Press `CapsLock + ;` to edit hotstrings or modify the script directly

---

## ⌨️ Hotkey Reference

### CapsLock Combinations

| Hotkey             | Function           | Description                                                                                       |
| ------------------ | ------------------ | ------------------------------------------------------------------------------------------------- |
| `CapsLock + C`     | URL Shortener      | Select a URL, press hotkey → URL is shortened via is.gd API and replaces selection (also copy it) |
| `CapsLock + V`     | Clipboard History  | Opens a menu showing last 25 copied items. Click any item to paste it instantly                   |
| `CapsLock + J`     | Joke Generator     | Opens a GUI to configure and fetch random jokes from JokeAPI                                      |
| `CapsLock + ;`     | Hotstring Editor   | Opens GUI to add/edit/delete custom text expansions                                               |
| `CapsLock + M`     | Google Meet        | Creates a new Google Meet, waits for load, and copies the meeting URL                             |
| `CapsLock` (alone) | Toggle + Uppercase | Toggles CapsLock state AND converts selected text to UPPERCASE                                    |
| `Ctrl + CapsLock`  | Lowercase          | Converts selected text to lowercase (does not toggle CapsLock)                                    |

### Alt + Key Shortcuts

| Hotkey    | Target         | URL/Action                                                                                            |
| --------- | -------------- | ----------------------------------------------------------------------------------------------------- |
| `Alt + Q` | Gmail          | `https://mail.google.com/`                                                                            |
| `Alt + C` | ChatGPT        | `https://chat.openai.com/`                                                                            |
| `Alt + W` | Facebook       | `https://www.facebook.com/`                                                                           |
| `Alt + S` | Spotify Web    | `https://open.spotify.com/`                                                                           |
| `Alt + G` | Gemini         | `https://gemini.google.com/`                                                                          |
| `Alt + R` | Reddit         | `https://reddit.com/`                                                                                 |
| `Alt + V` | VS Code        | Activates existing window or launches VS Code                                                         |
| `Alt + A` | Quick Navigate | Shows input box → searches/navigates in Edge (uses browser autocomplete for frequently visited sites) |
| `Alt + 1` | Google Search  | Searches Google for selected text                                                                     |
| `Alt + 2` | Explain Search | Searches Google for "explain " + selected text                                                        |

---

## 🔧 Features in Detail

### 📋 Clipboard History Manager

Automatically tracks everything you copy to the clipboard.

- **Capacity**: Stores up to 25 items (configurable via `MaxHistoryItems`)
- **Display**: Items are truncated to 60 characters in menu (configurable via `MaxDisplayLength`)
- **Duplicate Handling**: If you copy the same text again, it moves to the top instead of duplicating
- **Access**: Press `CapsLock + V` anywhere to see the history menu
- **Paste**: Click any item to instantly paste it at cursor position
- **Clear**: Option at bottom of menu to clear all history

### ⌨️ Hotstring Manager

Create custom text expansions with optional rich text formatting.

**Default Prefix**: `;` (configurable in GUI)

**Built-in Hotstrings**:
| Trigger | Expansion |
|---------|-----------|
| `;brb` | be right back |
| `;omw` | on my way |
| `;ty` | thank you |
| `;np` | no problem |
| `;idk` | I don't know |
| `;afaik` | as far as I know |
| `;btw` | by the way |
| `;imo` | in my opinion |
| `;thx` | thanks |
| `;yw` | you're welcome |
| `;fyi` | for your information |
| `;asap` | as soon as possible |
| `;pls` | please |
| `;req` | request |
| `;eod` | end of day |
| `;eta` | estimated time of arrival |
| `;tbd` | to be determined |
| `;wip` | work in progress |
| `;mail` | Formatted email signature (italic + bold) |

**Rich Text Markup**:
| Tag | Effect | Example |
|-----|--------|---------|
| `<b>text</b>` | **Bold** (Ctrl+B) | `<b>Important</b>` |
| `<i>text</i>` | _Italic_ (Ctrl+I) | `<i>Note</i>` |
| `<u>text</u>` | Underline (Ctrl+U) | `<u>Highlight</u>` |
| `<br>` | New line (Enter) | `Line 1<br>Line 2` |

**GUI Features**:

- Double-click any hotstring to edit
- Formatting buttons (B, I, U, Break) insert tags at cursor
- Change prefix without restarting
- Save All applies changes immediately

### 🎭 Joke Generator (JokeAPI v2)

Fetches random jokes from [JokeAPI](https://v2.jokeapi.dev/) with customizable filters:

- **Categories**: Programming, Misc, Dark, Pun, Spooky, Christmas, or Any
- **Filters**: Blacklist NSFW/religious/political content, Safe Mode option
- **Languages**: English, Czech, German, Spanish, French, Portuguese
- **Types**: Single jokes, two-part jokes, or both
- **Search**: Optional keyword filtering
- **Actions**: Copy to clipboard, try another, or close

### 🔗 URL Shortener

Shortens URLs using the [is.gd](https://is.gd/) API.

**How to use**:

1. Select a URL in any application
2. Press `CapsLock + C`
3. The selected URL is replaced with the shortened version

**Features**:

- Validates URL format before sending
- Shows loading indicator during API call
- Displays success/error tooltip notifications
- Preserves original clipboard if operation fails

### 🔄 Text Case Conversion

**Uppercase** (`CapsLock` alone):

- If text is selected: Converts to UPPERCASE and toggles CapsLock
- If no text selected: Just toggles CapsLock state
- Smart detection: Ignores auto-selected single lines

**Lowercase** (`Ctrl + CapsLock`):

- Converts selected text to lowercase
- Does not affect CapsLock state

---

## ⚙️ Requirements

- **AutoHotkey v2.0** or later ([Download](https://www.autohotkey.com/))
- **Windows 10/11**
- **Web browser** (Microsoft Edge by default, configurable in `config.ahk`)
- **Internet connection** (for URL shortening and JokeAPI)

---

## 🛠️ Customization

### Change Hotstring Prefix

1. Press `CapsLock + ;` to open editor
2. Change the prefix in the top field (e.g., from `;` to `//`)
3. Click "Apply Prefix"

### Modify Clipboard History Size

Edit `config.ahk` and change:

```ahk
global MaxHistoryItems := 25        ; Maximum items to store
global MaxDisplayLength := 60       ; Characters shown per item
```

### Change Browser

Edit `config.ahk` and modify:

```ahk
global PreferredBrowser := "chrome.exe"  ; Change to your preferred browser
```

Supported browsers: `msedge.exe`, `chrome.exe`, `firefox.exe`, `brave.exe`, etc.

### Add New Website Shortcuts

Add new hotkeys in the Browser Shortcuts section:

```ahk
!x:: OpenInBrowser("https://example.com/")  ; Alt+X opens example.com
```

---

## 📝 License

Free to use and modify.
