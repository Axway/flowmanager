# FlowManager Deploy

Deploy Amplify FlowManager on multiple container orchestration.

## Requirements

* `Git`
* `docker >= 19.03.12`
* `docker-compose >= 1.26.2`

## docker-compose

### Install

* Go to `docker-compose` path
* Copy `env.template` in `.env` file
* Change value of parameters as you want in `.env` file
* Run docker `docker-compose up -d`
* Check the health of the services by typing this `docker-compose ps` command.

### Upgrade

* Be sure you are in the same `docker-compose` path
* In `.env` file that you already have from install stage, change `FLOWMANAGER_VERSION` with the newer version
* Type `docker-compose up -d` command, this will do the updating of your container with the new version
* Check the health of the services by typing this `docker-compose ps` command.

### Remove

* Be sure you are in the same `docker-compose` path
* Type `docker-compose down -v`, this will remove all the contianers, volumes and other parts related to the containers.

## Contribute

Contributions are always welcome.

* Fork the repo
* Create a pull request against master
* Be sure tests pass (if exists)

Check [GitHub Flow](https://guides.github.com/introduction/flow/) for details.

## Authors

* FlowManager - DevOps Team

***
All active parameters, including description and default values can be found [here](docs/parameters.md)
