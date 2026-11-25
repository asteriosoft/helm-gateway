# gateway

A Helm chart for a Kubernetes Gateway API entry point: one GatewayClass, one Gateway, a global https redirect and,
optionally, the Envoy Gateway objects that go with it

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm repo add helm-gateway git+https://github.com/asteriosoft/helm-gateway?ref=0.1.0
$ helm install my-release helm-gateway/gateway -f values.yaml
```

The chart contains no workload. It renders [Gateway API](https://gateway-api.sigs.k8s.io/) objects, so the Gateway API
CRDs and a Gateway controller must already be installed. The Envoy Gateway objects (`envoy.enabled`) also need the Envoy
Gateway CRDs.

## What it renders

| Option | Renders |
|---|---|
| `gatewayClass` | a `GatewayClass` (default controller: Envoy Gateway), or `create: false` to use an existing one |
| `gateway` | one `Gateway` with the given `listeners` (protocol HTTP and routes from all namespaces by default) |
| `httpsRedirect.enabled` | one `HTTPRoute` that redirects every request on the plain-http listener to https, for all hosts |
| `envoy.enabled` | an Envoy Gateway `EnvoyProxy` (replicas, resources, PDB, Service and its load balancer annotations) referenced from the GatewayClass, plus an optional `BackendTrafficPolicy` (`requestTimeout`) and `ClientTrafficPolicy` (`allowUnderscoresInHeaders`) |
| `routes` | extra HTTPRoutes of the platform, for example a maintenance page |
| `extraObjects` | anything else, as free-form manifests (rendered with `tpl`) |

A typical setup (NLB with TLS termination, Envoy Gateway, https redirect) is about 25 lines of values, see
[`examples/envoy-gateway-aws-nlb.yaml`](examples/envoy-gateway-aws-nlb.yaml).

## Routes of the applications

Routes of the applications do **not** belong here: each application chart creates its own `HTTPRoute` with `parentRefs`
pointing at this Gateway (name, namespace and `sectionName` of the https listener). The redirect and the Gateway itself
are defined once. Listeners accept routes from every namespace by default (`allowedRoutes.namespaces.from: All`).

## Compatibility

The chart uses `gateway.networking.k8s.io/v1` (Gateway API 1.0 and newer). `gateway.infrastructure` needs Gateway API 1.1
or newer. The `envoy.pdb` option renders `envoyPDB` and needs an Envoy Gateway version that supports it.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| commonAnnotations | object | `{}` | Annotations added to every rendered object |
| commonLabels | object | `{}` | Labels added to every rendered object |
| envoy.allowUnderscoresInHeaders | bool | `false` | Accept request headers that contain underscores (ClientTrafficPolicy). Envoy drops them by default |
| envoy.enabled | bool | `false` | Render the Envoy Gateway objects (EnvoyProxy and the traffic policies) and reference the EnvoyProxy from the GatewayClass |
| envoy.name | string | `""` | EnvoyProxy name (defaults to the GatewayClass name) |
| envoy.nodeSelector | object | `{}` | Node selector of the Envoy pods |
| envoy.pdb | object | `{}` | PodDisruptionBudget of the Envoy pods, for example `{minAvailable: 1}` |
| envoy.replicas | int | `1` | Replicas of the Envoy (data plane) pods |
| envoy.requestTimeout | string | `""` | Request timeout for every route of the Gateway (BackendTrafficPolicy), for example `60s`. Empty = Envoy default (15s) |
| envoy.resources | object | `{}` | Container resources of the Envoy pods (empty = Envoy Gateway defaults) |
| envoy.service.annotations | object | `{}` | Service annotations, for example the AWS Load Balancer Controller settings of the NLB |
| envoy.service.externalTrafficPolicy | string | `""` | `externalTrafficPolicy` of the Service (empty = Kubernetes default) |
| envoy.service.type | string | `"LoadBalancer"` | Type of the Service that exposes Envoy |
| envoy.topologySpreadConstraints | list | `[]` | Topology spread constraints of the Envoy pods |
| extraObjects | list | `[]` | Free-form manifests, as strings or maps, rendered with `tpl`. For anything the options above cannot express |
| gateway.addresses | list | `[]` | `spec.addresses` of the Gateway |
| gateway.annotations | object | `{}` | Extra annotations of the Gateway |
| gateway.className | string | `""` | GatewayClass of the Gateway (defaults to the class created by this chart) |
| gateway.infrastructure | object | `{}` | `spec.infrastructure` of the Gateway (labels, annotations, parametersRef), needs Gateway API 1.1 or newer |
| gateway.labels | object | `{}` | Extra labels of the Gateway |
| gateway.listeners | list | `[{"name":"http","port":80},{"name":"https","port":443}]` | Listeners. `protocol` defaults to HTTP and `allowedRoutes` to routes from all namespaces. Optional per listener: `hostname`, `tls`, `allowedRoutes` |
| gateway.name | string | `""` | Gateway name (defaults to the release name) |
| gatewayClass.annotations | object | `{}` | Extra annotations of the GatewayClass |
| gatewayClass.controllerName | string | `"gateway.envoyproxy.io/gatewayclass-controller"` | Controller that implements the class (default: Envoy Gateway) |
| gatewayClass.create | bool | `true` | Create a GatewayClass. Set to false to use a class that already exists (see `gateway.className`) |
| gatewayClass.description | string | `""` | GatewayClass description |
| gatewayClass.labels | object | `{}` | Extra labels of the GatewayClass |
| gatewayClass.name | string | `""` | GatewayClass name (defaults to the release name) |
| gatewayClass.parametersRef | object | `{}` | Reference to implementation specific configuration (group, kind, name, namespace). Set automatically to the EnvoyProxy of this chart when `envoy.enabled` is true |
| httpsRedirect.enabled | bool | `false` | Redirect every request that arrives on the plain-http listener to https (one HTTPRoute for all hosts) |
| httpsRedirect.listener | string | `"http"` | Name of the plain-http listener the redirect route attaches to |
| httpsRedirect.port | int | `443` | Port of the https redirect target (omit to use the default https port) |
| httpsRedirect.statusCode | int | `308` | Redirect status code |
| nameOverride | string | `""` | Override the chart name used in the `app.kubernetes.io/name` label |
| routes | object | `{}` | Extra HTTPRoutes of the platform (for example a maintenance page), keyed by name. Every item takes `spec` (`parentRefs` defaults to this Gateway) and optionally `labels`, `annotations`, `namespace` |
