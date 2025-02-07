<<<<<<< HEAD
# Use a Node base image to build the app
FROM node:16 AS build

# Set working directory
WORKDIR /app

# Install dependencies and build the app
COPY package.json package-lock.json ./
RUN npm install
COPY . ./
RUN npm run build

# Use a lighter image to serve the app
FROM nginx:alpine

# Copy the build folder to Nginx’s HTML folder
COPY --from=build /app/build /usr/share/nginx/html
#COPY --from=build /app/src/main/resources/static/built /usr/share/nginx/html


EXPOSE 80
=======
# Build stage (AMD64)
FROM --platform=linux/amd64 node:18-alpine AS build
WORKDIR /app

# Install dependencies with clean cache
COPY package.json package-lock.json ./
RUN npm ci --silent

# Copy source files
COPY . .

# Build application
RUN npm run build

# Runtime stage (AMD64)
FROM --platform=linux/amd64 nginx:1.25-alpine

# Copy built assets
COPY --from=build /app/build /usr/share/nginx/html

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Security hardening
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chmod -R 755 /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
>>>>>>> origin/main
