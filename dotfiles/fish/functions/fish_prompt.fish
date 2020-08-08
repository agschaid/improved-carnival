set -g base03  (set_color 002b36)
set -g base02  (set_color 073642)
set -g base01  (set_color 586e75)
set -g base00  (set_color 657b83)
set -g base0   (set_color 839496)
set -g base1   (set_color 93a1a1)
set -g base2   (set_color eee8d5)
set -g base3   (set_color fdf6e3)
set -g yellow  (set_color b58900)
set -g orange  (set_color cb4b16)
set -g red     (set_color dc322f)
set -g magenta (set_color d33682)
set -g violet  (set_color 6c71c4)
set -g blue    (set_color 268bd2)
set -g cyan    (set_color 2aa198)
set -g green   (set_color 859900)
          
set -l theme (command cat ~/.theme)
if test $theme = 'dark'
  set -g emphasized    $base1
  set -g content       $base0
  set -g secondary     $base01
  set -g bkg_highlight $base02
  set -g background    $base03
else
  set -g emphasized    $base01
  set -g content       $base00
  set -g secondary     $base1
  set -g bkg_highlight $base2
  set -g background    $base3
end
          
set -g battery_average (acpi | sed 's/^Battery.* \([0-9]\{1,3\}\)%.*$/\1/' | awk '{sum+= $1} END {print sum/ NR}')
          
set -g pb $secondary 
if [ "$battery_average" -gt 10 ]
  set -g lb $pb
else
  set -g lb $orange
end

switch $fish_bind_mode
  case insert
    set -g vi_sign ""
  case default
    set -g vi_sign "N"
  case replace_one
    set -g vi_sign "R"
  case visual
    set -g vi_sign "V"
  case '*'
    set -g vi_sign "?"
end

if test -n "$vi_sign" 
  set -g vi_ind "$lb┤$pb$vi_sign$lb├"
else
  set -g vi_ind "$lb───"
end

set _git_branch (command git symbolic-ref HEAD ^/dev/null | sed -e 's|^refs/heads/||')

if test -z "$_git_branch"
  set -g git_prompt ""
else
  set _git_is_dirty (command git status -s --ignore-submodules=dirty ^/dev/null)

  if test -n "$_git_is_dirty"
    set git_colour $magenta
  else
    set git_colour $green
  end

  set -l git_stash_count (git stash list | wc -l)
  if test "$git_stash_count" -gt 0
    set stash_prompt " $blue☰$git_stash_count"
  end

  set -g git_prompt "$lb├───┤$git_colour$_git_branch$stash_prompt"

end

set -l cwd (basename (prompt_pwd))
echo "$lb╭─$vi_ind──────┤$pb$cwd$git_prompt$lb│"
echo "$lb╰┤"
