FROM nginx:1.27

COPY ./excalidraw-app/build /usr/share/nginx/html

RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

HEALTHCHECK CMD curl -f http://localhost || exit 1
