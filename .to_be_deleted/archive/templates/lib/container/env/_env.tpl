{{/* Call this template like this:
{{- include "ix.v1.common.container.env" (dict "envs" $envs "root" $root "containerName" $containerName) -}}
*/}}
{{- define "ix.v1.common.container.env" -}}
  {{- $envs := .envs -}}
  {{- $root := .root -}}
  {{- $containerName := .containerName -}}

  {{/* We need to make sure that is always dict. With nested values.
  Will be removed once the tpl is moved in upper level
  */}}
  {{- $envDict := (dict "envs" $envs) -}}
  {{- if $envs -}}
    {{- $envs = (fromYaml (tpl ($envDict | toYaml) $root)).envs -}}
  {{- end -}}

  {{- $dupeCheck := dict -}}

  {{- with $envs -}}
    {{- range $k, $v := . -}}
      {{- $name := $k -}}
      {{- $value := $v -}}

      {{- if kindIs "int" $name -}}
        {{- fail "Environment Variables as a list is not supported. Use key-value format." -}}
      {{- end }}
- name: {{ $name | quote }}
      {{- if not (kindIs "map" $value) }}
  value: {{ $value | quote }}
        {{- $_ := set $dupeCheck $name $value -}}
      {{- else if kindIs "map" $value -}} {{/* If value is a dict... */}}
        {{- if hasKey $value "valueFrom" -}}
          {{- fail "Please remove <valueFrom> and use directly configMapKeyRef or secretKeyRef" -}}
        {{- end }}
  valueFrom:
        {{- if hasKey $value "configMapKeyRef" }} {{/* And contains configMapRef... */}}
    configMapKeyRef:
          {{- $_ := set $value "name" $value.configMapKeyRef.name -}} {{/* Extract name and key */}}
          {{- $_ := set $value "key" $value.configMapKeyRef.key -}}
          {{- if hasKey $value.configMapKeyRef "optional" -}}
            {{- fail "<optional> is not supported in configMapRefKey" -}}
          {{- end -}}
        {{- else if hasKey $value "secretKeyRef" }} {{/* And contains secretRef... */}}
    secretKeyRef:
          {{- $_ := set $value "name" $value.secretKeyRef.name -}} {{/* Extract name and key */}}
          {{- $_ := set $value "key" $value.secretKeyRef.key -}}
          {{- if (hasKey $value.secretKeyRef "optional") -}}
            {{- if (kindIs "bool" $value.secretKeyRef.optional) }}
      optional: {{ $value.secretKeyRef.optional }}
            {{- else -}}
              {{- fail (printf "<optional> in secretKeyRef must be a boolean on Environment Variable (%s)" $name) -}}
            {{- end -}}
          {{- end -}}
        {{- else -}}
          {{- fail "Not a valid valueFrom reference. Valid options are (configMapKeyRef and secretKeyRef)" -}}
        {{- end }}
      name: {{ required (printf "<name> for the keyRef is not defined in (%s)" $name) $value.name }} {{/* Expand name and key */}}
      key: {{ required (printf "<key> for the keyRef is not defined in (%s)" $name) $value.key }}
      {{- end -}}
    {{- end -}}
    {{- include "ix.v1.common.util.storeEnvsForDupeCheck" (dict "root" $root "source" "env" "data" $dupeCheck "containers" (list $containerName)) -}}
  {{- end -}} {{/* Finish env */}}
{{- end -}}
