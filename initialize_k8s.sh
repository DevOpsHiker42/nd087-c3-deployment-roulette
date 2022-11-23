#!/bin/bash

set -e

kubectl apply -f starter/apps/hello-world
kubectl apply -f starter/apps/canary/index_v1_html.yml
kubectl apply -f starter/apps/canary/canary-v1.yml
kubectl apply -f starter/apps/blue-green/blue.yml
kubectl apply -f starter/apps/blue-green/index_blue_html.yml
