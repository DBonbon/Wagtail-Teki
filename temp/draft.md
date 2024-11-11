docker/.env:

# Ports
NEXTJS_PORT=3000
DOCKER_WEB_PORT=8081
DOCKER_WEB_SSL_PORT=8082
DOCKER_DB_PORT=8083

# Database Configurations
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=app

# Django Environment Variables
DJANGO_SECRET_KEY=your_secret_key_here
DJANGO_ALLOWED_HOSTS=*

docker-compose.yml:
services:
  web:
    image: nginx:latest
    working_dir: /app
    ports:
      - "${DOCKER_WEB_PORT}:80"
      - "${DOCKER_WEB_SSL_PORT}:443"
    depends_on:
      - python
    environment:
      - PYTHON_HOST=http://python
      - MEDIA_REMOTE_DOMAIN=example.com
    volumes:
      - "./docker/files/static/502.html:/app/502.html:cached"
      - "./docker/files/config/nginx.conf.template:/etc/nginx/templates/default.conf.template:cached"
      - "./docker/files/certs:/etc/nginx/certs"
      - "./src/media:/app/media"
      - "./src/static:/app/static"

  python:
    image: dbonbon/company_project_python
    build:
      context: ./src
      args:
        - ENVIRONMENT=local
    command: "runserver"
    volumes:
      - "./src:/home/app/web"
      - "./src/media:/home/app/media"
      - "./src/static:/home/app/static"
    depends_on:
      - db
    env_file: ./docker/config/python.env

  db:
    image: postgis/postgis:12-2.5-alpine
    ports:
      - "${DOCKER_DB_PORT}:5432"
    volumes:
      - "./docker/files/db-dumps/:/docker-entrypoint-initdb.d/"
      - "./docker/files/shared:/shared:rw"
    environment:
      - POSTGRES_USER=${POSTGRES_USER}
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
      - POSTGRES_DB=${POSTGRES_DB}

Dockerfile:
# BUILDER
FROM ubuntu:22.04 AS builder-image

# Use build args for environment-specific variables
ARG ENVIRONMENT=prod
ENV ENVIRONMENT=${ENVIRONMENT}

RUN apt-get update && apt-get install --no-install-recommends -y python3.11 python3.11-dev libpq-dev python3.11-venv python3-pip python3-wheel build-essential && \
	apt-get clean && rm -rf /var/lib/apt/lists/*

RUN python3.11 -m venv /home/app/venv
ENV PATH="/home/app/venv/bin:$PATH"

COPY requirements/*.txt .
RUN pip3 install --no-cache-dir wheel
RUN pip3 install --no-cache-dir -r $ENVIRONMENT.txt

# RUNNER
FROM ubuntu:22.04 AS runner-image
ARG ENVIRONMENT=prod
ENV ENVIRONMENT=${ENVIRONMENT}

RUN apt-get update && apt-get install --no-install-recommends -y netcat vim gettext curl python3.11 python3-venv tzdata gdal-bin && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN addgroup app --gid 1000 && adduser app --gid 1000 --uid 1000
COPY --from=builder-image /home/app/venv /home/app/venv

RUN mkdir /home/app/web /home/app/static
WORKDIR /home/app/web
COPY . .

EXPOSE 8000

# Use environment variables instead of hardcoding
ENV PYTHONUNBUFFERED=1 \
    DJANGO_SETTINGS_MODULE=teki.settings.${ENVIRONMENT} \
    ALLOWED_HOSTS=* \
    INTERNAL_IPS=0.0.0.0 \
    SECRET_KEY=${DJANGO_SECRET_KEY} \
    MEDIA_PATH=/home/app/media \
    STATIC_PATH=/home/app/static \
    SENTRY_DSN="" \
    DATABASE_USER=${POSTGRES_USER} \
    DATABASE_PASSWORD=${POSTGRES_PASSWORD} \
    DATABASE_NAME=${POSTGRES_DB} \
    DATABASE_HOST=db \
    PYTHONPATH="${PYTHONPATH}:/home/app/web" \
    IN_DOCKER=1

RUN python manage.py collectstatic --noinput

USER app

ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["gunicorn"]

nginx.conf:
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    proxy_read_timeout 120s;

    server_name {{cookiecutter.domain_prod}}.test _;

    listen 443 ssl;
    ssl_certificate /etc/nginx/certs/cert.pem;
    ssl_certificate_key /etc/nginx/certs/cert-key.pem;

    client_max_body_size 128M;

    gzip on;
    gzip_proxied any;
    gzip_types text/plain text/xml text/css application/x-javascript;
    gzip_vary on;
    gzip_disable “MSIE [1-6]\.(?!.*SV1)”;

    sendfile on;
    sendfile_max_chunk 512k;

    root /app/src;

    access_log off;

    error_page 502 /502.html;
    location /502.html {
        root /app;
    }

    location / {
        proxy_set_header Host $host:$DOCKER_WEB_PORT;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://host.docker.internal:$NEXTJS_PORT;
    }

    location /_next/webpack-hmr {
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_pass http://host.docker.internal:$NEXTJS_PORT/_next/webpack-hmr;
    }

    location /wt {
        proxy_set_header Host $host:$DOCKER_WEB_PORT;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass ${PYTHON_HOST}:8000/wt;
    }
}

next.config:
module.exports = {
  env: {
    NEXT_PUBLIC_WAGTAIL_API_URL: process.env.NEXT_PUBLIC_WAGTAIL_API_URL,
    WAGTAIL_API_URL: process.env.WAGTAIL_API_URL,
    NEXTJS_PORT: process.env.NEXTJS_PORT || 3000,
  },
};
