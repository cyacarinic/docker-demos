############################### KEYSTORE
echo "[1.1/numerodepasos.] Creando KEYSTORE Machine"
docker-machine create -d virtualbox --virtualbox-memory "2000" \
    --engine-opt="label=com.function=consul" keystore

echo "[1.2/numerodepasos.] Estableciendo KEYSTORE como entorno"
eval $(docker-machine env keystore)

echo "[1.3/numerodepasos.] Iniciando CONSUL en KEYSTORE"
docker-compose up -d consul

echo "[1.4/numerodepasos.] Testeando CONSUL"
echo $(curl $(docker-machine ip keystore):8500/v1/catalog/nodes)


############################### SWARM
echo "[2.1/numerodepasos.] Creando Swarm MANAGER Machine"
docker-machine create -d virtualbox  --virtualbox-memory "2000" \
    --engine-opt="label=com.function=manager" \
    --engine-opt="cluster-store=consul://$(docker-machine ip keystore):8500" \
    --engine-opt="cluster-advertise=eth1:2376" manager

echo "[2.2/numerodepasos.] Estableciendo MANAGER como entorno"
eval $(docker-machine env manager)

echo "[2.3/numerodepasos.] copiar IP en SWARM de DOCKER COMPOSE"
echo $(docker-machine ip keystore)
echo "[Enter...]"
read

echo "[2.4/numerodepasos.] Iniciando SWARM en MANAGER"
docker-compose up -d swarm


############################### LOAD BALANCER
echo "[3.1/numerodepasos.] copiar IP en CONF.TOML"
echo $(docker-machine ip manager)
echo "[Enter...]"
read

echo "[3.2/numerodepasos.] Creando Swarm LOADBALANCER Machine"
docker-machine create -d virtualbox --virtualbox-memory "2000" \
    --engine-opt="label=com.function=interlock" \
    loadbalancer

echo "[3.3/numerodepasos.] Estableciendo LOADBALANCER como entorno"
eval $(docker-machine env loadbalancer)

echo "[3.4/numerodepasos.] Iniciando INTERLOCK en LOADBALANCER"
docker-compose up -d interlock

echo "[3.5/numerodepasos.] Testeando INTERLOCK"
echo $(docker-compose logs interlock)

echo "[3.6/numerodepasos.] Iniciando NGINX en LOADBALANCER Machine"
docker-compose up -d nginx


############################### NODOS
echo "[4.1/numerodepasos.] Creando FRONT-01 MAchine"
docker-machine create -d virtualbox --virtualbox-memory "2000" \
   --engine-opt="label=com.function=frontend01" \
   --engine-opt="cluster-store=consul://$(docker-machine ip keystore):8500" \
   --engine-opt="cluster-advertise=eth1:2376" frontend01

echo "[4.2/numerodepasos.] Estableciendo FRONT-01 como entorno"
eval $(docker-machine env frontend01)

echo "[4.3/numerodepasos.] Agregando FRONT-01 al Swarm Cluster"
docker run -d swarm join --addr=$(docker-machine ip frontend01):2376 consul://$(docker-machine ip keystore):8500


echo "[4.4/numerodepasos.] Creando FRONT-02 MAchine"
docker-machine create -d virtualbox --virtualbox-memory "2000" \
   --engine-opt="label=com.function=frontend02" \
   --engine-opt="cluster-store=consul://$(docker-machine ip keystore):8500" \
   --engine-opt="cluster-advertise=eth1:2376" frontend02

echo "[4.5/numerodepasos.] Estableciendo FRONT-02 como entorno"
eval $(docker-machine env frontend02)

echo "[4.6/numerodepasos.] Agregando FRONT-02 al Swarm Cluster"
docker run -d swarm join --addr=$(docker-machine ip frontend02):2376 consul://$(docker-machine ip keystore):8500


echo "[4.7/numerodepasos.] Creando WORKER-01 MAchine"
docker-machine create -d virtualbox --virtualbox-memory "2000" \
   --engine-opt="label=com.function=worker01" \
   --engine-opt="cluster-store=consul://$(docker-machine ip keystore):8500" \
   --engine-opt="cluster-advertise=eth1:2376" worker01

echo "[4.8/numerodepasos.] Estableciendo WORKER-01 como entorno"
eval $(docker-machine env worker01)

echo "[4.9/numerodepasos.] Agregando WORKER-01 al Swarm Cluster"
docker run -d swarm join --addr=$(docker-machine ip worker01):2376 consul://$(docker-machine ip keystore):8500


echo "[4.10/numerodepasos.] Creando DB-STORE MAchine"
docker-machine create -d virtualbox --virtualbox-memory "2000" \
   --engine-opt="label=com.function=dbstore" \
   --engine-opt="cluster-store=consul://$(docker-machine ip keystore):8500" \
   --engine-opt="cluster-advertise=eth1:2376" dbstore

echo "[4.11/numerodepasos.] Estableciendo DB-STORE como entorno"
eval $(docker-machine env dbstore)

echo "[4.12/numerodepasos.] Agregando DB-STORE al Swarm Cluster"
docker run -d swarm join --addr=$(docker-machine ip dbstore):2376 consul://$(docker-machine ip keystore):8500


############################### SWARM CLUSTER
echo "[5.1/numerodepasos.] Listando Maquinas"
docker-machine ls

echo "[5.2/numerodepasos.] Verificando que el Manager se comunique con todos los nodos"
docker -H $(docker-machine ip manager):3376 info


############################### VOLUMES & NETWORK
echo "[6.1/numerodepasos.] Estableciendo MANAGER como entorno"
eval $(docker-machine env manager)

echo "[6.2/numerodepasos.] Creando el Container Network VOTEAPP"
docker network create -d overlay voteapp

echo "[6.3/numerodepasos.] Estableciendo DBSTORE como entorno"
eval $(docker-machine env dbstore)

echo "[6.4/numerodepasos.] Verificando el estado de la red (network)"
docker network ls

echo "[6.5/numerodepasos.] Creando el Volumen DB-DATA"
docker volume create --name db-data


############################### APP'S & SERVICES
echo "[7.1/numerodepasos.] copiar IP de MANAGER en SERVICES con variable de entorno 'DOCKER_HOST'"
echo $(docker-machine ip manager)
echo "[Enter...]"
read

echo "[7.2/numerodepasos.] establecer MANAGER como HOST en el puerto 3376"
export DOCKER_HOST=$(docker-machine ip manager):3376
echo "[Enter...]"
read

echo "[7.3/numerodepasos.] Iniciando Aplicaciones y Creando Volumenes + Overlay Network"
docker-compose -f docker-compose-services.yml up -d

echo "[Fin...]"
read





