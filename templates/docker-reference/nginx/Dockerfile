FROM nginx:alpine

RUN apk add --no-cache openssl

COPY nginx.conf /etc/nginx/nginx.conf

RUN mkdir -p /etc/nginx/ssl

# Generate self-signed cert for development (replace with real certs in production)
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/travion.key \
    -out /etc/nginx/ssl/travion.crt \
    -subj "/C=US/ST=State/L=City/O=Travion/CN=localhost" 2>/dev/null || true

RUN chmod 644 /etc/nginx/ssl/travion.crt 2>/dev/null || true && \
    chmod 600 /etc/nginx/ssl/travion.key 2>/dev/null || true

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
