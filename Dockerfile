FROM ruby:3.0.3 as base

ARG APP_ENV=prod
ARG MINDLEAPS_HOME=/mindleaps
ARG TRACKER_HOME=$MINDLEAPS_HOME/tracker

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl \
    && curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.12/gosu-$(dpkg --print-architecture)" \
    && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.12/gosu-$(dpkg --print-architecture).asc" \
    && gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && apt-get install -y --no-install-recommends \
        build-essential \
        libpq-dev \
        libxml2-dev \
        libxslt1-dev \
        xvfb \
        postgresql-client \
        nodejs \
        npm \
    && mkdir -p $TRACKER_HOME

WORKDIR $TRACKER_HOME
ADD . $TRACKER_HOME

RUN if [[ APP_ENV = "dev" ]]; then \
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | tee /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update \
    && apt-get -y install google-chrome-stable \
; fi

RUN bundle install
RUN RAILS_ENV="production" SECRET_KEY_BASE="secret" bundle exec rake assets:precompile

ENTRYPOINT ["./ENTRYPOINT.sh"]
