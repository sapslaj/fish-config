# sdkman doesn't officially support fish at this time, so this is a hack
# https://github.com/sdkman/sdkman-cli/issues/294#issuecomment-318252058
if not test -d $HOME/.sdkman
  exit
end

function sdk
  bash -c "source $HOME/.sdkman/bin/sdkman-init.sh && sdk $argv"
end

for item in $HOME/.sdkman/candidates/*
  set -gp PATH -p $item/current/bin
end
