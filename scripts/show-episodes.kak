# ## <season>
# ...
# ### <episode>
# ...
# Position: <position>
define-command show-episodes-paste-and-select %{
  execute-keys '%s^Position: <ret>lGl'
  execute-keys -draft 'o1 – 2 – 3'
  evaluate-commands -draft -itersel %{
    execute-keys -save-regs '' 'Z'
    execute-keys 'yf3;R'
    execute-keys '<a-/>^### <ret>lGlyzf2;R'
    execute-keys '<a-/>^## <ret>lGlyzf1;R'
  }
  execute-keys 'jx_'
}
