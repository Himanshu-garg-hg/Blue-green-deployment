# install Istio first
az aks get-credentials --resource-group devrg-k8s-infra --name devtodo-aks-cluster --overwrite-existing
istioctl install --set profile=default -y
kubectl label namespace default istio-injection=enabled --overwrite
kubectl get namespace default --show-labels
# #verification
# kubectl get svc | grep microtodo-ui-service # single shared Service
# kubectl get deploy -l app=microtodo-ui # two deployments (blue & green) from different releases
# kubectl get pods -l version=blue
# kubectl get pods -l version=green
# kubectl get virtualservice,destinationrule -n default



#AGIC has permission to manage ingress in istio-system and App Gateway can reach istio-ingressgateway.
