#!/usr/bin/env bash

set -e -o pipefail -u

self_dir=$(cd "$(dirname "$0")" &>/dev/null; pwd -P)
source "$self_dir"/utils.sh

python3 -m venv venv/
source venv/bin/activate
python3 setup.py install &>/dev/null
source <(git machete completion bash)

if ! declare -f __git_complete &>/dev/null; then
  # Notes:
  # * __git_complete (defined in https://github.com/git/git/blob/master/contrib/completion/git-completion.bash#L3496-L3505)
  #   is not public and is loaded by bash_completion dynamically on demand
  # * If __git_complete are not defined, then __git_complete_command and __gitcompappend are also undefined
  # * Solution is to source git completions (from one of these common locations)
  if [ -e /usr/share/bash-completion/completions/git ]; then
    source /usr/share/bash-completion/completions/git
  elif [ -f /usr/local/share/bash-completion/completions/git ]; then
    source /usr/local/share/bash-completion/completions/git
  elif [ -e /etc/bash_completion.d/git ]; then
    source /etc/bash_completion.d/git
  elif [ -e "$(brew --prefix)/etc/bash_completion.d/git-completion.bash" ]; then
    source "$(brew --prefix)/etc/bash_completion.d/git-completion.bash"
  else
    exit 1
  fi
fi

function dotest() {
  read -r -a COMP_WORDS <<< "$1"
  COMPREPLY=()
  COMP_CWORD=${#COMP_WORDS[@]}
  cur="$2"
  _git_machete
  if [[ "${COMPREPLY[*]}" != "$3" ]]; then
    die "'${COMPREPLY[*]}'\n'$3'"
  fi
}

dotest "git machete"         ""   "add  advance  anno  clean  d  delete-unmanaged  diff  discover  e  edit  file  fork-point  g  github  go  help  is-managed  l  list  log  reapply  s  show  slide-out  squash  status  t  traverse  update  version"
dotest "git machete"         "a"  "add  advance  anno"
dotest "git machete advance" "-"  "--debug  -h  --help  -v  --verbose  --version  -y  --yes"
