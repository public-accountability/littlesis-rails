FROM ruby:3.1.2-bullseye
LABEL maintainer="dev@littlesis.org"

RUN apt-get update && apt-get upgrade -y && apt-get -y install \
    brotli \
    build-essential \
    coreutils \
    curl \
    git \
    gnupg \
    grep \
    gzip \
    imagemagick \
    libasound2 \
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
RUN apt-get update && apt-get install -y postgresql-client-14 libpq-dev

# Manticore
RUN curl "https://repo.manticoresearch.com/manticore-repo.noarch.deb" >  /tmp/manticore-repo.noarch.deb
RUN dpkg -i /tmp/manticore-repo.noarch.deb && apt-get update && apt-get -y install manticore manticore-columnar-lib

# Node
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash -
RUN apt-get install -y nodejs
RUN npm install -g npm

# Firefox and Geckodriver
RUN curl -L "https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64&lang=en-US" | tar xjf - -C /opt
RUN printf "#!/bin/sh\nexec /opt/firefox/firefox \$@\n" > /usr/local/bin/firefox && chmod +x /usr/local/bin/firefox && firefox -version
# f5fcaf6aa1a45b06cb1cae99ff51d487173de8f776f647e18b750f7eccecbbd9
RUN curl -L "https://github.com/mozilla/geckodriver/releases/download/v0.31.0/geckodriver-v0.31.0-linux64.tar.gz" | tar xzf - -C /usr/local/bin

WORKDIR /littlesis

COPY ./Gemfile.lock ./Gemfile ./
# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1
RUN bundle install

COPY ./package.json ./package-lock.json ./
RUN npm install --includes=dev
EXPOSE 8080

CMD ["bundle", "exec", "puma"]
