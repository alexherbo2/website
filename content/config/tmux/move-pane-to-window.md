---
title: 'tmux: Move pane to window'
date: 2020-07-16
---

Move focused pane to window:

`tmux-move-pane-to-window`

``` sh
#!/bin/sh

target_window=$1
source_window=$(tmux display-message -p '#{window_index}')
tmux join-pane -t ":$target_window"
tmux select-window -t "$source_window"
```

`~/.tmux.conf`

```
bind-key '!' run-shell 'tmux-move-pane-to-window 1'
bind-key '@' run-shell 'tmux-move-pane-to-window 2'
bind-key '#' run-shell 'tmux-move-pane-to-window 3'
bind-key '$' run-shell 'tmux-move-pane-to-window 4'
bind-key '%' run-shell 'tmux-move-pane-to-window 5'
bind-key '^' run-shell 'tmux-move-pane-to-window 6'
bind-key '&' run-shell 'tmux-move-pane-to-window 7'
bind-key '*' run-shell 'tmux-move-pane-to-window 8'
bind-key '(' run-shell 'tmux-move-pane-to-window 9'
bind-key ')' run-shell 'tmux-move-pane-to-window 10'
```

**Discussion**: [reddit • tmux • Move pane to window]

[reddit • tmux • Move pane to window]: https://reddit.com/r/tmux/comments/hs5cra/move_pane_to_window/

See also [Switch or create workspace].

[Switch or create workspace]: ../switch-or-create-workspace/
