{{/* Returns the lifecycle for the container */}}
{{- define "ix.v1.common.container.lifecycle" -}}
  {{- $lifecycle := .lifecycle -}}

  {{- with $lifecycle -}}
    {{- range $k, $v := . -}}
      {{- if not (mustHas $k (list "preStop" "postStart")) -}}
        {{- fail (printf "Invalid key (%s) in lifecycle. Valid keys are preStop and postStart" $k) -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}

  {{- if (hasKey $lifecycle "preStop") -}}
    {{- with $lifecycle.preStop.command }}
preStop:
  exec:
    command:
      {{- include "ix.v1.common.container.command" (dict "commands" .) | trim | nindent 6 }}
    {{- else -}}
      {{- fail "No commands were given for preStop lifecycle hook" -}}
    {{- end -}}
  {{- end -}}

  {{- if (hasKey $lifecycle "postStart") -}}
    {{- with $lifecycle.postStart.command }}
postStart:
  exec:
    command:
      {{- include "ix.v1.common.container.command" (dict "commands" .) | trim | nindent 6 }}
    {{- else -}}
      {{- fail "No commands were given for postStart lifecycle hook" -}}
    {{- end -}}
  {{- end -}}

{{- end -}}
