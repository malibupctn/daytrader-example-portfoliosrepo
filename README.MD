
# Portfolios Microservice

The APIs to the portfolios business operations


## Monolithic Architecture
DayTrader is multi-tier application is built around the paradigm of an online stock trading system. Example business operations include
login, register, view portfolio, lookup stock quotes, and buy or sell stock. DayTrader was originally developed by IBM and donated 
to the Apache Geronimo community in the 2005 timeframe. The DayTrader architecture is representitive of monolithic applications that 
many businesses are still using. For that reason, we selected it to clarify the techniques for refactoring a monolith to microservices. 
For the monolithic architecture, see [daytrader - a more complex application](http://geronimo.apache.org/GMOxDOC30/daytrader-a-more-complex-application.html). 



## Microservices Architecture

Consider the following microservices architecture diagram. In this architecture, the Web is responsible for the UI to the DayTrader business operations. It accepts 
incoming HTTPS requests from the browser and delegates them to the [Gateway Microservice](https://github.com/jpmorganchase/daytrader-example-gatewayrepo/). The 
Gateway Microservice in turn redirects the request to the ([Accounts Microservice](https://github.com/jpmorganchase/daytrader-example-accountsrepo/), 
[Portfolios Microservice](https://github.com/jpmorganchase/daytrader-example-portfoliosrepo/), or 
[Quotes Microservice](https://github.com/jpmorganchase/daytrader-example-quotesrepo/); which implements that business operation. All of these componenets are Spring Boot applications.

![Target-State-Architecture](images/Target-State-Architecture.JPG)

This README shows how to put Portfolios into a Docker Image and how to deploy that Docker Image to Kubernetes. 



## Prerequisites

1.  [Install Java 8](http://www.oracle.com/technetwork/java/javase/downloads/index.html)

2.  [Install Maven 3.3.9+](https://maven.apache.org/download.cgi)

3.  [Install Docker](https://www.docker.com/get-docker)
    
4.  [Create DockerHub Account](https://hub.docker.com/)



## Configuration

Maven must be able to authenticate to your DockerHub account so it can push Docker images

1.  In `daytrader-portfolios/pom.xml` change the ${user.name} to your DockerHub user name:

    ```xml
    <docker.image.prefix>${user.name}</docker.image.prefix>
    ``` 

2.  In `daytrader-portfolios/env/external/k8s/portfolios-deployment.yaml`, change the image to your DockerHub username

    ```yaml
    image: YOUR_DOCKERHUB_USERNAME/daytrader-portfolios:4.0.18
    ```

3.  In `daytrader-portfolios/pom.xml`, you don't have to change the <tag>, but if you do, change the above version too.
        
    ```xml
    <tag>4.0.18</tag>
    ```

4.  In `~/.m2/settings.xml`, add the following so Maven can push images to your DockerHub account

    ```xml
    <servers>
        <server>
            <id>docker.io</id>
            <username>YOUR_DOCKERHUB_USERNAME</username>
            <password>YOUR_DOCKERHUB_PASSWORD</password>
        </server>
    </servers> 
    ```

## Setup
You will need a cluster to run the application. If you already have a cluster with the NGINX Ingress Controller installed then feel free to use it. If not, we have provided instructions to help you setup a cluster on Minikube, Amazon EKS, Google Kubernetes Engine, and Azure Kubernetes Service. We have also tested the application on those platforms. For additional information see [Picking the right Solution](https://kubernetes.io/docs/setup/pick-right-solution/).  

1.  [Setup on Minikube](docs/SETUP-ON-MINIKUBE.MD)

2.  [Setup on Amazon EKS](docs/SETUP-ON-EKS.MD)

3.  [Setup on Google GKE](docs/SETUP-ON-GKE.MD)

3.  [Setup on Azure AKS](docs/SETUP-ON-AKS.MD)



## Build, Release, and Run

You can run the application on Spring Boot or on the Kubernetes Cluser.

1.  [Run on Spring Boot](docs/RUN-ON-SPRING-BOOT.MD)

2.  [Run on Kubernetes Cluster](docs/RUN-ON-SPRING-BOOT.MD)

**Note** Portfolios is 100% portable across the Kubernetes Platforms we tested.


    
## Steps to Generate the Docker Image

These steps were very straightforward and easy to perform.
 
### Create the Dockerfile
    
The `Dockerfile` is where you define all the commands to setup the environment and start the Portfolios in the container.

```yaml
FROM openjdk:8-jdk
VOLUME /tmp
MAINTAINER Donald Vines <donald_vines@hotmail.com>
# Set ssl variables
ENV DAYTRADER_KEYSTORE_FILENAME=/var/ssl/daytrader/keystore.jks
ENV DAYTRADER_KEYSTORE_PASSWORD=password
ENV DAYTRADER_TRUSTSTORE_LOCATION=/var/ssl/daytrader/truststore.jks
ENV DAYTRADER_TRUSTSTORE_PASSWORD=password
# Set app variables
ENV DAYTRADER_APP_VERSION=4.0.0
ENV DAYTRADER_APP_ARTIFACTID=daytrader-portfoliosapp
ENV DAYTRADER_WAR_ARTIFACTID=daytrader-portfolios
# Set database variables
ENV DAYTRADER_DATABASE_DRIVER=org.apache.derby.jdbc.EmbeddedDriver
ENV DAYTRADER_DATABASE_URL='jdbc:derby:tradesdb;create=true'
ENV DAYTRADER_DATABASE_USERNAME=xxx
ENV DAYTRADER_DATABASE_PASSWORD=xxx
# Set tomcat variables
ENV SERVER_PORT=3443
ENV SERVER_PORT_HTTPS=3443
# Make port visible
EXPOSE 3443
# Set service routes
ENV DAYTRADER_ACCOUNTS_SERVICE=https://daytrader-accounts
ENV DAYTRADER_GATEWAY_SERVICE=https://daytrader-gateway
ENV DAYTRADER_PORTFOLIOS_SERVICE=https://daytrader-portfolios
ENV DAYTRADER_QUOTES_SERVICE=https://daytrader-quotes
# Set logging variables
ENV DAYTRADER_LOG_FILENAME=/var/log/daytrader/$DAYTRADER_APP_ARTIFACTID-$DAYTRADER_APP_VERSION.log
ENV DAYTRADER_LOG_LEVEL=TRACE
ENV DAYTRADER_LOG_APPENDER=ConsoleAppender
# Create the log folder
RUN mkdir -p -m 0777 /var/log/daytrader
# Create the log file and set permissions
RUN touch $DAYTRADER_LOG_FILENAME
RUN chmod 666 $DAYTRADER_LOG_FILENAME
# Create the ssl folder
RUN mkdir -p -m 0777 /var/ssl/daytrader
# Add the truststore to the container and set permissions
ARG JKS_FILE=target/$DAYTRADER_WAR_ARTIFACTID-$DAYTRADER_APP_VERSION/WEB-INF/classes/truststore.jks
ADD ${JKS_FILE} $DAYTRADER_TRUSTSTORE_LOCATION
RUN chmod 666 $DAYTRADER_TRUSTSTORE_LOCATION
# Add the application's war to the container
ARG WAR_FILE=target/$DAYTRADER_WAR_ARTIFACTID-$DAYTRADER_APP_VERSION.war
ADD ${WAR_FILE} app.war
ENV JAVA_OPTS="-Djavax.net.ssl.trustStore=/var/ssl/daytrader/truststore.jks -Djavax.net.ssl.trustStorePassword=password"
ENTRYPOINT exec java $JAVA_OPTS -jar app.war
```

### Add Dockerfile Maven Plugin

In `daytrader-portfoliosapp/daytrader-portfolios/pom.xml`, add the [Dockerfile Maven Plugin](https://github.com/spotify/dockerfile-maven) and specify the DockerHub account. 
        
```xml
<plugin>
    <groupId>com.spotify</groupId>
    <artifactId>dockerfile-maven-plugin</artifactId>
    <version>${dockerfile-maven-version}</version>
    <executions>
        <execution>
            <phase>package</phase>
            <goals>
                <goal>build</goal>    <!-- Builds the Docker image -->
                <goal>push</goal>     <!-- Pushes the Docker image -->
            </goals>
        </execution>
    </executions>
    <configuration>
        <repository>${docker.image.prefix}/${project.artifactId}</repository>
        <tag>4.0.18</tag>
        <buildArgs>
            <JAR_FILE>target/${project.artifactId}-${project.version}.war</JAR_FILE>
        </buildArgs>
        <useMavenSettingsForAuth>true</useMavenSettingsForAuth>   <!-- Authenticates to your DockerHub account -->
    </configuration>
</plugin>
```

### Build and Push the Docker image

With the `Dockerfile` and the `Dockerfile Maven Plugin` in place, we can use Maven to build and push the Docker image to DockerHub.

1.  `$ cd daytrader-portfoliosapp`

2.  `$ mvn -Pcd clean install`

This command creates an image with the version <tag> you specified in the configuration. You can update this <tag> for a rolling update.
    
    
## Steps to Deploy the Docker Image to a Kubernetes Cluster

Deployment to Kubernetes required a number of manual steps. Some of these steps were to specify the configuration of the resources; others were to create the resources; and still others were used to verify the deployment. You only have to specify the configuration once; after that you can use it to create the resources. The creation of resources has be done whenever you do a deployment. As such they should be automated via Maven. The other other steps to verify the deployment should only used by developers troubleshooting a problem. Before automating though it is important to first identify the manual steps which is what we do in this section. 

**Notes** 

1.  All configuration files are located in this folder: `daytrader-portfoliosapp/daytrader-portfolios/env/external/k8s`

2.  All configuration files and `kubectl` commands were 100% portable across the Kubernetes platforms we tested.

    This means you write configuration files once and run them on any platform. This is great news for DevOps!

### Create the Deployment for our Docker Image

#### Use `yaml` to specify the deployment configuration

The `deployment.yaml` is where you specify the Docker Image for your application along with other specs
    
```yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  labels:
    app: daytrader-portfolios
  name: daytrader-portfolios
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: daytrader-portfolios
  template:
    metadata:
      labels:
        app: daytrader-portfolios
    spec:
      containers:
      - name: daytrader-portfolios
        image: dhvines/daytrader-portfolios:4.0.18
        imagePullPolicy: Always
        ports:
        - containerPort: 3443
          protocol: TCP
        readinessProbe:  
          httpGet:
            path: /health
            scheme: HTTPS
            port: 3443
          initialDelaySeconds: 30
          periodSeconds: 30
          timeoutSeconds: 10
        livenessProbe:  
          httpGet:
            path: /health
            scheme: HTTPS
            port: 3443
          initialDelaySeconds: 30
          periodSeconds: 30
          timeoutSeconds: 10
          failureThreshold: 4
        env:
        - name: ACCOUNTS_SERVICE_ROUTE
          value: https://daytrader-accounts
        - name: GATEWAY_SERVICE_ROUTE
          value: https://daytrader-gateway
        - name: PORTFOLIOS_SERVICE_ROUTE
          value: https://daytrader-portfolios
        - name: QUOTES_SERVICE_ROUTE
          value: https://daytrader-quotes
        - name: GET_HOSTS_FROM
          value: dns
```
#### Use `kubectl apply -f` to create the deloyment resource

1.  `$ kubectl apply -f deployment.yaml`

    This command creates a Deployment resource, which creates the ReplicaSet, which then creates the Pods
    
2.  `$ kubectl get pods`
    
    NAME | READY | STATUS | RESTARTS | AGE
    ---- | ----- | ------ | -------- | ---
    daytrader-portfolios-xxxxxxxxx-xxxxx | 1/1 | Running | 0 | 6m
    
    Wait until you see READY `1/1` and STATUS `Running`
              
3.  Review the pods (application) logs
        
    `$ kubectl logs daytrader-portfolios-xxxxxxxxx-xxxxx -f`
    
    You should see `Tomcat started on port(s): 3443 (https)`
    
#### Use `kubectl port-forward` to test the connection
        
1.  `$ kubectl port-forward daytrader-portfolios-xxxxxxxxx-xxxxx 8888:3443`
    
    This command forwards local port 8888 to port 3443 of your pod
       
    You should see `Forwarding from 127.0.0.1:8888 -> 3443`
       
2.  `$ curl -k https://127.0.0.1:8888/health`

    You should see `{"status":"UP"}` 
            
### Create the Service for our Pod

The Service load balances requests across the Pods. Remember that the pods are ephemeral. So if one of them stops, the ReplicaSet will 
create a replacement, but that Pod will have a different IP address. For that reason, clients should not communicate directly with the 
application in a Pod. Instead clients should talk to applications via their service. 
    
#### Use `yaml` to specify the service configuration

The `service.yaml` is where you specify the selector for the backend pods along with other specifications

```yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    app: daytrader-portfolios
  name: daytrader-portfolios
  namespace: default
spec:
  ports:
  - port: 443
    protocol: TCP
    targetPort: 3443
  selector:
    app: daytrader-portfolios
  sessionAffinity: None
  type: ClusterIP
```

#### Use `kubectl apply -f` to create the service resource

1.  `$ kubectl apply -f service.yaml`
           
2.  `$ kubectl get services`
        
    NAME | TYPE | CLUSTER-IP | EXTERNAL-IP | PORT(S) | AGE
    ---- | ---- | ---------- | ----------- | ------- | ---
    daytrader-portfolios | ClusterIP | 10.100.17.24 | <none> | 443/TCP | 38s
       
    The above command creates a service resource. This resource listens on the CLUSTER IP and PORT. It is backed by endpoints 
    to one or more pods. You can see the enpoints buy doing `kubectl get endpoints`. When the service receives an HTTPS request,
    it selects one of the endpoints (pods) and forwards the HTTPS request to the pod. The application running inside the pod 
    handles the request and returns an HTTPS response.
            
    See also [Kubernetes Concepts - Services, Load Balancing, and Networking](https://kubernetes.io/docs/concepts/services-networking/service)

#### Use `kubectl proxy` to test the connection
                        
1.  Start the proxy to locates and authenticate to the API Server.
    
    `$ kubectl proxy`
        
    You should see `Starting to serve on 127.0.0.1:8001`
            
2.  If you get a port binding error then find the processId for that server and kill it 

    `$ lsof -P | grep ':8001'`
    `$ kill -9 processId`

3.  Test the connection using the `curl` command

    `$ curl -k http://localhost:8001/api/v1/namespaces/default/services/https:daytrader-web:/proxy/health`
    
    You should see `{"status":"UP"}`
    
    The above curl command sends the HTTP request (without any authentication headers) to the proxy that is running on your local machine.
    The proxy, then, sends an HTTPS request with appropriate authentication headers to the API server. This is the easiest way to connect 
    to the API server. 
    
4.  See also [Access Clusters Using the Kubernetes API](https://kubernetes.io/docs/tasks/administer-cluster/access-cluster-api/) 




