# Stage 1: Build the Vue.js app
FROM node:18-alpine AS build

# Set working directory
WORKDIR /app

# Copy package files and install dependencies
COPY package.json package-lock.json* ./
RUN npm install

# Copy application source code
COPY . .

# Build the Vue.js app for production
RUN npm run build

# Stage 2: Serve the app with NGINX
FROM nginx:alpine

# Copy built files from the build stage
COPY --from=build /app/dist /usr/share/nginx/html

# Add NGINX configuration directly in Dockerfile
RUN echo 'events { worker_connections 1024; } \
http { \
    server { \
        listen 80; \
        server_name _; \
        root /usr/share/nginx/html; \
        index index.html; \
        location / { \
            try_files $uri $uri/ /index.html; \
        } \
        error_page 404 /index.html; \
    } \
}' > /etc/nginx/nginx.conf

# Expose NGINX port
EXPOSE 80

# Start NGINX
CMD ["nginx", "-g", "daemon off;"]
