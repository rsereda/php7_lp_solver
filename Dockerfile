FROM ubuntu:16.04

MAINTAINER Roman Sereda <sereda.roman@gmail.com>


RUN apt-get update && apt-get install -y \
        software-properties-common \
        git \
        curl \
        wget \
        zip && \
        locale-gen en_US.UTF-8 && export LANG=en_US.UTF-8 && \
        add-apt-repository ppa:ondrej/php -y && \
        apt-get update && \ 
        apt-get -yqq install \
        php7.0 \
        php7.0-fpm \
        php7.0-mysql \
        php7.0-xml \
        php7.0-curl \
        php7.0-gd \
        php7.0-intl \
        php7.0-json \
        php7.0-mbstring \
        php7.0-mcrypt \
        php7.0-pgsql \
        php7.0-zip \
        php-apcu \
        php-redis \
        php-yaml  \
        lp-solve \
        php-dev
#Add composer support
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php --install-dir=/usr/bin --filename=composer
RUN php -r "unlink('composer-setup.php');"
RUN sed -i -e "s|listen = /run/php/php7.0-fpm.sock|listen = 0.0.0.0:9000|g"  /etc/php/7.0/fpm/pool.d/www.conf 




##Add lp_solve support
COPY src/lp_solve_5.5 /usr/lib/lp_solve_5.5
RUN ln -s /usr/lib/lp_solve/liblpsolve55.so /usr/lib
RUN cd /usr/lib/lp_solve_5.5/lpsolve55/ && chmod +x ccc && bash ./ccc | true
RUN cd  /usr/lib/lp_solve_5.5/lp_solve && chmod +x ccc && bash ./ccc | true

RUN ln -s /usr/lib/lp_solve_5.5/lpsolve55/bin/ux64/liblpsolve55.so /usr/lib/liblpsolve5.5.so

RUN cd /usr/lib/lp_solve_5.5/extra/PHP/ && \
           phpize && \
           ./configure --enable-maintainer-zts --with-phplpsolve55=../.. && \
           make && \
           make test
RUN ln -s /usr/lib/lp_solve_5.5/extra/PHP/modules/phplpsolve55.so /usr/lib/php/20151012/phplpsolve55.so

RUN echo "extension=phplpsolve5.5.so" >> /etc/php/7.0/mods-available/lp_solve.ini
RUN ln -s /etc/php/7.0/mods-available/lp_solve.ini /etc/php/7.0/fpm/conf.d/lp_solve.ini
RUN ln -s /etc/php/7.0/mods-available/lp_solve.ini /etc/php/7.0/cli/conf.d/lp_solve.ini

EXPOSE 9000
CMD service php7.0-fpm start &&   while true; do sleep 1000; done
