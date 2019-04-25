# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.20190425] - Release

### Added
-	Flow Patterns are now JSON Schema compliant (version 2). 
        o	This is a breaking change. Previous patters (version 1) are not working any more, if you’re upgrading an older Flow Central to this version, you need to remove all subscriptions, templates and patterns.
        o	Parameters from templates can now be pushed to the catalog using the pin next to each of them.  Pushing a parameter to the catalog will alow it to be available at subscription level.
-	Amplify Catalog connectivity can now be managed from Flow Central
-	Products UI can now be accessed from products tab by clicking on it’s name. A new tab is opened and you can operate changes at product level.
-	Partners can now be managed from Flow Central.
-	Users can now be managed from Flow Central. 


### Removed
- UMA has been removed. Not Flow Central uses less resources and is able to start faster.

### Improved
-   Docker base image to openjdk:8u201-jdk-alpine
-   Docker image size from 1.07GB to 272MB

-	

