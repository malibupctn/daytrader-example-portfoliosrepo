
# Portfolios Microservice

	The APIs to the portfolios business functions



## Current State Architecture

DayTrader is multi-tier application built around the paradigm of an online stock trading system. Example business functions include
login, register, view portfolio, lookup stock quotes, and buy or sell stock. DayTrader was originally developed by IBM and donated 
to the Apache Geronimo community in the 2005 timeframe. The DayTrader architecture is representitive of monolithic applications that 
many businesses are still using. For that reason, we selected it to clarify the techniques for refactoring a monolith to microservices. 
For the original monolithic architecture, see http://geronimo.apache.org/GMOxDOC30/daytrader-a-more-complex-application.html. 



## Target State Architecture

![Target-State-Architecture](images/Target-State-Architecture.JPG)



### Portfolios Application

The Portfolios Application(highlighted in the green box) is a Spring Boot Application responsible for managing user portfolios



#### Static Viewpoint

![Static-Viewpoint](images/Static-Viewpoint.JPG)



#### Dynamic Viewpoint

![Dynamic-Viewpoint](images/Dynamic-Viewpoint.JPG)



#### Participant and Responsibilities

![Participant-Responsibilities](images/Participant-Responsibilities.JPG)



### Portfolios Database

The Portfolios Database(highlighted in the green box) stores user portfolio information. 

![Database-Schema](images/Database-Schema.JPG)

Note: attributes not directly related to portfolios are struck through in the diagram.





## Prerequisites

### Installation

		1.	Java Development Kit (64 bit) 1.8+
		2.	Apache Maven 3.3.9+
		3.  DockerHub Account (https://hub.docker.com/)
		4.  Docker (https://www.docker.com/get-docker)
		5.  kubectl 1.10.3+ (https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html)
		6.  Minikube (https://kubernetes.io/docs/tasks/tools/install-minikube/)
		7.  AWS CLI (https://docs.aws.amazon.com/cli/latest/userguide/installing.html)

### Configuration

#### DockerHub

        The following settings are required for Maven to push Docker images to you DockerHub account

        1.  Change the following property in the "daytrader-portfolios" pom.xml file to your DockerHub user name:
    
            <docker.image.prefix>${user.name}</docker.image.prefix>
    
        2.  Add your DockerHub account settings as shown below to your Maven ~/.m2/settings.xml  

            <servers>
              <server>
                    <id>docker.io</id>
                    <username>docker_username</username>
                    <password>docker_password</password>
                </server>
            </servers>
        
   
    
#### kubectl

        1.  See https://docs.aws.amazon.com/eks/latest/userguide/configure-kubectl.html
    
            ## Follow the instructions in section "Install and Configure kubectl for Amazon EKS"
        
                
#### Kubernetes Cluster

        You have to have at least one cluster.

        1.  For Minikube, 
        
            $ minikube --memory 8192 --cpus 2 start
            
            ## Minikube comes pre-installed with a single node cluster that runs on your local computer
            
        2.  For EKS, Follow steps 1 to 3 in the getting started guide
        
            https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html#eks-create-cluster
        
        3.  If you installed Minikube and EKS, then you will have two contexts in your ~/.kube/config file: one for the Minikube cluster and the other 
            for the EKS cluster. This means that you will need to point kubectl to the correct cluster when running commands. To make it easier to do 
            that, 
            
                a.  Open the ~/.kube/config file and change the "name" of the AWS context to "eks".
            
                b.  Enter one of the following commands to kubectl to access the Minikube or the EKS cluster
        
                        - For Minikube, type "kubectl config set-context minikube"
                        
                        - For EKS, type "kubectl config set-context eks"
        
            Notes: After setting the context all subsequent commends go to that cluster. To change clusters, simply set the context to the other cluster.
   


## Delivery Pipeline

### Build Automation

		1.	cd daytrader-portfoliosapp
		2.	mvn clean install


### Continuous Integration

		1.	cd daytrader-portfoliosapp
		2.	mvn -Pci clean install


### Continuous Delivery

    Many of these manual steps can be automated by maven at a later date.
    

#### Create the Docker image and push it to DockerHub

        1.	$ cd daytrader-portfoliosapp
	    2.	$ mvn -Pcd clean install
		
	
#### Configure kubectl to access the right cluster
    
        1.  For Minikube,  
        
            $ minikube --memory 8192 --cpus 2 start
        
            $ kubectl config use-context minikube   
        
        2.  For EKS, 
        
            $ kubectl config use-context eks
            
            
#### Create the deployment, replica set, and pod(s) to run the application

	    1.  $ cd daytrader-portfoliosapp\daytrader-portfolios\env\external\k8s
    
		2.	$ kubectl apply -f portfolios-deployment.yaml 
		
		3.  $ kubectl get pods -o wide
		
		    ## Take note of the POD_NAME, and wait until the STATUS is Running.
              
        4.  $ kubectl logs {POD_NAME}
        
            ##  You should see : Tomcat started on port(s): 1443 (https)
        
        
#### Create the service so clients can communicate with pods via a constant IP

        It is important to norte that pods are ephemeral. If a pod dies, then Kubernetes may create an identical pod but it will have a 
        different IP. This means that clients shold not communicate with the pod IPs. Instead, all pods should be fronted by a service,
        and any communication to the pods go through the service IP. To create the service,

        1.  apply -f portfolios-service.yaml
        
        2.  kubectl get services
        
            ## Note of the CLUSTER-IP; that's the IP of the service proxy
             
        3.  $ kubectl exec {POD_NAME} -- curl -k https://{CLUSTER-IP}/health
        
            ## The above command instructs Kubernetes to execute the "curl" command inside the container of one of the pods. 
            ## Curl sent an HTTPS request to the service IP; which is backed by one of more pods. The service proxy selected
            ## a random pod and forwarded the request to it. The application running inside the pod handled the request, and
            ## an HTTPS response indicating that it is "UP". So you should see {"status":"UP"}
            
        See also https://kubernetes.io/docs/concepts/services-networking/service/

      
### Troubleshooting
        
    Review the standard output from your application using your pod names
    
        $ kubectl logs {POD_NAME} -f
        
        ## The -f option tails the logs
                
    Open a bash terminal using your pod names

        $ kubectl exec -ti {POD_NAME} bash
        # echo $SERVER_PORT    ## you should see 1443
        # exit
   


## API Endpoints 

### Swagger UI Documentation

	To see the API documentation, 

		1. Start the application

			a.	cd daytrader-portfoliosapp
			b. 	daytrader-portfolios\env\external\bin\start_server

		2. 	Point you browser to https://localhost:3443/swagger-ui.html

		3.	Stop the application after reviewing the APIs

			a.	cd daytrader-portfoliosapp	
			b.	daytrader-portfolios\env\external\bin\stop_server

