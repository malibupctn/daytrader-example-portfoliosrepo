                
## Setup on GKE

### Prerequisites

1.  [Create GCP Account](https://cloud.google.com/free/)

### Install the Cluster
    
1.  [Sign-in to Google Cloud Platform Console](console.cloud.google.com)

2.  [Install and initialize the Google Cloud SDK](//https://cloud.google.com/sdk/docs/quickstarts)

    **Note:** When you initialize the Google Cloud SDK, be sure to Create a new project named `daytrader`
    
    `$ gcloud container clusters create daytrader-gke-cluster`
            
    NAME | LOCATION | MASTER_VERSION | MASTER_IP | MACHINE_TYPE | NODE_VERSION | NUM_NODES | STATUS
    ---- | -------- | -------------- | --------- | ------------ | ------------ | --------- | ------
    gke-daytrader-cluster | us-central1-a | 1.9.7-gke.11 | xx.xx.xx.xx | n1-standard-1 | 1.9.7-gke.11 | 3 | RUNNING
        
3.  Get authentication credentials for the cluster
    
    `$ gcloud container clusters get-credentials daytrader-gke-cluster`
            
    This command updates your kubeconfig so that the kubectl command can connect to your new cluster.
    
4.  Configure kubeconfig

At this point you should have a cluster and `~/.kube/config` file created. That file has information about the cluster(s) you created. The `kubectl` command line interface uses that information to locate and authenticate to a cluster. If you have multiple clusters, then you can use `kubectl config use-context CONTEXT_NAME` command to point kubectl to a specific cluster. To make it easier for you to work with multiple clusters, edit the context name in the config file. For example,

**Original ~/.kube/config**

```yaml
- context:
    cluster: arn:aws:eks:us-east-1:xxxxxxxxxxxx:cluster/daytrader-eks-cluster
    user: arn:aws:eks:us-east-1:xxxxxxxxxxxx:cluster/daytrader-eks-cluster
  name: `arn:aws:eks:us-east-1:xxxxxxxxxxxx:cluster/daytrader-eks-cluster`
```

**Modified ~/.kube/config**

```yaml
- context:
    cluster: arn:aws:eks:us-east-1:xxxxxxxxxxxx:cluster/daytrader-eks-cluster
    user: arn:aws:eks:us-east-1:xxxxxxxxxxxx:cluster/daytrader-eks-cluster
  name: `daytrader-eks-cluster`
```
        
5.  Verify that the cluster is running

    `$ kubectl cluster-info`
                
    You should see `Kubernetes master is running at https://35.184.21.226`

6.  Verify that the worker nodes are running

     
    a.  `$ kubectl config use-context daytrader-gke-cluster`
                    
    You should see `Switched to context daytrader-gke-cluster`

    b.  `$ kubectl get nodes`
            
    NAME | STATUS | ROLES | AGE | VERSION
    ---- | ------ | ----- | --- | -------
    gke-daytrader-gke-cluste-default-pool-xxxxxxxx-xxxx | Ready | `<none>` | 7m11s | v1.9.7-gke.11
    gke-daytrader-gke-cluste-default-pool-xxxxxxxx-xxxx | Ready | `<none>` | 7m11s | v1.9.7-gke.11
    gke-daytrader-gke-cluste-default-pool-xxxxxxxx-xxxx | Ready | `<none>` | 7m11s | v1.9.7-gke.11

### Install the NGINX Ingress Controller
      
1.  Create the cluster role binding
        
    `$ kubectl create clusterrolebinding cluster-admin-binding --clusterrole cluster-admin --user $(gcloud config get-value account)`
    
    This command grants your GCP user account the permissions to administer the cluster.
                    
2.  Deploy the NGINX Ingress Controller
    
    a.  `$ kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/mandatory.yaml`
            
    b.  `$ kubectl -n ingress-nginx get pods`
                
    NAMESPACE | NAME | READY | STATUS | RESTARTS | AGE
    --------- | ---- | ----- | ------ | -------- | --- 
    ingress-nginx | nginx-ingress-controller-xxxxxxxxx-xxxxx | 1/1 | Running | 0 | 39s
    
    Wait for the controller start. It may take a few minutes

3.  Create the NGINX Ingress Service
    
    a.  `$ kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/provider/cloud-generic.yaml`
                
    b.  `$ kubectl -n ingress-nginx get services`
                
    NAME | TYPE | CLUSTER-IP | EXTERNAL-IP | PORT(S) | AGE
    ---- | ---- | ---------- | ----------- | ------- | ---
    ingress-nginx | LoadBalancer | 10.7.252.186 | xx.xx.xx.xx | 80:31884/TCP,443:31058/TCP | 55s
    
    Wait for the service to start. It may take a few minutes.
    
4.  Review the controller's logs. This is also useful for troubleshooting ingress resources.

    `$ kubectl -n ingress-nginx logs nginx-ingress-controller-*********-*****`

    You should see `successfully acquired lease ingress-nginx/ingress-controller-leader-nginx`
                            
### Install the Kubernetes Dashboard (N/A)
        
The Kubernetes Dashboard is disabled and deprecated in GKE. instead, use the [GKE Dashboard](https://cloud.google.com/kubernetes-engine/docs/concepts/dashboards) through the Console.

## Resources

1.  [Google Kubernetes Engine](https://cloud.google.com/kubernetes-engine/)


