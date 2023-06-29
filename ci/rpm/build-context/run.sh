#!/usr/bin/env bash

set -e -o pipefail -u

if ! ( [ -f setup.py ] && grep -q "name='git-machete'" setup.py ); then
  echo "Error: the repository should be mounted as a volume under $(pwd)"
  exit 1
fi

python3 setup.py bdist_rpm
rpm -i dist/git-machete-*.rpm
git machete version
git machete completion bash  # to check if completion files are available in the runtime
