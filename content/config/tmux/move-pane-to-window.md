---
title: 'tmux: Move pane to window'
date: 2020-07-16
---

Using [`tmux-move-pane-to-window`] from [tmux-tools].

[tmux-tools]: https://github.com/alexherbo2/tmux-tools
[`tmux-move-pane-to-window`]: https://github.com/alexherbo2/tmux-tools/blob/master/bin/tmux-move-pane-to-window

Move focused pane to window:

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

**Note**: It is `Shift` + `<number>` on the US layout.

**Discussion**: [reddit • tmux • Move pane to window]

[reddit • tmux • Move pane to window]: https://reddit.com/r/tmux/comments/hs5cra/move_pane_to_window/

See also [Switch or create workspace].

[Switch or create workspace]: ../switch-or-create-workspace/
