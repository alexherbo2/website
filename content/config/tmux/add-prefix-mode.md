---
title: 'tmux: Add prefix mode'
date: 2019-12-28
---

- Enter _prefix mode_ with the prefix key.
- Exit mode with `Escape`.

`~/.tmux.conf`

```
run-shell "tmux bind-key #{prefix} set-option key-table prefix '\\;' display-message 'Enter prefix mode'"
bind-key Escape set-option key-table root ';' display-message 'Exit mode'
```

**Note**: `bind-key` does not work with variables, hence using `run-shell` instead of the following configuration.

`~/.tmux.conf`

```
bind-key '#{prefix}' set-option key-table prefix
bind-key Escape set-option key-table root
```

See also [Make tmux modal].

[Make tmux modal]: ../make-tmux-modal/
