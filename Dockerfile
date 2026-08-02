FROM nginx:1.27-alpine

LABEL maintainer="devops-team"
LABEL description="ECS application container with health check endpoint"

# Copy custom nginx configuration with health endpoint
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf

# Run as non-root user (nginx user exists in base image)
RUN chown -R nginx:nginx /var/cache/nginx /var/log/nginx /etc/nginx/conf.d \
    && touch /var/run/nginx.pid \
    && chown nginx:nginx /var/run/nginx.pid

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget -qO- http://localhost/health || exit 1

USER nginx

CMD ["nginx", "-g", "daemon off;"]
