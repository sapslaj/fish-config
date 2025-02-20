# Fish customizations
set -g fish_greeting
fish_config theme choose 'Catppuccin Mocha'

# Secrets
test -f "$HOME/.secrets" && source "$HOME/.secrets"

# Homebrew Configuration
if test -d /opt/homebrew/bin
  set -gx HOMEBREW_AUTO_UPDATE_SECS 315360000
  set -gx HOMEBREW_NO_ANALYTICS 1
  set -gx HOMEBREW_NO_AUTO_UPDATE 1
  set -gx HOMEBREW_NO_INSTALL_CLEANUP 1
  set -gx HOMEBREW_NO_INSTALL_UPGRADE 1
  set -gx HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK 1
  set -gp PATH -p /opt/homebrew/bin
  set -gpx LD_LIBRARY_PATH /opt/homebrew/lib
end

# other misc configs
set -gx PROMPT_TOOLKIT_COLOR_DEPTH DEPTH_4_BIT
set -gx TF_INSTALL_DIR "$HOME/.local/bin"
set -gx AWS_MFA_1PASSWORD_ITEM AWS
set -gx AWS_ROLE_SESSION_NAME "$USER"
set -gx AWS_PAGER ""
set -gx PAGER "less -R"
set -gx EDITOR nvim
set -gx GIT_EDITOR "$EDITOR"
set -gx BROWSER none
set -gx JSII_SILENCE_WARNING_UNTESTED_NODE_VERSION true
set -gx VIRTUAL_ENV_DISABLE_PROMPT true

if not contains "$HOME/.local/bin" $PATH
  set -gp PATH -p "$HOME/.local/bin"
end

# abbreviations/aliases
command -q gsed && abbr -a sed gsed
abbr -a cp cp -r
abbr -a rm rm -rf
abbr -a nd nextd
abbr -a pd prevd
abbr -a n nvim .
abbr -a l ls -lah
abbr -a k kubectl
abbr -a kctx kubectx
abbr -a kns kubens
abbr -a lg lazygit
abbr -a gg lazygit
abbr -a g git
abbr -a ga git add
abbr -a gaa git add --all
abbr -a gb git branch
abbr -a gbD git branch -D
abbr -a gbl git blame -b -w
abbr -a gbr git branch --remote
abbr -a gbs git bisect
abbr -a gbsb git bisect bad
abbr -a gbsd git bisect good
abbr -a gbsr git bisect reset
abbr -a gbss git bisect start
abbr -a gc git commit -v
abbr -a gc! git commit -v --amend
abbr -a gca git commit -v -a
abbr -a gca! git commit -v -a --amend
abbr -a gca! git commit -v -a --amend
abbr -a gcam git commit -v -a -m
abbr -a gcan! git commit -v -a --no-edit --amend
abbr -a gcans! git commit -v -a -s --no-edit --amend
abbr -a gcas git commit -v -a -s
abbr -a gcasm git commit -v -a -s -m
abbr -a gcb git checkout -b
abbr -a gcn! git commit -v --no-edit --amend
abbr -a gcl git clone
abbr -a gco git checkout
abbr -a gcor git checkout --recurse-submodules
abbr -a gcount git shortlog -sn
abbr -a gcp git cherry-pick
abbr -a gcpa git cherry-pick --abort
abbr -a gcpc git cherry-pick --continue
abbr -a gcs git commit -v -S
abbr -a gcsm git commit -v -s -m
abbr -a gcss git commit -v -s -S
abbr -a gcssm git commit -v -s -S -m
abbr -a gd git diff
abbr -a gdca git diff --cached
abbr -a gdcw git diff --cached --word-diff
abbr -a gds git diff --staged
abbr -a gdt git diff-tree --no-commit-id --name-only -r
abbr -a gdw git diff --word-diff
abbr -a gf git fetch
abbr -a gfa git fetch --all --prune --jobs=10
abbr -a gfo git fetch origin
abbr -a gl git pull
abbr -a glg git log --stat
abbr -a glgg git log --graph
abbr -a glgga log log --graph --decorate --all
abbr -a glgm git log --graph --max-count=10
abbr -a glgp git log --stat -p
abbr -a glo git log --oneline --decorate
abbr -a glog git log --oneline --decorate --graph
abbr -a gloga git log --oneline --decorate --graph --all
abbr -a gm git merge
abbr -a gma git merge --abort
abbr -a gmtl git mergetool --no-prompt
abbr -a gp git push
abbr -a gpd git push --dry-run
abbr -a gpf git push --force-with-lease
abbr -a gpf! git push --force
abbr -a gpr git pull --rebase
abbr -a grb git rebase
abbr -a grba git rebase --abort
abbr -a grbc git rebase --continue
abbr -a grbi git rebase -i
abbr -a grbo git rebase --onto
abbr -a grbs git rebase --skip
abbr -a grev git revert
abbr -a grh git reset
abbr -a grhh git reset --hard
abbr -a grm git rm
abbr -a grmc git rm --cached
abbr -a grs git restore
abbr -a grv git remote -v
abbr -a gsb git status -sb
abbr -a gsh git show
abbr -a gsi git submodule init
abbr -a gsps git show --pretty=short --show-signature
abbr -a gss git status -s
abbr -a gsta git stash push --include-untracked
abbr -a gstaa git stash apply
abbr -a gstall git stash --all
abbr -a gstc git stash clear
abbr -a gstd git stash drop
abbr -a gstl git stash list
abbr -a gstp git stash pop
abbr -a gsts git stash show --text
abbr -a gsu git submodule update
abbr -a gsw git switch
abbr -a gswc git switch -c
abbr -a gts git tag -s

abbr -a ... ../..
abbr -a .... ../../..
abbr -a ..... ../../../..
abbr -a ...... ../../../../..

function tf
  if test -f terragrunt.hcl
    terragrunt $argv
  else
    tofu $argv
  end
end

function awswhoami
  aws sts get-caller-identity $argv
  aws iam list-account-aliases $argv
end

function mkcd
  mkdir -p $argv && cd $argv
end

function gwip
  git add -A
  git rm $(git ls-files --deleted) 2> /dev/null
  git commit --no-verify --no-gpg-sign -m "wip ~ $(git rev-parse --abbrev-ref HEAD) [skip ci]"
end

function aws-export-credentials
  eval "$(aws configure export-credentials --format env)"
end

# tool setup

command -q direnv && direnv hook fish | source
command -q zoxide && zoxide init fish | source
command -q mise && mise activate fish | source

if test -d "$HOME/.bun/bin"; and not contains "$HOME/.bun/bin" $PATH
  set -gp PATH -p "$HOME/.bun/bin"
end

if test -d "$HOME/.pulumi/bin"; and not contains "$HOME/.pulumi/bin" $PATH
  set -gp PATH -p "$HOME/.pulumi/bin"
end

if command -q pyenv
  set -gx PYENV_ROOT $HOME/.pyenv
  if not contains "$PYENV_ROOT/bin" $PATH
    set -gp PATH -p $PYENV_ROOT/bin
  end
  pyenv init - fish | source
end
