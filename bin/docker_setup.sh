#!/bin/sh
set -e

# This is roughly the same as littlesis-main/litltesis.docker,
# except written as a script

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
                                                libsqlite3-dev


# MariaDB client
apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
add-apt-repository 'deb [arch=amd64,i386,ppc64el] http://nyc2.mirrors.digitalocean.com/mariadb/repo/10.5/debian buster main'
apt-get update && apt-get -y install mariadb-client libmariadb-dev

# Manticore
curl -sSL https://github.com/manticoresoftware/manticoresearch/releases/download/3.4.2/manticore_3.4.2-200410-69033058-release.buster_amd64-bin.deb > /tmp/manticore.deb
echo '2e0af4aaf7b96934c9c71bffb83db2a51999b50ce463fb0c624b722ad489f07e /tmp/manticore.deb' | sha256sum -c -
apt-get install -y /tmp/manticore.deb

# Node
curl -sL https://deb.nodesource.com/setup_14.x | bash -
apt-get install -y nodejs

# Yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
add-apt-repository "deb https://dl.yarnpkg.com/debian/ stable main"
apt-get update && apt-get -y install yarn

# Chrome and Chrome Driver
curl -L "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb" > /tmp/chrome.deb
apt-get install -y /tmp/chrome.deb && google-chrome --version
curl -L "https://chromedriver.storage.googleapis.com/88.0.4324.27/chromedriver_linux64.zip" > /tmp/chromedriver.zip
unzip /tmp/chromedriver.zip chromedriver -d /usr/bin
chown root:root /usr/bin/chromedriver && chmod +x /usr/bin/chromedriver && chromedriver --version

# Firefox and Geckodriver
curl -L "https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64&lang=en-US" | tar xjf - -C /opt
printf "#!/bin/sh\nexec /opt/firefox/firefox \$@\n" > /usr/local/bin/firefox && chmod +x /usr/local/bin/firefox && firefox -version
curl -L "https://github.com/mozilla/geckodriver/releases/download/v0.28.0/geckodriver-v0.28.0-linux64.tar.gz" | tar xzf - -C /usr/local/bin

# Clean
apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
