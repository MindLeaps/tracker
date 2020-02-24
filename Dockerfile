ARG APP_ENV=dev
ARG MINDLEAPS_HOME=/mindleaps
ARG TRACKER_HOME=$MINDLEAPS_HOME/tracker

FROM ruby:2.6.4 as base
RUN apt-get update && apt-get -y --no-install-recommends install \
    ca-certificates \
    curl
RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.4/gosu-$(dpkg --print-architecture)" \
    && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.4/gosu-$(dpkg --print-architecture).asc" \
    && gpg --verify /usr/local/bin/gosu.asc \
    && rm /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu

FROM base as app
ARG MINDLEAPS_HOME
ARG TRACKER_HOME
RUN apt-get update -qq && apt-get install -y build-essential

# for postgres
RUN apt-get install -y libpq-dev

# for nokogiri
RUN apt-get install -y libxml2-dev libxslt1-dev

# for capybara-webkit
RUN apt-get install -y libqtwebkit4 libqt4-dev xvfb

RUN apt-get install -y postgresql-client-11

RUN mkdir $MINDLEAPS_HOME
WORKDIR $MINDLEAPS_HOME

RUN mkdir $TRACKER_HOME
WORKDIR $TRACKER_HOME

ADD . $TRACKER_HOME

############# DEV STAGE ################
FROM app as dev-install
# Getting Chrome so we can run feature specs in the container
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | tee /etc/apt/sources.list.d/google-chrome.list
RUN apt-get update
RUN apt-get -y install google-chrome-stable
ARG TRACKER_HOME
WORKDIR $TRACKER_HOME
RUN bundle

############# PRODUCTION STAGE ################
FROM app as prod-install
ARG TRACKER_HOME
WORKDIR $TRACKER_HOME
RUN bundle install --deployment
RUN bundle exec rake assets:precompile

############ MAIN STAGE #################
FROM ${APP_ENV}-install