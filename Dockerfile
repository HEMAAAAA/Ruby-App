# Build stage
FROM ruby:3.1.2-alpine AS builder

# Set working directory
WORKDIR /app

# Install build dependencies
RUN apk add --no-cache \
    build-base \
    postgresql-dev \
    nodejs \
    npm \
    git \
    tzdata

# Install bundler
RUN gem install bundler

# Install Ruby dependencies
COPY Gemfile Gemfile.lock ./
RUN bundle config set --local without 'development test' && \
    bundle install --jobs 4 --retry 3 && \
    bundle clean --force

# Install JS dependencies and build assets
COPY package.json ./
RUN npm install --production

# Copy application code
COPY . .

# Set environment variables for build
ENV TZ=UTC \
    RAILS_ENV=production \
    RAILS_SERVE_STATIC_FILES=true \
    SECRET_KEY_BASE=dummy_key_for_asset_precompilation

# Precompile assets
RUN bundle exec rails assets:precompile

# Runtime stage
FROM ruby:3.1.2-alpine

# Set working directory
WORKDIR /app

# Install runtime dependencies only
RUN apk add --no-cache \
    postgresql-client \
    tzdata \
    nodejs

# Set environment variables for runtime
ENV TZ=UTC \
    RAILS_ENV=production \
    RAILS_SERVE_STATIC_FILES=true

# Create a non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy gems from builder stage
COPY --from=builder /usr/local/bundle/ /usr/local/bundle/

# Copy app with compiled assets from builder stage
COPY --from=builder /app /app

# Create and set permissions for tmp and log directories
RUN mkdir -p /app/tmp/pids /app/log && \
    chmod -R 777 /app/tmp /app/log && \
    chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Expose the Rails server port
EXPOSE 3000

# Start the server
CMD bundle exec rails db:prepare && bundle exec rails s -b 0.0.0.0