FROM returntocorp/semgrep:0.59.0

ENV REVIEWDOG_VERSION v0.13.0

USER root
RUN apk update
RUN apk add ruby ruby-dev ruby-json jq bash git grep

RUN wget -O - -q https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh | sh -s -- -b /usr/local/bin/ $REVIEWDOG_VERSION

ADD https://raw.github.skroutz.gr/security/brakeman-ignore/master/yogurt/semgrep.ignore semgrep.ignore

RUN chmod 644 *.ignore
RUN mkdir semgrep-rules
RUN chown semgrep:semgrep semgrep-rules

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
