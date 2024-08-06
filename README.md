# mukesh-java-war-docker
#This repo is having java web application built using docker..worked perfectly

This is java web application which will show web page
Used Apache Maven 3.8.7, JAVA 21.0.4 to build this application

Used docker commands:

sudo docker build -t sample-javaapp .
sudo docker container run -d -p 9090:8080 mukesh-javaapp:latest

access using http://<server ip address>:9090/my-web-app-1.0-SNAPSHOT/
