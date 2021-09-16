# Geolocation Service

Geolocation Service is an application which provides service to find particular location data using IP Address.
## Get Started

To use this application need to be installed on your machine.

## Clone this repository

Change project-name to your projects name.

```bash
> git clone https://github.com/MukeshMano19/geo-location-service.git <project-name>
> cd <project-name>
```

There are two options to run this application

  * Dockerized Method
  * Non-Dockerized Method

### Dockerized Method

To learn more about Docker, see [Docker Documentation page](https://docs.docker.com/get-started/).

To download Docker, see [Docker Downloads page](https://docs.docker.com/get-started/).

We want our app to be as light as it can be, so we are going to use Elixir/Phoenix and Postgres as a containers.

To start your Phoenix server using Docker,

```bash
> docker-compose build
> docker-compose up
```

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

To start a docker container as daemon process,

```bash
> docker-compose up -d
```

To kill one or more running containers,

```bash
> docker-compose kill -s SIGINT
```

### Non Dockerized Method

Change database hostname to `localhost` to access the local postgresql database.

```
in /config/dev.exs

config :geo_location_service, GeoLocationService.Repo,
  ....
  hostname: "localhost", 
  ....
```

To setup the project and start phoenix endpoind,

```bash
> mix setup
> mix phx.server
```

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## To deploy in Production

With Docker, deploying in production is pretty easy and exactly same as development.

But, make sure the configuration and the credentials for the postgres database to connect and access.

To build and start docker container as daemon process,

```bash
> docker-compose build
> docker-compose up -d
```

### For Non Dockerized method, Learn more

  * Phoenix Deployment: https://hexdocs.pm/phoenix/deployment.html
  * Elixir Release: https://hexdocs.pm/phoenix/releases.html
  * Docs: https://hexdocs.pm/phoenix


