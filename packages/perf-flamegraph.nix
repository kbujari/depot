# Script that collects perf timing for the execution of a command and
# writes a flamegraph to stdout

{
  writeShellScriptBin,
  linuxPackages,
  flamegraph,
  ...
}:

writeShellScriptBin "perf-flamegraph" ''
  set -euo pipefail

  ${linuxPackages.perf}/bin/perf record -g --call-graph dwarf -F max "$@"
  ${linuxPackages.perf}/bin/perf script \
    | ${flamegraph}/bin/stackcollapse-perf.pl \
    | ${flamegraph}/bin/flamegraph.pl
''
