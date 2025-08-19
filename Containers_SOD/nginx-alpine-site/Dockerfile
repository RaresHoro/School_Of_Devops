FROM alpine:latest

RUN apk add --no-cache nginx

RUN mkdir -p /usr/share/nginx/html

COPY default.conf /etc/nginx/http.d/default.conf

COPY index.html /usr/share/nginx/html/index.html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
