FROM openjdk:8-jdk
VOLUME /tmp  # For creatng short lived files

MAINTAINER Donald Vines <donald_vines@hotmail.com>

##
## Build Arguments -- values set by build 
##

# App's Name
ARG APP_VERSION
ARG APP_ARTIFACTID
ARG WAR_ARTIFACTID

# Exposed Port
ARG EXPOSE_PORT

# Database's URL
ARG DATABASE_DRIVER
ARG DATABASE_URL
ARG DATABASE_USERNAME
ARG DATABASE_PASSWORD

##
## Environment Variables
##

# Set ssl variables
ENV DAYTRADER_KEYSTORE_FILENAME=/var/ssl/daytrader/keystore.jks
ENV DAYTRADER_KEYSTORE_PASSWORD=password
ENV DAYTRADER_TRUSTSTORE_LOCATION=/var/ssl/daytrader/truststore.jks
ENV DAYTRADER_TRUSTSTORE_PASSWORD=password

ENV DAYTRADER_DATABASE_DRIVER=${DATABASE_DRIVER}
ENV DAYTRADER_DATABASE_URL=${DATABASE_URL}
ENV DAYTRADER_DATABASE_USERNAME=${DATABASE_USERNAME}
ENV DAYTRADER_DATABASE_PASSWORD=${DATABASE_PASSWORD}

# Set tomcat variables
ENV SERVER_PORT=${EXPOSE_PORT}
ENV SERVER_PORT_HTTPS=${EXPOSE_PORT}

# Make port visible
EXPOSE ${EXPOSE_PORT}

# Set service routes
ENV DAYTRADER_ACCOUNTS_SERVICE=https://daytrader-accounts
ENV DAYTRADER_GATEWAY_SERVICE=https://daytrader-gateway
ENV DAYTRADER_PORTFOLIOS_SERVICE=https://daytrader-portfolios
ENV DAYTRADER_QUOTES_SERVICE=https://daytrader-quotes

# Set logging variables
ENV DAYTRADER_LOG_FILENAME=/var/log/daytrader/${APP_ARTIFACTID}-${APP_VERSION}.log
ENV DAYTRADER_LOG_LEVEL=TRACE
ENV DAYTRADER_LOG_APPENDER=ConsoleAppender

# Create the database folder
RUN mkdir -p -m 0777 /var/dat/daytrader

# Create the log folder
RUN mkdir -p -m 0777 /var/log/daytrader

# Create the log file and set permissions
RUN touch $DAYTRADER_LOG_FILENAME
RUN chmod 666 $DAYTRADER_LOG_FILENAME

# Create the ssl folder
RUN mkdir -p -m 0777 /var/ssl/daytrader

# Add the truststore to the container and set permissions
ARG JKS_FILE=target/${WAR_ARTIFACTID}-${APP_VERSION}/WEB-INF/classes/truststore.jks
ADD ${JKS_FILE} $DAYTRADER_TRUSTSTORE_LOCATION
RUN chmod 666 $DAYTRADER_TRUSTSTORE_LOCATION

# Add the application's war to the container
ARG WAR_FILE=target/${WAR_ARTIFACTID}-${APP_VERSION}.war
ADD ${WAR_FILE} app.war

ENV JAVA_OPTS="-Djavax.net.ssl.trustStore=/var/ssl/daytrader/truststore.jks -Djavax.net.ssl.trustStorePassword=password"

ENTRYPOINT exec java $JAVA_OPTS -jar app.war
