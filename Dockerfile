FROM docker.io/library/ruby:3.1.4-bookworm
LABEL maintainer="dev@littlesis.org"
ARG RAILS_ENV=$RAILS_ENV

RUN apt-get update && apt-get upgrade -y && apt-get -y install \
    nodejs npm \
    brotli build-essential coreutils curl git grep gzip imagemagick libmagickwand-dev libpq-dev libsqlite3-dev postgresql-client rclone rsync sqlite3 unzip zip

RUN curl "https://repo.manticoresearch.com/manticore-repo.noarch.deb" >  /tmp/manticore-repo.noarch.deb \
    && dpkg -i /tmp/manticore-repo.noarch.deb && apt-get update && apt-get -y install manticore manticore-extra

# development extras, install latest firefox and geckodriver into /usr/local/bin
RUN if [ $RAILS_ENV = "development" ];then \
    apt-get -y install firefox-esr chromium redis-tools \
    && curl -L "https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64&lang=en-US" | tar xjf - -C /opt \
    && ln -s /opt/firefox/firefox /usr/local/bin/firefox \
    && curl -L "https://github.com/mozilla/geckodriver/releases/download/v0.33.0/geckodriver-v0.33.0-linux64.tar.gz" | tar xzf - -C /usr/local/bin \
    && firefox --version && geckodriver --version; fi

WORKDIR /littlesis

## gems

# throw errors if Gemfile has been modified since Gemfile.lock
RUN if [ $RAILS_ENV = "production" ]; then \
    bundle config --global frozen 1; fi

COPY /Gemfile.lock ./Gemfile ./
RUN bundle install

## node modules

# ensure package-lock in production
RUN if [ $RAILS_ENV = "production" ]; then \
    npm config set package-lock-only 'true'; fi

COPY ./package.json ./package-lock.json ./
RUN npm ci

EXPOSE 8080
CMD /littlesis/bin/puma
