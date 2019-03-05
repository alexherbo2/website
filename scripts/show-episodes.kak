define-command show-episodes %{ evaluate-commands -save-regs '"B' %{
  set-register B %val(bufname)
  edit! -scratch *episodes*
  evaluate-commands -draft %{
    buffer %reg(B)
    execute-keys '%1s^Position:\h+([^\n]+)$<ret>'
    evaluate-commands -draft -itersel %{
      execute-keys 'Z<a-/>^###\h+([^\n]+)<ret>1s<ret><a-Z>a<a-/>^##\h+([^\n]+)<ret>1s<ret><a-z>a'
      set-register dquote %reg(.)
      buffer *episodes*
      execute-keys '<a-o>j<a-P>)<a-space>i – <esc>'
    }
    buffer *episodes*
    execute-keys ggd
  }
  execute-keys '%|tac<ret><a-s>_'
}}
