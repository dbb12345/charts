{{/* Returns Service Account Name */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.pod.serviceAccountName" (dict "rootCtx" $ "objectData" $objectData) }}
rootCtx: The root context of the chart.
objectData: The object data to be used to render the Pod.
*/}}
{{- define "ix.v1.common.lib.pod.serviceAccountName" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

  {{- $saName := "default" -}}
  {{- $saNameCount := 0 -}}

  {{- range $name, $serviceAccount := $rootCtx.Values.serviceAccount -}}
    {{- $name = (printf "%s-%s" (include "ix.v1.common.lib.chart.names.fullname" $rootCtx) $name) -}}

    {{- if $serviceAccount.enabled -}}
      {{/* If targetSelectAll is true */}}
      {{- if $serviceAccount.targetSelectAll -}}
        {{- $saName = $name -}}
        {{- $saNameCount = add1 $saNameCount -}}

      {{/* Else if targetSelector is a list */}}
      {{- else if (kindIs "slice" $serviceAccount.targetSelector) -}}
        {{- if (mustHas $objectData.shortName $serviceAccount.targetSelector) -}}
          {{- $saName = $name -}}
          {{- $saNameCount = add1 $saNameCount -}}
        {{- end -}}

      {{/* If not targetSelectAll or targetSelector, but is the primary pod */}}
      {{- else if $objectData.primary -}}
        {{- $saName = $name -}}
        {{- $saNameCount = add1 $saNameCount -}}
      {{- end -}}

    {{- end -}}
  {{- end -}}

  {{- if gt $saNameCount 1 -}}
    {{- fail (printf "Expected at most 1 ServiceAccount to be assigned on a pod [%s]. But [%v] were assigned" $objectData.shortName $saNameCount) -}}
  {{- end -}}

  {{- $saName -}}
{{- end -}}
