FROM httpd:latest
ARG HTTPD_PORT

EXPOSE $HTTPD_PORT

# /var/www/html is from line 122 of httpd.conf
COPY public-html /usr/local/apache2/htdocs
