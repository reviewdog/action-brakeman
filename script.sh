#!/bin/sh -e

if [ -n "${GITHUB_WORKSPACE}" ]
then
    git config --global --add safe.directory "${GITHUB_WORKSPACE}" || exit 1
    git config --global --add safe.directory "${GITHUB_WORKSPACE}/${INPUT_WORKDIR}" || exit 1
    cd "${GITHUB_WORKSPACE}/${INPUT_WORKDIR}" || exit 1
fi

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

TEMP_PATH="$(mktemp -d)"
PATH="${TEMP_PATH}:$PATH"

echo '::group::🐶 Installing reviewdog ... https://github.com/reviewdog/reviewdog'
curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh | sh -s -- -b "${TEMP_PATH}" "${REVIEWDOG_VERSION}" 2>&1
echo '::endgroup::'

echo '::group:: Installing brakeman with extensions ... https://github.com/presidentbeef/brakeman'
# if 'gemfile' brakeman version selected
if [ "$INPUT_BRAKEMAN_VERSION" = "gemfile" ]; then
  # if Gemfile.lock is here
  if [ -f 'Gemfile.lock' ]; then
    # grep for brakeman version
    BRAKEMAN_GEMFILE_VERSION=$(ruby -ne 'print $& if /^\s{4}brakeman\s\(\K.*(?=\))/' Gemfile.lock)

    # if brakeman version found, then pass it to the gem install
    # left it empty otherwise, so no version will be passed
    if [ -n "$BRAKEMAN_GEMFILE_VERSION" ]; then
      BRAKEMAN_VERSION=$BRAKEMAN_GEMFILE_VERSION
      else
        printf "Cannot get the brakeman's version from Gemfile.lock. The latest version will be installed."
    fi
    else
      printf 'Gemfile.lock not found. The latest version will be installed.'
  fi
  else
    # set desired brakeman version
    BRAKEMAN_VERSION=$INPUT_BRAKEMAN_VERSION
fi

gem install -N brakeman --version "${BRAKEMAN_VERSION}"
echo '::endgroup::'

echo '::group:: Running brakeman with reviewdog 🐶 ...'
BRAKEMAN_REPORT_FILE="$TEMP_PATH"/brakeman_report

# shellcheck disable=SC2086
brakeman --quiet --format tabs ${INPUT_BRAKEMAN_FLAGS} --output "$BRAKEMAN_REPORT_FILE"
reviewdog < "$BRAKEMAN_REPORT_FILE" \
  -f=brakeman \
  -name="${INPUT_TOOL_NAME}" \
  -reporter="${INPUT_REPORTER}" \
  -filter-mode="${INPUT_FILTER_MODE}" \
  -fail-on-error="${INPUT_FAIL_ON_ERROR}" \
  -level="${INPUT_LEVEL}" \
  "${INPUT_REVIEWDOG_FLAGS}"

exit_code=$?
echo '::endgroup::'

exit $exit_code
