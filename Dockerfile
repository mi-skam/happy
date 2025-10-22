# Stage 1: Building the application
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package.json and yarn.lock
COPY patches ./patches
COPY package.json yarn.lock ./

# Install dependencies
RUN yarn install --frozen-lockfile --ignore-engines

# Copy the rest of the application code
COPY sources ./sources
COPY public ./public
COPY plugins ./plugins
COPY * ./

# Build the application for web in production mode
ENV NODE_ENV=production
ENV APP_ENV=production

RUN yarn expo export --platform web --output-dir dist

# Stage 2: Runtime with Caddy
FROM caddy:2-alpine AS runner

# Copy the built static files from builder stage to caddy html directory
COPY --from=builder /app/dist /usr/share/caddy

# Expose the standard http port
EXPOSE 80

# Caddy starts automatically with the default CMD 