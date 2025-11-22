kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
### TO ACCESS ARGOCD SERVER FROM OUTSIDE THE CLUSTER
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'


kubectl get svc -n argocd argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
### TO GET password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode