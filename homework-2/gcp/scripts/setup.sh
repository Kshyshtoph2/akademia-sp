#!/bin/bash

sudo apt update -y
sudo apt install -y nginx
CONF=$(cat <<- END 
events {
    worker_connections 1024;
}

http {

    server {
        listen 80;
        
        location / {
            root /www/data;
        }
    }
}
END
)
echo "$CONF" | sudo tee /etc/nginx/nginx.conf
sudo mkdir /www 
sudo mkdir /www/data 
INDEX=$(cat <<- END
<!doctype html>
<html>
  <head>
    <title>Hello nginx</title>
    <meta charset="utf-8" />
  </head>
  <body>
    <h1>
      Hello World!
    </h1>
  </body>
</html>
END
)
echo "$INDEX" | sudo tee /www/data/index.html
sudo service nginx restart