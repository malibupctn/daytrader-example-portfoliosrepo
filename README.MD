
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

#### For building Docker images and pushing them to a Docker registry

		1.	Inatall Java Development Kit (64 bit) 1.8+
		2.	Install Apache Maven 3.3.9+
		3.  Create DockerHub Account (https://hub.docker.com/)
		4.  Install Docker (https://www.docker.com/get-docker)
		
#### For deploying and managing applications on Kubernetes

		1.  Install kubectl (https://kubernetes.io/docs/tasks/tools/install-kubectl/)

#### For running Kubernetes on Minikube 

		1.  Install Minikube (https://kubernetes.io/docs/setup/minikube/)

#### For running Kubernetes on Amazon EKS

		1.  Create AWS Account (https://aws.amazon.com/premiumsupport/knowledge-center/create-and-activate-aws-account/)
		2.  Install AWS IAM Authenticator (https://docs.aws.amazon.com/eks/latest/userguide/configure-kubectl.html)
		2.  Install AWS Command Line Interface (https://docs.aws.amazon.com/cli/latest/userguide/installing.html)
		3.  Install eksctl (https://github.com/weaveworks/eksctl)


### Configuration

#### Maven

        The following settings are required for Maven to push Docker images to you DockerHub account

        1.  Change the following property in daytrader-portfolios/pom.xml to your DockerHub user name:
    
            <docker.image.prefix>${user.name}</docker.image.prefix>
               
        3.  Change the following key-value in daytrader-portfolios/env/external/k8s/portfolios-deployment.yaml to your DockerHub user name
        
            image: YOUR_DOCKERHUB_USERNAME/daytrader-gateway:4.0.18
        
        4.  The following property in daytrader-portfolios/pom.xml is also worth noting. You do not have to change it, but if you do, change the above key-value accordingly.
        
    		<tag>4.0.18</tag>
        
        5.  Add the following settings to your Maven ~/.m2/settings.xml so Maven can push images to your DockerHub account

                <servers>
                  <server>
                        <id>docker.io</id>
                        <username>YOUR_DOCKERHUB_USERNAME</username>
                        <password>YOUR_DOCKERHUB_PASSWORD</password>
                    </server>
                </servers>       
   
        

#### AWS CLI

        1.  Configuring the AWS CLI (https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html)

                
                
#### Kubernetes Cluster

        1.  You must have at least one Kubernetes cluster.

                a.  For Minikube,
        
                    $ minikube --memory 8192 --cpus 2 start
            
                    ## Minikube comes with a cluster. It was running out of memory so increased to 8GB of RAM. You may be able to run with less RAM, but that setting worked well.
            
                b.  For EKS, 
        
                    $ eksctl create cluster --name=user116-eks-cluster --region=us-east-1
            
                    ## This command creates an EKS cluster named user116-eks-cluster in the us-east-1 region. For additional details on parameters, see https://github.com/weaveworks/eksctl
            
        2.  If you installed Minikube and Amazon EKS, then you will have two contexts in your ~/.kube/config file. One of those contexts is for accessing the Minikube
            cluster; the other context is for accessing the EKS cluster. You must set the context to the cluster before running kubectl commands. Set the context once
            then all subsequent kubectl commands will be directed to that cluster. Set it again and the kubectl commands will go to the other cluster. To do that,
                  
                a.  For Minikube, 
                
                    $ kubectl config use-context minikube
                        
                b.  For Amazon EKS, 
                
                    $ kubectl config use-context user116-eks-cluster  ## Use the name of your Amazon EKS cluster

        3.  Now you can verify your cluster by running some kubectl commands
        
                a.  For Minikube
        
                    $ kubectl config use-context minikube
                    
                    Switched to context "minikube".

                    $ kubectl cluster-info
                    
                    Kubernetes master is running at https://192.168.99.100:8443
                    KubeDNS is running at https://192.168.99.100:8443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
                        
                b.  For Amazon EKS,
        
                    $ kubectl config use-context user116-eks-cluster  ## Use the name of your Amazon EKS cluster
                    
                    Switched to context "user116-eks-cluster".
            
                    $ kubectl kubectl cluster-info
                    
                    Kubernetes master is running at https://8D36DB7CBD2E3394FF0843CEA0C0A266.sk1.us-east-1.eks.amazonaws.com
   


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
		
	
#### Configure kubectl to access the cluster
    
        1.  For Minikube,  
        
            $ minikube --memory 8192 --cpus 2 start
        
            $ kubectl config use-context minikube   
        
        2.  For EKS, 
        
            $ kubectl config use-context eks
            
            
            
#### Create a Deployment to run the application in one or more pods

    Notes: A Deployment also creates the specified number of PODs and a ReplicaSet to manage the lifecycle of the pods

	    1.  $ cd daytrader-portfoliosapp\daytrader-portfolios\env\external\k8s
    
		2.	$ kubectl apply -f deployment.yaml 
		
		
		3.  $ kubectl get pods
		
    		NAME                                    READY   STATUS    RESTARTS   AGE  
            daytrader-portfolios-87b5658f4-889gp    1/1     Running   0          6m   
		
		    ## Record the NAME of the pod, and wait until the STATUS is Running and all pods are READY (e.g. 1/1, 2/2, or 3/3)
              
        4.  $ kubectl logs <POD_NAME>
        
            ##  You should see : Tomcat started on port(s): 3443 (https). If not see Troubleshooting
            
        
#### Create a Service to load balance requests across the Pods

	Before creating the service it is important to understand the rationale for creating them. Remember that pods are ephemeral. If 
	a pod stops, then Kubernetes will create an identical one, but it will have a different IP. For that reason, clients should not 
	communicate with application's directly. Instead they should talk to applications via service. To create the service,
        
        1.  $ kubectl apply -f service.yaml
           
        2.  $ kubectl get services
        
            NAME            	    TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)         AGE
            daytrader-portfolios	ClusterIP   10.100.17.24     <none>        443/TCP         3d
       
            ## Notes
        
            	a.	The above command creates a service resource. This resource listens on the CLUSTER IP and PORT. It is backed by endpoints 
               	    to one or more pods. You can see the dnpoints buy doing kubectl get endpoints. When the service receives an HTTPS request, 
               	    it selects one of the endpoints (pods) and forwards the HTTPS request to the pod. The application running inside the pod 
               	    handles the request and returns an HTTPS response.
            	
              	b.	See also https://kubernetes.io/docs/concepts/services-networking/service/      



                            
## Troubleshooting


### Pods
        
        1.	Retrieve the pods (application) logs
    
	           	a.	$ kubectl logs {POD_NAME} -f      ## The -f option tails the logs
               

        2.  Access the pod (application) through the port forwarder
        
	            a.	$ kubectl port-forward <POD_NAME> 8888:3443  ## This command forwards local port 8888 to port 3443 of your pod
       
        	    	Forwarding from 127.0.0.1:8888 -> 3443
       
	            b.	$ curl -k https://127.0.0.1:8888/health

        	    	{"status":"UP"}      

        	    	
### Services
        
        1.	Access the service (application) through the API Server
                        
	    		a.	$ kubectl proxy
        
	    			Starting to serve on 127.0.0.1:8001
                
	    			## Locates and authenticates to the API Server.

    			b.	$ curl -k http://localhost:8001/api/v1/namespaces/default/services/https:daytrader-portfolios:/proxy/health      
		
	    			{"status":"UP"}      		
				
	    		    ## The curl command sent the HTTP request (without any authentication headers) to the proxy that is running on your local machine.
	    		    ## The proxy, then, sent an HTTPS request to the API server's identity by validating its certificate. Encryption, authentication,
	    		    ## and server verification is handled by the proxy. This is the easiest way to connect to the API server. 
			    
	    		c. See also
						  
	    		   - https://kubernetes.io/docs/tasks/administer-cluster/access-cluster-api/ 

	    		   
### Secrets
			                 
	    1.	Check and verify your certificate and key. This can be useful before applying them to your server. 

		        a.	$ openssl x509 -in tls.crt -text  ## Check the certificate and its information (signing authority, expiration date, etc.)

        		b.	$ openssl rsa -in tls.key -check  ## Check the SSL key and verify the consistency
    
    	2. 	Verify the certificate and key match by comparing their checksums for equality

	        	a.	$ openssl x509 -noout -modulus -in tls.crt | openssl md5
        
        		b.	$ openssl rsa -noout -modulus -in tls.key | openssl md5      
        
        

### Dashboard

        1.  Use kubernetes dashboard to manage and troubleshoot your cluster
        
            For Minikube
        
                a.  $ minikube dashboard
        
            For EKS
        
                a.  $ kubectl proxy
                
                b.  $ kubectl -n kube-system get secrets | grep admin
               
                      ## Copy the NAME of the admin-user-token
                
                c.  $ kubectl -n kube-system describe secrets <ADMIN_USER_TOKEN>
                
                    ## Copy the value of the authentication token
                                    
                d.  Open the following link in a browser to access the dashboard
                
                    http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/
                    
                e.  You will see a login screen; choose Token and then enter the <AUTHENTICATION_TOKEN> from step c. 
   
            See also 
    
                a.  https://github.com/AcalephStorage/kubernetes-dashboard/blob/master/docs/user-guide/troubleshooting.md
                b.  https://docs.aws.amazon.com/eks/latest/userguide/dashboard-tutorial.html



## Swagger UI Documentation


### Access Swagger UI via Spring Boot

#### Local

   		1. Make sure the application is running

     			$ cd daytrader-portfoliosapp
       			$ daytrader-portfolios\env\external\bin\start_server

   		2. 	Point you browser to https://localhost:3443/swagger-ui.html

	    3.	Stop the application after reviewing the APIs

      			$ cd daytrader-portfoliosapp	
            	$ daytrader-portfolios\env\external\bin\stop_server


### Access Swagger UI via Kubernetes


#### Pod
        
        1.  Make sure the application is accessible via the Pod (port forwarding)
                
   		2. 	Point you browser to https://localhost:8888/swagger-ui.html

#### Service
        
        1.  Make sure the application is accessible via the Service (kubectl proxy)

		2. 	Point you browser to http://localhost:8001/api/v1/namespaces/default/services/https:daytrader-portfolios:/proxy/swagger-ui.html        		
        		

         

