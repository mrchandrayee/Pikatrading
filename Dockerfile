# NOTE: this example is taken from the default Dockerfile for the official nginx Docker Hub Repo
# https://hub.docker.com/_/nginx/
# NOTE: This file is slightly different than the video, because nginx versions have been updated 
#       to match the latest standards from docker hub... but it's doing the same thing as the video
#       describes
# Pull official base Python Docker image
FROM python:3.12.3

# all images must have a FROM
# usually from a minimal Linux distribution like debian or (even better) alpine
# if you truly want to start with an empty container, use FROM scratch

# Set environment variables
# 1. Prevents Python from writing out pyc files.
ENV PYTHONDONTWRITEBYTECODE=1
# 2. Ensures that the Python stdout and stderr streams are sent straight to the terminal without first being buffered.
ENV PYTHONUNBUFFERED=1
# Set work directory and Python path
WORKDIR /code
ENV PYTHONPATH=/code/pikatrading

# Create necessary user and set permissions
RUN groupadd -g 33 www-data || true && \
    useradd -u 1000 -g www-data -m -d /home/uwsgi uwsgi && \
    chown -R uwsgi:www-data /code && \
    chmod -R g+w /code
# Install dependencies
RUN pip install --upgrade pip
COPY requirement.txt /code/
RUN pip install -r requirement.txt
# Copy wait-for-it script first and make it executable
COPY wait-for-it.sh /code/
RUN chmod +x /code/wait-for-it.sh

# Copy the Django project
COPY ./pikatrading /code/pikatrading/
COPY ./config /code/config/

# Install system dependencies and debugging tools
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    libgconf-2-4 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libgdk-pixbuf2.0-0 \
    libgtk-3-0 \
    libgbm-dev \
    libnss3-dev \
    libxss-dev \
    libasound2 \
    fonts-liberation \
    xvfb \
    netcat-traditional \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Add debug script
RUN echo '#!/bin/bash\n\
echo "Testing socket connection..."\n\
echo "GET / HTTP/1.1\r\nHost: localhost\r\n\r\n" | nc -U /code/run/uwsgi.sock\n\
echo "Socket permissions:"\n\
ls -l /code/run/uwsgi.sock\n\
echo "Process list:"\n\
ps aux | grep uwsgi\n\
echo "Socket connection test complete."' > /usr/local/bin/test-socket.sh && \
chmod +x /usr/local/bin/test-socket.sh

# Install Python Playwright
RUN pip install playwright
RUN playwright install
RUN playwright install-deps

# Create directory for socket with proper permissions
RUN mkdir -p /code/run && \
    chown uwsgi:www-data /code/run && \
    chmod 775 /code/run

# Add script to handle socket cleanup
RUN echo '#!/bin/sh\n\
rm -f /code/run/uwsgi.sock\n\
exec "$@"' > /entrypoint.sh && \
    chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
# Create directory for socket with proper permissions
RUN mkdir -p /code/pikatrading && \
    chown uwsgi:www-data /code/pikatrading && \
    chmod 775 /code/pikatrading
