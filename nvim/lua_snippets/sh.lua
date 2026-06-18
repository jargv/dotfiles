return {
  -- script {{{1
  s('script', fmt([[
    #!/usr/bin/env bash
    set -euo pipefail
    pushd "$(dirname "$0")"
    {}
    popd
  ]], {i(0)})),

  -- }}}
}
