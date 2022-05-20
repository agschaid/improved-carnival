set -l last_status $status

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
set -g lb $pb

set -g battery_color false

if [ "$battery_average" -lt 10 ]
  set -g lb $orange
  set -g battery_color true
end
if [ "$battery_average" -lt 5 ]
  set -g lb $red
  set -g battery_color true
end

set -g bb $lb

jobs -q
set -l jobs_status $status
if test $jobs_status -eq 0
  set -g bb $green
  if test $battery_color = false
    set -g lb $green
  end
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
  set -g vi_ind "$bb───"
end

set _git_branch (command git symbolic-ref HEAD 2>/dev/null | sed -e 's|^refs/heads/||')

set separation_element "$lb├$bb───$lb┤"

if test -z "$_git_branch"
  set -g git_prompt ""
else
  set _git_is_dirty (command git status -s --ignore-submodules=dirty 2>/dev/null)

  if test -n "$_git_is_dirty"
    set git_colour $magenta
  else
    set git_colour $green
  end

  set -l git_stash_count (git stash list | wc -l)
  if test "$git_stash_count" -gt 0
    set stash_prompt " $blue☰$git_stash_count"
  end

  set -g git_prompt "$separation_element$git_colour$_git_branch$stash_prompt"

end

set -l cwd (basename (prompt_pwd))

set -g status_prompt ""
if test $last_status != 0
  set -l x_symbol "⨯"
  set -g status_prompt "$separation_element$violet$x_symbol $red$last_status"
end

set -g duration_prompt ""
# commant took longer than 1 second
if [ "$CMD_DURATION" -gt 1000 ]
  set -l duration_symbol "⟳"
  set -l seconds (math $CMD_DURATION / 1000)
  set -g duration_prompt "$separation_element$violet$duration_symbol $cyan$seconds"
  set -g CMD_DURATION 0
end


set -l ze_time (date "+$secondary%H:%M$bkg_highlight:%S")

echo "$bb╭─$vi_ind$bb───$lb┤$pb$cwd$git_prompt$status_prompt$duration_prompt$lb│   $ze_time"
echo "$bb╰$lb┤"
