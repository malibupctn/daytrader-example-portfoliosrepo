
## Run on Kubernetes

### Build the Portfolios

1.  `$ cd daytrader-portfoliosapp`

2.  `$ mvn -Pcd clean install`

    This command builds the Docker Image and pushes it to the DockerHub registry

### Start the Portfolios

1.  `$ kubectl apply -f daytrader-portfolios/env/external/k8s/deployment.yaml`

    This command pulls the image from DockerHub and deploys it to the Kubernetes Cluster
    
2.  `$ kubectl get pods --watch`
    
    NAME | READY | STATUS | RESTARTS | AGE
    ---- | ----- | ------ | -------- | ---
    daytrader-portfolios-xxxxxxxxx-xxxxx | 1/1 | Running | 0 | 6m
    
    Watch until you see READY `1/1` and STATUS `Running` then Ctrl-c to stop watching
    
3.  `$ kubectl apply -f daytrader-portfolios/env/external/k8s/service.yaml`

**TODO** Add a `deploy_server` shell script to run these commands. (See Run on Spring Boot)

### Test the Portfolios
                                   
1.  `$ cd daytrader-portfolios`

2.  `$ mvn -Pci-k8s clean install`

    This command starts the application, runs the integration tests, and stops the application

    **TODO** Add a `ci-k8s` Maven profile to run these integration tests. (See Run on Spring Boot)
    
### Stop the Portfolios

1.  `$ kubectl delete deployments daytrader-portfolios`

2.  `$ kubectl delete services daytrader-portfolios`

**TODO** Add an `undeploy_server` shell script to run these commands. (See Run on Spring Boot)

### Review the Swagger Documentation

1.  Start the Portfolios

2.  `kubectl port-forward daytrader-portfolios-xxxxxxxxx-xxxxx`

    You should see `Forwarding from 127.0.0.1:8888 -> 3443`
    
    This command forwards local port 8888 to port 3443 of your Pod

3.  Point you browser to `https://localhost:3443/swagger-ui.html`

4.  Stop the Portfolios after reviewing the APIs


