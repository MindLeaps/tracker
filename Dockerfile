FROM ruby:2.7.1 as base
ARG APP_ENV=prod
ARG MINDLEAPS_HOME=/mindleaps
ARG TRACKER_HOME=$MINDLEAPS_HOME/tracker

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.4/gosu-$(dpkg --print-architecture)" \
    && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.4/gosu-$(dpkg --print-architecture).asc" \
    && gpg --verify /usr/local/bin/gosu.asc \
    && rm /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && apt-get install -y --no-install-recommends \
        build-essential \
        libpq-dev \
        libxml2-dev \
        libxslt1-dev \
        libqtwebkit4 \
        libqt4-dev \
        xvfb \
        postgresql-client-11 \
    && mkdir -p $TRACKER_HOME

WORKDIR $TRACKER_HOME
ADD . $TRACKER_HOME

RUN if [ "$APP_ENV" = "dev" ]; then \
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | tee /etc/apt/sources.list.d/google-chrome.list \
    && apt-get -y install google-chrome-stable \
    && bundle \
; elif [ "$APP_ENV" = "prod" ]; then \
    bundle install --deployment \
    && bundle exec rake assets:precompile \
; fi

