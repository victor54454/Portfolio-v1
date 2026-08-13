FROM nginx:alpine

COPY . /usr/share/nginx/html/

COPY docker_config/nginx/nginx-http.conf /etc/nginx/conf.d/nginx.conf
COPY docker_config/nginx/nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]