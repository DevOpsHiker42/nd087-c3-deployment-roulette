#!/bin/bash
#
# Non-interactive Canary deployment script
# e.g. for use with GitHub Actions
#
########################################################################
# Functions                                                            #
########################################################################

ShowInfo()
{
  echo "Non-interactive Canary deployment script:"
  echo
  echo "Replicas are split as near as possible 50:50"
  echo "between v1 and v2."
  echo "Total replica count is kept as the initial v1 replica count."
  echo "If total replica count is odd, v1 takes precedence."
  echo
}

function deploy_canaries {
  # Get replica counts
  current_v1_replicas=$(kubectl get pods -n udacity | grep -c canary-v1)
  current_v2_replicas=$(kubectl get pods -n udacity | grep -c canary-v2)

  # Deploy v2 replicas one at a time, replacing a v1 replica if we
  # have too many of those

  while [ $target_v2_replicas -gt $current_v2_replicas ]
  do
    # Display status
    echo
    echo "Current Status:"
    echo "==============="
    echo "v1 pod replicas: " ${current_v1_replicas}
    echo "v2 pod replicas: " ${current_v2_replicas}
    echo

    # Increment v2 replicas by 1
    echo "...Increasing v2 replicas by 1..."
    kubectl scale deployment canary-v2 --replicas=$((current_v2_replicas + 1))

    # Decrement v1 replicas by 1 if we have too many
    if [ $current_v1_replicas -gt $target_v1_replicas ]
    then
      echo "...Decreasing v1 replicas by 1..."
      kubectl scale deployment canary-v1 --replicas=$((current_v1_replicas - 1))
    fi

    # Monitor v2 deployment
    monitor_v2_deploy

    # Update replica counts
    current_v1_replicas=$(kubectl get pods -n udacity | grep -c canary-v1)
    current_v2_replicas=$(kubectl get pods -n udacity | grep -c canary-v2)

  done

  # Finally scale v1 replicas to target in case we didn't quite get there
  if [ $current_v1_replicas -ne $target_v1_replicas ]
  then
    echo "...Scaling v1 replicas to final target value..."
    kubectl scale deployment canary-v1 --replicas=$((target_v1_replicas))
    monitor_v1_scale
  fi
}

function monitor_v2_deploy {
  # Monitor the v2 deployment every 5 seconds as it rolls out
  attempts=0
  rollout_status_cmd="kubectl rollout status deployment/canary-v2 -n udacity"
  until $rollout_status_cmd || [ $attempts -eq 12 ]; do
    $rollout_status_cmd
    attempts=$((attempts + 1))
    sleep 5
    echo "...v2 Deployment still rolling out..."
  done
}

function monitor_v1_scale {
  # Monitor the v1 scale every 5 seconds
  attempts=0
  rollout_status_cmd="kubectl rollout status deployment/canary-v1 -n udacity"
  until $rollout_status_cmd || [ $attempts -eq 12 ]; do
    $rollout_status_cmd
    attempts=$((attempts + 1))
    sleep 5
    echo "...v1 Deployment still scaling..."
  done
}

########################################################################
# Main Script                                                          #
########################################################################

# Show script information
ShowInfo

# Get total replica count
total_replicas=$(kubectl get pods -n udacity | grep -c canary-v1)
echo "Total replicas: "${total_replicas}
if [ $total_replicas -le 1 ]
then
  echo "*********************************************************************"
  echo "*** ERROR: Total replicas (existing v1 replica count) must be > 1 ***"
  echo "*********************************************************************"
fi

# Calculate target v1 and v2 replica counts
target_v2_replicas=$((total_replicas/2))
target_v1_replicas=$((total_replicas - target_v2_replicas))
echo "Target v1 replicas: "${target_v1_replicas}
echo "Target v2 replicas: "${target_v2_replicas}

# Stage v2 deployment
kubectl apply -f canary-v2.yml

# Start canary deployment rollout
deploy_canaries

echo "***********************************************"
echo "*** ALL DONE: Canary deployment successful! ***"
echo "***********************************************"
