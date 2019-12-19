set -g __fish_git_prompt_show_informative_status 1
set -g __fish_git_prompt_hide_untrackedfiles 1

set -g __fish_git_prompt_color_branch magenta bold
set -g __fish_git_prompt_showupstream "informative"
set -g __fish_git_prompt_char_upstream_ahead "↑"
set -g __fish_git_prompt_char_upstream_behind "↓"
set -g __fish_git_prompt_char_upstream_prefix ""

set -g __fish_git_prompt_char_stagedstate "●"
set -g __fish_git_prompt_char_dirtystate "✚"
set -g __fish_git_prompt_char_untrackedfiles "…"
set -g __fish_git_prompt_char_conflictedstate "✖"
set -g __fish_git_prompt_char_cleanstate "✔"

set -g __fish_git_prompt_color_dirtystate blue
set -g __fish_git_prompt_color_stagedstate yellow
set -g __fish_git_prompt_color_invalidstate red
set -g __fish_git_prompt_color_untrackedfiles $fish_color_normal
set -g __fish_git_prompt_color_cleanstate green bold

function fish_prompt --description 'Write out the prompt'
  set -l last_status $status

  if not set -q __fish_prompt_hostname
    set -g __fish_prompt_hostname (hostname)
  end

  set_color -o red
  echo -n -s "$USER" @ "$__fish_prompt_hostname" " "

  set_color $fish_color_cwd
  echo -n (prompt_pwd)
  set_color normal

  __informative_git_prompt

  if not test $last_status -eq 0
    set_color $fish_color_error
  end

  echo -n ' $ '
end


fish_vi_key_bindings

if test -d /snap/bin
    set -g -x PATH /snap/bin $PATH
end

if test -d $HOME/bin
    set -g -x PATH $HOME/bin $PATH
end

if test -d $HOME/.local/bin
    set -g -x PATH $HOME/.local/bin $PATH
end

set -g -x TERM xterm-256color
set -g -x EDITOR vim

# use "most" instead of "vimpager" because sometimes it does not work.
set -g -x MANPAGER most

set -g -x CCACHE_CONFIGPATH ~/.ccache/ccache.conf

alias less=$PAGER
alias more=$PAGER

#set -g -x LANGUAGE en_US.UTF-8
#set -g -x LC_ALL en_US.UTF-8

set -g -x TZ `Asia/Taipei`

umask 022

