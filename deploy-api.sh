#This script takes a local api repository and builds and runs a docker
#container for testing changes made in the repo

#Updated to use apache because nginx doesn't easily cooperate with CI
#route rewrites

DOCKERFILE="../Dockerfile"
APACHECONFIG="../000-default.conf"

#Build the Dockerfile

cat > $DOCKERFILE <<- EOM
FROM ubuntu:latest
ENV DEBIAN_FRONTEND noninteractive
RUN apt update -y
RUN apt install apache2 libapache2-mod-php -qy
RUN apt install php-pear php-fpm php-dev php-zip php-curl php-xmlrpc php-gd php-mysql php-mbstring php-xml -qy
RUN a2enmod proxy_fcgi setenvif
RUN a2enconf php7.2-fpm
RUN a2enmod rewrite
COPY 000-default.conf /etc/apache2/sites-available/
COPY ./api/ /var/www/api
CMD service php7.2-fpm start && apachectl -DFOREGROUND
EOM

#Build the apache config

cat > $APACHECONFIG <<- EOM
<VirtualHost *:80>
	<Directory "/var/www/api">
		Options Indexes FollowSymLinks MultiViews
		AllowOverride All
		Order allow,deny
		allow from all
		Require all granted
	</Directory>
	ServerAdmin justinmarmorato@gmail.com
	DocumentRoot /var/www/api
	ErrorLog ${APACHE_LOG_DIR}/error.log
	CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOM

#Build the container

cd ../
docker build -t livebrm-api-dev-apache .

#Clean up build files
rm Dockerfile 000-default.conf

#Kill the previous version of this container
docker rm -f livebrm-api-dev-apache

#Run the newly created container

docker run -itd --name=livebrm-api-dev-apache livebrm-api-dev-apache

#Return the container internal IP

IP="$(docker inspect livebrm-api-dev-apache | grep "IPAddress" |\
 tail -1 | sed 's/"//g' | sed "s/^[ \t]*//" | sed 's/IPAddress: //g' |\
 sed 's/,//g')"

echo "API IP Address: " "${IP}"
