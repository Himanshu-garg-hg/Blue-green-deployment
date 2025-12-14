================================================================================
UNDERSTANDING ISTIO SERVICE MESH WITH YOUR TODO APPLICATION
================================================================================

1. WHAT IS ISTIO? (THE BIG PICTURE)
================================================================================

Istio is a service mesh — think of it as a traffic cop for microservices 
communication inside Kubernetes. Without Istio, pods talk directly to each other. 
With Istio, all communication flows through intelligent proxies.

WITHOUT ISTIO:
Pod A → (direct TCP) → Pod B

WITH ISTIO:
Pod A → [Envoy Sidecar] → [mTLS encryption] → [Envoy Sidecar] → Pod B


2. HOW ISTIO INJECTS SIDECARS (THE MAGIC)
================================================================================

When you label a namespace with istio-injection=enabled, Istio automatically 
adds a sidecar container to every pod:

Command:
kubectl label namespace default istio-injection=enabled --overwrite

WHAT HAPPENS:
1. You create a pod → Pod spec goes to API Server
2. API Server checks Mutating Admission Webhooks
3. Istio's webhook (istiod) says: "I need to inject an Envoy sidecar"
4. API Server adds the Envoy container to your pod spec
5. Pod starts with 2 containers: your app + Envoy sidecar

IN YOUR TODO APP:
When your pods start (GetTasks, AddTask, DeleteTask, UI), each gets an 
Envoy proxy sidecar without you doing anything.

Your AddTask Pod:
├── Container 1: Your FastAPI app (listening on :8000)
└── Container 2: Envoy sidecar (listening on :15001, intercepts traffic)


3. HOW TRAFFIC FLOWS (THE JOURNEY)
================================================================================

SCENARIO: UI wants to create a task (POST /api/tasks)

UI Browser Request
    ↓
[UI Pod - Envoy Sidecar] ← intercepts outgoing request
    ↓ (applies rules from VirtualService)
    ↓ (encrypts with mTLS)
    ↓
Network
    ↓
[AddTask Pod - Envoy Sidecar] ← intercepts incoming request
    ↓ (verifies mTLS certificate)
    ↓ (decrypts)
    ↓
[AddTask Container - FastAPI app]
    ↓
Response flows back (encrypted → decrypted)


4. mTLS EXPLAINED (THE SECURITY PART)
================================================================================

mTLS = Mutual TLS = Both sides prove their identity with certificates.

WITHOUT mTLS:
Client: "Hi, I'm Pod A"
Server: "OK, come in" ← No verification!

WITH mTLS:
Client Sidecar: "Hi, I'm Pod A, here's my certificate signed by Istio CA"
Server Sidecar: "Let me verify... ✓ Certificate is valid"
Server Sidecar: "Here's my certificate signed by Istio CA"
Client Sidecar: "Let me verify... ✓ Certificate is valid"
→ Encrypted tunnel established

IN YOUR SETUP:
Istio automatically:
- Issues certificates to each pod via istiod (Istio control plane)
- Rotates certificates automatically
- Encrypts all service-to-service communication
- No code changes needed!


5. YOUR VIRTUALSERVICE (THE TRAFFIC RULES)
================================================================================

VirtualService Example - INIT Endpoint:

http:
  # INIT: Call "/" of backend to create DB table
  - match:
      - uri:
          exact: "/api/init"
    rewrite:
      uri: "/"
    route:
      - destination:
          host: {{ .Release.Name }}-gettasks-todo-microservice-service
          port:
            number: 80

WHAT THIS DOES:
1. Match: If request URI is exactly /api/init
2. Rewrite: Change URI to / before sending to backend
3. Route: Send to GetTasks microservice

FOR YOUR UI (BLUE-GREEN ROUTING):

- match:
    - uri:
        prefix: "/"
  route:
    - destination:
        host: {{ .Release.Name }}-microtodo-ui-service
        subset: blue
        port:
          number: 80
      weight: 90
    - destination:
        host: {{ .Release.Name }}-microtodo-ui-service
        subset: green
        port:
          number: 80
      weight: 10

THIS MEANS:
90% traffic → blue UI
10% traffic → green UI (canary deployment!)


6. DESTINATIONRULE (THE SUBSET DEFINITION)
================================================================================

DestinationRule defines what "blue" and "green" subsets are:

apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: microtodo-ui-destination-rule
spec:
  host: microtodo-ui-service
  trafficPolicy:
    connectionPool:
      tcp:
        maxConnections: 100
      http:
        http1MaxPendingRequests: 100
        http2MaxRequests: 1000
  subsets:
    - name: blue
      labels:
        version: blue
    - name: green
      labels:
        version: green

EXPLANATION:
- trafficPolicy: Connection limits (circuit breaking)
- subsets: Pods with label version=blue are one subset, version=green is another
- VirtualService routes traffic to these subsets based on weight


7. COMPLETE FLOW IN YOUR TODO APP
================================================================================

┌─────────────────────────────────────────────────────────────┐
│  BROWSER (External)                                         │
└──────────────────────────┬──────────────────────────────────┘
                           │ HTTP Request to /api/tasks
                           ↓
┌─────────────────────────────────────────────────────────────┐
│  INGRESS GATEWAY (Istio)                                    │
│  - Routes based on Gateway rules                            │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ↓
┌──────────────────────┬────────────────────────────────────────┐
│  UI Pod (Blue 90%)   │   UI Pod (Green 10%)                   │
├──────────────────────┼────────────────────────────────────────┤
│ Envoy Sidecar ←←←←←← │ Envoy Sidecar ←←←←←                    │
│  ↓                   │  ↓                                      │
│  - Intercepts req    │  - Intercepts req                      │
│  - Applies mTLS      │  - Applies mTLS                        │
│  - Routes via        │  - Routes via                          │
│    VirtualService    │    VirtualService                      │
│  ↓                   │  ↓                                      │
│ React App            │ React App                              │
└──────────────────────┴────────────────────────────────────────┘
        │
        │ JavaScript calls: axios.post("/api/tasks", {...})
        │
        ├─→ Envoy intercepts (origin: UI pod)
        │
        ↓
┌──────────────────────────────────────────────────────────────┐
│  ADD TASK POD                                                │
├──────────────────────────────────────────────────────────────┤
│ Envoy Sidecar ←←←←←                                          │
│  ↓                                                            │
│  - Receives encrypted request                               │
│  - Verifies client certificate (mTLS)                       │
│  - Decrypts payload                                         │
│  ↓                                                            │
│ FastAPI App (/tasks endpoint)                               │
│  ↓                                                            │
│ Inserts task into DB                                        │
└──────────────────────────────────────────────────────────────┘


8. CERTIFICATE FLOW (mTLS DEEP DIVE)
================================================================================

STARTUP:
┌──────────────────────────────────────────────────┐
│  istiod (Istio Control Plane)                    │
│  - Root CA (self-signed)                         │
│  - Issues certs to all sidecars                  │
│  - Rotates every 24 hours (default)              │
└──────────────────────────────────────────────────┘
         ↓ (certificate + private key)
    ┌────┴────┐
    ↓         ↓
[UI Pod]  [AddTask Pod]
Sidecar   Sidecar
Cert      Cert

REQUEST TIME:
UI Sidecar                    AddTask Sidecar
├─ Sign request with         ├─ Receive request
│  private key               │
│                            ├─ Verify signature with
├─ Send encrypted request    │  UI Sidecar's certificate
│                            │
│  ← ← ← ← ← ← ← ← ← ← ← ← ←│
│  (encrypted tunnel)        │
│                            ├─ Decrypt with shared key
│                            │
│                            ├─ Pass to FastAPI app


9. KEY COMMANDS TO VERIFY YOUR SETUP
================================================================================

Check if sidecars are injected:
kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[*].name}{"\n"}{end}'
Output should show 2 containers per pod (app + istio-proxy)

Check mTLS status:
kubectl get peerauthentication -A

View VirtualService routing rules:
kubectl get virtualservice
kubectl describe virtualservice dev-blue-microtodo-virtualservice

Check DestinationRule:
kubectl get destinationrule
kubectl describe destinationrule microtodo-ui-destination-rule

View Envoy config in a sidecar:
kubectl exec -it <pod-name> -c istio-proxy -- \
  curl localhost:15000/config_dump | grep -A 20 "routes"

Check certificate in sidecar:
kubectl exec -it <pod-name> -c istio-proxy -- \
  cat /etc/certs/out/cert-chain.pem


10. HOW YOUR BLUE-GREEN DEPLOYMENT WORKS
================================================================================

In your dev.blue.values.yaml vs dev.green.values.yaml:

dev.blue.values.yaml:
version: blue
replicaCount: 3

dev.green.values.yaml:
version: green
replicaCount: 3

ISTIO ROUTING MAGIC:
VirtualService routes 90% → pods with label version=blue
                   10% → pods with label version=green

You can SWITCH TRAFFIC INSTANTLY by changing weights:

50-50 split for testing:
weight: 50  # blue
weight: 50  # green

Full switch to green:
weight: 0   # blue
weight: 100 # green


QUICK SUMMARY TABLE
================================================================================

Component          | Purpose
-------------------+-------------------------------------------------------
Envoy Sidecar      | Intercepts all pod traffic, applies mTLS, follows 
                   | routing rules
-------------------+-------------------------------------------------------
istiod             | Issues certificates, manages config, control plane
-------------------+-------------------------------------------------------
VirtualService     | Defines how to route requests (which service, 
                   | which weight)
-------------------+-------------------------------------------------------
DestinationRule    | Defines subsets (blue/green) and traffic policies
-------------------+-------------------------------------------------------
mTLS               | Automatic encryption & certificate verification 
                   | between pods
-------------------+-------------------------------------------------------
Gateway            | Ingress point for external traffic
-------------------+-------------------------------------------------------

YOUR TODO APP IS FULLY SECURED WITH mTLS AND CAN DO BLUE-GREEN 
DEPLOYMENTS WITH ZERO DOWNTIME!

================================================================================
END OF DOCUMENT
================================================================================