FROM alpine

RUN apk update && apk add --no-cache nginx curl iputils

RUN mkdir -p /run/nginx /usr/share/nginx/html \
 && echo '<h1>Hello from NGINX</h1>' > /usr/share/nginx/html/index.html \
 && cat <<EOF > /etc/nginx/nginx.conf
events {}

http {
    server {
        listen 80;
        location / {
            root /usr/share/nginx/html;
            index index.html;
        }
    }
}
EOF

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
