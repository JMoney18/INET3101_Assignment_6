#!/bin/bash
# Student-created fallback build script; not supplied by the instructor.
set -euo pipefail
cd "$(dirname "$0")"
version=9.7
archive="build/coreutils-$version.tar.xz"
source_dir="build/coreutils-$version"
mkdir -p build evidence
if [ ! -f "$archive" ]; then
  curl -fL "https://ftp.gnu.org/gnu/coreutils/coreutils-$version.tar.xz" -o "$archive"
fi
printf '%s  %s\n' e8bb26ad0293f9b5a1fc43fb42ba970e312c66ce92c1b0b16713d7500db251bf "$archive" | shasum -a 256 -c -
if [ ! -d "$source_dir" ]; then
  tar -xf "$archive" -C build
fi
# Always copy the submission sources into the build, including on rebuilds.
cp ls.c whoami.c "$source_dir/src/"
cd "$source_dir"
if [ ! -f Makefile ]; then
  ./configure --disable-nls --disable-dependency-tracking --without-gmp
fi
# Generate portability headers before requesting individual executable targets.
make -j4 -f Makefile -f - assignment-prerequisites <<'MAKE'
.PHONY: assignment-prerequisites
assignment-prerequisites: $(BUILT_SOURCES)
MAKE
make -j4 src/ls src/whoami
printf '\nBUILD SUCCESS: Coreutils %s ls and whoami\n' "$version"
