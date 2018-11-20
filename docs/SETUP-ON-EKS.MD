                
## Setup on EKS

### Prerequisites

1.  [Create AWS Account](https://aws.amazon.com/premiumsupport/knowledge-center/create-and-activate-aws-account/)

### Install the Cluster

1.  Follow [EKS getting started guide](https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html) from `Amazon EKS Prerequisites` to `Step 4: Launch a Guest Book` exclusive.

2.  Configure kubeconfig

At this point you should have a cluster and `~/.kube/config` file created. That file has information about the cluster(s) you created. The `kubectl` command line interface uses that information to locate and authenticate to a cluster. If you have multiple clusters, then you can use `kubectl config use-context CONTEXT_NAME` command to point kubectl to a specific cluster. To make it easier for you to work with multiple clusters, edit the context name in the config file. For example,

**Original ~/.kube/config**

```yaml
- context:
    cluster: gke_daytrader-xxxxxx_us-central1-a_daytrader-gke-cluster
    user: gke_daytrader-xxxxxx_us-central1-a_daytrader-gke-cluster
  name: gke_daytrader-xxxxxx_us-central1-a_daytrader-gke-cluster
```

**Modified ~/.kube/config**

```yaml
- context:
    cluster: gke_daytrader-xxxxxx_us-central1-a_daytrader-gke-cluster
    user: gke_daytrader-xxxxxx_us-central1-a_daytrader-gke-cluster
  name: `daytrader-gke-cluster`
```

3.  Verify the EKS Cluster
     
    a.  `$ kubectl config use-context daytrader-eks-cluster`
                    
    You should see `Switched to context daytrader-eks-cluster`
                
    b.  `$ kubectl kubectl cluster-info`
                    
    You should see `Kubernetes master is running at https://8D36DB7CBD2E3394FF0843CEA0C0A266.sk1.us-east-1.eks.amazonaws.com`
                    
    c.  `$ kubectl get nodes`
                
    NAME | STATUS | ROLES | AGE | VERSION
    ---- | ------ | ----- | --- | -------
    ip-172-31-19-232.ec2.internal | Ready | `<none>` | 3h | v1.10.3
    ip-172-31-2-133.ec2.internal  | Ready | `<none>` | 3h | v1.10.3
    ip-172-31-30-11.ec2.internal  | Ready | `<none>` | 3h | v1.10.3

### Install the Ingres Controller

1.  Deploy the NGINX Ingress Controller
                
    a.  `$ kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/mandatory.yaml`
    
    b.  `$ kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/provider/cloud-generic.yaml`
                
    c.  `$ kubectl -n ingress-nginx get pods`
                    
    NAMESPACE | NAME | READY | STATUS | RESTARTS | AGE
    --------- | ---- | ----- | ------ | -------- | ---
    ingress-nginx | nginx-ingress-controller-xxxxxxxxx-xxxxx | 1/1 | Running | 0 | 39s
    
    Wait for the controller start. It may take a few minutes
                    
3.  Review the logs to verify the installation. This is also useful for troubleshooting ingress resources.
                
    `$ kubectl -n ingress-nginx logs nginx-ingress-controller-xxxxxxxxx-xxxxx`
                   
    You should see `successfully acquired lease ingress-nginx/ingress-controller-leader-nginx`
                    
### Install the Kubernetes Dashboard

The Kubernetes is a great resource for managing and troubleshooting the cluster. To install it,
                   
1.  Get the token so you can authenticate with the Kubernetes Dashboard

    a.  `$ kubectl -n kube-system get secrets | grep admin`
       
    Record the NAME of the `admin-user-token`
        
    b.  `$ kubectl -n kube-system describe secrets ADMIN_USER_TOKEN`
        
    Copy the value of the `authentication token`
                            
2.  Start the proxy so you can authenticate with the Kubernetes API Server

    `$ kubectl proxy`

3.  Open the following link to access the Kubernetes Dashboard through the API Server
        
    `http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/`
            
4.  You will see a login screen; choose `Token` and then enter the value of the `authentication token` from Step 2. 

## Resources 

1.  [Amazon Elastic Container Service for Kubernetes](https://aws.amazon.com/eks/)

2.  [NGINX Ingress Controller Installation Guide](https://kubernetes.github.io/ingress-nginx/deploy/)

3.  [Troubleshooting Authentication to the Kubernetes Dashboard](https://github.com/AcalephStorage/kubernetes-dashboard/blob/master/docs/user-guide/troubleshooting.md)
    
4.  [Tutorial: Deploy the Kubernetes Web UI (Dashboard)](https://docs.aws.amazon.com/eks/latest/userguide/dashboard-tutorial.html)


