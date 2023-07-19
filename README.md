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

```
$ docker build -t my-apache2 .
$ docker run -dit --name my-running-app -p 8080:80 my-apache2
```

Need to install mod_wsgi in this apache instance

```
$ pip install mod_wsgi
```

fix wsgi script
