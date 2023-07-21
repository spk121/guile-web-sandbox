[comment]: <> (    |         |         |         |         |         |          |)
# guile-web-sandbox

This is just an idea. I haven't started yet.

Imagine a containerized web app that provides a browser-based terminal to
Guile sandbox.

There is a working sandbox-constrained repl in the module directory.  Look at
```(sandy sandy)``` to see how to call it.

Since I've been having fun with the DevOps, I thought it would be cool to make
something with Guile that I could use to practice CD.

So this is going to be a Docker container that launches a webserver to serve an
xterm.js console, and on the back end, each connection will launch a pty
connection to a Guile instance launching with a sandbox-mode REPL.

It will include
- Guile sandbox repl module
- Webpage
- Launcher: kicks off webserver, limits max Guile instances

I could just start with this: [pytermjs](https://github.com/cs01/pyxtemjs).
It has everything I need, and then I just launch pytermjs with the right 
cmd and cmd args.  The only think it is missing is a limit on the number of
forks.  It uses flask.

So a Dockerfile with Flask and Guile and the sandbox repl.

Here's a pretty good article about getting a Flask app into a Dockerfile:
[How to Dockerize a Flask App](https://www.freecodecamp.org/news/how-to-dockerize-a-flask-app/).

Microsoft talks about getting a Flask App on Azure here:
[Migrate custom software to Azure App Service using a custom container](https://learn.microsoft.com/en-us/azure/app-service/tutorial-custom-container?tabs=azure-cli&pivots=container-linux)

## Where we are

So I made a static dockerfile for just Apache.

Need to fix my-httpd.conf.

Don't forget `LogLevel info` in the httpd.conf until it works.

```
$ docker build -t my-apache2 .
$ docker run -dit --name my-running-app -p 8080:80 my-apache2
```

Need to install mod_wsgi in this apache instance

```
$  apt-get install libapache2-mod-wsgi-py3
```

fix wsgi script

add my my-httpd.conf the output from this 

```
mod_wsgi-express module-config
```

add to my-httpd.conf something like this

```
<VirtualHost *>
    ServerName example.com

    WSGIDaemonProcess yourapplication user=user1 group=group1 threads=5
    WSGIScriptAlias / /var/www/yourapplication/yourapplication.wsgi

    <Directory /var/www/yourapplication>
        WSGIProcessGroup yourapplication
        WSGIApplicationGroup %{GLOBAL}
        Order deny,allow
        Allow from all
    </Directory>
</VirtualHost>
```

That first slash in WSGIScriptAlias is the URL mount point of the WSGI application.
The 2nd argument is an absolute path to the wsgi file.

So if you mount the flask app in a subdirectory, it goes like this

```
<VirtualHost *:80>
    ServerName www.example.com
    ServerAlias example.com
    ServerAdmin webmaster@example.com

    DocumentRoot /usr/local/www/documents

    <Directory /usr/local/www/documents>
        Require all granted
    </Directory>

    WSGIScriptAlias /myapp /usr/local/www/wsgi-scripts/myapp.wsgi

    <Directory /usr/local/www/wsgi-scripts>
        Require all granted
    </Directory>
</VirtualHost>
```

But if you mount it in root, you need to escape all the directories that aren't part of
the flask app..

```
<VirtualHost *:80>

    ServerName www.example.com
    ServerAlias example.com
    ServerAdmin webmaster@example.com

    DocumentRoot /usr/local/www/documents

    Alias /robots.txt /usr/local/www/documents/robots.txt
    Alias /favicon.ico /usr/local/www/documents/favicon.ico

    Alias /media/ /usr/local/www/documents/media/

    <Directory /usr/local/www/documents>
        Require all granted
    </Directory>

    WSGIScriptAlias / /usr/local/www/wsgi-scripts/myapp.wsgi

    <Directory /usr/local/www/wsgi-scripts>
        Require all granted
    </Directory>

</VirtualHost>
```

For multiple applications, put them in order of precedence

```
WSGIScriptAlias /wiki /usr/local/wsgi/scripts/mywiki.wsgi
WSGIScriptAlias /blog /usr/local/wsgi/scripts/myblog.wsgi
WSGIScriptAlias / /usr/local/wsgi/scripts/myapp.wsgi
```

More info here https://modwsgi.readthedocs.io/en/master/user-guides/configuration-guidelines.html

There's some info there on limiting number of processes and threads, and something about *daemon mode*

How do I mis mod_proxy and mod_wsgi?  Mod proxy setup is something like this.

```
LoadModule proxy_module modules/mod_proxy.so
LoadModule proxy_http_module modules/mod_proxy_http.so
ProxyPass / http://127.0.0.1:8000/
RequestHeader set X-Forwarded-Proto http
RequestHeader set X-Forwarded-Prefix /
```

In the app init, decorate the app with this middlware for proxy stuff

```
from werkzeug.middleware.proxy_fix import ProxyFix
# App is behind one proxy that sets the -For and -Host headers.
app = ProxyFix(app, x_for=1, x_host=1)
```

it says

    ```
    X-Forwarded-For sets REMOTE_ADDR.
    X-Forwarded-Proto sets wsgi.url_scheme.
    X-Forwarded-Host sets HTTP_HOST, SERVER_NAME, and SERVER_PORT.
    X-Forwarded-Port sets HTTP_HOST and SERVER_PORT.
    X-Forwarded-Prefix sets SCRIPT_NAME.
    The original values of the headers are stored in the WSGI environ as werkzeug.proxy_fix.orig, a dict.
    ```
    
What does that mean?

There is another version of reverse proxy middleware here
https://pypi.org/project/flask-reverse-proxy-fix/

## Docs

https://learn.microsoft.com/en-us/azure/app-service/tutorial-custom-container?tabs=azure-cli&pivots=container-linux

https://learn.microsoft.com/en-us/azure/app-service/app-service-sql-github-actions

Also, Azure's example Dockerfile starts with a container that already has wsgi/flask/nginx.  Is nginx more flask-y than Apache?

```

FROM tiangolo/uwsgi-nginx-flask:python3.6

RUN mkdir /code
WORKDIR /code
ADD requirements.txt /code/
RUN pip install -r requirements.txt --no-cache-dir
ADD . /code/

# ssh
ENV SSH_PASSWD "root:Docker!"
RUN apt-get update \
        && apt-get install -y --no-install-recommends dialog \
        && apt-get update \
	&& apt-get install -y --no-install-recommends openssh-server \
	&& echo "$SSH_PASSWD" | chpasswd 

COPY sshd_config /etc/ssh/
COPY init.sh /usr/local/bin/
	
RUN chmod u+x /usr/local/bin/init.sh
EXPOSE 8000 2222
#CMD ["python", "/code/manage.py", "runserver", "0.0.0.0:8000"]
ENTRYPOINT ["init.sh"]
```

But hey, if you look up at the maintainer of that dockerfile, tiangolo, he says that python:3.6 is obsolete.  He has up to 3.11 on his repo.
He also give an example of how he would use that repo here https://github.com/tiangolo/uwsgi-nginx-flask-docker/tree/master/example-flask-package-python3.8
