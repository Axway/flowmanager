# Migrate MongoDB data

How to migrate data between different MongoDB docker containers (same version). Use case: We have a MongoDB container with a custom image and we want to move data to another MongoDB container that uses an official image.

## Dump data

`docker-compose exec -T <mongodb service> sh -c 'mongodump -u [USER] -p --archive' > db.dump`

## Restore data

`docker-compose exec -T <mongodb service> sh -c 'mongorestore -u [USER] -p --archive' < db.dump`
