# Use the official Nginx base image
FROM nginx

# Remove the default Nginx configuration
RUN rm /etc/nginx/conf.d/default.conf

# Copy the custom Nginx configuration generator script
COPY generate-config.sh /usr/local/bin/generate-config.sh

# Make the script executable
RUN chmod +x /usr/local/bin/generate-config.sh

# Run the script to generate Nginx configuration
RUN /usr/local/bin/generate-config.sh

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
