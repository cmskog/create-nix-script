{
  coreutils,
  writeShellScriptBin
}
:
writeShellScriptBin
  "create-nix-script"
  ''
  PATH=
  set \
    -o errexit \
    -o nounset \
    -o pipefail
  shopt -s shift_verbose

  usage()
  {
    local exit_value=$1
    shift

    local fmt="$1"
    shift
    fmt+='\n'

    printf "$fmt" "$@" >&2

    exit $exit_value
  }

  if [[ $# != 1 ]]
  then
    usage 1 "Usage: $0 <script name directory location>"
  fi

  SCRIPT_NAME="$1"

  if [[ -e "$SCRIPT_NAME" ]]
  then
    usage 2 "A file with the requested script name directory('%s') already exists" "$SCRIPT_NAME"
  fi

  ${coreutils}/bin/mkdir -p "$SCRIPT_NAME"

  cd "$SCRIPT_NAME"

  ${coreutils}/bin/cat <<__END__ >build.nix
  { pkgs ? import <nixpkgs> {} }:
    [
      (
        pkgs.callPackage ./. {}
      )
    ]
  __END__

  ${coreutils}/bin/cat <<__END__ >default.nix
  {
    writeShellScriptBin
  }
  :
  writeShellScriptBin
    "''${SCRIPT_NAME##*/}"
    '''
    PATH=
    set \\
      -o errexit \\
      -o nounset \\
      -o pipefail
    shopt -s shift_verbose

    echo -e "Great"'!'"\nYou managed to create your ''${SCRIPT_NAME##*/} script"
    '''
  __END__

  ${coreutils}/bin/cat <<__END__ >LICENSE
  Copyright (c) $(${coreutils}/bin/date +%Y) Carl Michael Skog

  Permission is hereby granted, free of charge, to any person obtaining
  a copy of this software and associated documentation files (the
  "Software"), to deal in the Software without restriction, including
  without limitation the rights to use, copy, modify, merge, publish,
  distribute, sublicense, and/or sell copies of the Software, and to
  permit persons to whom the Software is furnished to do so, subject to
  the following conditions:

  The above copyright notice and this permission notice shall be
  included in all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  __END__

  ${coreutils}/bin/cat <<__END__ >.gitignore
  *.swp
  *~
  /result
  /result-[2-9]
  /result-[1-9][0-9]*
  __END__
  ''
