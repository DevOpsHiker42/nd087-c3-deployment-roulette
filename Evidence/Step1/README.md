# Step 1: Debugging Steps for hello-world Application
1. Checked load balancer in AWS web console. No obvious issues, so proceeded to check load balancer targets, which were found to be unhealthy ![deployment-troubleshooting_01_Unhealthy_Targets.png](deployment-troubleshooting_01_Unhealthy_Targets.png)

2. Checked pods and found a crashed hello-world pod ![deployment-troubleshooting_02_Crashed_Pod.png](deployment-troubleshooting_02_Crashed_Pod.png)

3. Checked the pod events for the crashed pod using kubectl describe pod, and confirmed that liveness probe was failing ![deployment-troubleshooting_03_Unhealthy_Pod_Events.png](deployment-troubleshooting_03_Unhealthy_Pod_Events.png)

*N.B. For the screenshot, the command was executed a second time and passed through the tail command so that both the relevant events and pod name were both visible.*

4. Inspected the logs for the crashed pod - these gave the strong hint that the `/healthz` endpoint should be being checked for the health check ![deployment-troubleshooting_04_Unhealthy_Pod_Logs.png](deployment-troubleshooting_04_Unhealthy_Pod_Logs.png)

The liveness probe was amended accordingly in `hello.yml`

5. Following application of the amended YAML deployment, the endpoint became accessible ![deployment-troubleshooting_05_Fix_Applied.png](deployment-troubleshooting_05_Fix_Applied.png)

6. Rechecking the pods showed everything to be running healthily ![deployment-troubleshooting_06_Healthy_Pod.png](deployment-troubleshooting_06_Healthy_Pod.png)

7. Rechecking the load balancer targets showed that they were now also reporting as healthy ![deployment-troubleshooting_07_Healthy_Targets.png](deployment-troubleshooting_07_Healthy_Targets.png)

8. Output from `kubectl logs <pod_name>` verified as returning `healthy!`
![deployment-troubleshooting_08_Healthy_Pod_Log_Output.png](deployment-troubleshooting_08_Healthy_Pod_Log_Output.png)
