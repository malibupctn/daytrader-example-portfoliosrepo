## Setup on Minikube



### Prerequisites

1.  [Install kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
   

### Install the Cluster
    
1.  [Install the latest release of Minikube](https://github.com/kubernetes/minikube/releases)

2.  Start the Minikube cluster
        
    `$ minikube start --cpus 2 --memory 8192`
                
    You should see `Kubectl is now configured to use the cluster`
        
3.  Verify the Minikube cluster
        
    a.  `$ kubectl config use-context minikube`
            
        You should see `Switched to context "minikube"`

    b.  `$ kubectl cluster-info`
            
    You should see `Kubernetes master is running at https://192.168.99.100:8443`
            
    c.  `$ kubectl get nodes`
            
    NAME | STATUS | ROLES | AGE | VERSION
    ---- | ------ | ----- | --- | -------
    minikube | Ready | master | 24d | v1.10.0
        

### Install the NGINX Ingress Controller
        
1.  Create configmaps for tcp-services and udp-services; otherwise the controller will throw an unexpected error
        
    a.  `$ cd daytrader-webapp/daytrader-web/env/external/k8s`
            
    b.  `$ kubectl apply -f tcp-services-configmap.yaml`
            
    c.  `$ kubectl apply -f udp-services-configmap.yaml`
        
2.  Enable the ingress add-on
       
    a.  `$ minikube addons enable ingress`
            
    You should see `ingress was successfully enabled`
            
    b.  `$ kubectl -n kube-system get pods`
            
    NAMESPACE | NAME | READY | STATUS | RESTARTS | AGE
    --------- | ---- | ----- | ------ | -------- | ---
    kube-system | nginx-ingress-controller-xxxxxxxxxx-xxxxx | 1/1 | Running | 0 | 39s
    
    Wait for the controller to start. It may take a few minutes.
            
4.  Review the logs to verify the installation. This is also useful for troubleshooting ingress resources.
        
    `$ kubectl -n kube-system logs <POD_NAME>`
            
    You should see `successfully acquired lease kube-system/ingress-controller-leader-nginx`

### Install the Kubernetes Dashboard (Optional)

The Kubernetes Dashboard can be useful for managing and troubleshooting your cluster
       
`$ minikube dashboard`

This command opens the Kubernetes Dashboard in a browser
        

## Resources 

1.  [Running Kubernetes Locally via Minikube](https://kubernetes.io/docs/setup/minikube/)

2.  [Ingress ConfigMap](https://github.com/kubernetes/minikube/blob/master/deploy/addons/ingress/ingress-configmap.yaml/)

3.  [NGINX Ingress Controller Installation Guide](https://kubernetes.github.io/ingress-nginx/deploy/)


