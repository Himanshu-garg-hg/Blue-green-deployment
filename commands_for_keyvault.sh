az aks get-credentials --resource-group devrg-k8s-infra --name devtodo-aks-cluster --overwrite-existing

az aks enable-addons  --addons azure-keyvault-secrets-provider   --resource-group devrg-k8s-infra   --name devtodo-aks-cluster




