#Base OS
FROM ubuntu:18.04
#nstalling nginx
RUN apt-get update && apt-get upgrade -y && apt install -y nginx

# to avoid asking country confirmation to yes
ARG DEBIAN_FRONTEND=noninteractive
#RUN apt install -y php7.2 php7.2-fpm php7.2-common php7.2-mysql php7.2-gd php7.2-cli
RUN apt install software-properties-common -y && add-apt-repository ppa:ondrej/php -y && apt update -y && apt install php7.2 php7.2-fpm php7.2-common php7.2-mysql php7.2-xml php7.2-xmlrpc php7.2-curl php7.2-gd php7.2-imagick php7.2-cli php7.2-dev php7.2-imap php7.2-mbstring php7.2-opcache php7.2-soap php7.2-zip unzip -y

#Configure Nginx
RUN rm /etc/nginx/sites-available/default 
RUN rm /etc/nginx/sites-enabled/default 
COPY default /etc/nginx/sites-available/default
RUN ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled 

#install and Configure supervisord
RUN apt-get install -y supervisor mysql-server
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

#Enable php configuratin
COPY php.ini /etc/php/7.2/cli/php.ini
#COPY gzip.conf /etc/supervisor/conf.d/gzip.conf
COPY www.conf /etc/php/7.2/fpm/pool.d/www.conf
#creating  process ID file and directory by default it wont be there
RUN mkdir /var/run/php && touch /var/run/php/php7.2-fpm.pid

# init script
COPY init_script.sh /init_script.sh
RUN chmod +x /init_script.sh

# COPY Spacecraft files
COPY --chown=www-data:www-data development/.  /var/www/html/
#RUN chmod -R 755 /var/www/html

# Expose Ports
EXPOSE 443 80

CMD ["/bin/sh", "/init_script.sh"]

