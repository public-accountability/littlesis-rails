#!/bin/sh
set -e

apt-get update && apt-get upgrade -y && apt-get -y install \
	                                        build-essential \
	                                        coreutils \
	                                        curl \
	                                        git \
	                                        gnupg \
	                                        grep \
	                                        imagemagick \
	                                        iproute2 \
	                                        libmagickwand-dev \
	                                        lsof \
                                                netcat \
	                                        redis-tools \
	                                        software-properties-common \
	                                        sqlite3 \
	                                        unzip \
	                                        zip \
                                                libdbus-glib-1-dev \
                                                libsqlite3-dev \
                                                postgresql-client \
                                                libmariadb-dev

# Manticore
curl -sSL https://repo.manticoresearch.com/repository/manticoresearch_buster/pool/m/manticore/manticore_3.5.4-201211-13f8d08d_amd64.deb > /tmp/manticore.deb
echo 'cb7d8105067fa5822aa7e85d11ab4208db1f1976793c1f31b621f0b148b48ee8  /tmp/manticore.deb' | sha256sum -c -
apt-get install -y /tmp/manticore.deb

# Node  & Yarn
curl -sL https://deb.nodesource.com/setup_14.x | bash -
apt-get install -y nodejs
npm install --global yarn

# Chrome and Chrome Driver
curl -L "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb" > /tmp/chrome.deb
apt-get install -y /tmp/chrome.deb && google-chrome --version
curl -L "https://chromedriver.storage.googleapis.com/88.0.4324.96/chromedriver_linux64.zip" > /tmp/chromedriver.zip
unzip /tmp/chromedriver.zip chromedriver -d /usr/bin
chown root:root /usr/bin/chromedriver && chmod +x /usr/bin/chromedriver && chromedriver --version

# Firefox and Geckodriver
curl -L "https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64&lang=en-US" | tar xjf - -C /opt
printf "#!/bin/sh\nexec /opt/firefox/firefox \$@\n" > /usr/local/bin/firefox && chmod +x /usr/local/bin/firefox && firefox -version
curl -L "https://github.com/mozilla/geckodriver/releases/download/v0.28.0/geckodriver-v0.28.0-linux64.tar.gz" | tar xzf - -C /usr/local/bin

# Clean
apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
