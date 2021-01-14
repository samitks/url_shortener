# url_shortener
A URL shortener application in Ruby using Sinatra

## Introduction
- This is a small URL shortener application developer using Sinatra and database mongo which runs inside a docker container.
- Docker compose is used for running the complete application for local testing.

## Pre-requisites
- docker engine
- `docker-compose` command

## Steps to run the application.
- Clone the repository.
- Go inside the cloned repository directory.
- Run the below command to start the application and databases using docker-compose
```
docker-compose up -d
```
The above command will start the application in the daemon mode and runs in the background.
- If both the containers got created successfully from docker-compose, you should see the following lines at the end of the above command's output.
```
Creating db ... done
Creating app ... done
```
- Open http://localhost:1234 in the browser to run and test the URL shortener.

## Components:

### 1. URL shortener backend:
- A docker container `app` is the backend implemented in Ruby which is running the API server using Sinatra.
- The API server runs on the port `1234` and `docker-compose.yml` file tries to use the local machine's 1234 port while testing locally. In order to change the local port for testing, just update the port mapping inside `docker-compose.yml` file.
- When a shortened URL is hit from the browser, the request comes directly to the application, the backend retrieves the mapping from the datastore and redirect the user to the original URL with a 302 redirection.
- If the shortened URL does not exist in the datastore, the user receives a 404 error with a error message.

### 2. Datastore
- `Mongodb` has been used as the data storage for storing the URL mappings.
- The API server creates an entry in the database for each URL for which a short URL has been generated.
- `original_url` is the indexed key here and will always be unique.



