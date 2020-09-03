# MongoDB - TLS/SSL

Encrypt all of MongoDB’s network traffic. TLS/SSL ensures that MongoDB network traffic is only readable by the intended client.

## docker-compose

* Go to `docker-compose/files/mongo/config` path
* Uncomment `ssl` block from `mongod.conf` file
* Change `CAFile` and `PEMKeyFile` values with yours
* Save it
* Run `docker-compose up -d` command in case you run MongoDB for the first time  or `docker-compose restart mongodb` in case you already have MongoDB up.
