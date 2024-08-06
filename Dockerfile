# Use an official Tomcat runtime as a parent image
FROM tomcat:10.1-jdk21

# Copy the WAR file into the webapps directory of Tomcat
COPY target/*.war /usr/local/tomcat/webapps/

# Expose port 8080
EXPOSE 8080

# Start Tomcat server
ENTRYPOINT ["catalina.sh", "run"]
CMD ["/bin/startup.sh", "run"]
