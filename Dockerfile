FROM ruby:2.7-alpine

ENV BRAKEMAN_VERSION 4.7.2
ENV REVIEWDOG_VERSION v0.9.17

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
RUN apk add --update --no-cache build-base git
RUN wget -O - -q https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh | sh -s -- -b /usr/local/bin/ $REVIEWDOG_VERSION
RUN gem install -N brakeman:$BRAKEMAN_VERSION

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
