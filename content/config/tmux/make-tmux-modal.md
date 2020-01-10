---
title: Make tmux modal
date: 2020-01-01
---

- Unset prefix.
- Enter _prefix mode_ (yellow) with `Control` + `Space`.
- Exit mode (green) with `Escape`.

`~/.tmux.conf`

```
set-option -g prefix None
bind-key -n C-Space {
  set-option key-table prefix
  set-option status-bg yellow
}
bind-key Escape {
  set-option key-table root
  set-option status-bg green
}
```

You might want to display the current mode in the status line.

`~/.tmux.conf`

```
set-option -g status-left '[#{session_name}] #{?#{!=:#{client_key_table},root},[#{client_key_table}] ,}'
set-option -g status-left-length 0
```

**Note**: Only display active modes in the status line.

## Quirks

Restore _root table_ on detach.

`~/.tmux.conf`

```
set-hook -g client-detached[0] 'set-option key-table root'
set-hook -g client-detached[1] 'set-option status-bg green'
```

Restore _root table_ in _tree mode_.

`~/.tmux.conf`

```
bind-key s {
  choose-tree -Z -s
  set-option key-table root
  set-option status-bg green
}
```

See also [tmux: Add prefix mode].

[tmux: Add prefix mode]: ../add-prefix-mode/
