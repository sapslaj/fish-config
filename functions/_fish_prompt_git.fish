function _fish_prompt_git
  # `fish_git_prompt` isn't quite flexible enough for what I want, so this is
  # Tide's git status implementation

  if git branch --show-current 2>/dev/null | string shorten -m 24 | read -l location
    git rev-parse --git-dir --is-inside-git-dir | read -fL gdir in_gdir
    set location $location
  else if test $pipestatus[1] != 0
    return
  else if git tag --points-at HEAD | string shorten -m 24 | read location
    git rev-parse --git-dir --is-inside-git-dir | read -fL gdir in_gdir
    set location '#'$location
  else
    git rev-parse --git-dir --is-inside-git-dir --short HEAD | read -fL gdir in_gdir location
    set location @$location
  end

  # Operation
  if test -d $gdir/rebase-merge
    # Turn ANY into ALL, via double negation
    if not path is -v $gdir/rebase-merge/{msgnum,end}
      read -f step <$gdir/rebase-merge/msgnum
      read -f total_steps <$gdir/rebase-merge/end
    end
    test -f $gdir/rebase-merge/interactive && set -f operation rebase-i || set -f operation rebase-m
  else if test -d $gdir/rebase-apply
    if not path is -v $gdir/rebase-apply/{next,last}
      read -f step <$gdir/rebase-apply/next
      read -f total_steps <$gdir/rebase-apply/last
    end
    if test -f $gdir/rebase-apply/rebasing
      set -f operation rebase
    else if test -f $gdir/rebase-apply/applying
      set -f operation am
    else
      set -f operation am/rebase
    end
  else if test -f $gdir/MERGE_HEAD
    set -f operation merge
  else if test -f $gdir/CHERRY_PICK_HEAD
    set -f operation cherry-pick
  else if test -f $gdir/REVERT_HEAD
    set -f operation revert
  else if test -f $gdir/BISECT_LOG
    set -f operation bisect
  end

  # Git status/stash + Upstream behind/ahead
  test $in_gdir = true && set -l _set_dir_opt -C $gdir/..
  # Suppress errors in case we are in a bare repo or there is no upstream
  set -l stat (git $_set_dir_opt --no-optional-locks status --porcelain 2>/dev/null)
  string match -qr '(0|(?<stash>.*))\n(0|(?<conflicted>.*))\n(0|(?<staged>.*))
(0|(?<dirty>.*))\n(0|(?<untracked>.*))(\n(0|(?<behind>.*))\t(0|(?<ahead>.*)))?' \
    "$(git $_set_dir_opt stash list 2>/dev/null | count
    string match -r ^UU $stat | count
    string match -r ^[ADMR] $stat | count
    string match -r ^.[ADMR] $stat | count
    string match -r '^\?\?' $stat | count
    git rev-list --count --left-right @{upstream}...HEAD 2>/dev/null)"

  if test -n "$operation$conflicted"
    set -f text_color (set_color f38ba8)
  else
    set -f text_color (set_color a6adc8)
  end

  echo -ns $text_color ' ['  $location
  echo -ns (set_color eba0ac) ' '$operation ' '$step/$total_steps
  echo -ns (set_color 89b4fa) ' ⇣'$behind ' ⇡'$ahead
  echo -ns (set_color f38ba8) ' ~'$conflicted
  echo -ns (set_color f9e2af) ' +'$staged
  echo -ns (set_color f9e2af) ' !'$dirty
  echo -ns (set_color 89dceb) ' ?'$untracked
  echo -ns $text_color ']'
  echo -ns (set_color normal)
end
