#!/usr/bin/env bash
# derived from install script in https://github.com/sstephenson/bats
set -e

resolve_link() {
  $(type -p greadlink readlink | head -1) "$1"
}

abs_dirname() {
  local cwd="$(pwd)"
  local path="$1"

  while [ -n "$path" ]; do
    cd "${path%/*}"
    local name="${path##*/}"
    path="$(resolve_link "$name" || true)"
  done

  pwd
  cd "$cwd"
}

PREFIX="$1"
if [ -z "$1" ]; then
  { echo "usage: $0 <prefix>"
    echo "  e.g. $0 /usr/local"
  } >&2
  exit 1
fi

API_BUILDER_ROOT="$(abs_dirname "$0")"
mkdir -p "$PREFIX"/{bin,src}
cp -R "$API_BUILDER_ROOT"/bin/* "$PREFIX"/bin
cp -R "$API_BUILDER_ROOT"/src/* "$PREFIX"/src

eval "./util/update-library-path.rb $PREFIX/bin/apibuilder ${PREFIX}/src/apibuilder-cli.rb"
eval "./util/update-library-path.rb $PREFIX/bin/read-config ${PREFIX}/src/apibuilder-cli.rb"
eval "./util/update-library-path.rb $PREFIX/bin/create-config ${PREFIX}/src/apibuilder-cli.rb"
eval "chmod +x $PREFIX/bin/apibuilder"
eval "chmod +x $PREFIX/bin/read-config"
eval "chmod +x $PREFIX/bin/create-config"

echo "Installed API_BUILDER_CLI to $PREFIX/bin/apibuilder"

