# syntax=docker/dockerfile:1

# Let's start with static HTML
FROM httpd:2.4
COPY ./public-html/ /usr/local/apache2/htdocs/
COPY ./my-httpd.conf /usr/local/apache2/conf/httpd.conf



#FROM python:3.8-slim-buster

#WORKDIR .

#COPY requirements.txt requirements.txt
#COPY module/ module
#RUN pip3 install -r requirements.txt
#RUN pip3 install pyxtermjs
#RUN sudo apt-get install guile-3.0

#COPY . .

#CMD [ "pyxtermjs", "--command" , "guile"]
#EXPOSE 5000

