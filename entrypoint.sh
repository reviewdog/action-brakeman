#!/bin/sh

version() {
  if [ -n "$1" ]; then
    echo "-v $1"
  fi
}

if [ -n "${GITHUB_WORKSPACE}" ]
then
  git config --global --add safe.directory "${GITHUB_WORKSPACE}" || exit 1
  cd "${GITHUB_WORKSPACE}" || exit 1
fi
export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

# if 'gemfile' brakeman version selected
if [[ $INPUT_BRAKEMAN_VERSION = "gemfile" ]]; then
  # if Gemfile.lock is here
  if [[ -f 'Gemfile.lock' ]]; then
    # grep for brakeman version
    BRAKEMAN_GEMFILE_VERSION=`cat Gemfile.lock | grep -oP '^\s{4}brakeman\s\(\K.*(?=\))'`

    # if brakeman version found, then pass it to the gem install
    # left it empty otherwise, so no version will be passed
    if [[ -n "$BRAKEMAN_GEMFILE_VERSION" ]]; then
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

gem install -N brakeman $(version $BRAKEMAN_VERSION)

brakeman --quiet --format tabs ${INPUT_BRAKEMAN_FLAGS} \
  | reviewdog -f=brakeman \
    -name="${INPUT_TOOL_NAME}" \
    -reporter="${INPUT_REPORTER}" \
    -filter-mode="${INPUT_FILTER_MODE}" \
    -fail-on-error="${INPUT_FAIL_ON_ERROR}" \
    -level="${INPUT_LEVEL}" \
    ${INPUT_REVIEWDOG_FLAGS}
exit_code=$?

exit $exit_code
