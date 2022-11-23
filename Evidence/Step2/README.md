# Step 2: Canary Deployments
- Shell script `canary.sh` created in directory `starter/apps/canary`.
- Assumption that 50% of canary-v1 replicas needed to be replaced with canary-v2, so initial v1 replica count increased from 3 to 4 to allow for 2 of each.
- Deployed service was hit 10 times with curl and the results saved as `canary.txt` in the `starter/apps/canary` directory. This shows both canary-v1 and canary-v2 were reachable via the canary-svc.
- Output from `kubectl get pods --all-namespaces` saved as `canary2.txt` in `starter/apps/canary`
