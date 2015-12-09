#!/bin/bash

# create host to run consul on
docker-machine create -d virtualbox consul-discovery

# save consul ip
CONSUL_IP=$(docker-machine env consul-discovery | awk -F'[/:]' '/DOCKER_HOST/{print $4}')

# setup consul vm environment
eval "$(docker-machine env consul-discovery)"

# run consul server
docker run -d -p 8400:8400 -p 8500:8500 -p 8600:53/udp -h node1 progrium/consul -server -bootstrap -ui-dir /ui
echo "consul UI can be reached here $CONSUL_IP:8500"

# create swarm master
docker-machine create \
        -d virtualbox \
        --swarm \
        --swarm-master \
        --swarm-discovery consul://$CONSUL_IP:8500 \
        swarm-master

# create swarm slave 0
docker-machine create \
    -d virtualbox \
    --swarm \
    --swarm-discovery consul://$CONSUL_IP:8500 \
    swarm-agent-00

# create swarm slave 1
docker-machine create \
    -d virtualbox \
    --swarm \
    --swarm-discovery consul://$CONSUL_IP:8500 \
    swarm-agent-01

# setup swarm master environment
eval "$(docker-machine env --swarm swarm-master)"

echo "your cluster is ready!"