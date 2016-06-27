# DEMO 06

### CONNECT TO DEFAULT DOCKER MACHINE
```sh
$ eval $(docker-machine env default)
```

### BUILD, START & SCALE SERVICES (CONTAINERS)
```sh
$ docker-compose build
$ docker-compose up -d
$ docker-compose scale foo_service=5 bar_service=5
```

### GET MACHINE IP
```sh
$ docker-machine ip default
```
OUTPUT EXAMPLE
```sh
$ docker-machine ip default
192.168.99.100
```

### ADD TO OUR /etc/hosts
```sh
192.168.99.100    foo.dev
192.168.99.100    bar.dev
```
--> Access to "foo.dev" or "bar.dev", even to "192.168.99.100"