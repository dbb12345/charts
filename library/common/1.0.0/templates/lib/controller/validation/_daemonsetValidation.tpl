{{/* DaemonSet Validation */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.controller.daemonsetValidation" (dict "objectData" $objectData) -}}
rootCtx: The root context of the template. It is used to access the global context.
objectData:
  strategy: The strategy of the object.
  rollingUpdate: The rollingUpdate of the object.
*/}}
{{- define "ix.v1.common.lib.controller.daemonsetValidation" -}}
  {{- $objectData := .objectData -}}

  {{- if $objectData.strategy -}}
    {{- $strategy := $objectData.strategy -}}

    {{- if not (mustHas $strategy (list "OnDelete" "RollingUpdate")) -}}
      {{- fail (printf "DaemonSet - Expected <strategy> to be one of [OnDelete, RollingUpdate], but got [%v]" $strategy) -}}
    {{- end -}}

  {{- end -}}

  {{- if $objectData.rollingUpdate -}}
    {{- $rollUp := $objectData.rollingUpdate -}}

    {{- if and $rollUp (not (kindIs "map" $rollUp)) -}}
      {{- fail (printf "DaemonSet - Expected <rollingUpdate> to be a dictionary, but got [%v]" (kindOf $rollUp)) -}}
    {{- end -}}

  {{- end -}}
{{- end -}}
{{/* TODO: Extend validation for sub-values of rollingUpdate */}}