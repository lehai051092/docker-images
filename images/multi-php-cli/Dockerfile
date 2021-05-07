FROM debian:buster

ENV DEBIAN_FRONTEND=noninteractive

COPY config /usr/local/etc/php/conf.d/
COPY install-multi-php.sh /tmp/
COPY entrypoint.sh /entrypoint.sh

RUN apt-get update && apt-get install -y \
        curl wget gnupg2 sendmail \
        ca-certificates lsb-release \
        apt-transport-https \
        nano vim zip unzip htop rsync \
        msmtp git default-mysql-client \
        jpegoptim optipng gifsicle webp \
        openssh-client cron patch \
        build-essential \
        --no-install-recommends \
    && cd /tmp \
    && wget https://packages.sury.org/php/apt.gpg \
    && apt-key add apt.gpg \
    && echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php7.list \
    && curl -sL https://deb.nodesource.com/setup_12.x -o nodesource_setup.sh \
    && bash nodesource_setup.sh \
    && apt-get install -y nodejs --no-install-recommends \
    && npm install -g requirejs grunt-cli gulp yarn eslint jscs jscs-stylish \
    # create user dev
    && useradd -ms /bin/bash dev \
    # set password for user root
    && echo 'root:root' |chpasswd \
    && bash /tmp/install-multi-php.sh \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --version=1.10.20 --filename=composer \
    # install blackfire
    && mkdir -p /tmp/blackfire \
    && architecture=$(case $(uname -m) in i386 | i686 | x86) echo "i386" ;; x86_64 | amd64) echo "amd64" ;; aarch64 | arm64 | armv8) echo "arm64" ;; *) echo "amd64" ;; esac) \
    && curl -A "Docker" -L https://blackfire.io/api/v1/releases/client/linux/$architecture | tar zxp -C /tmp/blackfire \
    && mv /tmp/blackfire/blackfire /usr/bin/blackfire \
    && rm -Rf /tmp/blackfire \
    # install redis cli
    && cd /tmp \
    && wget http://download.redis.io/redis-stable.tar.gz \
    && mkdir -p /usr/src/redis \
    && tar -xzf redis-stable.tar.gz -C /usr/src/redis --strip-components=1 \
    && make -C /usr/src/redis install redis-cli /usr/bin \
    && rm -rf /usr/src/redis \
    # end
    # install n98-magerun2
    && wget https://files.magerun.net/n98-magerun2.phar -P /usr/local/bin \
    && chmod +x /usr/local/bin/n98-magerun2.phar \
    # end
    && git config --system core.fileMode false \
    && git config --system core.autocrlf false \
    && git config --system core.eol input \
    && git config --system credential.helper cache \
    && git config --system credential.helper 'cache --timeout=7200' \
    && apt-get -y purge build-essential php-pear \
        php5.6-dev php7.0-dev php7.1-dev php7.2-dev php7.3-dev php7.4-dev \
        unixodbc-dev \
        --auto-remove \
    && npm cache clean --force \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["bash"]

USER dev