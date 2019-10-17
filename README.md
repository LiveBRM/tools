#LiveBRM Dev Tools

Use the deploy-mysql.sh and deploy-api.sh to setup a locally running copy of the LiveBRM API

To quickly setup your own development copy of the LiveBRM API, create a directory for all assets related to the API to reside.  (This can be in the same directory as the front end, e.g.

* LiveBRM/
  * api/
  * front-end/
  * tools/


````
git clone https://github.com/LiveBRM/api.git
git clone https://github.com/LiveBRM/tools.git
cd tools
sudo ./deploy-mysql.sh
````

The deploy-mysql.sh script will output the IP address of the MySQL container, so take that and make sure you set the hostname in api/application/config/database.php.  Once that is complete, deploy the API container with

````
cd tools
./deploy_api.sh
````

The deploy-api.sh script should give you the IP address of the API container when it is finished running.  You should be able to access the API at that IP address on port 80.
