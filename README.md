# gateway

A generic Helm chart for Kubernetes Gateway API resources (GatewayClass, Gateways, Routes and implementation specific objects)

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm repo add helm-gateway git+https://github.com/asteriosoft/helm-gateway?ref=0.1.0
$ helm install my-release helm-gateway/gateway -f values.yaml
```

The chart contains no workload. It renders [Gateway API](https://gateway-api.sigs.k8s.io/) objects, so the Gateway API
CRDs and a Gateway controller (Envoy Gateway, Cilium, Istio, NGINX Gateway Fabric, ...) must already be installed.

## Design

The chart does not hide the Gateway API behind its own options. Every object takes the **spec exactly as in the API**
(`spec:`), the chart only adds metadata, defaults and some safety checks. That keeps it independent of the controller and of
the Gateway API version.

| Section | Renders | Notes |
|---|---|---|
| `gatewayClass` | `GatewayClass` | optional, `create: false` by default (use an existing class with `gateways.<name>.spec.gatewayClassName`) |
| `gateways` | `Gateway` | a map keyed by name; `spec.gatewayClassName` defaults to `gatewayClass.name` |
| `routes` | `HTTPRoute` (default), `GRPCRoute`, `TLSRoute`, `TCPRoute`, `UDPRoute` | `kind` and `apiVersion` per item; `defaultParentRefs` for routes without `parentRefs` |
| `objects` | any namespaced custom resource | implementation specific objects (Envoy Gateway `EnvoyProxy`, `ClientTrafficPolicy`, `BackendTrafficPolicy`, `SecurityPolicy`, ...), `ReferenceGrant`, ... |
| `extraObjects` | free-form manifests | strings or maps, rendered with `tpl` |

- `gateways`, `routes` and `objects` are **maps keyed by name**, not lists, so values files of different environments can be
  merged (`-f base.yaml -f prod.yaml`). Lists inside a `spec` (for example `listeners`) are replaced as a whole by Helm.
- Every item accepts `enabled` (default `true`), `name` (default: the key), `namespace`, `labels`, `annotations`.
- Strings inside every `spec` (and in `extraObjects`) are rendered with `tpl`, so `{{ .Release.Name }}` and other chart
  values can be used.
- `commonLabels` and `commonAnnotations` are added to every object.

## Examples

See [`examples/`](examples):

- [`simple.yaml`](examples/simple.yaml): a Gateway on an existing class and one route;
- [`envoy-gateway-aws-nlb.yaml`](examples/envoy-gateway-aws-nlb.yaml): Envoy Gateway behind an AWS NLB that terminates TLS,
  with a global http to https redirect;
- [`multi-environment.yaml`](examples/multi-environment.yaml): merging values files of several environments.

## Compatibility

`GatewayClass`, `Gateway`, `HTTPRoute` and `GRPCRoute` use `gateway.networking.k8s.io/v1` (Gateway API 1.0 and newer).
`Gateway.spec.infrastructure` needs Gateway API 1.1 or newer. `TLSRoute`, `TCPRoute` and `UDPRoute` need the experimental
channel CRDs (set `apiVersion: gateway.networking.k8s.io/v1alpha2` on the item).

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| commonAnnotations | object | `{}` | Annotations added to every rendered object |
| commonLabels | object | `{}` | Labels added to every rendered object |
| defaultParentRefs | list | `[]` | Default `spec.parentRefs` of the routes that do not set their own, usually a reference to a Gateway |
| extraObjects | list | `[]` | Free-form manifests, as strings or maps, rendered with `tpl`. For anything the sections above cannot express |
| gatewayClass.annotations | object | `{}` | Extra annotations of the GatewayClass |
| gatewayClass.controllerName | string | `""` | Controller that implements the class, e.g. `gateway.envoyproxy.io/gatewayclass-controller` (required when `create` is true) |
| gatewayClass.create | bool | `false` | Create a GatewayClass |
| gatewayClass.description | string | `""` | GatewayClass description |
| gatewayClass.labels | object | `{}` | Extra labels of the GatewayClass |
| gatewayClass.name | string | `""` | GatewayClass name (defaults to the release name). Also the default `spec.gatewayClassName` of the gateways below |
| gatewayClass.parametersRef | object | `{}` | Reference to implementation specific configuration (group, kind, name, namespace), e.g. an Envoy Gateway EnvoyProxy |
| gateways | object | `{}` | Gateways, keyed by name. Every item takes `spec` (the Gateway spec exactly as in the Gateway API), and optionally `enabled`, `name`, `namespace`, `labels`, `annotations`, `apiVersion`. `spec.gatewayClassName` defaults to `gatewayClass.name` |
| nameOverride | string | `""` | Override the chart name used in the `app.kubernetes.io/name` label |
| objects | object | `{}` | Any other namespaced custom resource, keyed by name (implementation specific objects, `ReferenceGrant`, ...). Every item needs `apiVersion`, `kind` and takes `spec` |
| routes | object | `{}` | Routes, keyed by name. Every item takes `spec` and optionally `kind` (default `HTTPRoute`), `apiVersion`, `enabled`, `name`, `namespace`, `labels`, `annotations` |
