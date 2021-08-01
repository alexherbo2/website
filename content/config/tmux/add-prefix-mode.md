---
title: 'tmux: Add prefix mode'
date: 2019-12-28
---

- Enter _prefix mode_ (yellow) with the prefix key (type the prefix key twice).
- Exit mode (green) with `Escape`.

`~/.tmux.conf`

``` tmux
run-shell {
  tmux bind-key #{prefix} set-option key-table prefix
}

bind-key Escape set-option key-table root
```

**Note**: `bind-key` does not work with variables, hence using `run-shell` instead of simply:

``` tmux
bind-key '#{prefix}' set-option key-table prefix
```

You might want to display the current mode with a different color in the status line.

`~/.tmux.conf`

``` tmux
set-option -g status-style 'fg=black,bg=#{?#{==:#{client_key_table},root},green,yellow}'
```

**Discussion**: [reddit • tmux • Add prefix mode]

[reddit • tmux • Add prefix mode]: https://reddit.com/r/tmux/comments/ehkjp5/add_prefix_mode/

See also [Make tmux modal].

[Make tmux modal]: ../make-tmux-modal/
