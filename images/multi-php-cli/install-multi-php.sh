#!/bin/bash
set -e

php_versions=(
	5.6
	7.0
	7.1
	7.2
	7.3
	7.4
)
architecture=$(case $(uname -m) in i386 | i686 | x86) echo "i386" ;; x86_64 | amd64) echo "amd64" ;; aarch64 | arm64 | armv8) echo "arm64" ;; *) echo "amd64" ;; esac)

cd /tmp
curl -O https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz \
    && tar zxvf ioncube_loaders_lin_x86-64.tar.gz

for php in "${php_versions[@]}"
do :
   	apt-get install -y \
   		php$php-cli php$php-common php$php-gd php$php-mysql php$php-sockets \
        php$php-curl php$php-intl php$php-xsl php$php-mbstring php$php-zip php$php-redis \
        php$php-bcmath php$php-iconv php$php-soap php$php-opcache php$php-mysqli \
        --no-install-recommends

    cp "./ioncube/ioncube_loader_lin_$php.so" "$(php$php -r "echo ini_get ('extension_dir');")/ioncube.so"

    version=$(php$php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;")
    curl -A "Docker" -o /tmp/blackfire-probe.tar.gz -D - -L -s https://blackfire.io/api/v1/releases/probe/php/linux/$architecture/$version \
    && mkdir -p /tmp/blackfire \
    && tar zxpf /tmp/blackfire-probe.tar.gz -C /tmp/blackfire \
    && mv /tmp/blackfire/blackfire-*.so $(php$php -r "echo ini_get ('extension_dir');")/blackfire.so \
    && rm -rf /tmp/blackfire /tmp/blackfire-probe.tar.gz

    if [[ "$php" == "5.6" || "$php" == "7.0" || "$php" == "7.1" ]]
    then
        apt-get install -y php$php-mcrypt --no-install-recommends
    fi

    xdebug_version=2.9.8
    if [[ "$php" == "5.6" ]]
    then
        xdebug_version=2.5.5
    elif [[ "$php" == "7.0" ]]
    then
        xdebug_version=2.7.2
    fi

    # install xdebug old version
    apt-get install -y php$php-dev --no-install-recommends
    cd /tmp
    wget "https://xdebug.org/files/xdebug-$xdebug_version.tgz" -O "xdebug-$xdebug_version.tgz"
    tar -xzf xdebug-$xdebug_version.tgz
    cd xdebug-$xdebug_version
    /usr/bin/phpize$php
    ./configure --enable-xdebug --with-php-config=/usr/bin/php-config$php
    make
    make install
    cd /tmp
    rm -rf xdebug-$xdebug_version.tgz xdebug-$xdebug_version
    # end install xdebug

    cp -rf /usr/local/etc/php/conf.d/xdebug2.ini /etc/php/$php/cli/conf.d/20-xdebug.ini
    ln -s /usr/local/etc/php/conf.d/custom.ini /etc/php/$php/cli/conf.d/00-custom.ini
done

# install mssql extension
curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list
apt-get update
apt-get install -y php-pear --no-install-recommends
ACCEPT_EULA=Y apt-get install -y msodbcsql17 unixodbc-dev mssql-tools --no-install-recommends
export PHP_SUFFIXES="7.3 7.4"
for v in $PHP_SUFFIXES; do
  pecl -d php_suffix="$v" install sqlsrv
  pecl -d php_suffix="$v" install pdo_sqlsrv
  # This does not remove the extensions; it just removes the metadata that says
  # the extensions are installed.
  pecl uninstall -r sqlsrv
  pecl uninstall -r pdo_sqlsrv
  printf "; priority=20\nextension=sqlsrv.so\n" > /etc/php/"$v"/cli/conf.d/20-sqlsrv.ini
  printf "; priority=30\nextension=pdo_sqlsrv.so\n" > /etc/php/"$v"/cli/conf.d/30-pdo_sqlsrv.ini
done
#Create symlinks for tools
ln -sfn /opt/mssql-tools/bin/sqlcmd /usr/bin/sqlcmd
ln -sfn /opt/mssql-tools/bin/bcp /usr/bin/bcp
