{{/* vim: set filetype=mustache: */}}
{{/*
Chart name used in labels.
*/}}
{{- define "gateway.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Chart name and version as used by the chart label.
*/}}
{{- define "gateway.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Gateway name: gateway.name or the release name.
*/}}
{{- define "gateway.gatewayName" -}}
{{- default .Release.Name .Values.gateway.name -}}
{{- end -}}

{{/*
GatewayClass name: gatewayClass.name or the release name.
*/}}
{{- define "gateway.className" -}}
{{- default .Release.Name .Values.gatewayClass.name -}}
{{- end -}}

{{/*
EnvoyProxy name: envoy.name or the GatewayClass name.
*/}}
{{- define "gateway.envoyName" -}}
{{- default (include "gateway.className" .) .Values.envoy.name -}}
{{- end -}}

{{/*
GatewayClass referenced by the Gateway: gateway.className, else the class of this chart.
*/}}
{{- define "gateway.gatewayClassName" -}}
{{- if .Values.gateway.className -}}
{{- .Values.gateway.className -}}
{{- else if or .Values.gatewayClass.create .Values.gatewayClass.name -}}
{{- include "gateway.className" . -}}
{{- else -}}
{{- fail "set gateway.className, or gatewayClass.name, or gatewayClass.create" -}}
{{- end -}}
{{- end -}}

{{/*
Object metadata. Precedence for labels and annotations: item > commonLabels/commonAnnotations > standard labels.
Usage: include "gateway.metadata" with a dict of ctx (root context), name, and item (a dict that may hold labels,
annotations and namespace).
*/}}
{{- define "gateway.metadata" -}}
{{- $std := dict "helm.sh/chart" (include "gateway.chart" .ctx) "app.kubernetes.io/name" (include "gateway.name" .ctx) "app.kubernetes.io/instance" .ctx.Release.Name "app.kubernetes.io/managed-by" .ctx.Release.Service -}}
{{- $labels := merge (dict) (.item.labels | default dict) (.ctx.Values.commonLabels | default dict) $std -}}
{{- $annotations := merge (dict) (.item.annotations | default dict) (.ctx.Values.commonAnnotations | default dict) -}}
name: {{ .name }}
{{- with .item.namespace }}
namespace: {{ . }}
{{- end }}
labels:
  {{- toYaml $labels | nindent 2 }}
{{- with $annotations }}
annotations:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end -}}
