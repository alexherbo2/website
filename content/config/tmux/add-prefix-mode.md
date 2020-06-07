---
title: 'tmux: Add prefix mode'
date: 2019-12-28
---

- Enter _prefix mode_ (yellow) with the prefix key.
- Exit mode (green) with `Escape`.

`~/.tmux.conf`

```
run-shell {
  tmux bind-key #{prefix} \
    set-option key-table prefix '\;' \
    set-option status-bg yellow
}
bind-key Escape {
  set-option key-table root
  set-option status-bg green
}
```

**Note**: `bind-key` does not work with variables, hence using `run-shell` instead of the following configuration:

`~/.tmux.conf`

```
bind-key '#{prefix}' set-option key-table prefix
bind-key Escape set-option key-table root
```

**Discussion**: [reddit • tmux • Add prefix mode]

[reddit • tmux • Add prefix mode]: https://reddit.com/r/tmux/comments/ehkjp5/add_prefix_mode/

See also [Make tmux modal].

[Make tmux modal]: ../make-tmux-modal/
