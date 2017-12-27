FROM php:7.0-apache
RUN apt-get update && \
apt-get install -y wget nginx supervisor libapache2-mod-rpaf sudo git mc net-tools openssh-server mysql-client vim nano msmtp \
	cron gcc make libjpeg-dev libpng-dev libtiff-dev libvpx-dev libxpm-dev libfontconfig1-dev libxpm-dev checkinstall \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
        libxml2 \
        libxml2-dev \
        libcurl4-openssl-dev \
        libpspell-dev \
        libtidy-dev \
        libgeoip-dev \
        libxslt1-dev 

WORKDIR /usr/src
#RUN apt-get install wget -y
RUN wget https://github.com/libgd/libgd/releases/download/gd-2.1.1/libgd-2.1.1.tar.gz
RUN tar zxvf libgd-2.1.1.tar.gz
WORKDIR /usr/src/libgd-2.1.1
RUN ./configure
RUN make
RUN checkinstall --pkgname=libgd3



RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-gd=/usr/src/libgd-2.1.1/src/ \
        && docker-php-ext-install gd \
        &&  ln -s /usr/local/lib/libgd.so.3 /usr/lib/x86_64-linux-gnu/libgd.so.3


RUN docker-php-ext-install iconv mcrypt \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-gd=/usr/src/libgd-2.1.1/src/ \
    && docker-php-ext-install gd 
RUN docker-php-ext-install bcmath ctype curl dom gettext hash iconv json mbstring mysqli opcache posix pspell  session shmop simplexml  soap sockets
RUN docker-php-ext-install tidy tokenizer wddx 
RUN docker-php-ext-install xsl zip
RUN docker-php-ext-install pdo pdo_mysql 
RUN docker-php-ext-install xml  xmlrpc xmlwriter 

#RUN pecl install memcache && echo "extension=memcache.so" >> /usr/local/etc/php/conf.d/memcache.ini
RUN pecl install geoip-1.1.1  && echo "extension=geoip.so" >> /usr/local/etc/php/conf.d/geoip.ini 



RUN a2enmod rpaf rewrite
ADD apache-security.conf /etc/apache2/conf-enabled/security.conf

ADD supervisord.conf /etc/supervisor/

#RUN /usr/bin/ssh-keygen -A

RUN useradd -m -d /home/sftpdev/ -s /bin/bash -o -g 33 -u 33 sftpdev; \
    echo "sftpdev ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers; \
    echo "www-data ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers

RUN ln -s /var/www/html /home/sftpdev/html -f

RUN mkdir /var/run/sshd; chmod 0755 /var/run/sshd
RUN sed -i "s/Listen 80/Listen 81/g" /etc/apache2/ports.conf

ADD nginx.conf /etc/nginx/

RUN echo "DOCKER PHP_VERSION=$PHP_VERSION; BUILD DATE: `date -I`" > /etc/motd


RUN echo 'sendmail_path = "/usr/bin/msmtp -C /var/www/.msmtprc  -t"' > /usr/local/etc/php/conf.d/sendmail-msmtp.ini

WORKDIR /home/sftpdev

ADD start.sh /
CMD ["/start.sh"]


#RUN apt-get install wget -y
#RUN wget https://github.com/libgd/libgd/releases/download/gd-2.1.1/libgd-2.1.1.tar.gz
#RUN tar zxvf libgd-2.1.1.tar.gz
#WORKDIR /usr/src/libgd-2.1.1
#RUN apt-get install gcc make libjpeg-dev libpng-dev libtiff-dev libvpx-dev libxpm-dev libfontconfig1-dev libxpm-dev checkinstall -y
#RUN ./configure
#RUN make
#RUN checkinstall

#COMPOSER
RUN cd /home/sftpdev/ && \
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');"

RUN chown 33:33 /var/www/


#CLEAN
RUN apt-get remove -y gcc make libjpeg-dev libpng-dev libtiff-dev libvpx-dev libxpm-dev libfontconfig1-dev libxpm-dev checkinstall  libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
        libxml2-dev \
        libcurl4-openssl-dev \
        libpspell-dev \
        libtidy-dev \
        libxslt1-dev

