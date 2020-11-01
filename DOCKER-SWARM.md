### How To Run Docker swarm mode with docker-stack.yml

#### docker-machine setup
- https://github.com/dockersamples/example-voting-app/blob/master/docker-stack.yml
- https://github.com/docker/machine
```
brew install virtualbox
brew install docker-machine
docker-machine create -d virtualbox master
docker-machine create -d virtualbox worker1
docker-machine create -d virtualbox worker2
docker-machine ls
```

- if you don't have virtualbox. you got blow of message.
```
VBoxManage not found. Make sure VirtualBox is installed and VBoxManage is in the path
```

```
docker-machine ssh master
### or eval "$(docker-machine env master)"

docker@master:~$ docker swarm init --advertise-addr 192.168.99.100                                                                                                                                        

Swarm initialized: current node (4l396ni602807sb2hk1ujlvm5) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-5jcphjyj4ykejxphj2o15yh7bz4syyxo5qg8bt25ldkhd4poez-1l2skxj2931mtjolwd43139jy 192.168.99.100:2377

To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.
```

```
docker-machine ssh worker1
   ( '>')
  /) TC (\   Core is distributed with ABSOLUTELY NO WARRANTY.
 (/-_--_-\)           www.tinycorelinux.net

docker@worker1:~$ docker swarm join --token SWMTKN-1-5jcphjyj4ykejxphj2o15yh7bz4syyxo5qg8bt25ldkhd4poez-1l2skxj2931mtjolwd43139jy 192.168.99.100:2377
This node joined a swarm as a worker.
```

```
docker-machine ssh worker2
   ( '>')
  /) TC (\   Core is distributed with ABSOLUTELY NO WARRANTY.
 (/-_--_-\)           www.tinycorelinux.net

docker@worker2:~$ docker swarm join --token SWMTKN-1-5jcphjyj4ykejxphj2o15yh7bz4syyxo5qg8bt25ldkhd4poez-1l2skxj2931mtjolwd43139jy 192.168.99.100:2377
This node joined a swarm as a worker.
```

#### Private registry
- https://docs.docker.com/engine/swarm/stack-deploy/
```
docker service create --name registry --publish published=5000,target=5000 registry:2
curl http://localhost:5000/v2/
```

#### Initial source
```
git clone https://github.com/x1wins/CW-OVP.git
cd ./CW-OVP
git fetch
git checkout feature/docker-stack
```

#### update source 
```
cd CW-OVP/
git pull
git reset --hard feature/docker-stack
```

#### update s3 
```
vi .env.dev.s3
```

#### build image

- build image and change tag with localhost:5000
    ```
    docker build -t cw-ovp:latest .
    docker tag cw-ovp:latest localhost:5000/cw-ovp
    ```
- build image with localhost:5000 for private repository
    ```
    docker build -t localhost:5000/cw-ovp . 
    ```

#### Push image to Pirvate regitory
```
docker push localhost:5000/cw-ovp
```

#### Run stack
```
docker stack deploy --compose-file docker-stack.yml CW-OVP
http://192.168.99.100:8080/
http://192.168.99.100:3000/

docker exec -it 1f7193e6042e bundle exec rails webpacker:install
docker exec -it 1f7193e6042e bundle exec rake db:migrate 
```

#### Stop stack
```
docker stack rm CW-OVP
```

#### Trouble shooting
- https://stackoverflow.com/a/45373282/1399891
```
docker service ps --no-trunc {serviceName}
docker service ps --no-trunc mbbutj2bbida
docker service ps --no-trunc kged4le7e3jn
mkdir /home/docker/CW-OVP/tmp/redis                                                                                                                                               
mkdir /home/docker/CW-OVP/tmp/db
```