example docker-compose.yml

```
example.com:
 image: casp/site-php7.1
 restart: always
 container_name: example.com
 hostname: example.com
 volumes:
  - /srv/docker/docker-sitehosting/example.com/www:/var/www/html
  - /srv/docker/docker-sitehosting/example.com/log/nginx/:/var/log/nginx
  - /srv/docker/docker-sitehosting/example.com/log/apache2/:/var/log/apache2
  - /srv/docker/docker-sitehosting/example.com/nginx/nginx.conf:/etc/nginx/nginx.conf
  - /srv/docker/docker-sitehosting/example.com/log/supervisor/:/var/log/supervisor
  - /srv/docker/docker-sitehosting/example.com/letsencrypt:/var/www/letsencrypt:ro
  - /srv/docker/docker-sitehosting/example.com/sftpdev-home:/home/sftpdev
 ports:
  - "1089:80"
 command: "/usr/bin/python /usr/bin/supervisord -c /etc/supervisor/supervisord.conf"
 external_links:
  - mysql_local
```

After login:
```
sudo supervisorctl status
apache2                          RUNNING    pid 11, uptime 8 days, 0:45:32
nginx                            RUNNING    pid 9, uptime 8 days, 0:45:33
sshd                             RUNNING    pid 10, uptime 8 days, 0:45:32
```

