az aks get-credentials --resource-group devrg-k8s-infra --name devtodo-aks-cluster --overwrite-existing
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
### TO ACCESS ARGOCD SERVER FROM OUTSIDE THE CLUSTER
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

sleep 30
kubectl get svc -n argocd argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
sleep 10
### TO GET password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode

## user name --> admin