#!/bin/bash

# Replace these with your actual domain and email
domains=(pikatrading.com www.pikatrading.com)
email="raud.boss@gmail.com"
staging=0 # Set to 1 if you're testing your setup to avoid hitting request limits

# Create required directories
mkdir -p certbot/conf
mkdir -p certbot/www

# Stop any running containers
docker-compose down

# Start containers
echo "### Starting nginx..."
docker-compose up --force-recreate -d nginx

# Wait for nginx to start
echo "### Waiting for nginx to start..."
sleep 5

echo "### Requesting Let's Encrypt certificate for ${domains[*]} ..."

# Join domains for certbot command
domain_args=""
for domain in "${domains[@]}"; do
  domain_args="$domain_args -d $domain"
done

# Request the certificate
docker-compose run --rm --entrypoint "\
  certbot certonly --webroot -w /var/www/certbot \
    --email $email \
    $domain_args \
    --rsa-key-size 4096 \
    --agree-tos \
    --force-renewal \
    $([ $staging = 1 ] && echo '--staging') \
    --non-interactive" certbot

# Once we have the certificates, enable HTTPS configuration
if [ -d "./certbot/conf/live/pikatrading.com" ]; then
    echo "### Enabling HTTPS configuration..."
    # Update nginx config to include HTTPS
    cat > config/nginx/default.conf.template <<'EOF'
# HTTP Server - Redirect to HTTPS
server {
    listen 80;
    listen [::]:80;
    server_name pikatrading.com www.pikatrading.com;

    # Debug logging
    error_log /var/log/nginx/error.log debug;
    access_log /var/log/nginx/access.log combined buffer=512k flush=1s;

    # Certbot challenges
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location = /health {
        access_log off;
        add_header Content-Type text/plain;
        return 200 'healthy\n';
    }

    location / {
        return 301 https://$host$request_uri;
    }
}

# HTTPS Server
server {
    listen 443 ssl;
    listen [::]:443 ssl;
    server_name pikatrading.com www.pikatrading.com;

    ssl_certificate /etc/letsencrypt/live/pikatrading.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/pikatrading.com/privkey.pem;
    
    # SSL configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_timeout 1d;
    ssl_session_cache shared:SSL:50m;
    ssl_session_tickets off;
    
    # HSTS
    add_header Strict-Transport-Security "max-age=63072000" always;
    
    client_max_body_size 4G;

    location /static/ {
        alias /code/pikatrading/static/;
        access_log off;
        expires 30d;
    }

    location /media/ {
        alias /code/pikatrading/media/;
        access_log off;
        expires 30d;
    }

    location / {
        include uwsgi_params;
        uwsgi_pass unix:///code/run/uwsgi.sock;
        
        # Standard proxy headers
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Timeouts
        proxy_connect_timeout 300s;
        proxy_send_timeout 300s;
        proxy_read_timeout 300s;
    }
}
EOF

    echo "### Restarting nginx with HTTPS enabled..."
    docker-compose restart nginx
    echo "Certificate created and HTTPS enabled! You can now access your site at https://pikatrading.com"
else
    echo "### Failed to obtain SSL certificate. Check the certbot logs for more information."
    exit 1
fi
echo "Note: It may take a few minutes for DNS changes to propagate and SSL to be fully active"