{{- define "salt-master.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "salt-master.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name (include "salt-master.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "salt-master.headlessServiceName" -}}
{{- printf "%s-headless" (include "salt-master.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "salt-master.masterConfigMapName" -}}
{{- if .Values.config.external.configMap.create -}}
{{- default (printf "%s-master-config" (include "salt-master.fullname" .)) .Values.config.external.configMap.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- .Values.config.external.configMap.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "salt-master.labels" -}}
app.kubernetes.io/name: {{ include "salt-master.name" . }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}
