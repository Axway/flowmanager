# Migrate MongoDB data

How to migrate data between different MongoDB docker containers (same MongoDB version).

Use case: _We have a MongoDB container with a custom image and we want to move data to another MongoDB container that uses an official image_.

## Dump data

`docker-compose exec -T <mongodb service> sh -c 'mongodump -u [USER] -p --archive' > db.dump`

## Restore data

`docker-compose exec -T <mongodb service> sh -c 'mongorestore -u [USER] -p --archive' < db.dump`
