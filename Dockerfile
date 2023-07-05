# Use the official Nginx base image
FROM nginx

# Remove the default Nginx configuration
RUN rm /etc/nginx/conf.d/default.conf

# Set environment variables from the .env file
ENV FROM_1=domainA
ENV TO_1=domainB
ENV FROM_2=domainC
ENV TO_2=domainD

# Generate Nginx configuration dynamically
RUN echo '#!/bin/sh' > /usr/local/bin/generate-config.sh && \
    echo 'echo "Generating Nginx configuration..."' >> /usr/local/bin/generate-config.sh && \
    echo 'for i in $(env | awk -F "=" '\''/^FROM_[0-9]+/{print $1}'\''); do' >> /usr/local/bin/generate-config.sh && \
    echo '    num=$(echo $i | awk -F "_|[a-zA-Z]+" '\''{print $2}'\'')' >> /usr/local/bin/generate-config.sh && \
    echo '    from_var="FROM_$num"' >> /usr/local/bin/generate-config.sh && \
    echo '    to_var="TO_$num"' >> /usr/local/bin/generate-config.sh && \
    echo '    from_value=${!from_var}' >> /usr/local/bin/generate-config.sh && \
    echo '    to_value=${!to_var}' >> /usr/local/bin/generate-config.sh && \
    echo '    if [[ $from_value && $to_value ]]; then' >> /usr/local/bin/generate-config.sh && \
    echo '        echo "Generating reverse proxy configuration for $from_value to $to_value"' >> /usr/local/bin/generate-config.sh && \
    echo '        echo "server {" >> \"/etc/nginx/conf.d/reverse-proxy-$num.conf\"' >> /usr/local/bin/generate-config.sh && \
    echo '        echo "    listen 80;" >> \"/etc/nginx/conf.d/reverse-proxy-$num.conf\"' >> /usr/local/bin/generate-config.sh && \
    echo '        echo "    server_name $from_value;" >> \"/etc/nginx/conf.d/reverse-proxy-$num.conf\"' >> /usr/local/bin/generate-config.sh && \
    echo '        echo "    location / {" >> \"/etc/nginx/conf.d/reverse-proxy-$num.conf\"' >> /usr/local/bin/generate-config.sh && \
    echo '        echo "        proxy_pass http://$to_value;" >> \"/etc/nginx/conf.d/reverse-proxy-$num.conf\"' >> /usr/local/bin/generate-config.sh && \
    echo '        echo "        proxy_set_header Host \$host;" >> \"/etc/nginx/conf.d/reverse-proxy-$num.conf\"' >> /usr/local/bin/generate-config.sh && \
    echo '        echo "        proxy_set_header X-Real-IP \$remote_addr;" >> \"/etc/nginx/conf.d/reverse-proxy-$num.conf\"' >> /usr/local/bin/generate-config.sh && \
    echo '        echo "    }" >> \"/etc/nginx/conf.d/reverse-proxy-$num.conf\"' >> /usr/local/bin/generate-config.sh && \
    echo '        echo "}" >> \"/etc/nginx/conf.d/reverse-proxy-$num.conf\"' >> /usr/local/bin/generate-config.sh && \
    echo '    fi' >> /usr/local/bin/generate-config.sh && \
    echo 'done' >> /usr/local/bin/generate-config.sh && \
    echo 'echo "Nginx configuration generated successfully."' >> /usr/local/bin/generate-config.sh && \
    chmod +x /usr/local/bin/generate-config.sh

# Generate Nginx configuration
RUN generate-config.sh

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
