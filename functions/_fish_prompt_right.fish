function _has_in_parent_dir
  set -f dir $PWD
  while true
    for f in $argv
      if path is $dir/$f
        return 0
      end
    end
    if test $dir = '/'
      return 1
    end
    set -f dir (path dirname $dir)
  end
  return 1
end

function _fish_prompt_node
  if not _has_in_parent_dir package.json
    return
  end

  if not command -q node
    return
  end

  node --version | string match -qr "v(?<v>.*)"
  echo -ns (set_color 44883E) "  $v" (set_color normal)
end

function _fish_prompt_python
  if not command -q python3; and not command -q python
    return
  end

  if _has_in_parent_dir .python-version Pipfile __init__.py pyproject.toml requirements.txt setup.py
    set -f in_python true
  end

  if test -n "$VIRTUAL_ENV"
    set -f in_python true
    set -f in_venv true
  end

  if test -n "$in_python"
    echo -ns ' ' (set_color 00AFAF) ' 󰌠 '

    if command -q python3
      python3 --version | string match -qr "(?<v>[\d.]+)"
    else
      python --version | string match -qr "(?<v>[\d.]+)"
    end

    echo "$v"

    if set -q $in_venv
      string match -qr "^.*/(?<dir>.*)/(?<base>.*)" $VIRTUAL_ENV
      if test "$dir" = virtualenvs
        string match -qr "(?<base>.*)-.*" $base
        echo "($base)"
      else if contains -- "$base" virtualenv venv .venv env # avoid generic names
        echo "($dir)"
      else
        echo "($base)"
      end
    end

    echo -ns (set_color normal)
  end
end

function _fish_prompt_java
  if not _has_in_parent_dir pom.xml build.gradle.kts build.gradle
    return
  end

  if not command -q java
    return
  end

  java -version &| string match -qr "(?<v>[\d.]+)"
  echo -ns (set_color ED8B00) "  $v" (set_color normal)
end

function _fish_prompt_kubectl
  if not _has_in_parent_dir Chart.yaml jsonnetfile.json helmfile.yaml
    return
  end

  if not command -q kubectl
    return
  end

  kubectl config view --minify --output 'jsonpath={.current-context}/{..namespace}' 2>/dev/null | read -l context &&
    echo -ns (set_color 326CE5) " 󱃾 " (string replace -r '/(|default)$' '' $context) (set_color normal)
end

function _fish_prompt_aws
  if set -q AWS_PROFILE
    echo -ns (set_color FF9900) "  $AWS_PROFILE"
    if set -q AWS_REGION
      echo -ns " / $AWS_REGION"
    end
    echo -ns (set_color normal)
  end
end

function _fish_prompt_right
  _fish_prompt_node
  _fish_prompt_python
  _fish_prompt_java
  _fish_prompt_kubectl
  _fish_prompt_aws
end
