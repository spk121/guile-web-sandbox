# syntax=docker/dockerfile:1

FROM python:3.8-slim-buster

WORKDIR .

COPY requirements.txt requirements.txt
COPY module/ module
RUN pip3 install -r requirements.txt
RUN pip3 install pyxtermjs
RUN sudo apt-get install guile-3.0

COPY . .

CMD [ "pyxtermjs", "--command" , "guile"]
EXPOSE 5000

