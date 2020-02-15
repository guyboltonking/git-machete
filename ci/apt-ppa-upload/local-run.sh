#!/usr/bin/env bash

set -e -o pipefail -u

function build_image() {
  docker-compose build --build-arg user_id="$(id -u)" --build-arg group_id="$(id -g)" apt-ppa-upload
}

cd "$(git rev-parse --show-toplevel)"/ci/apt-ppa-upload/

cat gpg-ssh.env | while read -r var; do
  [[ -n ${!var-} ]] || { echo "Var $var is missing from the environment"; exit 1; }
done

set -x

hash=$(git rev-parse HEAD:ci/apt-ppa-upload)
if git diff-index --quiet HEAD .; then
  export DIRECTORY_HASH="$hash"
  docker-compose pull apt-ppa-upload || build_image
else
  export DIRECTORY_HASH="$hash"-dirty
  build_image
fi

docker-compose up --exit-code-from=apt-ppa-upload apt-ppa-upload
