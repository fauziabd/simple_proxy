#!/bin/bash

set -e

# Read the reverse proxy configurations from the .env file
while IFS='=' read -r key value; do
  if [[ $key =~ ^from_ && $value ]]; then
    num=${key#*_}
    from_var="from_$num"
    to_var="to_$num"
    from_value=${!from_var}
    to_value=${!to_var}

    if [[ $from_value && $to_value ]]; then
      echo "Generating reverse proxy configuration for $from_value to $to_value"
      echo "server {" >> "/etc/nginx/conf.d/reverse-proxy-$num.conf"
      echo "    listen 80;" >> "/etc/nginx/conf.d/reverse-proxy-$num.conf"
      echo "    server_name $from_value;" >> "/etc/nginx/conf.d/reverse-proxy-$num.conf"
      echo "    location / {" >> "/etc/nginx/conf.d/reverse-proxy-$num.conf"
      echo "        proxy_pass http://$to_value;" >> "/etc/nginx/conf.d/reverse-proxy-$num.conf"
      echo "        proxy_set_header Host \$host;" >> "/etc/nginx/conf.d/reverse-proxy-$num.conf"
      echo "        proxy_set_header X-Real-IP \$remote_addr;" >> "/etc/nginx/conf.d/reverse-proxy-$num.conf"
      echo "    }" >> "/etc/nginx/conf.d/reverse-proxy-$num.conf"
      echo "}" >> "/etc/nginx/conf.d/reverse-proxy-$num.conf"
    fi
  fi
done < .env
