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
bind-key -n C-Space set-option key-table prefix
bind-key Escape set-option key-table root
```

You might want to display the current mode in the status line.

`~/.tmux.conf`

```
set-option -g status-left '[#{session_name}] #{?#{!=:#{client_key_table},root},[#{client_key_table}] ,}'
set-option -g status-left-length 0
```

**Note**: Only display active modes in the status line.

See also [tmux: Add prefix mode].

[tmux: Add prefix mode]: ../add-prefix-mode/
