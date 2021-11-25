{{/*
Expand the name of the chart.
*/}}
{{- define "netprobe.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "netprobe.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "netprobe.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "netprobe.labels" -}}
helm.sh/chart: {{ include "netprobe.chart" . }}
app.kubernetes.io/name: {{ include "netprobe.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Match labels
*/}}
{{- define "netprobe.matchLabels" -}}
app.kubernetes.io/name: {{ include "netprobe.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account
*/}}
{{- define "netprobe.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "netprobe.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the cluster role
*/}}
{{- define "netprobe.clusterRoleName" -}}
{{- if .Values.clusterRole.create }}
{{- default (include "netprobe.fullname" .) .Values.clusterRole.name }}
{{- else }}
{{- default "default" .Values.clusterRole.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the role
*/}}
{{- define "netprobe.roleName" -}}
{{- if .Values.role.create }}
{{- default (include "netprobe.fullname" .) .Values.role.name }}
{{- else }}
{{- default "default" .Values.role.name }}
{{- end }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "netprobe.selectorLabels" -}}
app.kubernetes.io/name: {{ include "netprobe.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Write the common processors added to all collectors
*/}}
{{- define "netprobe.collectorEnrichmentProcessors" -}}
{{- /* Retain backwards compatibility before labelMode was added - don't add the kube_app_name dimensions.  */}}
{{- if not (eq .Values.labelMode "attributes") }}
- type: plugin
  class-name: KubernetesEnricher
{{- end }}
- type: enrichment
  overwrite: false
  dimensions:
    {{- if eq .Values.mode "DaemonSet" }}
    node_name: ${env:NODE_NAME}
    {{- end }}
    {{- range $k, $v := .Values.customDimensions }}
    {{ toYaml $v }}
    {{- end }}
{{- end -}}