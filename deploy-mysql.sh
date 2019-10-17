#!/bin/bash

#If you want to run this script to destroy an old install of
#the MySQL container, you must stop the old container first

# This script deploys and configures a Docker MySQL container
# for the LiveBRM API

#Kill the previously running container (but don't use the -f
#flag just in case invocation of this script is accidental.)
docker rm -f livebrm-mysql-dev

#Start the container
docker run --name livebrm-mysql-dev -e MYSQL_ROOT_PASSWORD=password -e MYSQL_DATABASE=livebrm -d mysql

#Write the SQL user creation scripts
echo "CREATE USER 'livebrm'@'%' IDENTIFIED WITH mysql_native_password BY 'password';" > setup_user.sql
echo "GRANT ALL PRIVILEGES ON livebrm.* TO 'livebrm'@'%';" >> setup_user.sql
echo "FLUSH PRIVILEGES;" >> setup_user.sql
echo "#!/bin/bash" > run_setup_user.sh
echo "/bin/cat /setup_user.sql | /usr/bin/mysql -u root -ppassword livebrm" >> run_setup_user.sh

docker cp setup_user.sql livebrm-mysql-dev:/setup_user.sql
docker cp run_setup_user.sh livebrm-mysql-dev:/run_setup_user.sh

sleep 20
docker exec -it livebrm-mysql-dev chmod +x /run_setup_user.sh
docker exec -it livebrm-mysql-dev /run_setup_user.sh

#Return the container internal IP

IP="$(docker inspect livebrm-mysql-dev | grep "IPAddress" |\
 tail -1 | sed 's/"//g' | sed "s/^[ \t]*//" | sed 's/IPAddress: //g' |\
 sed 's/,//g')"

echo "MySQL IP Address:" "${IP}"

rm setup_user.sql run_setup_user.sh
