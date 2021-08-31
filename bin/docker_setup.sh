#!/bin/sh
set -e

apt-get update && apt-get upgrade -y && apt-get -y install \
	                                        build-essential \
	                                        coreutils \
	                                        curl \
	                                        git \
	                                        imagemagick \
	                                        redis-tools \
	                                        sqlite3 \
	                                        unzip \
	                                        zip \
                                                libsqlite3-dev \
                                                libgtk-3-dev \
                                                libdbus-glib-1-dev \
                                                postgresql-client \
                                                libmariadb-dev

# Manticore
curl -sSL https://repo.manticoresearch.com/repository/manticoresearch_buster/pool/m/manticore/manticore_3.6.0-210504-96d61d8bf_amd64.deb  > /tmp/manticore.deb
echo 'a9a3e20b67fa47e569a18a6742a6eba44f9c1531b138e8da8c8a9422120cf378 /tmp/manticore.deb' | sha256sum -c -
apt-get install -y /tmp/manticore.deb

# Node  & Yarn
curl -sL https://deb.nodesource.com/setup_14.x | bash -
apt-get install -y nodejs
npm install --global yarn

# Firefox and Geckodriver
curl -L "https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64&lang=en-US" | tar xjf - -C /opt
printf "#!/bin/sh\nexec /opt/firefox/firefox \$@\n" > /usr/local/bin/firefox && chmod +x /usr/local/bin/firefox && firefox -version
curl -L "https://github.com/mozilla/geckodriver/releases/download/v0.29.1/geckodriver-v0.29.1-linux64.tar.gz" | tar xzf - -C /usr/local/bin
