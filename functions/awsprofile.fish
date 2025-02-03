function awsprofile
  if test -n "$argv[1]"
    set -gx AWS_PROFILE $argv[1]
  else
    perl -nle '/\[profile (.+)\]/ && print "$1"' < "$HOME/.aws/config" | sort | fzf | read -gx AWS_PROFILE
  end
end
