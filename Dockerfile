# Use the official Nginx base image
FROM nginx

# Remove the default Nginx configuration
RUN rm /etc/nginx/conf.d/default.conf

# Copy the custom Nginx configuration generator script
COPY generate-config.sh /usr/local/bin/generate-config.sh

# Make the script executable
RUN chmod +x /usr/local/bin/generate-config.sh

# Set the working directory
WORKDIR /app

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
