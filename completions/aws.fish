if not command -q aws; or not command -q aws_completer
  exit
end

function __fish_complete_aws
  env COMP_LINE=(commandline -pc) aws_completer | tr -d ' '
end

complete -c aws -f -a "(__fish_complete_aws)"
