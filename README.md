# dev-env

Dev environment 

### Configure SSH keys
Create folder name keys, and put public keys inside that folder.

### Configure mintty when using wsltty
Copy mintty director to /mnt/c/<user_name>/AppData

### Run container 
This container must only be published to host.

#### Docker
docker run --publish 127.0.0.1:2222:22

docker run -d --publish  127.0.0.1:2222:22 --mount type=bind,source={source_path},target=/home/plainbash/{directory}/ --name dev dev 

#### Docker Compose
docker-compose up -d

### SSH
ssh -p 2233 plainbash@127.0.0.1
