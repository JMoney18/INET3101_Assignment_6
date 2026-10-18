#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
base="$PWD"
ls_bin="$base/build/coreutils-9.7/src/ls"
who_bin="$base/build/coreutils-9.7/src/whoami"
export LC_ALL=C
fixture=$(mktemp -d)
trap 'rm -rf "$fixture"' EXIT
printf 'example\n' > "$fixture/alpha.txt"
printf 'second\n' > "$fixture/beta.txt"
cd "$fixture"
printf '$ modified ls (no arguments)\n'
"$ls_bin"
"$ls_bin" > default.txt
grep -Eq '^[-d][rwxStTs-]{9} ' default.txt
printf 'PASS: no-argument output contains permissions\n'
"$ls_bin" -l > explicit.txt
# Compare a fixed operand list so temporary output files do not change listings.
"$ls_bin" alpha.txt beta.txt > default.txt
"$ls_bin" -l alpha.txt beta.txt > explicit.txt
cmp default.txt explicit.txt
printf 'PASS: default format matches -l\n'
[ "$("$ls_bin" -1 alpha.txt beta.txt)" = "$(printf 'alpha.txt\nbeta.txt')" ]
printf 'PASS: -1 overrides the long default\n'
"$ls_bin" -C alpha.txt beta.txt | grep -q 'alpha.txt.*beta.txt'
printf 'PASS: -C overrides the long default\n'
printf '\n$ modified whoami\n'
"$who_bin"
[ "$("$who_bin")" = "You are: $(/usr/bin/id -un)" ]
printf 'PASS: prefix and effective username match\n'
if "$who_bin" unexpected > /dev/null 2>&1; then
  printf 'FAIL: extra operand accepted\n'; exit 1
fi
"$who_bin" --help > /dev/null
"$ls_bin" --version | head -1
"$who_bin" --version | head -1
printf '\nALL CHECKS PASSED\n'
