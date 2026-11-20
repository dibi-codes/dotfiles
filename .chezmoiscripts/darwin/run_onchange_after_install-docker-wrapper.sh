#!/bin/bash

set -eu

# Real file instead of a symlink, so tools invoking `docker` (e.g. az acr login) work with Apple `container`
wrapper=/opt/homebrew/bin/docker
rm -f "$wrapper"
cat >"$wrapper" <<'EOF'
#!/bin/sh
# Map common docker subcommands onto Apple `container`
cmd=$1
[ $# -gt 0 ] && shift
case $cmd in
  login|logout)            exec container registry "$cmd" "$@" ;;
  ps)                      exec container list "$@" ;;
  images)                  exec container image list "$@" ;;
  rmi)                     exec container image delete "$@" ;;
  pull|push|tag|save|load) exec container image "$cmd" "$@" ;;
  "")                      exec container ;;
  *)                       exec container "$cmd" "$@" ;;
esac
EOF
chmod +x "$wrapper"
