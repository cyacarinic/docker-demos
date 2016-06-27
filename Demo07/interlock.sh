#!/bin/bash
echo "INTERLOCK DEMO"
echo "Maintener: cyacarinic@gmail.com"

echo "Obteniendo Swarm Token"
token=$(curl -s -XPOST https://discovery-stage.hub.docker.com/v1/clusters)
echo "Token :: "$token
echo "[Enter...]"
read

echo "Creando el Swarm Master"
docker-machine create \
	-d virtualbox \
	--virtualbox-memory "4096" \
	--swarm  --swarm-master \
	--swarm-discovery token://$token \
	swarm-master
echo "[Enter...]"
read

echo "Creando el Nodo 01"
docker-machine create \
	-d virtualbox \
	--virtualbox-memory "4096" \
	--swarm --swarm-discovery token://$token \
	node-01
docker-machine ls
echo "[Enter...]"
read

echo "Conectandose al Swarm Master"
eval $(docker-machine env swarm-master)
echo "[Enter...]"
read

echo "Corriendo Interlock en Swarm Master"
docker run --name interlock -p 80:8080 -d \
	-v ~/.docker/machine/certs/:/certs ehazlett/interlock \
	-s tcp://$(docker-machine ip swarm-master):3376 \
	--plugin haproxy --swarm-tls-ca-cert /certs/ca.pem \
	--swarm-tls-cert /certs/cert.pem \
	--swarm-tls-key /certs/key.pem \
	--debug --plugin haproxy start
docker ps
docker logs interlock

echo "Conectandose al Swarm Cluster"
eval $(docker-machine env --swarm swarm-master)

echo "Iniciando Web App"
docker run -P -d -e INTERLOCK_DATA='{"hostname":"test", "domain":"demo.dev", "alias_domains":["demo.dev"], "port":8080}' ehazlett/docker-demo
echo "[Enter...]"
read

echo "Iniciando 5 containers"
for p in {1..5}; do
	docker run -P -d -e INTERLOCK_DATA='{"hostname":"test", "domain":"demo.dev", "alias_domains":["demo.dev"], "port":8080}' ehazlett/docker-demo
done
echo "[Enter...]"
read

echo "Conectandose al Swarm Cluster"
eval $(docker-machine env --swarm swarm-master)
echo "añadir en 'sudo vim /etc/hosts'"
echo "'"$(docker-machine ip swarm-master)" demo.dev'"
echo "Testear en 'demo.dev' y 'demo.dev/haproxy?stats' (stats:interlock)"
