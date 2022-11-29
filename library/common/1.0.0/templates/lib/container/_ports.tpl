{{/*
If no targetPort is given, default to port.
This is for cases where port (that container listens)
can be dynamically configured via an env var.
*/}}
{{/* Ports included by the container. */}}
{{- define "ix.v1.common.container.ports" -}}
  {{ $ports := list }}
  {{- range $svcName, $svc := .Values.service -}}
    {{- if $svc.enabled -}}
      {{- if not $svc.ports -}}
        {{- fail (printf "At least one port is required in an enabled service (%s)" $svcName) -}}
      {{- end -}}
      {{- range $name, $port := $svc.ports -}}
        {{- $_ := set $port "name" $name -}}
        {{- $ports = mustAppend $ports $port -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}

{{/* Render the list of ports */}}
{{- if $ports -}}
  {{- range $_ := $ports }}
    {{- if .enabled }}
- name: {{ tpl .name $ }}
      {{- if not .port -}}
        {{- fail (printf "Port is required on enabled services. Service (%s)" .name) -}}
      {{- end -}}
      {{- if and .targetPort (kindIs "string" .targetPort) -}}
        {{- fail (printf "This common library does not support named ports for targetPort. port name (%s), targetPort (%s)" .name .targetPort) -}}
      {{- end }}
  containerPort: {{ default .port .targetPort }}
      {{- $protocol := "TCP" -}}
      {{- with .protocol -}}
        {{- if has . (list "HTTP" "HTTPS" "TCP") -}}
          {{- $protocol = "TCP" -}}
        {{- else if (eq . "UDP") -}}
          {{- $protocol = "UDP" -}}
        {{- else -}}
          {{- fail (printf "Not valid <protocol> (%s)" .) -}}
        {{- end }}
  protocol: {{ $protocol }}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- end -}}