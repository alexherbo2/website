---
title: Control mpv from the command-line
---

## Configuration

`~/.config/mpv/mpv.conf`

```
input-ipc-server=~~/socket
```

## Commands

### Play / Pause

``` sh
echo cycle pause | socat - "$XDG_CONFIG_HOME/mpv/socket"
```

You can add a key-binding to `XF86AudioPlay` and `XF86AudioPause` [media controls].

### Next Track

``` sh
echo playlist-next | socat - "$XDG_CONFIG_HOME/mpv/socket"
```

You can add a key-binding to `XF86AudioNext` [media control][Media controls].

### Previous Track

``` sh
echo playlist-prev | socat - "$XDG_CONFIG_HOME/mpv/socket"
```

You can add a key-binding to `XF86AudioPrev` [media control][Media controls].

[Media controls]: https://cgit.freedesktop.org/xorg/proto/x11proto/tree/XF86keysym.h
