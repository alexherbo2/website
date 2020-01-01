---
title: Make tmux modal
date: 2020-01-01
---

- Unset prefix.
- Enter _prefix mode_ with `Control` + `Space`.
- Exit mode with `Escape`.

`~/.tmux.conf`

```
set-option -g prefix None
bind-key -n C-Space set-option key-table prefix ';' display-message 'Enter prefix mode'
bind-key Escape set-option key-table root ';' display-message 'Exit mode'
```

See also [tmux: Add prefix mode].

[tmux: Add prefix mode]: ../add-prefix-mode/
