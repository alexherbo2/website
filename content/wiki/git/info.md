---
title: GitInfo
description: Git Cheat Sheet
date: 2019-03-28
---

{{< table-of-contents >}}

## Root

```
git rev-parse --show-toplevel
```

## Git directory

```
git rev-parse --git-dir
```

You can use its exit status to determine if the current directory is a Git repository.

## Branch

```
git rev-parse --abbrev-ref HEAD
```

`HEAD` indicates a detached head.

## Commit

```
git rev-parse [--short] HEAD
```

You can use its exit status to ask if there is at least one commit.

## Stashes

```
git stash list
```

You can use `wc [--lines -l]` to count stashes.

## Rebasing

```
.git
├── rebase-apply
│  └── …
└── rebase-merge
   └── …
```

Is rebasing if `rebase-apply` or `rebase-merge` directories exist.

## Porcelain

```
git status --porcelain
```

Porcelain format:

The `[1][2]` is a two-letter status code.

```
[1][2]
 │  │
 │  └── Status
 └───── Status (Cached)
```

Status code:

```
␣ → Unmodified
M → Modified
A → Added
D → Deleted
R → Renamed
C → Copied
U → Updated but unmerged
?? → Untracked
!! → Ignored
```

### Modified

```
[*][M]
```

### Added

```
[A][␣]
```

### Deleted

```
[*][D]
```

### Untracked

```
[?][?]
```

### Modifications

```
[*][M]
[*][A]
[*][D]
[*][?]
```

### Unstaged changes

```
[*][Not ␣]
```

### Ready to commit

```
[*][␣]
```

### Merge conflicts

```
[U][U]
```

## Icons

### Git (<i class="fab fa-github-alt"></i>)

``` yaml
Glyph: 
HTML: <i class="fab fa-github-alt"></i>
Page: https://fontawesome.com/icons/github-alt
```

### New (•)

``` yaml
Glyph: •
Page: https://unicode-table.com/en/2022/
```

### Untracked branch (<i class="fas fa-anchor"></i>)

``` yaml
Glyph: 
HTML: <i class="fas fa-anchor"></i>
Page: https://fontawesome.com/icons/anchor
```

### Push (<i class="fas fa-angle-double-down"></i>)

``` yaml
Glyph: 
HTML: <i class="fas fa-angle-double-down"></i>
Page: https://fontawesome.com/icons/angle-double-down
```

### Pull (<i class="fas fa-angle-double-up"></i>)

``` yaml
Glyph: 
HTML: <i class="fas fa-angle-double-up"></i>
Page: https://fontawesome.com/icons/angle-double-up
```

### Untracked (<i class="fas fa-tint"></i>)

``` yaml
Glyph: 
HTML: <i class="fas fa-tint"></i>
Page: https://fontawesome.com/icons/tint
```

### Modified (<i class="fas fa-pencil-alt"></i>)

``` yaml
Glyph: 
HTML: <i class="fas fa-pencil-alt"></i>
Page: https://fontawesome.com/icons/pencil-alt
```

### Added (<i class="fas fa-plus"></i>)

``` yaml
Glyph: 
HTML: <i class="fas fa-plus"></i>
Page: https://fontawesome.com/icons/plus
```

### Deleted (<i class="fas fa-minus"></i>)

``` yaml
Glyph: 
HTML: <i class="fas fa-minus"></i>
Page: https://fontawesome.com/icons/minus
```

### Ready (<i class="fas fa-sign-out-alt"></i>)

``` yaml
Glyph: 
HTML: <i class="fas fa-sign-out-alt"></i>
Page: https://fontawesome.com/icons/sign-out-alt
```

### Rebase (<i class="fas fa-wrench"></i>)

``` yaml
Glyph: 
HTML: <i class="fas fa-wrench"></i>
Page: https://fontawesome.com/icons/wrench
```

### Merge (<i class="fas fa-code-branch"></i>)

``` yaml
Glyph: 
HTML: <i class="fas fa-code-branch"></i>
Page: https://fontawesome.com/icons/code-branch
```

### Diverged (<i class="fas fa-code-branch"></i>)

``` yaml
Glyph: 
HTML: <i class="fas fa-code-branch"></i>
Page: https://fontawesome.com/icons/code-branch
```

### Detached (<i class="fas fa-unlink"></i>)

``` yaml
Glyph: 
HTML: <i class="fas fa-unlink"></i>
Page: https://fontawesome.com/icons/unlink
```

### Stashes (<i class="fas fa-hourglass-start"></i>)

``` yaml
Glyph: 
HTML: <i class="fas fa-hourglass-start"></i>
Page: https://fontawesome.com/icons/hourglass-start
```

### Tags (<i class="fas fa-tag"></i>)

``` yaml
Glyph: 
HTML: <i class="fas fa-tag"></i>
Page: https://fontawesome.com/icons/tag
```
