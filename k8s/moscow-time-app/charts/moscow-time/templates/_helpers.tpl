{{/*
Expand the name of the chart.
*/}}
{{- define "moscow-time.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "moscow-time.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "moscow-time.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "moscow-time.labels" -}}
helm.sh/chart: {{ include "moscow-time.chart" . }}
{{ include "moscow-time.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "moscow-time.selectorLabels" -}}
app.kubernetes.io/name: {{ include "moscow-time.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "moscow-time.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "moscow-time.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Define common environment variables
*/}}
{{- define "moscow-time.env" -}}
- name: MY_PASS
  valueFrom:
    secretKeyRef:
      name: credentials
      key: password
- name: APP_NAME
  value: "Moscow Time App"
- name: APP_VERSION
  value: {{ .Chart.AppVersion | quote }}
{{- end }}

{{/*
Define Vault template for config.txt
*/}}
{{- define "moscow-time.vault-template" -}}
vault.hashicorp.com/agent-inject-template-config.txt: |
  {{`{{- with secret "secret/data/myapp/config" -}}
  username: {{ .Data.data.username }}
  password: {{ .Data.data.password }}
  {{- end -}}`}}
{{- end }}
