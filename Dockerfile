FROM ruby:3.0.2-bullseye
LABEL maintainer="dev@littlesis.org"

RUN apt-get update && apt-get upgrade -y && apt-get -y install \
    brotli \
    build-essential \
    coreutils \
    cron \
    csvkit \
    curl \
    git \
    gnupg \
    grep \
    gzip \
    imagemagick \
    libdbus-glib-1-dev \
    libgtk-3-0 \
    libmagickwand-dev \
    libsqlite3-dev \
    libx11-xcb1 \
    lsof \
    redis-tools \
    sqlite3 \
    unzip \
    zip

# Postgres
RUN curl "https://www.postgresql.org/media/keys/ACCC4CF8.asc" > /usr/share/keyrings/ACCC4CF8.asc
RUN echo "deb [signed-by=/usr/share/keyrings/ACCC4CF8.asc] http://apt.postgresql.org/pub/repos/apt bullseye-pgdg main" > /etc/apt/sources.list.d/pgdg.list
RUN apt-get update && apt-get install -y postgresql-client-13 libpq-dev

# Manticore
RUN curl -sSL https://repo.manticoresearch.com/repository/manticoresearch_buster/pool/m/manticore/manticore_3.6.0-210504-96d61d8bf_amd64.deb  > /tmp/manticore.deb
RUN echo 'a9a3e20b67fa47e569a18a6742a6eba44f9c1531b138e8da8c8a9422120cf378 /tmp/manticore.deb' | sha256sum -c -
RUN apt-get install -y /tmp/manticore.deb

# Node
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -
RUN apt-get install -y nodejs
RUN npm --global install yarn

# Firefox and Geckodriver
RUN curl -L "https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64&lang=en-US" | tar xjf - -C /opt
RUN printf "#!/bin/sh\nexec /opt/firefox/firefox \$@\n" > /usr/local/bin/firefox && chmod +x /usr/local/bin/firefox && firefox -version
RUN curl -L "https://github.com/mozilla/geckodriver/releases/download/v0.28.0/geckodriver-v0.28.0-linux64.tar.gz" | tar xzf - -C /usr/local/bin

RUN mkdir -p /littlesis
WORKDIR /littlesis

COPY ./Gemfile.lock ./Gemfile ./
RUN bundle install --jobs=2

COPY ./package.json ./
RUN yarn install

EXPOSE 8080

CMD ["bundle", "exec", "puma"]
