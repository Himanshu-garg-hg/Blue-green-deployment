Service Mesh:

1. What is service mesh  -->  It used to control traffic management inside kubernetes cluster
2. Why we use service mesh --> As all pod/service can connect with each other then why service mensh required.
                           --> Reason is Manual TLS ( Feature of service mensh). Means it secure serive to service connection
                           --> ALso using Istio we can use advance deployment stratergy ( Canary , Blue - green deployment in very easy way )
                           --> It also help in observibility . ( kiali which you need to install and it work best with istio for obserbility as it keep trach of service to service communication)
3. How istio will work  --> with each and every pod it create a new container that is know as  side car container . Side car container contain Envoy Proxy server
                            which handle traffic management to the pod
                        --> Any request comes in pod and goes outside of pod it must pass through Side car container
                        --> when every request pass to pod it attach a tls certificate and when it pass to another pod , the tls certificate check by his side car 
                            container and it will show his tls ceertificate which is known as mutual TLS

4. Admission Controller --> if we create a new pod then it request goes to api server which authenticate and authorize the request and after authentication it  create a 
                           object in the ETCD. 
                        --> Now admission controller comes in picture where it place his position between api server and ETCD. So if a request comes to api server first
                            it pass through Admission contoller then goes to ETCD.
                        --> Admission controller use for mutation ( to add any thing ) or for validaition . There are 30+ types of admission controller that were 
                            present in kubernetes by default. but in some distribution some are enable and some disable. You can enable according to your requirement.
                            To check admission controller enable or not go to -- /etc/kubernetes/manifest/kubeapiserver.yaml and check enable admission plugins and then you can check list of admission controller
                        --> Example of mutation - if you want to create a pvc and in the request you did not mention storage class name then there is default storage 
                            class admission controller that add storage class in the request and then pass to ETCD to store a information in a object. 
                        --> Same type a pod request comes and there if envoy proxy side car container not mentioned then admission controller add the info in pod 
                            request and pass to ETCD
5. Install Istio --> https://istio.io/latest/docs/setup/getting-started/
    --> istioctl -- command line to run istio commands same as kubectl
    --> istioD --> Control plane of istio
    --> virtual Service  --> wh
    --> Destination rule
6. Dynamic Admission Controller --> As istio is 3rd party app so how api server connect with with istio to injuct side car container in every pod. This process is 
                                    called Dynamic Admission controll
                                --> Two special admission controller part of APi server - Mutating Admission Webhook controller and validating Admission Webhook 
                                    controller.
                                --> There controller take input from api server and notify info to IsteoD ( Admission webhook ). They do not do any work except 
                                    passing the info.
                                --> Then the isteoD admission webhook mutate the side car container or do validation and then pass to ETCD

                                --> Kubectl get mutatingwebhookconfiguration --> To get to know isteo side car injetion yaml file where rules are defined

2. AGIC is used to control traffic from outside and direct to appropriate service. 
3. Three tyep of service mesh --> Istio / 
4. Istio Service mesh Advantages ->
     . Traffic Management
     . cercuit breaking
     . mTLS




----------------------------------------------------------------------------------------------------------------------
                                  USING GPT
----------------------------------------------------------------------------------------------------------------------                                  

Service Mesh:

1. What is service mesh
   --> It is used to control traffic management inside a Kubernetes cluster.
   --> It sits between services and handles communication, security, and observability.

2. Why we use service mesh
   --> Even if pods/services can talk to each other, service mesh adds features that are hard or manual otherwise:
       - Automatic mutual TLS (mTLS) for service-to-service encryption without changing app code.
       - Advanced deployment strategies made easy (Canary, Blue-Green, A/B).
       - Observability: traces, metrics, and service dependency maps (Kiali works well with Istio).
       - Policy enforcement (rate limits, authz/authn).
       - Fault injection, retries, timeouts, circuit breaking.

3. How Istio works (simple)
   --> For each pod Istio adds a sidecar container (Envoy proxy).
   --> All inbound and outbound pod traffic goes through the Envoy sidecar.
   --> Sidecars handle mTLS, routing, telemetry, retries, timeouts, circuit breaking.
   --> Istio control plane (istiod) configures the sidecars and manages certificates.
   --> When services communicate, Envoy performs mTLS and verifies certificates (mutual TLS).

4. Admission Controller (short)
   --> Kubernetes API server handles requests then objects are stored in etcd.
   --> Admission controllers sit between API server and etcd: they can mutate or validate requests.
   --> Mutating admission webhook can inject the Envoy sidecar into pod spec automatically.
   --> Use kubectl get mutatingwebhookconfiguration to see Istio injection webhook.
   --> Example of mutation: add default StorageClass or add sidecar container if not present.
   --> There are 30+ Admission controller that are part of API server.
   --> Istio is 3rd party app for that there is admission controller -- Mutating admission webhook and validating admission webhook that connect with isteoD
       Webhook and mutate side car container in the pod

5. Install Istio (quick)
   --> Official docs: https://istio.io/latest/docs/setup/getting-started/
   --> istioctl is the CLI (similar to kubectl).
   --> Installation methods: istioctl install, Helm, IstioOperator (operator pattern).
   --> Control plane: istiod (manages config, certificates).
   --> Components to know: Gateway (ingress/egress), VirtualService, DestinationRule, Sidecar resource.

6. Dynamic Admission (how sidecar is injected)
   --> API server calls the Mutating and Validating Admission Webhook controllers.
   --> Istio provides a mutating webhook (istiod) that adds sidecar containers or annotations.
   --> Validating webhook can enforce policies on resources before they are persisted.
   --> Check mutating/validating webhooks with kubectl get mutatingwebhookconfiguration and kubectl get validatingwebhookconfiguration.

7. Key Istio CRs and concepts (short notes)
   --> Gateway: manage inbound/outbound L4-L6 from outside the mesh (like Ingress but for istio).
   --> VirtualService: routing rules (traffic splitting, match conditions, HTTP routes).
   --> DestinationRule: configure policies for a service (load balancing, subsets, connection pool, outlier detection).
   --> ServiceEntry: add external services into the mesh (so you can control egress).
   --> Sidecar (CR): limits the set of services a sidecar can see (improves performance & security).
   --> PeerAuthentication / RequestAuthentication: configure mTLS and JWT validation.
   --> AuthorizationPolicy: fine-grained allow/deny between services.

8. Traffic management features
   --> Canary releases: split traffic by percentage using VirtualService.
   --> Blue-Green: route traffic to green then switch to blue via VirtualService/Gateway.
   --> Traffic mirroring (shadowing) to send copy of requests to another version.
   --> Retries, timeouts, circuit breakers (outlier detection).
   --> Fault injection to test resilience.
   --> Weighted routing, header-based routing.

9. Observability & Telemetry
   --> Istio collects metrics, logs, traces from Envoy sidecars.
   --> Common tools: Prometheus (metrics), Grafana (dashboards), Jaeger/Zipkin (traces), Kiali (service graph + UI).
   --> Use istioctl proxy-config, istioctl proxy-status, and istioctl analyze for troubleshooting.

10. Security
   --> Automatic mTLS for service-to-service encryption and identity.
   --> Istio issues certificates and rotates them automatically (istiod).
   --> Authentication (JWT), Authorization (policies), and RBAC can be enforced at mesh level.
   --> Egress rules and ServiceEntry help control outbound access.

11. Ingress vs Gateway
   --> Ingress (k8s native) vs Istio Gateway: Gateway is more powerful for L4/L7 routing and works with Envoy features.
   --> Use Gateway + VirtualService to expose services outside the cluster.

12. Advanced topics (brief)
   --> Multi-cluster and multi-network meshes (Istio supports different topologies).
   --> Mesh expansion: add VMs or non-K8s workloads into mesh.
   --> Sidecar resource to optimize config and restrict namespace visibility.
   --> EnvoyFilters for low-level customization (use carefully).
   --> Canary/Blue-Green automation can be integrated with CI/CD tools.

13. Performance & resource cost
   --> Sidecars add CPU/memory overhead per pod.
   --> Tune sidecar resources and use Sidecar CR to limit config distribution to improve scale.
   --> Monitor control plane (istiod) and Pilot push rates for large meshes.

14. Troubleshooting commands (use on Windows terminal / WSL)
   --> kubectl get pods -n istio-system
   --> kubectl logs -n istio-system deploy/istiod
   --> istioctl proxy-status
   --> istioctl proxy-config routes <pod>.<namespace>
   --> istioctl analyze
   --> kubectl get mutatingwebhookconfiguration

15. Tips & best practices
   --> Start small: enable Istio in a dev namespace first, use automatic injection and Bookinfo sample to learn.
   --> Use PeerAuthentication and AuthorizationPolicy with least privilege.
   --> Use Gateway for public ingress and keep internal services internal.
   --> Test rolling updates and canaries in staging before production.
   --> Watch for version compatibility when upgrading Istio and Envoy.

16. Useful commands / resources
   --> istioctl dashboard kiali
   --> istioctl install --set profile=demo (or minimal/production profiles)
   --> Official docs: https://istio.io
   --> Sample app: Bookinfo (good for learning routing, telemetry, security)

17. Quick glossary
   --> Envoy: sidecar proxy used by Istio.
   --> istiod: Istio control plane component (config + certs).
   --> VirtualService: HTTP/TCP routing rules.
   --> DestinationRule: policies for traffic to a service.
   --> Gateway: ingress/egress point controlled by Envoy.

18. Summary (simple)
   --> Istio/service mesh helps secure, observe, and control traffic between services with features like mTLS, routing, telemetry, and policy.
   --> It simplifies advanced deployment strategies (canary, blue-green) and provides tools for resilience and monitoring.