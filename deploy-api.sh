#This script takes a local api repository and builds and runs a docker
#container for testing changes made in the repo

DOCKERFILE="Dockerfile"
VHOSTFILE="default"

#Build the Dockerfile

echo "FROM ubuntu:latest"				>> $DOCKERFILE
echo "RUN apt update -y"				>> $DOCKERFILE
echo "RUN apt install nginx php-fpm php-mysql -y"	>> $DOCKERFILE
echo "COPY default /etc/nginx/sites-enabled/default"	>> $DOCKERFILE
echo "COPY ./api/ /var/www/html/"                       >> $DOCKERFILE
echo "CMD service php7.2-fpm start && /usr/sbin/nginx -g 'daemon off;'" >> $DOCKERFILE
#Build the nginx config

echo "server {"						>> $VHOSTFILE
echo "listen 80 default_server;"			>> $VHOSTFILE
echo "root /var/www/html;"				>> $VHOSTFILE
echo "index index.php index.html;"			>> $VHOSTFILE
echo "server_name _;"					>> $VHOSTFILE
echo "location / {"					>> $VHOSTFILE
echo "try_files \$uri \$uri/ =404;"			>> $VHOSTFILE
echo "}"						>> $VHOSTFILE
echo "location ~ \.php$ {"				>> $VHOSTFILE
echo "include snippets/fastcgi-php.conf;"		>> $VHOSTFILE
echo "fastcgi_pass unix:/var/run/php/php7.2-fpm.sock;"	>> $VHOSTFILE
echo "}"						>> $VHOSTFILE
echo "}"						>> $VHOSTFILE

#Build the container

docker build -t livebrm-api-dev .


#Clean up build files
#rm default Dockerfile


#Kill the previous version of this container
docker rm -f livebrm-api-dev


#Run the newly created container

docker run -itd --name=livebrm-api-dev livebrm-api-dev


#Return the container internal IP

IP="$(docker inspect livebrm-api-dev | grep "IPAddress" |\
 tail -1 | sed 's/"//g' | sed "s/^[ \t]*//" | sed 's/IPAddress: //g' |\
 sed 's/,//g')"

echo "API IP Address: " "${IP}"
