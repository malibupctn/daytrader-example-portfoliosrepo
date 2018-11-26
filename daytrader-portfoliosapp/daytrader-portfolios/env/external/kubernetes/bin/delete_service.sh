#!/bin/sh
echo "in delete_service.sh"
#
# Set the current directory
#
echo "set the current directory $(pwd)"
export CURRENT_DIRECTORY=$(pwd)

#
# Delete the deployment
#
kubectl delete deployments $PROJECT_ARTIFACTID

#
# Delete the service
#
kubectl delete services $PROJECT_ARTIFACTID

#
# Stop the kubectl proxy
#
kill -9 $(pgrep -f "kubectl proxy")  

echo "end of create_service.sh"
#
# exit 0
