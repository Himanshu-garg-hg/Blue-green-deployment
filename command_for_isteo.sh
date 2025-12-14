
# ===================================================================
# ISTIO SERVICE MESH SETUP COMMANDS
# ===================================================================

# 1. CONNECT TO AZURE KUBERNETES CLUSTER
# -------------------------------------------------------------------
az aks get-credentials --resource-group devrg-k8s-infra --name devtodo-aks-cluster --overwrite-existing


# 2. INSTALL ISTIO
# -------------------------------------------------------------------
istioctl install --set profile=default -y


# 3. ENABLE SIDECAR INJECTION FOR DEFAULT NAMESPACE
# -------------------------------------------------------------------
kubectl label namespace default istio-injection=enabled --overwrite


# 4. VERIFY NAMESPACE LABELS
# -------------------------------------------------------------------
kubectl get namespace default --show-labels


# ===================================================================
# OPTIONAL: MONITORING & VISUALIZATION SETUP
# ===================================================================

# 5. INSTALL KIALI (Service Mesh Visualization Dashboard)
# -------------------------------------------------------------------
# kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.28/samples/addons/kiali.yaml


# 6. INSTALL PROMETHEUS (Metrics Collection)
# -------------------------------------------------------------------
# kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.18/samples/addons/prometheus.yaml


# 7. LAUNCH KIALI DASHBOARD
# -------------------------------------------------------------------
# istioctl dashboard kiali


# ===================================================================
# NOTES:
# - Execute commands in order
# - Ensure kubectl is configured before running
# - Kiali dashboard helps visualize service mesh traffic flows
# - Prometheus stores metrics for monitoring and alerting
# ===================================================================