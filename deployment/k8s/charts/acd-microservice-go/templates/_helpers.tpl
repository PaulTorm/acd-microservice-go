{{/*
Expand the name of the chart.
*/}}
{{- define "acd-microservice-go.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "acd-microservice-go.fullname" -}}
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
{{- define "acd-microservice-go.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "acd-microservice-go.labels" -}}
helm.sh/chart: {{ include "acd-microservice-go.chart" . }}
{{ include "acd-microservice-go.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "acd-microservice-go.selectorLabels" -}}
app.kubernetes.io/name: {{ include "acd-microservice-go.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "acd-microservice-go.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "acd-microservice-go.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{/*
Application specific helpers
*/}}
{{- define "acd-microservice-go.examname" -}}
{{- printf "%s-%s" ( include "acd-microservice-go.fullname" . ) .Values.exam.name }}
{{- end }}

{{- define "acd-microservice-go.exammanagementname" -}}
{{- printf "%s-%s" ( include "acd-microservice-go.fullname" . ) .Values.exammanagement.name }}
{{- end }}

{{- define "acd-microservice-go.gatewayname" -}}
{{- printf "%s-%s" ( include "acd-microservice-go.fullname" . ) .Values.gateway.name }}
{{- end }}

{{- define "acd-microservice-go.studentname" -}}
{{- printf "%s-%s" ( include "acd-microservice-go.fullname" . ) .Values.student.name }}
{{- end }}

{{- define "acd-microservice-go.translationname" -}}
{{- printf "%s-%s" ( include "acd-microservice-go.fullname" . ) .Values.translation.name }}
{{- end }}