---
title: Create a keyboard interface to the web
description: A keyboard interface to the web, inspired by Kakoune
date: 2019-03-05
draft: true
---

This post is written for [Chrome], but can be adapted to the browser of your liking.

- [Configuration][Configuration for Chrome] and [default shortcuts][Chrome keyboard shortcuts] for [Chrome]
- [Configuration][Configuration for Firefox] and [default shortcuts][Firefox keyboard shortcuts] for [Firefox]
- [Configuration][Configuration for surf] and [default shortcuts][surf keyboard shortcuts] for [surf]

## Demos

### Download 3-gatsu no Lion episodes from HorribleSubs

[Download 3-gatsu no Lion episodes from HorribleSubs](https://youtu.be/aXaFt75lIqo)

**Commands**

- `f` → Focus link
  - Input: `o`
- `s` → Select active element
- `Alt` + `a` → Select parent elements (2 times)
- `Alt` + `i` → Select child elements (2 times)
- `Enter` → Open link
- `Alt` + `i` → Select child elements
- `Alt` + `k` → Keep selections that match the given [RegExp][Regular Expressions]
  - Input: `720p`
- `Alt` + `I` → Select links
- `Alt` + `k` → Keep selections that match the given [RegExp][Regular Expressions]
  - Input: `Magnet`
- `Alt` + `Shift` + `Enter` → Open link in the associated application

### Extract from Wikipedia the list of cities and towns in Russia

[Extract from Wikipedia the list of cities and towns in Russia](https://youtu.be/PJXCnRBkHDY)

**Commands**

- `f` → Focus link
  - Input: `a`, `l`
- `s` → Select active element
- `Alt` + `a` → Select parent elements (3 times)
- `S` → Select elements that match the specified group of selectors
  - Input: `tr td:first-child`
- `Alt` + `I` → Select links
- `Alt` + `y` → Copy link text

### Quickly move around a document with no table of contents

[Quickly move around a document with no table of contents](https://youtu.be/gp4_6VGXkOk)

**Commands**

- `%` → Select document
- `S` → Select elements that match the specified group of selectors
  - Input: `h1, h2, h3`
- `(` → Focus previous selection

### Tab search with dmenu

[Tab search with dmenu](https://youtu.be/tgrmss3u2aE)

**Commands**

- `q` → Tab search with [dmenu]

### Playing videos in picture-in-picture mode

[Playing videos in picture-in-picture mode](https://youtu.be/zgSx1AE6pig)

**Commands**

- `p` → Toggle picture-in-picture mode

### Opening links in a paragraph

[Opening links in a paragraph](https://youtu.be/v2Jvk1rhIlc)

**Commands**

- `f` → Focus link
  - Input: `e`
- `s` → Select active element
- `Alt` + `a` → Select parent elements
- `Alt` + `I` → Select links
- `Control` + `Enter` → Open link in new tab

### Play videos with mpv

[Play videos with mpv](https://youtu.be/gYTi-eXuWdI)

**Commands**

- `f` → Focus link
  - Input: `a`, `w`
- `s` → Select active element
- `Alt` + `a` → Select parent elements (3 times)
- `Alt` + `I` → Select links
- `Alt` + `m` → Play with [mpv] in reverse order

## Try It

- Make sure to deactivate your extension and browser bindings.
- Press `Alt` + `Escape` to activate [Krabby](/packages/krabby.js).
- Press `F1` for help.

**Note**: Commands are bound to **physical keys** and **displayed** with the [US layout][QWERTY].

{{< table-of-contents >}}

## Getting Started

To start, create a new directory to hold the extension’s files.

``` sh
mkdir chrome-configuration
cd chrome-configuration
```

Create a [manifest].

`manifest.json`

``` json
{
  "manifest_version": 2,
  "name": "Configuration",
  "description": "Configuration for Chrome",
  "version": "0.1.0"
}
```

The directory holding the manifest can be added as an extension in developer mode in its current state.

Open the _Extensions_ page by navigating to `chrome://extensions`, enable _Developer mode_ then _Load unpacked_ to select the extension directory.

![Load extension](https://developer.chrome.com/static/images/get_started/load_extension.png)

See the [Getting Started Tutorial] for more information.

## Part 1: Modal

The completed script can be downloaded [here][Modal].

### The Console

Press `Control` + `J` to open the _Console_, and _Paste_:

``` javascript
window.addEventListener('keydown', (event) => {
  if (event.code === 'KeyJ' && event.altKey)
    document.scrollingElement.scrollBy({ top: 60 })
  if (event.code === 'KeyK' && event.altKey)
    document.scrollingElement.scrollBy({ top: -60 })
})
```

You can now scroll down and up with `Alt` + `j` and `Alt` + `k`.

To map `j` and `k` without the `Alt` prefix,
we need to detect whether the [active element][activeElement] is text.

It’s handled by the following function:

``` javascript
isText(element) {
  const nodeNames = ['INPUT', 'TEXTAREA', 'OBJECT']
  return element.offsetParent !== null && (nodeNames.includes(element.nodeName) || element.isContentEditable)
}
```

``` javascript
window.addEventListener('keydown', (event) => {
  if (event.code === 'KeyJ' && isText(event.target) === false)
    document.scrollingElement.scrollBy({ top: 60 })
  if (event.code === 'KeyK' && isText(event.target) === false)
    document.scrollingElement.scrollBy({ top: -60 })
})
```

### The Content Script

Create a [content script][Content Scripts] titled `config.js` with everything preceding.

Update your manifest and reload the extension.

`manifest.json`

``` json
{
  "content_scripts": [
    {
      "matches": [
        "<all_urls>"
      ],
      "js": [
        "config.js"
      ]
    }
  ]
}
```

### The Library

Create a script titled under `scripts/modal.js` and add the following skeleton:

`scripts/modal.js`

``` javascript
class Modal {
  constructor(name) {
    this.name = name
    this.filters = {}
    this.mappings = {}
  }
  filter(name, filter) {
  }
  enable(...filters) {
  }
  map(context, keys, command, description = '') {
  }
  unmap(context, keys) {
  }
  mode(nextMode) {
  }
  on(type, listener) {
  }
  listen() {
  }
  unlisten() {
  }
}
```

Like `config.js`, this file needs to be designated as a content script in the manifest.

`manifest.json`

``` json
{
  "content_scripts": [
    {
      "matches": [
        "<all_urls>"
      ],
      "js": [
        "scripts/modal.js",
        "config.js"
      ]
    }
  ]
}
```

### Overview

#### Contexts

Modal lets you map a key to a command in different contexts:

- **Command** is the context for entering keyboard commands,
- **Text** is the context for typing text,
- **Link** is the context for links,
- **Video** is the context for videos,
- **Page** is a context with no filtering.

#### Get started

**Example** – A minimal configuration for getting started:

``` javascript
const modal = new Modal
modal.enable('Text', 'Command')
modal.map('Command', ['KeyJ'], () => document.scrollingElement.scrollBy({ top: 60 }), 'Scroll down')
modal.map('Command', ['KeyK'], () => document.scrollingElement.scrollBy({ top: -60 }), 'Scroll up')
```

**Context**: Context of the command.

**Keys**: Keys represent a chord – a key sequence in which the keys are pressed at the same time.
They are composed of a single [key code][KeyboardEvent.code] and optional [modifiers].
For special keys, the list of key values can be found [here][Key Values].

**Command**: The command is either a function that takes exactly one argument – the [keydown]
event that triggered the command – or an instance of **Modal**.

**Description**: Description of the command.

**Note**: Commands are bound to physical keys and displayed with the US layout by default.
If you want to display the commands with a different layout, you can set the `keyMap` or `KEY_MAP` properties,
depending if you want to change the display for an instance of **Modal** or the class itself.

#### Passing mode

**Example** – Create a mode to pass all keys but `Alt` + `Escape`:

``` javascript
const pass = new Modal('Pass')
modal.map('Page', ['Alt', 'Escape'], pass, 'Pass all keys to the page')
pass.map('Page', ['Alt', 'Escape'], modal, 'Stop passing keys to the page')
```

#### Custom contexts

Custom contexts can be created using filters.

**Example** – Override the built-in link context:

``` javascript
modal.filter('Link', () => document.activeElement.nodeName === 'A', 'Command')
modal.enable('Link', 'Text', 'Command')
```

The filter is a function that dictates in what context a mapping will be available.

A third parameter can be passed to inherit a context and its commands.
In the example above, **Link** inherits from **Command**.

#### Same key mappings

You can bind different commands to a same key.

**Example** – Add mappings to yank pages and links:

``` javascript
modal.map('Command', ['KeyY'], () => Clipboard.copy(location.href), 'Copy page address')
modal.map('Link', ['KeyY'], (event) => Clipboard.copy(event.target.href), 'Copy link address')
```

#### Specific site mappings

Specific site bindings are also supported through custom contexts.

**Example** – Disable shortcuts in Gmail:

``` javascript
modal.filter('Gmail', () => location.hostname === 'mail.google.com')
modal.enable('Gmail', ...)
```

Create a context for [Gmail] and use the [built-in shortcuts][Gmail keyboard shortcuts].

**Example** – Create a context for GitHub:

``` javascript
modal.filter('GitHub', () => location.hostname === 'github.com', 'Command')
modal.filter('GitHub · Notifications', () => location.pathname === '/notifications', 'GitHub')
modal.enable('GitHub · Notifications', 'GitHub', ...)

modal.map('GitHub · Notifications', ['KeyR'], () => document.querySelector('form[action="/notifications/mark"]').submit(), 'Mark all as read')
```

#### Events

Commands can be registered to be executed when certain events arise.

**Example** – Display the current context:

``` javascript
modal.on('context-change', (context) => modal.notify({ id: 'context', message: context.name }))
```

#### Getting help

Finally, you can display all available commands (for the current context) with the help command.

**Example** – Show help on `F1`:

``` javascript
modal.map('Page', ['F1'], () => modal.help(), 'Show help')
```

### Filters

Add a method to create filters.

`scripts/modal.js`

``` javascript
class Modal {
  filter(name, filter, parent = null) {
    this.filters[name] = { filter, parent }
    this.mappings[name] = {}
  }
}
```

Update the constructor to include some default filters.
Add `isText()` as a static method.

`scripts/modal.js`

``` javascript
class Modal {
  constructor(name) {
    this.filter('Page', () => true)
    this.filter('Command', () => ! Modal.isText(document.activeElement), 'Page')
    this.filter('Text', () => Modal.isText(document.activeElement), 'Page')
    this.filter('Link', () => document.activeElement.nodeName === 'A', 'Command')
    this.filter('Video', () => document.activeElement.nodeName === 'VIDEO' || Modal.findParent((element) => ['html5-video-player'].some((className) => element.classList.contains(className))), 'Page')
  }
}
```

And the method to enable the filters.

`scripts/modal.js`

``` javascript
class Modal {
  constructor(name) {
    this.enable('Page')
  }
  enable(...filters) {
    this.context.filters = filters.filter((name) => this.filters[name])
  }
}
```

### Mappings

**Prototype**

``` javascript
Modal.map(context, keys, command, description)
```

Keys are parsed with:

`scripts/modal.js`

``` javascript
class Modal {
  static parseKeys(keys) {
    const keyChord = {
      metaKey: false,
      altKey: false,
      ctrlKey: false,
      shiftKey: false,
      code: ''
    }
    for (const key of keys) {
      switch (key) {
        case 'Shift':
          keyChord.shiftKey = true
          break
        case 'Control':
          keyChord.ctrlKey = true
          break
        case 'Alt':
          keyChord.altKey = true
          break
        case 'Meta':
          keyChord.metaKey = true
          break
        default:
          keyChord.code = key
      }
    }
    return keyChord
  }
}
```

Commands are parsed with:

`scripts/modal.js`

``` javascript
class Modal {
  parseCommand(command) {
    switch (true) {
      case command instanceof Modal:
        return () => this.mode(command)
      case command instanceof Function:
        return command
    }
  }
}
```

If the command is a mode, generate a function to switch to it.

`scripts/modal.js`

``` javascript
class Modal {
  mode(nextMode) {
    this.unlisten()
    nextMode.listen()
  }
}
```

We can now implement the mapping methods.

`scripts/modal.js`

``` javascript
class Modal {
  map(context, keys, command, description = '') {
    const keyChord = Modal.parseKeys(keys)
    command = this.parseCommand(command)
    const key = JSON.stringify(keyChord)
    this.mappings[context][key] = { command, description }
  }
  unmap(context, keys) {
    const keyChord = Modal.parseKeys(keys)
    const key = JSON.stringify(keyChord)
    delete this.mappings[context][key]
  }
}
```

For convenience, we will provide a function to find a parent element (useful for videos).

``` javascript
class Modal {
  static findParent(find, element = document.activeElement) {
    if (element === null) {
      return null
    }
    const result = find(element)
    if (result) {
      return result
    }
    return this.findParent(find, element.parentElement)
  }
}
```

### Events

`scripts/modal.js`

``` javascript
class Modal {
  constructor(name) {
    this.events = {}
    this.events['context-change'] = []
    this.events['command'] = []
    this.events['default'] = []
    this.events['start'] = []
    this.events['stop'] = []
  }
}
```

Create a method to emit events.

`scripts/modal.js`

``` javascript
class Modal {
  on(type, listener) {
    this.events[type].push(listener)
  }
  triggerEvent(type, ...parameters) {
    for (const listener of this.events[type]) {
      listener(...parameters)
    }
  }
}
```

In order to execute a key depending on the context, we need to:

- Listen [key presses][KeyboardEvent.code] with the [keydown] event,
- Listen context changes with the [focus] and [blur] events.

`scripts/modal.js`

``` javascript
class Modal {
  constructor(name) {
    this.context = {}
    this.context.name = null
    this.context.filters = []
    this.context.commands = {}
  }
  listen() {
    this.onKey = (event) => {
      // Skip modifiers
      if (Modal.MODIFIER_KEYS.includes(event.key)) {
        return
      }
      const keyChord = {
        metaKey: event.metaKey,
        altKey: event.altKey,
        ctrlKey: event.ctrlKey,
        shiftKey: event.shiftKey,
        code: event.code
      }
      const key = JSON.stringify(keyChord)
      const command = this.context.commands[key]
      if (command) {
        // Prevent the browsers default behavior (such as opening a link)
        // and stop the propagation of the event.
        event.preventDefault()
        event.stopImmediatePropagation()
        // Command
        command.command(event)
        this.triggerEvent('command', event)
      } else {
        this.triggerEvent('default', event)
      }
    }
    this.onFocus = (event) => {
      this.updateContext()
    }
    // Use the capture method.
    //
    // This setting is important to trigger the listeners during the capturing phase
    // if we want to prevent bubbling.
    //
    // Also, some events (such as focus and blur) do not bubble, so this setting
    // is important to trigger the listeners attached to the parents of the target.
    //
    // Phase 1: Capturing phase: Window (1) → ChildElement (2) → Target (3)
    // Phase 2: Target phase: Target (1)
    // Phase 3: Bubbling phase: Window (3) ← ParentElement (2) ← Target (1)
    //
    // https://w3.org/TR/DOM-Level-3-Events#event-flow
    window.addEventListener('keydown', this.onKey, true)
    window.addEventListener('focus', this.onFocus, true)
    window.addEventListener('blur', this.onFocus, true)
    // Initialize active context
    this.updateContext()
    this.triggerEvent('start')
  }
  unlisten() {
    window.removeEventListener('keydown', this.onKey, true)
    window.removeEventListener('focus', this.onFocus, true)
    window.removeEventListener('blur', this.onFocus, true)
    this.triggerEvent('stop')
  }
  getContexts(name, accumulator = []) {
    if (name === null) {
      return accumulator
    }
    return this.getContexts(this.filters[name].parent, accumulator.concat(name))
  }
  updateContext() {
    const previousContextName = this.context.name
    this.context.name = this.context.filters.find((name) => this.getContexts(name).every((name) => this.filters[name].filter()))
    if (this.context.name !== previousContextName) {
      this.updateCommands()
      this.triggerEvent('context-change', this.context)
    }
  }
  updateCommands() {
    const commands = {}
    const contexts = this.getContexts(this.context.name)
    for (const context of contexts) {
      for (const [key, mapping] of Object.entries(this.mappings[context])) {
        if (commands[key] === undefined) {
          commands[key] = { context, ...mapping }
        }
      }
    }
    this.context.commands = commands
  }
}
```

### Key values

Display [key values].

`scripts/modal.js`

``` javascript
class Modal {
  static KEY_MAP = {
    Backquote: { key: '`', shiftKey: '~' }, Digit1: { key: '1', shiftKey: '!' }, Digit2: { key: '2', shiftKey: '@' }, Digit3: { key: '3', shiftKey: '#' }, Digit4: { key: '4', shiftKey: '$' }, Digit5: { key: '5', shiftKey: '%' }, Digit6: { key: '6', shiftKey: '^' }, Digit7: { key: '7', shiftKey: '&' }, Digit8: { key: '8', shiftKey: '*' }, Digit9: { key: '9', shiftKey: '(' }, Digit0: { key: '0', shiftKey: ')' }, Minus: { key: '-', shiftKey: '_' }, Equal: { key: '=', shiftKey: '+' },
    KeyQ: { key: 'q', shiftKey: 'Q' }, KeyW: { key: 'w', shiftKey: 'W' }, KeyE: { key: 'e', shiftKey: 'E' }, KeyR: { key: 'r', shiftKey: 'R' }, KeyT: { key: 't', shiftKey: 'T' }, KeyY: { key: 'y', shiftKey: 'Y' }, KeyU: { key: 'u', shiftKey: 'U' }, KeyI: { key: 'i', shiftKey: 'I' }, KeyO: { key: 'o', shiftKey: 'O' }, KeyP: { key: 'p', shiftKey: 'P' }, BracketLeft: { key: '[', shiftKey: '{' }, BracketRight: { key: ']', shiftKey: '}' }, Backslash: { key: '\\', shiftKey: '|' },
    KeyA: { key: 'a', shiftKey: 'A' }, KeyS: { key: 's', shiftKey: 'S' }, KeyD: { key: 'd', shiftKey: 'D' }, KeyF: { key: 'f', shiftKey: 'F' }, KeyG: { key: 'g', shiftKey: 'G' }, KeyH: { key: 'h', shiftKey: 'H' }, KeyJ: { key: 'j', shiftKey: 'J' }, KeyK: { key: 'k', shiftKey: 'K' }, KeyL: { key: 'l', shiftKey: 'L' }, Semicolon: { key: ';', shiftKey: ':' }, Quote: { key: "'", shiftKey: '"' },
    KeyZ: { key: 'z', shiftKey: 'Z' }, KeyX: { key: 'x', shiftKey: 'X' }, KeyC: { key: 'c', shiftKey: 'C' }, KeyV: { key: 'v', shiftKey: 'V' }, KeyB: { key: 'b', shiftKey: 'B' }, KeyN: { key: 'n', shiftKey: 'N' }, KeyM: { key: 'm', shiftKey: 'M' }, Comma: { key: ',', shiftKey: '<' }, Period: { key: '.', shiftKey: '>' }, Slash: { key: '/', shiftKey: '?' }
  }
  constructor(name) {
    this.keyMap = Modal.KEY_MAP
  }
  keyValues({ metaKey, altKey, ctrlKey, shiftKey, code }) {
    const keys = []
    const keyMap = this.keyMap[code]
    if (metaKey) keys.push('Meta')
    if (altKey) keys.push('Alt')
    if (ctrlKey) keys.push('Control')
    if (shiftKey && ! keyMap) keys.push('Shift')
    const key = keyMap
      ? shiftKey
      ? keyMap.shiftKey
      : keyMap.key
      : code
    keys.push(key)
    return keys
  }
}
```

### Help

`scripts/modal.js`

``` javascript
class Modal {
  constructor(name) {
    this.style = `
      #help.overlay {
        display: flex; /* Enable to center content */
        justify-content: center; /* Horizontally */
        align-items: center; /* Vertically */
        position: fixed;
        top: 0;
        left: 0;
        z-index: 2147483647; /* 2³¹ − 1 */
        width: 100%;
        height: 100%;
        background-color: hsla(0, 0%, 0%, 0.5);
      }
      #help main {
        position: relative;
        width: fit-content;
        height: fit-content;
        max-width: 30%;
        max-height: 90%;
        overflow-x: auto;
        overflow-y: auto;
        font-family: serif;
        font-size: 12px;
        color: gray;
        background-color: white;
        border: 1px solid lightgray;
        border-radius: 4px;
        padding: 3px;
      }
      #help main table caption {
        font-size: 18px;
        font-weight: bold;
        padding: 10px 0;
      }
      /* Style from GitHub */
      kbd {
        background-color: #fafbfc;
        border: 1px solid #c6cbd1;
        border-bottom-color: #959da5;
        border-radius: 3px;
        box-shadow: inset 0 -1px 0 #959da5;
        color: #444d56;
        display: inline-block;
        font-family: monospace;
        font-size: 11px;
        line-height: 10px;
        padding: 3px 5px;
        vertical-align: middle;
      }
      /* Scrollbar */
      ::-webkit-scrollbar {
        height: 25px;
      }
      ::-webkit-scrollbar-button:start,
      ::-webkit-scrollbar-button:end {
        display: none;
      }
      ::-webkit-scrollbar-track-piece {
        background-color: #eee;
      }
      ::-webkit-scrollbar-thumb {
        background-color: #bbb;
        border: 7px solid #eee;
        -webkit-background-clip: padding-box;
        -webkit-border-radius: 12px;
      }
    `
  }
  help() {
    // Open or close help
    const rootReference = document.querySelector('#modal-help')
    if (rootReference) {
      rootReference.remove()
      return
    }
    // Initialize
    const root = document.createElement('div')
    root.id = 'modal-help'
    // Place the document in a closed shadow root,
    // so that the document and page styles won’t affect each other.
    const shadow = root.attachShadow({ mode: 'closed' })
    // Container
    const container = document.createElement('div')
    container.id = 'help'
    container.classList.add('overlay')
    // Content
    const content = document.createElement('main')
    container.append(content)
    // Table
    const table = document.createElement('table')
    content.append(table)
    // Caption
    const caption = document.createElement('caption')
    caption.textContent = this.context.name
    table.append(caption)
    // Commands
    for (const [keyChord, { description }] of Object.entries(this.context.commands)) {
      // Table row
      const row = document.createElement('tr')
      table.append(row)
      // Table header cell
      const header = document.createElement('th')
      const keys = this.keyValues(JSON.parse(keyChord))
      for (const key of keys) {
        const atom = document.createElement('kbd')
        atom.textContent = key
        header.append(atom)
      }
      row.append(header)
      // Table data cell
      const data = document.createElement('td')
      data.textContent = description
      row.append(data)
    }
    // Style
    const style = document.createElement('style')
    style.textContent = this.style
    // Attach
    shadow.append(style)
    shadow.append(container)
    document.documentElement.append(root)
    // Close on click
    container.addEventListener('click', (event) => {
      // Stop propagation
      event.stopImmediatePropagation()
      root.remove()
    })
  }
}
```

### Notifications

`scripts/modal.js`

``` javascript
class Modal {
  constructor(name) {
    this.style = `
      #notification {
        position: fixed;
        bottom: 0;
        right: 0;
        z-index: 2147483647; /* 2³¹ − 1 */
        font-family: serif;
        font-size: 12px;
        color: gray;
        background-color: white;
        border: 1px solid lightgray;
        border-top-left-radius: 4px;
        padding: 3px;
      }
    `
  }
  notify({ id = Date.now(), message, duration }) {
    const initialize = () => {
      let root = document.querySelector('#modal-notifications')
      if (! root) {
        root = document.createElement('div')
        root.id = 'modal-notifications'
        document.documentElement.append(root)
      }
      return root
    }
    const clearViewport = (root, id) => {
      const container = root.querySelector(`[data-notification-id="${id}"]`)
      if (container) {
        container.remove()
      }
    }
    const notifications = initialize()
    clearViewport(notifications, id)
    // Initialize
    const root = document.createElement('div')
    root.setAttribute('data-notification-id', id)
    // Place the document in a closed shadow root,
    // so that the document and page styles won’t affect each other.
    const shadow = root.attachShadow({ mode: 'closed' })
    // Container
    const container = document.createElement('div')
    container.id = 'notification'
    container.textContent = message
    // Style
    const style = document.createElement('style')
    style.textContent = this.style
    // Attach
    shadow.append(style)
    shadow.append(container)
    notifications.append(root)
    // Duration of the notification (optional)
    if (duration) {
      setTimeout(() => {
        root.remove()
      }, duration)
    }
  }
}
```

### Configuration

Finally, update your configuration.

`config.js`

``` javascript
// Modes ───────────────────────────────────────────────────────────────────────

// Modal
const modal = new Modal('Modal')
modal.enable('Text', 'Command')

// Mappings ────────────────────────────────────────────────────────────────────

// Scroll
modal.map('Command', ['KeyJ'], () => document.scrollingElement.scrollBy({ top: 60 }), 'Scroll down')
modal.map('Command', ['KeyK'], () => document.scrollingElement.scrollBy({ top: -60 }), 'Scroll up')

// Initialization ──────────────────────────────────────────────────────────────

modal.listen()
```

### More commands

#### Scroll

`config.js`

``` javascript
modal.map('Command', ['KeyL'], () => document.scrollingElement.scrollBy({ left: 60 }), 'Scroll right')
modal.map('Command', ['KeyH'], () => document.scrollingElement.scrollBy({ left: -60 }), 'Scroll left')
```

#### Scroll faster

`config.js`

``` javascript
modal.map('Command', ['Shift', 'KeyJ'], () => document.scrollingElement.scrollBy({ top: window.innerHeight * 0.9 }), 'Scroll page down')
modal.map('Command', ['Shift', 'KeyK'], () => document.scrollingElement.scrollBy({ top: -window.innerHeight * 0.9 }), 'Scroll page up')
modal.map('Command', ['KeyG'], () => document.scrollingElement.scrollTo({ top: 0 }), 'Scroll to the top of the page')
modal.map('Command', ['Shift', 'KeyG'], () => document.scrollingElement.scrollTo({ top: document.scrollingElement.scrollHeight }), 'Scroll to the bottom of the page')
```

#### Navigation

`config.js`

``` javascript
modal.map('Command', ['Shift', 'KeyH'], () => history.back(), 'Go back in history')
modal.map('Command', ['Shift', 'KeyL'], () => history.forward(), 'Go forward in history')
modal.map('Command', ['KeyU'], () => location.assign('..'), 'Go up in hierarchy')
modal.map('Command', ['Shift', 'KeyU'], () => location.assign('/'), 'Go to the home page')
modal.map('Command', ['Alt', 'KeyU'], () => location.assign('.'), 'Remove any URL parameter')
```

#### Reload pages

`config.js`

``` javascript
modal.map('Command', ['KeyR'], () => location.reload(), 'Reload the page')
modal.map('Command', ['Shift', 'KeyR'], () => location.reload(true), 'Reload the page, ignoring cached content')
```

#### Unfocus

`config.js`

``` javascript
modal.map('Page', ['Escape'], () => document.activeElement.blur(), 'Unfocus active element')
```

#### Pass keys

`config.js`

``` javascript
// Modes ───────────────────────────────────────────────────────────────────────

// Pass
const pass = new Modal('Pass')

// Mappings ────────────────────────────────────────────────────────────────────

// Pass keys
modal.map('Page', ['Alt', 'Escape'], pass, 'Pass all keys to the page')
pass.map('Page', ['Alt', 'Escape'], modal, 'Stop passing keys to the page')
```

#### Status line

`config.js`

``` javascript
const updateStatusLine = () => {
  modal.notify({ id: 'status-line', message: modal.context.name })
}

modal.on('context-change', (context) => updateStatusLine())
```

#### Help

`config.js`

``` javascript
modal.map('Page', ['F1'], () => modal.help(), 'Show help')
modal.map('Page', ['Shift', 'F1'], () => window.open('https://alexherbo2.github.io/blog/chrome/create-a-keyboard-interface-to-the-web/'), 'Open the documentation in a new tab')
```

Add more commands to your liking.

### Updates

If you want to be up-to-date with my [version][Modal], you can create a script
to retrieve updates and automate the process with a Makefile.

`fetch`

``` sh
#!/bin/sh

fetch() {
  case $# in
    1) curl --location --remote-name $1 ;;
    2) curl --location $1 --output $2 ;;
  esac
}

mkdir -p packages
cd packages

fetch https://github.com/alexherbo2/modal.js/raw/master/scripts/modal.js
```

Make it executable.

``` sh
chmod +x fetch
```

`Makefile`

``` makefile
fetch:
	./fetch

clean:
	rm -Rf packages

.PHONY: fetch
```

Don’t forget to ignore the packages.

`.gitignore`

``` gitignore
packages
```

## Part 2: Link Hints

The completed script can be downloaded [here][Hint].

### The Prototype

Create the files and update your configuration.

`scripts/hint.js`

``` javascript
class Hint {
  constructor() {
    this.selectors = '*'
    this.keys = []
    this.lock = false
    this.hints = []
    this.inputKeys = []
    this.validatedElements = []
    this.keyMap = Hint.KEY_MAP
    // Events
    this.events = {}
    this.events['validate'] = []
    this.events['start'] = []
    this.events['exit'] = []
    // Style
    this.style = ''
  }
  on(type, listener) {
  }
  start() {
  }
  stop() {
  }
}
```

`config.js`

``` javascript
// Modes ───────────────────────────────────────────────────────────────────────

// Hint
const HINT_TEXT_SELECTORS = 'input:not([type="submit"]):not([type="button"]):not([type="reset"]):not([type="file"]), textarea, select'
const HINT_VIDEO_SELECTORS = 'video'

const hint = (selectors = '*') => {
  const hint = new Hint
  hint.selectors = selectors
  hint.on('validate', (target) => target.focus())
  hint.on('start', () => modal.unlisten())
  hint.on('exit', () => modal.listen())
  return hint
}

// Mappings ────────────────────────────────────────────────────────────────────

// Link hints
modal.map('Command', ['KeyF'], () => hint().start(), 'Focus link')
modal.map('Command', ['KeyI'], () => hint(HINT_TEXT_SELECTORS).start(), 'Focus input')
modal.map('Command', ['KeyV'], () => hint(HINT_VIDEO_SELECTORS).start(), 'Focus video')
```

`manifest.json`

``` json
{
  "content_scripts": [
    {
      "matches": [
        "<all_urls>"
      ],
      "js": [
        "scripts/modal.js",
        "scripts/hint.js",
        "config.js"
      ]
    }
  ]
}
```

### Filtering

Add a filter to select hintable elements.
An element is hintable if it is visible and clickable.

`scripts/hint.js`

``` javascript
class Hint {
  start() {
    const hintableElements = Array.from(document.querySelectorAll(this.selectors)).filter((element) => Hint.isHintable(element))
    console.log(hintableElements)
  }
  static isHintable(element) {
    return this.isVisible(element) && this.isClickable(element)
  }
  static isVisible(element) {
    return element.offsetParent !== null && this.isInViewport(element)
  }
  static isInViewport(element) {
    const rectangle = element.getBoundingClientRect()
    return rectangle.top >= 0 && rectangle.left >= 0 && rectangle.bottom <= window.innerHeight && rectangle.right <= window.innerWidth
  }
  static isClickable(element) {
    const nodeNames = ['A', 'BUTTON', 'SELECT', 'TEXTAREA', 'INPUT', 'VIDEO']
    const roles = ['button', 'checkbox', 'combobox', 'link', 'menuitem', 'menuitemcheckbox', 'menuitemradio', 'radio', 'tab', 'textbox']
    return element.offsetParent !== null && (nodeNames.includes(element.nodeName) || roles.includes(element.getAttribute('role')) || element.hasAttribute('onclick'))
  }
}
```

### Rendering

Add a method to generate an HTML hint for each element.

We will place the hints in a closed [shadow root][Using shadow DOM],
so that the hint and page styles won’t affect each other.

`scripts/hint.js`

``` javascript
class Hint {
  start() {
    const hintableElements = Array.from(document.querySelectorAll(this.selectors)).filter((element) => Hint.isHintable(element))
    this.render(hintableElements)
  }
  render(elements) {
    const root = document.createElement('div')
    root.id = 'hints'
    // Place the hints in a closed shadow root,
    // so that the hint and page styles won’t affect each other.
    const shadow = root.attachShadow({ mode: 'closed' })
    for (const [index, element] of elements.entries()) {
      const container = document.createElement('div')
      container.classList.add('hint')
      container.textContent = index
      const rectangle = element.getBoundingClientRect()
      // Place hints relative to the viewport
      container.style.position = 'fixed'
      // Vertical placement: center
      container.style.top = rectangle.top + (rectangle.height / 2) + 'px'
      // Horizontal placement: left
      container.style.left = rectangle.left + 'px'
      // Control overlapping
      container.style.zIndex = 2147483647 // 2³¹ − 1
      shadow.append(container)
    }
    this.clearViewport()
    // Style
    const style = document.createElement('style')
    style.textContent = this.style
    // Attach
    shadow.append(style)
    document.documentElement.append(root)
  }
  clearViewport() {
    const root = document.querySelector('#hints')
    if (root) {
      root.remove()
    }
  }
}
```

Configure which characters appear in hints.

`scripts/hint.js`

``` javascript
class Hint {
  static KEY_MAP = {
    Digit1: '1', Digit2: '2', Digit3: '3', Digit4: '4', Digit5: '5', Digit6: '6', Digit7: '7', Digit8: '8', Digit9: '9', Digit0: '0',
    KeyQ: 'q', KeyW: 'w', KeyE: 'e', KeyR: 'r', KeyT: 't', KeyY: 'y', KeyU: 'u', KeyI: 'i', KeyO: 'o', KeyP: 'p',
    KeyA: 'a', KeyS: 's', KeyD: 'd', KeyF: 'f', KeyG: 'g', KeyH: 'h', KeyJ: 'j', KeyK: 'k', KeyL: 'l',
    KeyZ: 'z', KeyX: 'x', KeyC: 'c', KeyV: 'v', KeyB: 'b', KeyN: 'n', KeyM: 'm'
  }
  constructor() {
    this.keys = ['KeyA', 'KeyJ', 'KeyS', 'KeyK', 'KeyD', 'KeyL', 'KeyG', 'KeyH', 'KeyE', 'KeyW', 'KeyO', 'KeyR', 'KeyU', 'KeyV', 'KeyN', 'KeyC', 'KeyM']
  }
  start() {
    const hintableElements = Array.from(document.querySelectorAll(this.selectors)).filter((element) => Hint.isHintable(element))
    this.hints = Hint.generateHints(hintableElements, this.keys)
    this.render()
  }
  render() {
    const root = document.createElement('div')
    root.id = 'hints'
    // Place the hints in a closed shadow root,
    // so that the hint and page styles won’t affect each other.
    const shadow = root.attachShadow({ mode: 'closed' })
    for (const [label, element] of this.hints) {
      const container = document.createElement('div')
      container.classList.add('hint')
      container.textContent = label
      const rectangle = element.getBoundingClientRect()
      // Place hints relative to the viewport
      container.style.position = 'fixed'
      // Vertical placement: center
      container.style.top = rectangle.top + (rectangle.height / 2) + 'px'
      // Horizontal placement: left
      container.style.left = rectangle.left + 'px'
      // Control overlapping
      container.style.zIndex = 2147483647 // 2³¹ − 1
      shadow.append(container)
    }
    this.clearViewport()
    // Style
    const style = document.createElement('style')
    style.textContent = this.style
    // Attach
    shadow.append(style)
    document.documentElement.append(root)
  }
  static generateHints(elements, keys) {
    const hintKeys = this.generateHintKeys(keys, elements.length)
    const hints = elements.map((element, index) => [hintKeys[index], element])
    return hints
  }
  static generateHintKeys(keys, count) {
    const hints = [[]]
    let offset = 0
    while (hints.length - offset < count || hints.length === 1) {
      const hint = hints[offset++]
      for (const key of keys) {
        hints.push(hint.concat(key))
      }
    }
    return hints.slice(offset, offset + count)
  }
}
```

Add some CSS.

`scripts/hint.js`

``` javascript
class Hint {
  constructor() {
    this.style = `
      .hint {
        /* Hints */
        padding: 0.15rem 0.25rem;
        border: 1px solid hsl(39, 70%, 45%);
        text-transform: uppercase;
        text-align: center;
        vertical-align: middle;
        background: linear-gradient(to bottom, hsl(56, 100%, 76%) 0%, hsl(42, 100%, 63%) 100%);
        border-radius: 4px;
        box-shadow: 0 3px 1px -2px hsla(0, 0%, 0%, 0.2), 0 2px 2px 0 hsla(0, 0%, 0%, 0.14), 0 1px 5px 0 hsla(0, 0%, 0%, 0.12);
        transform: translate3d(0%, -50%, 0);
        /* Characters */
        font-family: Roboto, sans-serif;
        font-size: 12px;
        font-weight: 900;
        color: hsl(45, 81%, 10%);
        text-shadow: 0 1px 0 hsla(0, 0%, 100%, 0.6);
      }
    `
  }
}
```

### Updating

Update hints whenever the viewport changes.

`scripts/hint.js`

``` javascript
class Hint {
  updateHints() {
    const hintableElements = Array.from(document.querySelectorAll(this.selectors)).filter((element) => Hint.isHintable(element))
    this.hints = Hint.generateHints(hintableElements, this.keys)
  }
  start() {
    this.onViewChange = (event) => {
      this.updateHints()
      this.render()
    }
    window.addEventListener('scroll', this.onViewChange)
    window.addEventListener('resize', this.onViewChange)
    // Retrieve hints and render
    this.updateHints()
    this.render()
  }
  stop() {
    window.removeEventListener('scroll', this.onViewChange)
    window.removeEventListener('resize', this.onViewChange)
    this.clearViewport()
    this.hints = []
  }
}
```

### Input handler

We will use the same pattern as in [Part 1][Events].
We also need to modify the render method to take into account the input changes.

`scripts/hint.js`

``` javascript
class Hint {
  // https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/key/Key_Values
  static MODIFIER_KEYS = ['Shift', 'Control', 'Alt', 'Meta']
  static NAVIGATION_KEYS = ['ArrowDown', 'ArrowLeft', 'ArrowRight', 'ArrowUp', 'End', 'Home', 'PageDown', 'PageUp']
  filterHints(input) {
    const filteredHints = this.hints.filter(([label]) => input.every((key, index) => label[index] === key))
    return filteredHints
  }
  processKeys(keys, validate = false) {
    const filteredHints = this.filterHints(keys)
    switch (filteredHints.length) {
      case 0:
        break
      case 1:
        this.inputKeys = []
        this.render()
        this.processHint(filteredHints[0])
        break
      default:
        if (validate) {
          this.inputKeys = []
          this.render()
          this.processHint(filteredHints[0])
        } else {
          this.inputKeys = keys
          this.render()
        }
    }
  }
  processHint([label, element]) {
    this.validatedElements.push(element)
    if (this.lock === false) {
      this.stop()
    }
    this.triggerEvent('validate', element)
  }
  start() {
    this.onKey = (event) => {
      // Skip modifier and navigation keys
      if ([...Hint.MODIFIER_KEYS, ...Hint.NAVIGATION_KEYS].includes(event.key)) {
        return
      }
      // Prevent the browsers default behavior (such as opening a link)
      // and stop the propagation of the event.
      event.preventDefault()
      event.stopImmediatePropagation()
      switch (event.code) {
        case 'Escape':
          this.stop()
          break
        case 'Backspace':
          this.processKeys(this.inputKeys.slice(0, -1))
          break
        case 'Enter':
          this.processKeys(this.inputKeys, true)
          break
        default:
          this.processKeys(this.inputKeys.concat(event.code))
      }
    }
    this.onViewChange = (event) => {
      this.updateHints()
      this.processKeys([])
    }
    this.onClick = (event) => {
      this.stop()
    }
    // Use the capture method.
    //
    // This setting is important to trigger the listeners during the capturing phase
    // if we want to prevent bubbling.
    //
    // Phase 1: Capturing phase: Window (1) → ChildElement (2) → Target (3)
    // Phase 2: Target phase: Target (1)
    // Phase 3: Bubbling phase: Window (3) ← ParentElement (2) ← Target (1)
    //
    // https://w3.org/TR/DOM-Level-3-Events#event-flow
    window.addEventListener('keydown', this.onKey, true)
    window.addEventListener('scroll', this.onViewChange)
    window.addEventListener('resize', this.onViewChange)
    window.addEventListener('click', this.onClick)
    // Start before processing hints
    this.triggerEvent('start')
    // Process hints
    this.updateHints()
    this.processKeys([])
  }
  stop() {
    window.removeEventListener('keydown', this.onKey, true)
    window.removeEventListener('scroll', this.onViewChange)
    window.removeEventListener('resize', this.onViewChange)
    window.removeEventListener('click', this.onClick)
    this.clearViewport()
    this.triggerEvent('exit', this.validatedElements)
    this.hints = []
    this.inputKeys = []
    this.validatedElements = []
  }
  render() {
    const root = document.createElement('div')
    root.id = 'hints'
    // Place the hints in a closed shadow root,
    // so that the hint and page styles won’t affect each other.
    const shadow = root.attachShadow({ mode: 'closed' })
    for (const [label, element] of this.filterHints(this.inputKeys)) {
      const container = document.createElement('div')
      container.classList.add('hint')
      for (const [index, code] of label.entries()) {
        const atom = document.createElement('span')
        atom.classList.add('character', code === this.inputKeys[index] ? 'active' : 'normal')
        atom.textContent = this.keyMap[code]
        container.append(atom)
      }
      const rectangle = element.getBoundingClientRect()
      // Place hints relative to the viewport
      container.style.position = 'fixed'
      // Vertical placement: center
      container.style.top = rectangle.top + (rectangle.height / 2) + 'px'
      // Horizontal placement: left
      container.style.left = rectangle.left + 'px'
      // Control overlapping
      container.style.zIndex = 2147483647 // 2³¹ − 1
      shadow.append(container)
    }
    this.clearViewport()
    // Style
    const style = document.createElement('style')
    style.textContent = this.style
    // Attach
    shadow.append(style)
    document.documentElement.append(root)
  }
}
```

Update your CSS.

`scripts/hint.js`

``` javascript
class Hint {
  constructor() {
    this.style = `
      .hint {
        padding: 0.15rem 0.25rem;
        border: 1px solid hsl(39, 70%, 45%);
        text-transform: uppercase;
        text-align: center;
        vertical-align: middle;
        background: linear-gradient(to bottom, hsl(56, 100%, 76%) 0%, hsl(42, 100%, 63%) 100%);
        border-radius: 4px;
        box-shadow: 0 3px 1px -2px hsla(0, 0%, 0%, 0.2), 0 2px 2px 0 hsla(0, 0%, 0%, 0.14), 0 1px 5px 0 hsla(0, 0%, 0%, 0.12);
        transform: translate3d(0%, -50%, 0);
      }
      .hint .character {
        font-family: Roboto, sans-serif;
        font-size: 12px;
        font-weight: 900;
        color: hsl(45, 81%, 10%);
        text-shadow: 0 1px 0 hsla(0, 0%, 100%, 0.6);
      }
      .hint .character.active {
        color: hsl(44, 64%, 53%);
      }
    `
  }
}
```

### Updates

The [same method][Updates] applies to [Part 1] if you want to be up-to-date with my [version][Hint].

## Part 3: Toolbox

### Mouse

The completed script can be downloaded [here][Mouse].

`scripts/mouse.js`

``` javascript
class Mouse {
  constructor() {
    this.timers = new Map
  }
  hover(target) {
    Mouse.hover(target)
    this.timers.set(target, setTimeout(this.hover.bind(this, target), 200))
  }
  unhover(target) {
    clearTimeout(this.timers.get(target))
    Mouse.unhover(target)
    this.timers.delete(target)
  }
  clear() {
    for (const [target, timer] of this.timers) {
      this.unhover(target)
    }
  }
  static click(target, modifierKeys) {
    this.dispatchEvents(target, ['mouseover', 'mousedown', 'mouseup', 'click'], modifierKeys)
  }
  static hover(target) {
    this.dispatchEvents(target, ['mouseover', 'mouseenter', 'mousemove'])
  }
  static unhover(target) {
    this.dispatchEvents(target, ['mousemove', 'mouseout', 'mouseleave'])
  }
  static dispatchEvents(target, events, { shiftKey, ctrlKey, altKey, metaKey } = {}) {
    for (const type of events) {
      const event = new MouseEvent(type, {
        bubbles: true,
        cancelable: true,
        view: window,
        shiftKey,
        ctrlKey,
        altKey,
        metaKey
      })
      target.dispatchEvent(event)
    }
  }
}
```

#### Show video controls

Update Hint configuration to show video controls.

`config.js`

``` javascript
// Modes ───────────────────────────────────────────────────────────────────────

// Hint
const hint = (selectors = '*') => {
  const hint = new Hint
  hint.on('start', () => {
    modal.unlisten()
    // Show video controls
    const videos = document.querySelectorAll('video')
    for (const video of videos) {
      mouse.hover(video)
    }
  })
  hint.on('exit', () => {
    mouse.clear()
    modal.listen()
  })
  return hint
}

// Tools ───────────────────────────────────────────────────────────────────────

const mouse = new Mouse
```

### Clipboard

The completed script can be downloaded [here][Clipboard].

`scripts/clipboard.js`

``` javascript
class Clipboard {
  static copy(text) {
    const activeElement = document.activeElement
    const textArea = document.createElement('textarea')
    textArea.style.position = 'fixed'
    textArea.value = text
    document.body.append(textArea)
    textArea.select()
    document.execCommand('copy')
    textArea.remove()
    activeElement.focus()
  }
  static paste() {
    const activeElement = document.activeElement
    const textArea = document.createElement('textarea')
    textArea.style.position = 'fixed'
    document.body.append(textArea)
    textArea.focus()
    document.execCommand('paste')
    const text = textArea.value
    textArea.remove()
    activeElement.focus()
    return text
  }
}
```

Update your manifest if you need to [read the clipboard contents][Declare Permissions].

`manifest.json`

``` json
{
  "permissions": [
    "clipboardRead"
  ]
}
```

#### Yank

Update your configuration to yank pages and links.

`config.js`

``` javascript
// Modes ───────────────────────────────────────────────────────────────────────

// Modal
modal.enable('Link', 'Text', 'Command')

// Commands ────────────────────────────────────────────────────────────────────

const notify = (message) => {
  modal.notify({ id: 'information', message, duration: 3000 })
}

const copyToClipboard = (text, message) => {
  Clipboard.copy(text)
  notify(message)
}

// Mappings ────────────────────────────────────────────────────────────────────

// Clipboard
modal.map('Command', ['KeyY'], () => copyToClipboard(location.href, 'Page address copied'), 'Copy page address')
modal.map('Command', ['Alt', 'KeyY'], () => copyToClipboard(document.title, 'Page title copied'), 'Copy page title')
modal.map('Command', ['Shift', 'KeyY'], () => copyToClipboard(`[${document.title}](${location.href})`, 'Page address and title copied'), 'Copy page address and title')
modal.map('Link', ['KeyY'], (event) => copyToClipboard(event.target.href, 'Link address copied'), 'Copy link address')
modal.map('Link', ['Alt', 'KeyY'], (event) => copyToClipboard(event.target.textContent, 'Link text copied'), 'Copy link text')
modal.map('Link', ['Shift', 'KeyY'], (event) => copyToClipboard(`[${event.target.textContent}](${event.target.href})`, 'Link address and text copied'), 'Copy link address and text')
```

### Scroll

The completed script can be downloaded [here][Scroll].

Based on [Saka Key]’s [implementation][Saka Key – Scroll].

> Scrolls the selected element smoothly.  Works around the quirks of keydown events.
> The first time a key is pressed (and held), a keydown event is fired immediately.
> After that, there is a delay before the second keydown event is fired.
> The third and all subsequent keydown events fire in rapid succession.
> [`event.repeat`][repeat] is false for the first keydown event, but true for all others.
> The delay (70 and 500) are carefully selected to keep scrolling smooth, but
> prevent unexpected scrolling after the user has released the scroll key.
> Relying on keyup events exclusively to stop scrolling is unreliable.

`scripts/scroll.js`

``` javascript
class Scroll {
  constructor() {
    this.element = document.scrollingElement
    this.step = 60
    this.behavior = 'smooth'
    this.animation = null
  }
  down(repeat) {
    if (this.behavior === 'smooth') {
      this.animate(() => this.element.scrollTop += this.step / 4, repeat)
    } else {
      this.element.scrollBy({ top: this.step })
    }
  }
  up(repeat) {
    if (this.behavior === 'smooth') {
      this.animate(() => this.element.scrollTop -= this.step / 4, repeat)
    } else {
      this.element.scrollBy({ top: -this.step })
    }
  }
  right(repeat) {
    if (this.behavior === 'smooth') {
      this.animate(() => this.element.scrollLeft += this.step / 4, repeat)
    } else {
      this.element.scrollBy({ left: this.step })
    }
  }
  left(repeat) {
    if (this.behavior === 'smooth') {
      this.animate(() => this.element.scrollLeft -= this.step / 4, repeat)
    } else {
      this.element.scrollBy({ left: -this.step })
    }
  }
  pageDown(percent = 0.9) {
    this.element.scrollBy({ top: window.innerHeight * percent, behavior: this.behavior })
  }
  pageUp(percent = 0.9) {
    this.element.scrollBy({ top: -window.innerHeight * percent, behavior: this.behavior })
  }
  top() {
    this.element.scrollTo({ top: 0, behavior: this.behavior })
  }
  bottom() {
    this.element.scrollTo({ top: this.element.scrollHeight, behavior: this.behavior })
  }
  animate(animation, repeat) {
    // Cancel potential animation being proceeded
    cancelAnimationFrame(this.animation)
    let start = null
    const delay = repeat ? 70 : 500
    const step = (timeStamp) => {
      if (start === null) {
        start = timeStamp
      }
      const progress = timeStamp - start
      animation()
      if (progress < delay) {
        this.animation = requestAnimationFrame(step)
      } else {
        this.animation = null
      }
    }
    requestAnimationFrame(step)
  }
}
```

#### Smooth scrolling

Update your configuration to smooth the scrolling.

`config.js`

``` javascript
// Tools ───────────────────────────────────────────────────────────────────────

const scroll = new Scroll

// Mappings ────────────────────────────────────────────────────────────────────

// Scroll
modal.map('Command', ['KeyJ'], (event) => scroll.down(event.repeat), 'Scroll down')
modal.map('Command', ['KeyK'], (event) => scroll.up(event.repeat), 'Scroll up')
modal.map('Command', ['KeyL'], (event) => scroll.right(event.repeat), 'Scroll right')
modal.map('Command', ['KeyH'], (event) => scroll.left(event.repeat), 'Scroll left')

// Scroll faster
modal.map('Command', ['Shift', 'KeyJ'], () => scroll.pageDown(), 'Scroll page down')
modal.map('Command', ['Shift', 'KeyK'], () => scroll.pageUp(), 'Scroll page up')
modal.map('Command', ['KeyG'], () => scroll.top(), 'Scroll to the top of the page')
modal.map('Command', ['Shift', 'KeyG'], () => scroll.bottom(), 'Scroll to the bottom of the page')
```

### Player

The completed script can be downloaded [here][Player].

`scripts/player.js`

``` javascript
class Player {
  constructor(media) {
    this.media = media
  }
  fullscreen() {
    if (document.fullscreenElement) {
      document.exitFullscreen()
    } else {
      this.media.requestFullscreen()
    }
  }
  pictureInPicture() {
    if (document.pictureInPictureElement) {
      document.exitPictureInPicture()
    } else {
      this.media.requestPictureInPicture()
    }
  }
  pause() {
    if (this.media.paused) {
      this.media.play()
    } else {
      this.media.pause()
    }
  }
  seekRelative(seconds) {
    this.media.currentTime += seconds
  }
  seekAbsolute(seconds) {
    this.media.currentTime = seconds
  }
  seekAbsolutePercent(percent) {
    this.media.currentTime = this.media.duration * percent
  }
  seekRelativePercent(percent) {
    this.media.currentTime += this.media.duration * percent
  }
  mute() {
    this.media.muted = ! this.media.muted
  }
  setVolume(percent) {
    this.media.volume = percent
  }
  increaseVolume(percent) {
    const volume = this.media.volume + percent
    this.media.volume = volume > 1
      ? 1
      : volume < 0
      ? 0
      : volume
  }
  descreaseVolume(percent) {
    this.increaseVolume(-percent)
  }
}
```

#### Video context

Update your configuration to add a context for videos.

`config.js`

``` javascript
modal.enable('Video', 'Link', 'Text', 'Command')

const player = () => {
  const media = Modal.findParent((element) => element.querySelector('video'))
  Mouse.hover(media)
  return new Player(media)
}

// Player
modal.map('Video', ['Space'], () => player().pause(), 'Pause video')
modal.map('Video', ['KeyM'], () => player().mute(), 'Mute video')
modal.map('Video', ['KeyL'], () => player().seekRelative(5), 'Seek forward 5 seconds')
modal.map('Video', ['KeyH'], () => player().seekRelative(-5), 'Seek backward 5 seconds')
modal.map('Video', ['KeyG'], () => player().seekAbsolutePercent(0), 'Seek to the beginning')
modal.map('Video', ['Shift', 'KeyG'], () => player().seekAbsolutePercent(1), 'Seek to the end')
modal.map('Video', ['KeyK'], () => player().increaseVolume(0.1), 'Increase volume')
modal.map('Video', ['KeyJ'], () => player().decreaseVolume(0.1), 'Decrease volume')
modal.map('Video', ['KeyF'], () => player().fullscreen(), 'Toggle full-screen mode')
modal.map('Video', ['KeyP'], () => player().pictureInPicture(), 'Toggle picture-in-picture mode')
```

## Part 4: Multiple selections

The completed script can be downloaded [here][Selection].

### Overview

[![Selection demo](https://img.youtube.com/vi_webp/KIsOSIQXAVU/maxresdefault.webp)](https://youtu.be/KIsOSIQXAVU)

**Motivation** – Improving on the hinting model

> vi basic grammar is **verb** followed by **object**; it’s nice because it
> matches well with the order we use in English, “delete word”.  On the other
> hand, it does not match well with the nature of what we express: there is only
> a handful of **verbs** in text editing (**d**elete, **y**ank, **p**aste,
> **i**nsert…), and they don’t compose, contrarily to **objects** which can be
> arbitrarily complex, and difficult to express.  That means that errors are not
> handled well.  If you express your object wrongly with a delete verb, the wrong
> text will get deleted, you will need to undo, and try again.
>
> Kakoune’s grammar is **object** followed by **verb**, combined with instantaneous
> feedback, that means you always see the current object (in Kakoune we call that
> the selection) before you apply your change, which allows you to correct errors
> on the go.
>
> Kakoune tries hard to fix one of the big problems with the vi model: its lack
> of interactivity.  Because of the **verb** followed by **object** grammar, vi
> changes are made in the dark, we don’t see their effect until the whole editing
> sentence is finished.  `5dw` will delete to next five words, if you then realize
> that was one word too many, you need to undo, go back to your initial position,
> and try again with `4dw`.  In Kakoune, you would do `5W`, see immediately that
> one more word than expected was selected, type `BH` to remove that word from
> the selection, then `d` to delete.  At each step you get visual feedback, and
> have the opportunity to correct it.
>
> ([Why Kakoune] – [Improving on the editing model])

**Example** – Manipulating selections on [Kakoune]:

``` javascript
const selections = new SelectionList

// Getting Started
const getStarted = document.querySelector('a[href*="getting-started"]')

selections.add(getStarted) // Select “Getting Started”
selections.parent(2) // Select the navigation section
selections.select('a') // Select all links
selections.focus(getStarted) // Select “Getting Started”
selections.next(2) // Select “Issue Tracker”
selections.children() // Select all of the child elements
selections.previous() // Select the bug icon
selections.remove() // Remove the element from the selections
```

### The Prototype

Create the files and update your configuration.

`scripts/selection.js`

``` javascript
class SelectionList {
  constructor() {
    this.main = 0
    this.collection = []
  }
  get length() {
    return this.collection.length
  }
  map(callback) {
    return this.collection.map(callback)
  }
  includes(element) {
    return this.collection.includes(element)
  }
  add(...elements) {
  }
  remove(...elements) {
  }
  filter(callback) {
  }
  parent(count = 1) {
  }
  children(depth = 1) {
  }
  select(selectors = '*') {
  }
  focus(element = this.collection[this.main]) {
  }
  next(count = 1) {
  }
  previous(count = 1) {
  }
  clear() {
  }
}
```

`styles/selection.css`

``` css
/* Dracula theme – https://draculatheme.com */

.primary-selection {
  outline: hsl(326, 100%, 74%) solid medium !important; /* Pink */
}

.secondary-selection {
  outline: hsl(265, 89%, 78%) dotted thin !important; /* Purple */
}
```

### Implementation

**SelectionList** is a collection of [elements][Element].

When manipulating selections, we need to ensure selections are sorted and
overlapping selections merged.

Sorting is the easy part.  We can rely on [Node.compareDocumentPosition] to sort
the selections by their position in the document.

`scripts/selection.js`

``` javascript
class SelectionList {
  sort() {
    if (this.length <= 1) {
      return
    }
    const main = this.collection[this.main]
    this.collection.sort(SelectionList.compare)
    this.main = this.collection.indexOf(main)
  }
  static compare(element, other) {
    if (element.compareDocumentPosition(other) & Node.DOCUMENT_POSITION_FOLLOWING) {
      return -1
    }
    if (element.compareDocumentPosition(other) & Node.DOCUMENT_POSITION_PRECEDING) {
      return 1
    }
    return 0
  }
}
```

Merging is a bit more tricky.  We assume to work on sorted selections.

A parent element is always positioned first to its child elements.
The first element of the collection is therefore always valid.

The strategy will be to iterate over the collection while comparing a valid element
to the next candidates.

An element is valid when it is not the same than the previously validated element
or contained by it.  When these conditions are met, we push the previously validated
element to our new collection and update the target to the index the candidate had.

We also keep track of the main index during the process.

`scripts/selection.js`

``` javascript
class SelectionList {
  merge() {
    if (this.length <= 1) {
      return
    }
    let main = this.main
    const collection = []
    let target = 0
    let candidate
    for (candidate = 1; candidate < this.length; ++candidate) {
      if (this.collection[target] === this.collection[candidate] || this.collection[target].contains(this.collection[candidate])) {
        if (candidate <= this.main) {
          --main
        }
        continue
      }
      collection.push(this.collection[target])
      target = candidate
    }
    collection.push(this.collection[target])
    this.main = main
    this.collection = collection
  }
}
```

Keeping track of the main selection has its tricks too.

Here is the function I use to modify a selection set, and keep track of the main selection.

`scripts/selection.js`

``` javascript
class SelectionList {
  fold(callback) {
    let main = this.main
    const collection = []
    for (const [index, element] of this.collection.entries()) {
      const elements = callback(element, index, this.collection)
      switch (elements.length) {
        case 0:
          if (index < this.main || this.main === this.length - 1) {
            --main
          }
          break
        case 1:
          collection.push(elements[0])
          break
        default:
          collection.push(...elements)
          if (index <= this.main) {
            main += elements.length - 1
          }
      }
    }
    this.set(collection, main)
  }
}
```

We can now implement the method to set the selections.

`scripts/selection.js`

``` javascript
class SelectionList {
  set(collection = this.collection, main = collection.length - 1) {
    this.clear()
    this.main = main >= 0 && main <= collection.length - 1
      ? main
      : 0
    this.collection = collection
    this.sort()
    this.merge()
    this.render()
    this.focus()
  }
  render() {
    if (this.length === 0) {
      return
    }
    this.collection[this.main].classList.add('primary-selection')
    for (const [index, element] of this.collection.entries()) {
      if (index !== this.main) {
        element.classList.add('secondary-selection')
      }
    }
  }
  clear() {
    if (this.length === 0) {
      return
    }
    this.collection[this.main].classList.remove('primary-selection')
    for (const [index, element] of this.collection.entries()) {
      if (index !== this.main) {
        element.classList.remove('secondary-selection')
      }
    }
    this.main = 0
    this.collection = []
  }
}
```

Adding and removing elements:

`scripts/selection.js`

``` javascript
class SelectionList {
  add(...elements) {
    const collection = this.collection.concat(elements)
    const main = collection.length - 1
    this.set(collection, main)
  }
  remove(...elements) {
    const collection = Object.assign([this.collection[this.main]], elements)
    this.filter((candidate) => collection.includes(candidate) === false)
  }
}
```

Filtering selections:

`scripts/selection.js`

``` javascript
class SelectionList {
  filter(callback) {
    this.fold((element, index, array) => callback(element, index, array) ? [element] : [])
  }
}
```

Skim through the selection list:

`scripts/selection.js`

``` javascript
class SelectionList {
  focus(element = this.collection[this.main]) {
    if (this.length === 0) {
      return
    }
    const main = this.collection.indexOf(element)
    if (main === -1) {
      return
    }
    if (main !== this.main) {
      const secondary = this.collection[this.main]
      secondary.classList.remove('primary-selection')
      secondary.classList.add('secondary-selection')
      element.classList.remove('secondary-selection')
      element.classList.add('primary-selection')
      this.main = main
    }
    element.focus()
    element.scrollIntoView({ block: 'nearest' })
  }
  next(count = 1) {
    const main = SelectionList.modulo(this.main + count, this.length)
    this.focus(this.collection[main])
  }
  previous(count = 1) {
    this.next(-count)
  }
  static modulo(dividend, divisor) {
    return ((dividend % divisor) + divisor) % divisor
  }
}
```

Select parents:

`scripts/selection.js`

``` javascript
class SelectionList {
  parent(count = 1) {
    const getParent = (element, count) => {
      if (count < 1) {
        return element
      }
      if (element === null) {
        return null
      }
      return getParent(element.parentElement, count - 1)
    }
    this.fold((element) => {
      const parent = getParent(element, count)
      return parent ? [parent] : []
    })
  }
}
```

Select all of the child elements:

`scripts/selection.js`

``` javascript
class SelectionList {
  children(depth = 1) {
    if (depth < 1 || this.length === 0) {
      return
    }
    this.fold((element) => element.children)
    this.children(depth - 1)
  }
}
```

Select elements:

`scripts/selection.js`

``` javascript
class SelectionList {
  select(selectors = '*') {
    this.fold((element) => Array.from(element.querySelectorAll(selectors)))
  }
}
```

Adding events:

`scripts/selection.js`

``` javascript
class SelectionList {
  constructor() {
    this.events = {}
    this.events['selection-change'] = []
  }
  on(type, listener) {
  }
  triggerEvent(type, ...parameters) {
  }
  set(collection = this.collection, main = collection.length - 1) {
    this.triggerEvent('selection-change', collection)
  }
  clear() {
    this.triggerEvent('selection-change', this.collection)
  }
}
```

### Configuration

Create an instance of **SelectionList**.

`config.js`

``` javascript
const selections = new SelectionList
```

#### Selection manipulation

`config.js`

``` javascript
const keep = (selections, matching, ...attributes) => {
  const mode = matching ? 'Keep matching' : 'Keep not matching'
  const value = prompt(`${mode} (${attributes})`)
  if (value === null) {
    return
  }
  const regex = new RegExp(value)
  selections.filter((selection) => attributes.some((attribute) => regex.test(selection[attribute]) === matching))
}

const select = (selections) => {
  const value = prompt('Select (querySelectorAll)')
  if (value === null) {
    return
  }
  selections.select(value)
}

modal.map('Command', ['KeyS'], () => selections.add(document.activeElement), 'Select active element')
modal.map('Command', ['Shift', 'KeyS'], () => select(selections), 'Select elements that match the specified group of selectors')
modal.map('Command', ['Shift', 'Digit5'], () => selections.set([document.documentElement]), 'Select document')
modal.map('Command', ['Shift', 'Digit0'], () => selections.next(), 'Focus next selection')
modal.map('Command', ['Shift', 'Digit9'], () => selections.previous(), 'Focus previous selection')
modal.map('Command', ['Space'], () => selections.clear(), 'Clear selections')
modal.map('Command', ['Control', 'Space'], () => selections.focus(), 'Focus main selection')
modal.map('Command', ['Alt', 'Space'], () => selections.remove(), 'Remove main selection')
modal.map('Command', ['Alt', 'KeyA'], () => selections.parent(), 'Select parent elements')
modal.map('Command', ['Alt', 'KeyI'], () => selections.children(), 'Select child elements')
modal.map('Command', ['Alt', 'Shift', 'KeyI'], () => selections.select('a'), 'Select links')
modal.map('Command', ['Alt', 'KeyK'], () => keep(selections, true, 'textContent'), 'Keep selections that match the given RegExp')
modal.map('Command', ['Alt', 'Shift', 'KeyK'], () => keep(selections, true, 'href'), 'Keep links that match the given RegExp')
modal.map('Command', ['Alt', 'KeyJ'], () => keep(selections, false, 'textContent'), 'Clear selections that match the given RegExp')
modal.map('Command', ['Alt', 'Shift', 'KeyJ'], () => keep(selections, false, 'href'), 'Clear links that match the given RegExp')
```

#### Link hints

`config.js`

``` javascript
const hint = ({ selections, selectors = '*', lock = false } = {}) => {
  const hint = new Hint
  hint.selectors = selectors
  hint.lock = lock
  hint.on('validate', (target) => {
    if (hint.lock) {
      if (selections.includes(target)) {
        selections.remove(target)
      } else {
        selections.add(target)
      }
    } else {
      target.focus()
    }
  })
  return hint
}

modal.map('Command', ['Shift', 'KeyF'], () => hint({ selections, lock: true }).start(), 'Select multiple links')
```

#### Open links

`config.js`

``` javascript
const click = (selections, modifierKeys = {}) => {
  const elements = selections.includes(document.activeElement)
    ? selections.collection
    : [document.activeElement]
  for (const element of elements) {
    Mouse.click(element, modifierKeys)
  }
}

modal.map('Link', ['Enter'], () => click(selections), 'Open link')
modal.map('Link', ['Control', 'Enter'], () => click(selections, { ctrlKey: true }), 'Open link in new tab')
modal.map('Link', ['Shift', 'Enter'], () => click(selections, { shiftKey: true }), 'Open link in new window')
modal.map('Link', ['Alt', 'Enter'], () => click(selections, { altKey: true }), 'Download link')
```

#### Clipboard

`config.js`

``` javascript
const yank = (selections, callback, message) => {
  const text = selections.includes(document.activeElement)
    ? selections.map(callback).join('\n')
    : callback(document.activeElement)
  copyToClipboard(text, message)
}

modal.map('Link', ['KeyY'], () => yank(selections, (selection) => selection.href, 'Link address copied'), 'Copy link address')
modal.map('Link', ['Alt', 'KeyY'], () => yank(selections, (selection) => selection.textContent, 'Link text copied'), 'Copy link text')
modal.map('Link', ['Shift', 'KeyY'], () => yank(selections, (selection) => `[${selection.textContent}](${selection.href})`, 'Link address and text copied'), 'Copy link address and text')
```

#### Status line

`config.js`

``` javascript
const updateStatusLine = () => {
  modal.notify({ id: 'status-line', message: `${modal.context.name} (${selections.length})` })
}

selections.on('selection-change', (selections) => updateStatusLine())
```

## Part 5: Polishment

### Custom prompt

The completed extension can be downloaded [here][Prompt].

`scripts/prompt.js`

``` javascript
class Prompt {
  constructor() {
    // Events
    this.events = {}
    this.events['open'] = []
    this.events['close'] = []
    // Style
    this.style = `
      dialog {
        position: fixed;
        margin-right: 0;
        top: 0;
        right: 0;
        color: gray;
        background-color: white;
        border: 1px solid lightgray;
        border-bottom-left-radius: 4px;
      }
      input {
        font-family: serif;
        font-size: 18px;
        background-color: white;
        border: none;
      }
      input:focus {
        outline: none;
      }
    `
  }
  on(type, listener) {
    this.events[type].push(listener)
  }
  triggerEvent(type, ...parameters) {
    for (const listener of this.events[type]) {
      listener(...parameters)
    }
  }
  fire(message) {
    const dialog = document.createElement('dialog')
    switch (typeof dialog.showModal) {
      case 'function':
        return this.fireDialog(message)
        break
      case 'undefined':
        return this.firePrompt(message)
        break
    }
  }
  fireDialog(message) {
    return new Promise((resolve, reject) => {
      const root = document.createElement('div')
      root.id = 'prompt'
      // Place the prompt in a shadow root,
      // so that the prompt and page styles won’t affect each other.
      // Use an open shadow root to mitigate key-binding issues.
      // For example, sites can access the real active element with document.activeElement.shadowRoot.activeElement.
      const shadow = root.attachShadow({ mode: 'open' })
      // Dialog
      const dialog = document.createElement('dialog')
      const form = document.createElement('form')
      form.method = 'dialog'
      const input = document.createElement('input')
      input.placeholder = message
      // Style
      const style = document.createElement('style')
      style.textContent = this.style
      // Attach
      shadow.append(style)
      shadow.appendChild(dialog).appendChild(form).appendChild(input)
      document.documentElement.append(root)
      // Show modal
      dialog.showModal()
      this.triggerEvent('open')
      // Events
      dialog.addEventListener('close', () => {
        resolve(dialog.returnValue)
        this.triggerEvent('close')
      })
      form.addEventListener('submit', () => {
        dialog.close(input.value)
      })
      dialog.addEventListener('cancel', () => {
        dialog.close(null)
      })
      dialog.addEventListener('keydown', (event) => {
        // Stop the propagation of the event
        event.stopImmediatePropagation()
      })
    })
  }
  firePrompt(message) {
    return new Promise((resolve, reject) => {
      const value = window.prompt(message)
      resolve(value)
    })
  }
}
```

Update your configuration.

`config.js`

``` javascript
// Prompt
const prompt = new Prompt
prompt.on('open', () => modal.unlisten())
prompt.on('close', () => modal.listen())

const keep = async (selections, matching, ...attributes) => {
  const mode = matching ? 'Keep matching' : 'Keep not matching'
  const value = await prompt.fire(`${mode} (${attributes})`)
  if (value === null) {
    return
  }
  const regex = new RegExp(value)
  selections.filter((selection) => attributes.some((attribute) => regex.test(selection[attribute]) === matching))
}

const select = async (selections) => {
  const value = await prompt.fire('Select (querySelectorAll)')
  if (value === null) {
    return
  }
  selections.select(value)
}
```

### Icons

Add [icons][Manifest – Icons] for the extension.

`manifest.json`

``` json
{
  "icons": {
    "16": "build/chrome.png",
    "48": "build/chrome.png",
    "128": "build/chrome.png"
  }
}
```

`fetch`

``` sh
fetch 'https://upload.wikimedia.org/wikipedia/commons/a/a5/Google_Chrome_icon_(September_2014).svg' chrome.svg
```

`Makefile`

``` makefile
build: fetch
	mkdir -p build
	inkscape --without-gui packages/chrome.svg --export-png build/chrome.png

fetch:
	./fetch

clean:
	rm -Rf build packages

.PHONY: build fetch
```

`.gitignore`

``` gitignore
build
packages
```

## Part 6: Chrome APIs

The completed extension can be downloaded [here][Commands].

### New extension

Like in [Getting Started], create a new directory to hold the extension’s files.

``` sh
mkdir chrome-commands
cd chrome-commands
```

`manifest.json`

``` json
{
  "manifest_version": 2,
  "name": "Commands",
  "description": "Commands for Chrome",
  "version": "0.1.0",
  "permissions": [
    "sessions",
    "notifications"
  ],
  "background": {
    "scripts": [
      "background.js"
    ],
    "persistent": false
  },
  "icons": {
    "16": "build/chrome.png",
    "48": "build/chrome.png",
    "128": "build/chrome.png"
  }
}
```

We will use the same `fetch` and Makefile scripts than preceding.

Create a [background script][Manage Events with Background Scripts] titled `background.js`.

`background.js`

``` javascript
const commands = {}
```

### Commands

#### Zoom

`background.js`

``` javascript
commands['zoom-in'] = (step = 0.1) => {
  chrome.tabs.getZoom(undefined, (zoomFactor) => {
    chrome.tabs.setZoom(undefined, zoomFactor + step)
  })
}

commands['zoom-out'] = (step = 0.1) => {
  commands['zoom-in'](-step)
}

commands['zoom-reset'] = () => {
  chrome.tabs.setZoom(undefined, 0)
}
```

#### Create tabs

`background.js`

``` javascript
commands['new-tab'] = (url) => {
  chrome.tabs.create({ url })
}

commands['restore-tab'] = () => {
  chrome.sessions.restore()
}

commands['duplicate-tab'] = () => {
  chrome.tabs.query({ currentWindow: true, active: true }, (tabs) => {
    const [tab] = tabs
    chrome.tabs.duplicate(tab.id)
  })
}
```

#### Create windows

`background.js`

``` javascript
commands['new-window'] = (url) => {
  chrome.windows.create({ url })
}

commands['new-incognito-window'] = () => {
  chrome.windows.create({ incognito: true })
}
```

#### Close tabs

`background.js`

``` javascript
commands['close-tab'] = () => {
  chrome.tabs.query({ currentWindow: true, active: true }, (tabs) => {
    const [tab] = tabs
    chrome.tabs.remove(tab.id)
  })
}

commands['close-other-tabs'] = () => {
  chrome.tabs.query({ currentWindow: true }, (tabs) => {
    for (const tab of tabs) {
      if (tab.active === false) {
        chrome.tabs.remove(tab.id)
      }
    }
  })
}

commands['close-right-tabs'] = () => {
  chrome.tabs.query({ currentWindow: true }, (tabs) => {
    const active = tabs.find((tab) => tab.active)
    const rightTabs = tabs.slice(active.index + 1)
    for (const tab of rightTabs) {
      chrome.tabs.remove(tab.id)
    }
  })
}
```

#### Refresh tabs

`background.js`

``` javascript
commands['reload-tab'] = (bypassCache = false) => {
  chrome.tabs.reload(undefined, { bypassCache })
}

commands['reload-all-tabs'] = (bypassCache = false) => {
  chrome.tabs.query({}, (tabs) => {
    for (const tab of tabs) {
      chrome.tabs.reload(tab.id, { bypassCache })
    }
  })
}
```

#### Switch tabs

`background.js`

``` javascript
commands['next-tab'] = (count = 1) => {
  chrome.tabs.query({ currentWindow: true }, (tabs) => {
    const active = tabs.find((tab) => tab.active)
    const next = tabs[modulo(active.index + count, tabs.length)]
    chrome.tabs.update(next.id, { active: true })
  })
}

commands['previous-tab'] = (count = 1) => {
  commands['next-tab'](-count)
}

commands['first-tab'] = () => {
  chrome.tabs.query({ currentWindow: true }, (tabs) => {
    const first = tabs[0]
    chrome.tabs.update(first.id, { active: true })
  })
}

commands['last-tab'] = () => {
  chrome.tabs.query({ currentWindow: true }, (tabs) => {
    const last = tabs[tabs.length - 1]
    chrome.tabs.update(last.id, { active: true })
  })
}

const modulo = (dividend, divisor) => {
  return ((dividend % divisor) + divisor) % divisor
}
```

#### Move tabs

`background.js`

``` javascript
commands['move-tab-right'] = (count = 1) => {
  chrome.tabs.query({ currentWindow: true }, (tabs) => {
    const active = tabs.find((tab) => tab.active)
    const next = tabs[modulo(active.index + count, tabs.length)]
    chrome.tabs.move(active.id, { index: next.index })
  })
}

commands['move-tab-left'] = (count) => {
  commands['move-tab-right'](-count)
}

commands['move-tab-first'] = () => {
  chrome.tabs.query({ currentWindow: true, active: true }, (tabs) => {
    const [tab] = tabs
    chrome.tabs.move(tab.id, { index: 0 })
  })
}

commands['move-tab-last'] = () => {
  chrome.tabs.query({ currentWindow: true, active: true }, (tabs) => {
    const [tab] = tabs
    chrome.tabs.move(tab.id, { index: -1 })
  })
}
```

#### Detach tabs

`background.js`

``` javascript
commands['detach-tab'] = () => {
  chrome.tabs.query({ currentWindow: true, active: true }, (tabs) => {
    const [tab] = tabs
    const pinned = tab.pinned
    chrome.windows.create({ tabId: tab.id }, (window) => {
      chrome.tabs.update(tab.id, { pinned })
    })
  })
}

commands['attach-tab'] = () => {
  chrome.tabs.query({ currentWindow: true, active: true }, (tabs) => {
    const [tab] = tabs
    const pinned = tab.pinned
    chrome.tabs.query({ windowId: focusedWindows[focusedWindows.length - 2] }, (tabs) => {
      const target = tabs.find((tab) => tab.active)
      chrome.tabs.move(tab.id, { windowId: target.windowId, index: modulo(target.index + 1, tabs.length + 1) }, (tab) => {
        chrome.tabs.update(tab.id, { pinned })
      })
    })
  })
}

// Events ──────────────────────────────────────────────────────────────────────

const focusedWindows = []

chrome.windows.onFocusChanged.addListener((id) => {
  if (id !== chrome.windows.WINDOW_ID_NONE) {
    focusedWindows.push(id)
  }
  if (focusedWindows.length > 2) {
    focusedWindows.shift()
  }
})
```

#### Discard tabs

`background.js`

``` javascript
commands['discard-tab'] = () => {
  chrome.tabs.query({ currentWindow: true, active: true }, (tabs) => {
    const [tab] = tabs
    chrome.tabs.discard(tab.id)
  })
}
```

#### Mute tabs

`background.js`

``` javascript
commands['mute-tab'] = () => {
  chrome.tabs.query({ currentWindow: true, active: true }, (tabs) => {
    const [tab] = tabs
    chrome.tabs.update(tab.id, { muted: ! tab.mutedInfo.muted })
  })
}

let muted = false

commands['mute-all-tabs'] = () => {
  muted = ! muted
  chrome.tabs.query({}, (tabs) => {
    for (const tab of tabs) {
      chrome.tabs.update(tab.id, { muted })
    }
  })
}
```

#### Pin tabs

`background.js`

``` javascript
commands['pin-tab'] = () => {
  chrome.tabs.query({ currentWindow: true, active: true }, (tabs) => {
    const [tab] = tabs
    chrome.tabs.update(tab.id, { pinned: ! tab.pinned })
  })
}
```

#### Notifications

`background.js`

``` javascript
commands['notify'] = (id, options) => {
  const properties = {}
  properties.title = ''
  properties.message = ''
  properties.type = 'basic'
  properties.iconUrl = 'packages/chrome.svg'
  Object.assign(properties, options)
  chrome.notifications.getAll((notifications) => {
    const notification = notifications[id]
    if (notification) {
      chrome.notifications.update(id, properties)
    } else {
      chrome.notifications.create(id, properties)
    }
  })
}
```

### Initialization

`background.js`

``` javascript
chrome.runtime.onConnectExternal.addListener((port) => {
  port.onMessage.addListener((request) => {
    const command = commands[request.command]
    const arguments = request.arguments || []
    if (command) {
      command(...arguments)
    }
  })
})
```

### Configuration

Assign a [key][Manifest – Key] to the extension to have a stable extension ID.

- If you haven’t uploaded the extension yet, you can get a suitable key value
by looking in your [user data directory] `Default/Extensions/<extension-id>/<version-string>/manifest.json`.
You will see the key value filled in there.

- If you already uploaded the extension, you can get the key value in the [Chrome Developer Dashboard]
by clicking on _Extension_ ❯ _More info_ ❯ _Public key_.

`manifest.json`

``` json
{
  // Extension ID: cabmgmngameccclicfmcpffnbinnmopc
  "key": "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAl7hfbL55fip9+2aqoPQmb8n3BLkhpqPR+oHHsU/vLDC1c8wb+CbmD7Gk2VlCWp0R8b0DDdDpcVgMEvoKkagXsfhOjW7zFG1bh6O4nUOZhzNkEVCZjWMewBE0FnJ74EE8Sz1jQJKqO8AiNiLZNpH6gkiG25CNVUg1bZAKFuqZQ1YNL9fw9EnI13oIetO0+gtkgNY8Rt3WCr+J74oD3Ox10f43Fj/8rF6x8mOfTu1D89MXIYXnN/ssPOZpzee+M0QoWUsS7dduuYDCQA/YjwKYgkZz5fX96ZC1Djwb4HE0Q9ijvTuA7YctEFHqL0KLyeUItCisElVa3cEnAfRWxjjahwIDAQAB"
}
```

Connect your configuration to the extension.

`config.js`

``` javascript
const commands = {}
commands.port = chrome.runtime.connect('cabmgmngameccclicfmcpffnbinnmopc')
commands.send = (command, ...arguments) => {
  commands.port.postMessage({ command, arguments })
}
```

#### Zoom

`config.js`

``` javascript
modal.map('Command', ['Shift', 'Equal'], () => commands.send('zoom-in'), 'Zoom in')
modal.map('Command', ['Minus'], () => commands.send('zoom-out'), 'Zoom out')
modal.map('Command', ['Equal'], () => commands.send('zoom-reset'), 'Reset to default zoom level')
```

#### Create tabs

`config.js`

``` javascript
modal.map('Command', ['KeyT'], () => commands.send('new-tab'), 'New tab')
modal.map('Command', ['Shift', 'KeyT'], () => commands.send('restore-tab'), 'Restore tab')
modal.map('Command', ['KeyB'], () => commands.send('duplicate-tab'), 'Duplicate tab')
```

#### Create windows

`config.js`

``` javascript
modal.map('Command', ['KeyN'], () => commands.send('new-window'), 'New window')
modal.map('Command', ['Shift', 'KeyN'], () => commands.send('new-incognito-window'), 'New incognito window')
```

#### Close tabs

`config.js`

``` javascript
modal.map('Command', ['KeyX'], () => commands.send('close-tab'), 'Close tab')
modal.map('Command', ['Shift', 'KeyX'], () => commands.send('close-other-tabs'), 'Close other tabs')
modal.map('Command', ['Alt', 'KeyX'], () => commands.send('close-right-tabs'), 'Close tabs to the right')
```

#### Refresh tabs

`config.js`

``` javascript
modal.map('Command', ['Alt', 'KeyR'], () => commands.send('reload-all-tabs'), 'Reload all tabs')
```

#### Switch tabs

`config.js`

``` javascript
modal.map('Command', ['Alt', 'KeyL'], () => commands.send('next-tab'), 'Next tab')
modal.map('Command', ['Alt', 'KeyH'], () => commands.send('previous-tab'), 'Previous tab')
modal.map('Command', ['Digit1'], () => commands.send('first-tab'), 'First tab')
modal.map('Command', ['Digit0'], () => commands.send('last-tab'), 'Last tab')
```

#### Move tabs

`config.js`

``` javascript
modal.map('Command', ['Alt', 'Shift', 'KeyL'], () => commands.send('move-tab-right'), 'Move tab right')
modal.map('Command', ['Alt', 'Shift', 'KeyH'], () => commands.send('move-tab-left'), 'Move tab left')
modal.map('Command', ['Alt', 'Digit1'], () => commands.send('move-tab-first'), 'Move tab first')
modal.map('Command', ['Alt', 'Digit0'], () => commands.send('move-tab-last'), 'Move tab last')
```

#### Detach tabs

`config.js`

``` javascript
modal.map('Command', ['KeyD'], () => commands.send('detach-tab'), 'Detach tab')
modal.map('Command', ['Shift', 'KeyD'], () => commands.send('attach-tab'), 'Attach tab')
```

#### Discard tabs

`config.js`

``` javascript
modal.map('Command', ['KeyZ'], () => commands.send('discard-tab'), 'Discard tab')
```

#### Mute tabs

`config.js`

``` javascript
modal.map('Command', ['Alt', 'KeyM'], () => commands.send('mute-tab'), 'Mute tab')
modal.map('Command', ['Alt', 'Shift', 'KeyM'], () => commands.send('mute-all-tabs'), 'Mute all tabs')
```

#### Pin tabs

`config.js`

``` javascript
modal.map('Command', ['Alt', 'KeyP'], () => commands.send('pin-tab'), 'Pin tab')
```

## Part 7: Native messaging and external commands

The completed extension can be downloaded [here][Shell].

### Introduction

> Extensions can exchange messages with native applications using an API that is
> similar to the other [message passing APIs][Message Passing].  Native applications
> that support this feature must register a native messaging host that knows how to
> communicate with the extension.  Chrome starts the host in a separate process and
> communicates with it using standard input and standard output streams.

Start by creating a new directory to hold the extension and application’s files.

``` sh
mkdir -p chrome-shell/extension chrome-shell/host
cd chrome-shell
```

### Native messaging host

> In order to register a native messaging host the application must install a manifest
> file that defines the native messaging host configuration.

`host/shell.json`

``` json
{
  "name": "shell",
  "description": "Native messaging host to execute external commands",
  "path": "/home/alex/projects/chrome-shell/host/bin/chrome-shell",
  "type": "stdio",
  "allowed_origins": [
    "chrome-extension://ohgecdnlcckpfnhjepfdcdgcfgebkdgl/"
  ]
}
```

### Native messaging host location

The location of the manifest file depends on the [platform][Native messaging host location].

Here are the scripts to handle the installation:

`host/scripts/chrome-target.sh`

``` sh
XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-~/.config}

# https://developer.chrome.com/extensions/nativeMessaging#native-messaging-host-location
case $(uname -s) in
  Darwin)
    TARGET="$HOME/Library/Application Support/Google/Chrome/NativeMessagingHosts"
    ;;
  Linux)
    TARGET="$XDG_CONFIG_HOME/google-chrome/NativeMessagingHosts"
    ;;
esac
```

`host/scripts/chromium-target.sh`

``` sh
XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-~/.config}

# https://developer.chrome.com/extensions/nativeMessaging#native-messaging-host-location
case $(uname -s) in
  Darwin)
    TARGET="$HOME/Library/Application Support/Chromium/NativeMessagingHosts"
    ;;
  Linux)
    TARGET="$XDG_CONFIG_HOME/chromium/NativeMessagingHosts"
    ;;
esac
```

`host/scripts/install-manifest`

``` sh
#!/bin/sh

# Faces
none='\033[0m'
green='\033[32m'

export application=$PWD/bin/chrome-shell
for platform do
  . "./scripts/$platform-target.sh"
  mkdir -p "$TARGET"
  printf "${green}Installing${none}: %s\n" "$TARGET/shell.json"
  jq '.path = env.application' shell.json > "$TARGET/shell.json"
done
```

`host/scripts/uninstall-manifest`

``` sh
#!/bin/sh

# Faces
none='\033[0m'
green='\033[32m'

for platform do
  . "./scripts/$platform-target.sh"
  printf "${green}Removing${none}: %s\n" "$TARGET/shell.json"
  rm -f "$TARGET/shell.json"
done
```

### Native messaging protocol

> Chrome starts each native messaging host in a separate process and communicates
> with it using standard input (`stdin`) and standard output (`stdout`).
> The same format is used to send messages in both directions: each message is
> serialized using JSON, UTF-8 encoded and is preceded with 32-bit message length
> in native byte order.

### Meet Crystal

Create a new [Crystal] project.

``` sh
crystal init app chrome-shell host
```

`host/shard.yml`

``` yaml
name: chrome-shell
version: 0.1.0
license: Unlicense
targets:
  chrome-shell:
    main: src/chrome-shell.cr
```

Here is the implementation to execute external commands.

`host/src/chrome-shell.cr`

``` crystal
require "json"

class Request
  JSON.mapping({
    id: String?,
    command: String,
    arguments: Array(String)?,
    environment: Hash(String, String)?,
    shell: { type: Bool, default: false },
    input: String?,
    directory: String?
  })
end

def main
  loop do
    request = read
    stdin = IO::Memory.new
    stdout = IO::Memory.new
    stderr = IO::Memory.new
    if request.input
      stdin << request.input
      stdin.rewind
    end
    fork do
      status = Process.run(
        command: request.command,
        args: request.arguments,
        env: request.environment,
        shell: request.shell,
        input: stdin,
        output: stdout,
        error: stderr,
        chdir: request.directory
      )
      response = {
        id: request.id,
        status: status.exit_status,
        output: stdout.to_s,
        error: stderr.to_s
      }
      send(response)
    end
  end
end

# Step 1: Read the message length (first 4 bytes)
# Step 2: Read the text (JSON object) of the message
def read
  bytes = STDIN.read_bytes(Int32)
  string = STDIN.read_string(bytes)
  request = Request.from_json(string)
end

# Step 1: Write the message size
# Step 2: Write the message itself
def send(response)
  string = response.to_json
  STDOUT.write_bytes(string.bytesize)
  STDOUT << string
  STDOUT.flush
end

main
```

Put the commands in a Makefile.

`host/Makefile`

``` makefile
build:
	shards build --release

install: build
	./scripts/install-manifest chrome chromium

uninstall:
	./scripts/uninstall-manifest chrome chromium

clean:
	rm -Rf bin
```

`host/.gitignore`

``` gitignore
bin
```

### Connecting to the application

> Sending and receiving messages to and from a native application is very similar
> to [cross-extension messaging].  The main difference is that [runtime.connectNative]
> is used instead of [runtime.connect], and [runtime.sendNativeMessage] is used
> instead of [runtime.sendMessage].

> These methods can only be used if the `nativeMessaging` permission is
> [declared][Declare Permissions] in your extension’s manifest file.

Create the manifest and background script for the extension.

`extension/manifest.json`

``` json
{
  // Extension ID: ohgecdnlcckpfnhjepfdcdgcfgebkdgl
  "key": "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAmSz06f+QU6YhleWBKOEUy88DV8wOmNy7Jf9mRhBqXjHVhySBbkOrPkWsMbLEHwo0MdEDf3XrrC38t95l/gvcTgSZv6VQpknf+QuMI4LWmkAqyD+M3F/w3pXXiiHNa6gQHeFganF7XckTDQzEUZFRjXlgW12wsGOnEGbjVKq8/ZXTHiMbFaACiy/ZAi3OvaJVR5KdxMkxtFg7Wg+bKY6Esi7GLeNKlBttahXAKMPcGenuLCmLzKEcIE6CSRKHu1zDlfUXn2Mmc5j5oLJDKuy2vA2yIu1CoLahgeHFUewZCFFKjMwO1ZQMUMO1yN18IterFDdkMsn5rdvC0w2tPLXYeQIDAQAB",
  "manifest_version": 2,
  "name": "Shell",
  "description": "Chrome API to execute external commands through native messaging",
  "version": "0.1.0",
  "permissions": [
    "nativeMessaging"
  ],
  "background": {
    "scripts": [
      "background.js"
    ],
    "persistent": false
  },
  "icons": {
    "16": "build/chromium.png",
    "48": "build/chromium.png",
    "128": "build/chromium.png"
  }
}
```

`extension/background.js`

``` javascript
const shell = {}
shell.port = chrome.runtime.connectNative('shell')
chrome.runtime.onConnectExternal.addListener((port) => {
  // Send request to the application
  port.onMessage.addListener((request) => {
    shell.port.postMessage(request)
  })
  // Receive response
  shell.port.onMessage.addListener((response) => {
    port.postMessage(response)
  })
})
```

Create Makefile and `fetch` script.

`extension/fetch`

``` sh
#!/bin/sh

fetch() {
  case $# in
    1) curl --location --remote-name $1 ;;
    2) curl --location $1 --output $2 ;;
  esac
}

mkdir -p packages
cd packages

fetch https://upload.wikimedia.org/wikipedia/commons/5/5f/Chromium_11_Logo.svg chromium.svg
```

`extension/Makefile`

``` makefile
build: fetch
	mkdir -p build
	inkscape --without-gui packages/chromium.svg --export-png build/chromium.png

fetch:
	./fetch

clean:
	rm -Rf build packages

.PHONY: build fetch
```

`extension/.gitignore`

``` gitignore
build
packages
```

### Configuration

Connect the configuration to the shell API:

`config.js`

``` javascript
const shell = {}
shell.port = chrome.runtime.connect('ohgecdnlcckpfnhjepfdcdgcfgebkdgl')
shell.send = (command, ...arguments) => {
  shell.port.postMessage({ command, arguments })
}
```

#### Open links

`config.js`

``` javascript
const open = (selections) => {
  const links = selections.includes(document.activeElement)
    ? selections.collection
    : [document.activeElement]
  for (const link of links) {
    shell.send('xdg-open', link.href)
  }
}

modal.map('Link', ['Alt', 'Shift', 'Enter'], () => open(selections), 'Open link in the associated application')
```

#### mpv

`config.js`

``` javascript
const mpv = ({ selections, reverse = false } = {}) => {
  const playlist = selections.includes(document.activeElement)
    ? selections.map((link) => link.href)
    : [document.activeElement.href]
  if (reverse) {
    playlist.reverse()
  }
  shell.send('mpv', ...playlist)
}

const mpvResume = () => {
  const media = player().media
  media.pause()
  shell.send('mpv', location.href, '-start', media.currentTime.toString())
}

modal.map('Video', ['Enter'], () => mpvResume(), 'Play with mpv')
modal.map('Link', ['KeyM'], () => mpv({ selections }), 'Play with mpv')
modal.map('Link', ['Alt', 'KeyM'], () => mpv({ selections, reverse: true }), 'Play with mpv in reverse order')
```

## Part 8: Tab search

> Tab search with [dmenu].

The completed extension can be downloaded [here][chrome-dmenu].

`manifest.json`

``` json
{
  // Extension ID: gonendiemfggilnopogmkafgadobkoeh
  "key": "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAhTEuT+lzy1gGMzShg7s7xadSUZdkoQh/L8c0L1hDdhDjQuB1kuCOKgExlmCAmuniea0/ZrnrnbQL154ea0HU/yWFp2ru0LmVX9ZgflVl8kQOgsb3qUz84/CkG+AyTgpqkDSuIVhb5eiAD1OW6vDCHtbda5C5/trMV3VUtItiOih4NXrUxDjw1A6ib1Fmy4DprmWJ54wI0uVrNMz7dX7+voNHwu+d7C/3EAZ7Q/8edqqHTvYXvt/5aEI85sY/z5nl1ZUVqZRlsAjuRL2j4tjDrEqcgi/pU61tzw3QvIlbwndL99/++sbrhi/sd0N2povs3JMw+tQt+sIeNMxaEZbRLQIDAQAB",
  "manifest_version": 2,
  "name": "dmenu",
  "description": "Tab search with dmenu",
  "version": "0.1.0",
  "permissions": [
    "tabs"
  ],
  "commands": {
    "tab-search": {
      "description": "Tab search",
      "suggested_key": {
        "default": "Ctrl+Q"
      }
    }
  },
  "background": {
    "scripts": [
      "background.js"
    ],
    "persistent": false
  },
  "icons": {
    "16": "build/suckless.png",
    "48": "build/suckless.png",
    "128": "build/suckless.png"
  }
}
```

See [chrome.commands] for more information.

`fetch`

``` sh
fetch https://suckless.org/logo.svg suckless.svg
```

`background.js`

``` javascript
// Extensions ──────────────────────────────────────────────────────────────────

// Shell
const shell = {}
shell.port = chrome.runtime.connect('ohgecdnlcckpfnhjepfdcdgcfgebkdgl')

// Requests ────────────────────────────────────────────────────────────────────

const requests = {}

requests['tab-search'] = () => {
  chrome.tabs.query({}, (tabs) => {
    const input = tabs.map((tab) => `${tab.id} ${tab.title} ${tab.url}`).join('\n')
    shell.port.postMessage({
      id: 'tab-search',
      command: 'rofi',
      arguments: ['-dmenu', '-i', '-p', 'Tab search'],
      input
    })
  })
}

// Responses ───────────────────────────────────────────────────────────────────

const responses = {}

responses['tab-search'] = (response) => {
  const id = parseInt(response.output)
  if (id) {
    // Does not affect whether the window is focused
    chrome.tabs.update(id, { active: true })
    chrome.tabs.get(id, (tab) => {
      chrome.windows.update(tab.windowId, { focused: true })
    })
  }
}

// Initialization ──────────────────────────────────────────────────────────────

// Commands
chrome.commands.onCommand.addListener((commandRequest) => {
  const command = requests[commandRequest]
  if (command) {
    command()
  }
})

// Requests
chrome.runtime.onConnectExternal.addListener((port) => {
  port.onMessage.addListener((request) => {
    const command = requests[request.command]
    const arguments = request.arguments || []
    if (command) {
      command(...arguments)
    }
  })
})

// Responses
shell.port.onMessage.addListener((response) => {
  const command = responses[response.id]
  if (command) {
    command(response)
  }
})
```

Update your configuration.

`config.js`

``` javascript
const dmenu = {}
dmenu.port = chrome.runtime.connect('gonendiemfggilnopogmkafgadobkoeh')
dmenu.send = (command, ...arguments) => {
  dmenu.port.postMessage({ command, arguments })
}

modal.map('Command', ['KeyQ'], () => dmenu.send('tab-search'), 'Tab search with dmenu')
```

## Part 9: Publish your extension

[Publish in the Chrome Web Store]

Update your Makefile.

`Makefile`

``` makefile
package: clean build
	zip --recurse-paths package.zip manifest.json config.js build packages

chrome-web-store: build
	mkdir -p build/chrome-web-store
	inkscape --without-gui packages/chrome.svg --export-png build/chrome-web-store/icon.png --export-width 128 --export-height 128
	inkscape --without-gui packages/chrome.svg --export-png build/chrome-web-store/screenshot.png --export-width 1280 --export-height 800

clean:
	rm -Rf build packages package.zip
```

`.gitignore`

``` gitignore
build
packages
package.zip
```

## Bonus

### Unfocus Omnibox

Open the _Search engines_ page by navigating to `chrome://settings/searchEngines`, then add a new search engine.

``` yaml
Search engine: 'Unfocus Omnibox'
Keyword: 'j'
URL: 'javascript:'
```

See also [Keyboard shortcut to deselect omnibox in Chrome].

[Keyboard shortcut to deselect omnibox in Chrome]: https://superuser.com/questions/726447/keyboard-shortcut-to-deselect-omnibox-in-chrome

### Create a theme for Chrome

The completed theme can be downloaded [here][Theme].

[Part 1]: #part-1-modal
[Getting Started]: #getting-started
[Events]: #events
[Updates]: #updates
[Part 6]: #part-6-chrome-apis

[Chrome]: https://google.com/chrome/
[Firefox]: https://mozilla.org/firefox/
[surf]: https://surf.suckless.org

[Chrome keyboard shortcuts]: https://support.google.com/chrome/answer/157179
[Firefox keyboard shortcuts]: https://support.mozilla.org/en-US/kb/keyboard-shortcuts-perform-firefox-tasks-quickly
[surf keyboard shortcuts]: https://git.suckless.org/surf/file/config.def.h.html

[Configuration for Chrome]: https://github.com/alexherbo2/chrome-configuration
[Configuration for Firefox]: https://github.com/alexherbo2/firefox-configuration
[Configuration for surf]: https://github.com/alexherbo2/surf-configuration

[Modal]: https://github.com/alexherbo2/modal.js
[Prompt]: https://github.com/alexherbo2/prompt.js
[Hint]: https://github.com/alexherbo2/hint.js
[Selection]: https://github.com/alexherbo2/selection.js
[Mouse]: https://github.com/alexherbo2/mouse.js
[Clipboard]: https://github.com/alexherbo2/clipboard.js
[Scroll]: https://github.com/alexherbo2/scroll.js
[Player]: https://github.com/alexherbo2/player.js
[Commands]: https://github.com/alexherbo2/chrome-commands
[Shell]: https://github.com/alexherbo2/chrome-shell
[chrome-dmenu]: https://github.com/alexherbo2/chrome-dmenu
[Theme]: https://github.com/alexherbo2/chrome-theme

[QWERTY]: https://en.wikipedia.org/wiki/QWERTY

[Chrome Developer Dashboard]: https://chrome.google.com/webstore/developer/dashboard
[Publish in the Chrome Web Store]: https://developer.chrome.com/webstore/publish
[User Data Directory]: https://chromium.googlesource.com/chromium/src/+/master/docs/user_data_dir.md
[Getting Started Tutorial]: https://developer.chrome.com/extensions/getstarted
[Manifest]: https://developer.chrome.com/extensions/manifest
[Manifest – Key]: https://developer.chrome.com/extensions/manifest/key
[Manifest – Icons]: https://developer.chrome.com/extensions/manifest/icons
[Declare Permissions]: https://developer.chrome.com/extensions/declare_permissions
[Content Scripts]: https://developer.chrome.com/extensions/content_scripts
[Manage Events with Background Scripts]: https://developer.chrome.com/extensions/background_pages
[Message Passing]: https://developer.chrome.com/extensions/messaging
[Cross-extension messaging]: https://developer.chrome.com/extensions/messaging#external
[Native messaging host location]: https://developer.chrome.com/extensions/nativeMessaging#native-messaging-host-location
[runtime.connect]: https://developer.chrome.com/extensions/runtime#method-connect
[runtime.connectNative]: https://developer.chrome.com/extensions/runtime#method-connectNative
[runtime.sendMessage]: https://developer.chrome.com/extensions/runtime#method-sendMessage
[runtime.sendNativeMessage]: https://developer.chrome.com/extensions/runtime#method-sendNativeMessage
[chrome.commands]: https://developer.chrome.com/extensions/commands

[keydown]: https://developer.mozilla.org/en-US/docs/Web/API/Document/keydown_event
[activeElement]: https://developer.mozilla.org/en-US/docs/Web/API/DocumentOrShadowRoot/activeElement
[blur]: https://developer.mozilla.org/en-US/docs/Web/API/Element/blur_event
[Element]: https://developer.mozilla.org/en-US/docs/Web/API/Element
[focus]: https://developer.mozilla.org/en-US/docs/Web/API/Element/focus_event
[target]: https://developer.mozilla.org/en-US/docs/Web/API/Event/target
[KeyboardEvent.code]: https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/code
[Key Values]: https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/key/Key_Values
[Modifiers]: https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/key/Key_Values#Modifier_keys
[repeat]: https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/repeat
[Node.compareDocumentPosition]: https://developer.mozilla.org/en-US/docs/Web/API/Node/compareDocumentPosition
[Regular Expressions]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Regular_Expressions
[Using shadow DOM]: https://developer.mozilla.org/en-US/docs/Web/Web_Components/Using_shadow_DOM

[Saka Key]: https://key.saka.io
[Saka Key – Scroll]: https://github.com/lusakasa/saka-key/tree/master/src/modes/command/client/commands/scroll

[Kakoune]: https://kakoune.org
[Why Kakoune]: https://kakoune.org/why-kakoune/why-kakoune.html
[Improving on the editing model]: https://kakoune.org/why-kakoune/why-kakoune.html#_improving_on_the_editing_model

[Gmail]: https://mail.google.com
[Gmail keyboard shortcuts]: https://support.google.com/mail/answer/6594

[GitHub]: https://github.com
[GitHub · Notifications]: https://github.com/notifications

[Crystal]: https://crystal-lang.org

[dmenu]: https://tools.suckless.org/dmenu/
[Rofi]: https://github.com/davatorium/rofi

[mpv]: https://mpv.io
