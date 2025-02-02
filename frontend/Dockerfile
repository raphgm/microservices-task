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