# R01-T027: Explore Readline Case Commands

## 1. Readline Default Case Commands (`bind -P`)

Running `bind -P | grep -E 'upcase-word|downcase-word|capitalize-word'` shows the active key bindings in Bash's default Emacs editing mode:

```text
capitalize-word can be found on "\ec".
downcase-word can be found on "\el".
upcase-word can be found on "\eu".
```

### Explanation of Readline Functions
- **`upcase-word` (`\eu` / `Esc + u` / `Alt-u`):** Converts characters from current cursor position to the end of the current word to uppercase, moving the cursor forward to the end of the word.
- **`downcase-word` (`\el` / `Esc + l` / `Alt-l`):** Converts characters from current cursor position to the end of the current word to lowercase, moving the cursor forward.
- **`capitalize-word` (`\ec` / `Esc + c` / `Alt-c`):** Capitalizes the character directly under the cursor and lowercases the remainder of the word, advancing the cursor forward.

## 2. Alt Key vs Esc Key in Terminal Emulators

Readline key specifications denote `\e` as the ASCII Escape character (`\x1b`).
- Historically, physical keyboards had a `Meta` key that set the 8th bit of transmitted bytes.
- Modern terminal emulators (xterm, GNOME Terminal, Terminal.app, iTerm2, Alacritty) send Escape sequences by prefixing the keystroke with `\e`.
- Consequently, pressing `Esc` then `u` transmits the byte sequence `0x1B 0x75` (`\eu`), identical to pressing `Alt+u` (when terminal option "Use Option/Alt as Meta key" or `metaSendsEscape` is enabled).

## 3. Impact of `set -o vi`

By default, Bash starts in Emacs mode (`set -o emacs`).
When switching to vi modal editing mode:
```bash
set -o vi
```
- In vi insert mode, `Esc` is the command to return to vi normal/command mode rather than a prefix for Emacs word transformations.
- In vi command mode, case mutations are performed using standard vi operators:
  - `~`: Invert case of the character under cursor.
  - `gU<motion>` (or Readline `vi-change-case`): Convert text covered by motion to uppercase.
  - `gu<motion>`: Convert text covered by motion to lowercase.
- Running `bind -P` under `set -o vi` reveals that `upcase-word` and `downcase-word` are unbound (`is not bound to any keys`) in vi command mode.

## 4. Custom Keybinding via `.inputrc`

Custom bindings can be declared in an inputrc file and loaded dynamically into the running shell with `bind -f <file>`.

For example, binding `Ctrl-x u` to `upcase-word`:
```text
"\C-xu": upcase-word
```
After loading with `bind -f inputrc`:
```bash
$ bind -P | grep upcase-word
upcase-word can be found on "\C-xu", "\eu".
```
Pressing `Ctrl-x` followed by `u` now uppercase-converts words directly.
