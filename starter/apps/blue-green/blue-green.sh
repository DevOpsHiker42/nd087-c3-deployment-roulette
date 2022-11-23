#!/bin/bash
# 
# Green deployment script
#
########################################################################
# Functions                                                            #
########################################################################

ShowInfo()
{
  echo "Green deployment script"
  echo
}

wait_for_green_service()
{
  # Monitor the deployment every 5 seconds
  attempts=0
  rollout_status_cmd="kubectl rollout status deployment/green -n udacity"
  until $rollout_status_cmd || [ $attempts -eq 12 ]; do                
    $rollout_status_cmd
    attempts=$((attempts + 1))
    sleep 5
    echo "...deploying..."
  done 

  # Wait for the service to be reachable
  green_svc_hostname=$(kubectl get service green-svc -n udacity -o json \
                     | jq -r .status.loadBalancer.ingress[].hostname)
  curlcmd="curl --output /dev/null --silent --head --fail $green_svc_hostname"
  until $curlcmd; do
    echo "Waiting for Green service: " ${green_svc_hostname}
    sleep 1
  done
}

########################################################################
# Main Script                                                          #
########################################################################

# Show script information
ShowInfo

# Apply green configmap
kubectl apply -f index_green_html.yml

# Execute a green deployment for the service apps/blue-green
kubectl apply -f green.yml

# Wait for the new deployment to successfully roll out and the service to be reachable
wait_for_green_service

echo "***********************************************"
echo "*** ALL DONE: Green deployment successful!  ***"
echo "***********************************************"
