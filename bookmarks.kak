declare-option str bookmarks_path %sh{echo $HOME/.local/share/bookmarks.kak}
declare-option -hidden int bookmarks_current_line

define-command bookmarks-init %{
  nop %sh{
    mkdir -p ~/.local/share
  }
}

define-command bookmarks-open %{
  edit -scratch *bookmarks*
  execute-keys "!cat %opt{bookmarks_path}<ret>;dgg"
  add-highlighter window/bookmarks ref bookmarks
  map buffer normal <ret> ':bookmarks-jump<ret>'
}

define-command bookmarks-jump %{
  evaluate-commands %{
    execute-keys 'xs^((?:\w:)?[^:]+):(\d+):(\d+)?<ret>'
    set-option buffer bookmarks_current_line %val{cursor_line}
    evaluate-commands -verbatim -- edit -existing %reg{1} %reg{2} %reg{3}
  }
}

define-command bookmarks-add -params 1 %{
  nop %sh{
    echo "$kak_buffile:$kak_cursor_line:$kak_cursor_column:$1" >> $kak_opt_bookmarks_path
  }
}

define-command bookmarks-add-prompt %{
  prompt bookmark: %{
    bookmarks-add %val{text}
  }
}

add-highlighter shared/bookmarks group
add-highlighter shared/bookmarks/lines regex "^((?:\w:)?[^:\n]+):(\d+):(\d+)?" 1:cyan 2:green 3:green
add-highlighter shared/bookmarks/current line %{%opt{bookmarks_current_line}} default+b

declare-user-mode bookmarks
map global bookmarks <ret> ':bookmarks-add-prompt<ret>' -docstring 'add a bookmark'
map global bookmarks l     ':bookmarks-open<ret>'       -docstring 'open bookmarks'
