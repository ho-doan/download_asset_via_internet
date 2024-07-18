FROM nginx:1.21.1-alpine
COPY images /usr/share/nginx/html
EXPOSE 80