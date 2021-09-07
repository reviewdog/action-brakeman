#!/bin/sh

version() {
  if [ -n "$1" ]; then
    echo "-v $1"
  fi
}

git clone https://github.skroutz.gr/security/semgrep-rules.git semgrep-rules

cd "$GITHUB_WORKSPACE"
export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

# brakeman --quiet --format tabs ${INPUT_BRAKEMAN_FLAGS} \
#   | reviewdog -f=brakeman \
#     -name="${INPUT_TOOL_NAME}" \
#     -reporter="${INPUT_REPORTER}" \
#     -filter-mode="${INPUT_FILTER_MODE}" \
#     -fail-on-error="${INPUT_FAIL_ON_ERROR}" \
#     -level="${INPUT_LEVEL}" \
#     ${INPUT_REVIEWDOG_FLAGS}
semgrep --config=p/ci --disable-version-check -o report.semgrep.tmp.json --json
cat report.semgrep.tmp.json
exit_code=$?

exit $exit_code
