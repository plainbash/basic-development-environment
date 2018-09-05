# dev-env

Dev environment 

### Configure mintty when using wsltty
Copy mintty director to /mnt/c/<user_name>/AppData

### Run Docker
This container must only be published to host.

docker run --publish 127.0.0.1:2222:22

docker run -d --publish  127.0.0.1:2222:22 --mount type=bind,source={source_path},target=/home/plainbash/{directory}/ --name dev dev 

### SSH
ssh -p 2222 plainbash@127.0.0.1
