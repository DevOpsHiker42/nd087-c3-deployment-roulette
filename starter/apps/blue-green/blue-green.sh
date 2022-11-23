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

wait_for_deploy()
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
}

########################################################################
# Main Script                                                          #
########################################################################

# Show script information
ShowInfo

# Execute a green deployment for the service apps/blue-green
kubectl apply -f green.yml

# Wait for the new deployment to successfully roll out and the service to be reachable
wait_for_deploy

echo "***********************************************"
echo "*** ALL DONE: Green deployment successful!  ***"
echo "***********************************************"
