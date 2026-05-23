#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -f "$SCRIPT_DIR/Gemfile" && -f "$SCRIPT_DIR/_config.yml" ]]; then
  SITE_DIR="$SCRIPT_DIR"
elif [[ -f "$SCRIPT_DIR/new_website_repo/Gemfile" && -f "$SCRIPT_DIR/new_website_repo/_config.yml" ]]; then
  SITE_DIR="$SCRIPT_DIR/new_website_repo"
else
  echo "Could not find Jekyll site directory." >&2
  echo "Looked in: $SCRIPT_DIR and $SCRIPT_DIR/new_website_repo" >&2
  exit 1
fi

HOST="${HOST:-0.0.0.0}"
PORT="${PORT:-4000}"
BROWSER_HOST="${BROWSER_HOST:-$HOST}"

if [[ "$BROWSER_HOST" == "0.0.0.0" ]]; then
  BROWSER_HOST="127.0.0.1"
fi

URL="http://$BROWSER_HOST:$PORT/"
LIVERELOAD="${LIVERELOAD:-0}"
LOCAL_GEM_DIR="${LOCAL_GEM_DIR:-$SITE_DIR/.gem-jekyll3}"

JEKYLL_ARGS=(serve --host "$HOST" --port "$PORT")

if [[ "$LIVERELOAD" == "1" ]]; then
  JEKYLL_ARGS+=(--livereload)
fi

has_bundler() {
  command -v bundle >/dev/null 2>&1 || ruby -rbundler -e 'exit 0' >/dev/null 2>&1
}

run_bundle() {
  if command -v bundle >/dev/null 2>&1; then
    bundle "$@"
  else
    ruby -rbundler -rbundler/cli -e 'Bundler::CLI.start(ARGV)' -- "$@"
  fi
}

exec_bundle() {
  if command -v bundle >/dev/null 2>&1; then
    exec bundle "$@"
  else
    exec ruby -rbundler -rbundler/cli -e 'Bundler::CLI.start(ARGV)' -- "$@"
  fi
}

open_preview() {
  sleep 2

  if [[ "${OPEN_BROWSER:-1}" == "0" ]]; then
    return
  fi

  if command -v xdg-open >/dev/null 2>&1; then
    xdg-open "$URL" >/dev/null 2>&1 || true
  elif command -v open >/dev/null 2>&1; then
    open "$URL" >/dev/null 2>&1 || true
  elif command -v wslview >/dev/null 2>&1; then
    wslview "$URL" >/dev/null 2>&1 || true
  fi
}

serve_with_local_jekyll() {
  if [[ ! -x "$LOCAL_GEM_DIR/bin/jekyll" ]]; then
    return 1
  fi

  export GEM_HOME="$LOCAL_GEM_DIR"
  export GEM_PATH="$LOCAL_GEM_DIR"
  export PATH="$LOCAL_GEM_DIR/bin:$PATH"
  export JEKYLL_NO_BUNDLER_REQUIRE=true

  echo "Using repo-local Jekyll gems from $LOCAL_GEM_DIR"
  open_preview &
  exec jekyll "${JEKYLL_ARGS[@]}"
}

cd "$SITE_DIR"

echo "Starting preview server at $URL"
echo "Set PORT=4001 or HOST=127.0.0.1 to override defaults."
echo "Set OPEN_BROWSER=0 to skip opening the browser."
echo "Set LIVERELOAD=1 to enable Jekyll live reload."

if [[ "${USE_BUNDLE:-0}" != "1" ]]; then
  serve_with_local_jekyll || true
fi

if ! has_bundler; then
  echo "Could not find a working Bundler command or repo-local Jekyll install." >&2
  echo "Install Bundler with: gem install --user-install bundler" >&2
  echo "Or install project gems with: gem install --install-dir .gem-jekyll3 jekyll jekyll-sitemap webrick" >&2
  exit 1
fi

export BUNDLE_PATH="${BUNDLE_PATH:-$SITE_DIR/.bundle/gems}"

if ! run_bundle check >/dev/null 2>&1; then
  echo "Installing missing Ruby gems into $BUNDLE_PATH..."
  run_bundle install
fi

open_preview &
exec_bundle exec jekyll "${JEKYLL_ARGS[@]}"
