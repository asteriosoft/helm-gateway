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
GatewayClass name: gatewayClass.name or the release name.
*/}}
{{- define "gateway.className" -}}
{{- default .Release.Name .Values.gatewayClass.name -}}
{{- end -}}

{{/*
Renders "true" unless the item is disabled with `enabled: false`.
Usage: wrap the item in an if that calls include with "gateway.enabled" and the item.
*/}}
{{- define "gateway.enabled" -}}
{{- if or (not (hasKey . "enabled")) .enabled -}}true{{- end -}}
{{- end -}}

{{/*
Object metadata. Precedence for labels and annotations: item > commonLabels/commonAnnotations > standard labels.
Usage: include "gateway.metadata" with a dict of ctx (root context), name (the map key) and item (the map value).
*/}}
{{- define "gateway.metadata" -}}
{{- $std := dict "helm.sh/chart" (include "gateway.chart" .ctx) "app.kubernetes.io/name" (include "gateway.name" .ctx) "app.kubernetes.io/instance" .ctx.Release.Name "app.kubernetes.io/managed-by" .ctx.Release.Service -}}
{{- $labels := merge (dict) (.item.labels | default dict) (.ctx.Values.commonLabels | default dict) $std -}}
{{- $annotations := merge (dict) (.item.annotations | default dict) (.ctx.Values.commonAnnotations | default dict) -}}
name: {{ .item.name | default .name }}
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
