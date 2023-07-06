[comment]: <> (    |         |         |         |         |         |          |)
# guile-web-sandbox
Containerized web app that provides a browser-based terminal to Guile sandbox.

Since I've been having fun with the DevOps, I thought it would be cool to make
something with Guile that I could use to practice CD.

So this is going to be a Docker container that launches a webserver to serve an
xterm.js console, and on the back end, each connection will launch a pty
connection to a Guile instance launching with a sandbox-mode REPL.

It will include
- Guile sandbox repl module
- Webpage
- Launcher: kicks off webserver, limits max Guile instances


