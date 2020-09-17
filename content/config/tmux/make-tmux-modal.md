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
bind-key -n C-Space set-option key-table prefix
bind-key Escape set-option key-table root
```

You might want to display the current mode with a different color in the status line.

`~/.tmux.conf`

```
set-option -g status-style 'fg=black,bg=#{?#{==:#{client_key_table},root},green,yellow}'
set-option -g status-left '[#{session_name}] #{?#{!=:#{client_key_table},root},[#{client_key_table}] ,}'
set-option -g status-left-length 0
```

**Note**: Only display active modes in the status line.

## Quirks

Restore _root table_ on detach.

`~/.tmux.conf`

```
set-hook -g client-detached[0] 'set-option key-table root'
```

Restore _root table_ in _tree mode_.

`~/.tmux.conf`

```
bind-key s {
  choose-tree -Z -s
  set-option key-table root
}
```

**Discussion**: [reddit • tmux • Make tmux modal]

[reddit • tmux • Make tmux modal]: https://reddit.com/r/tmux/comments/einuqy/make_tmux_modal/

See also [tmux: Add prefix mode].

[tmux: Add prefix mode]: ../add-prefix-mode/
