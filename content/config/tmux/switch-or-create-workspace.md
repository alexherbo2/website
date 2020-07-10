---
title: 'tmux: Switch or create workspace'
date: 2020-07-10
---

Switches to the specified window.
If the window does not exist, it will be created.

`tmux-select-window`

``` sh
#!/bin/sh

target_window=$1
tmux new-window -t "$target_window" ||
tmux select-window -t "$target_window"
```

Switch to window without prefix:

`~/.tmux.conf`

```
bind-key -n M-1 run-shell 'tmux-select-window 1'
bind-key -n M-2 run-shell 'tmux-select-window 2'
bind-key -n M-3 run-shell 'tmux-select-window 3'
bind-key -n M-4 run-shell 'tmux-select-window 4'
bind-key -n M-5 run-shell 'tmux-select-window 5'
bind-key -n M-6 run-shell 'tmux-select-window 6'
bind-key -n M-7 run-shell 'tmux-select-window 7'
bind-key -n M-8 run-shell 'tmux-select-window 8'
bind-key -n M-9 run-shell 'tmux-select-window 9'
bind-key -n M-0 run-shell 'tmux-select-window 10'
```

**Discussion**: [reddit • tmux • Switch or create workspace]

[reddit • tmux • Switch or create workspace]: https://reddit.com/r/tmux/comments/houfb6/switch_or_create_workspace/
