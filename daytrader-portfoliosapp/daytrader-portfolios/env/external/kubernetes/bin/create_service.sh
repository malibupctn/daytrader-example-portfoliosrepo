#!/bin/sh
echo "in create_service.sh"
#
# Set the current directory
#
echo "set the current directory $(pwd)"
export CURRENT_DIRECTORY=$(pwd)

#
# Create the deployment an wait for it to start
#
kubectl apply -f $CURRENT_DIRECTORY/env/external/kubernetes/conf/deployment.yaml
until kubectl get pods | grep -m 1 "$PROJECT_ARTIFACTID.*1/1"; do : ; done

#
# Create the service
#
kubectl apply -f $CURRENT_DIRECTORY/env/external/kubernetes/conf/service.yaml

#
# Start the kubectl proxy
#
kubectl proxy </dev/null &>/dev/null &

echo "end of create_service.sh"
#
# exit 0
