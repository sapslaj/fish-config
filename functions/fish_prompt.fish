# Based on/inspired by Tide
# https://github.com/IlanCosman/tide
#
# I'm not using Tide directly anymore for several reasons:
#   1. Tide is fast, but not fast enough.
#   2. Some behavior not customizable enough.
#   3. Unmaintained, as of February 2025.

function _fish_prompt_async
  set -f id $argv[1]
  set -f cmd $argv[2]
  if not contains $id "$_fish_prompt_async_ids"
    set -g _fish_prompt_async_ids -a $id
  end
  set -f var "_fish_prompt_async_$(echo -n $fish_pid)_$(echo -n $id)"

  if not set -q $var
    set -U $var
  end

  if set -q "$var"_repaint
    set -e "$var"_repaint
  else
    command fish -c "set $var ($cmd)" &
    builtin disown
    function refresh --on-variable $var
      functions -e (status current-function)
      set -g "$var"_repaint
      commandline -f repaint
    end
  end

  eval echo (printf '$%s' $var)
end

function _fish_prompt_cleanup --on-event fish_exit
  for id in $_fish_prompt_async_ids
    set -Ue "_fish_prompt_async_$(echo -n $fish_pid)_$(echo -n $id)"
  end
end

#function _fish_prompt_refresh --on-variable COLUMNS
#  commandline -f repaint
#end

function _fish_prompt_pwd
  set -f cols $argv[1]
  # target width is half of the terminal
  #set -f cols (math (tput cols) / 2)

  # approximate number of directories
  set -f dir_parts (count (string split '/' $PWD))

  # reduce number of full length dir parts until it fits within the target
  # width
  set -f prompt_pwd_result (prompt_pwd --full-length-dirs=$dir_parts)
  while test (string length $prompt_pwd_result) -gt $cols; and test $dir_parts -gt 1
    set -f dir_parts (math $dir_parts - 1)
    set -f prompt_pwd_result (prompt_pwd --full-length-dirs=$dir_parts)
  end

  echo -ns (set_color 89b4fa)
  # set the last dir to be a little brighter than the rest
  echo -ns (string replace -r '(.*)\/(.*)' (printf '$1/%s$2' (set_color 74c7ec)) $prompt_pwd_result)
  echo -ns (set_color normal)
end

function _fish_prompt_cmd_duration
  set -f last_command_status $argv[1]
  set -f last_command_duration $argv[2]

  if test $last_command_status -eq 0
    echo -ns (set_color fab387)
  else
    echo -ns (set_color e64553)
  end

  if test $last_command_duration -gt 1000
    echo -ns ' '
    set -f hours (math -s 0 $last_command_duration / 3600000)
    set -f minutes (math -s 0 $last_command_duration / 60000 % 60)
    set -f seconds (math -s 0 $last_command_duration / 1000 % 60)

    if test $hours -ne 0
      printf '%sh %sm %ss' $hours $minutes $seconds
    else if test $minutes -ne 0
      printf '%sm %ss' $minutes $seconds
    else
      printf '%ss' $seconds
    end
  end

  if test $last_command_status -ne 0
    echo -ns ' '
    echo -ns '✘ ' $last_command_status
  end

  echo -ns (set_color normal)
end

function fish_prompt
  # capture last command metrics for later
  set -f last_command_duration $CMD_DURATION
  set -f last_command_status $status

  set -f fish_prompt_cmd_duration (_fish_prompt_cmd_duration $last_command_status $last_command_duration)
  set -f fish_prompt_git (_fish_prompt_async git '_fish_prompt_git')
  set -f fish_prompt_right (_fish_prompt_async right '_fish_prompt_right')

  set -f fish_prompt_pwd_padding 1
  set -f fish_prompt_pwd (_fish_prompt_pwd (math $COLUMNS - $fish_prompt_pwd_padding - (string length -V "$fish_prompt_git$fish_prompt_cmd_duration$fish_prompt_right")))

  printf '\n'
  echo -ns $fish_prompt_pwd
  echo -ns $fish_prompt_git
  echo -ns $fish_prompt_cmd_duration
  echo -ns (string repeat -n (math $COLUMNS - (string length -V $fish_prompt_pwd) - (string length -V $fish_prompt_git) - (string length -V $fish_prompt_cmd_duration) - (string length -V $fish_prompt_right)) ' ')
  echo -ns $fish_prompt_right
  printf '\n'
  if test $last_command_status -eq 0
    echo -ns (set_color a6e3a1)
  else
    echo -ns (set_color f38ba8)
  end
  echo -ns '❯ ' (set_color normal)
end
