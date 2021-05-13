FROM ruby:3.0.1 as base
ARG APP_ENV=prod
ARG MINDLEAPS_HOME=/mindleaps
ARG TRACKER_HOME=$MINDLEAPS_HOME/tracker

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
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
        libqtwebkit4 \
        libqt4-dev \
        xvfb \
        postgresql-client-11 \
        nodejs \
        npm \
    && mkdir -p $TRACKER_HOME

RUN npm install --global yarn

WORKDIR $TRACKER_HOME
ADD . $TRACKER_HOME

RUN bundle install
CMD bundle exec rake assets:precompile && bundle exec bin/rails db:create && bundle exec bin/rails db:migrate && bundle exec bin/rails server -b 0.0.0.0
