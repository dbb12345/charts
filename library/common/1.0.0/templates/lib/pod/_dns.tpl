{{/* Returns dnsPolicy */}}
{{- define "ix.v1.common.dnsPolicy" -}}
  {{- $dnsPolicy := .dnsPolicy -}}
  {{- $hostNetwork := .hostNetwork -}}
  {{- $root := .root -}}
  {{- $policy := $root.Values.dnsPolicy -}}
  {{- if $dnsPolicy -}}
    {{- $policy = $dnsPolicy -}}
  {{- else if $hostNetwork -}}
    {{- $policy = "ClusterFirstWithHostNet" -}}
  {{- end -}}
  {{- if not (mustHas $policy (list "Default" "ClusterFirst" "ClusterFirstWithHostNet" "None"))  -}}
    {{- fail (printf "Not valid dnsPolicy (%s). Valid options are ClusterFirst, Default, ClusterFirstWithHostNet, None" $policy) -}}
  {{- end -}}
{{- $policy -}}
{{- end -}}

{{/* Returns dnsConfig */}}
{{- define "ix.v1.common.dnsConfig" -}}
  {{- $values := .values -}}
  {{- $dnsPolicy := .dnsPolicy -}}
  {{- $dnsConfig := .dnsConfig -}}
  {{- $root := .root -}}

  {{- $config := $root.Values.dnsConfig -}}

  {{- if not $dnsConfig -}}
    {{- $dnsConfig = $config -}}
  {{- end -}}

  {{- if and (eq $dnsPolicy "None") (not $dnsConfig.nameservers) -}}
    {{- fail "With dnsPolicy set to None, you must specify at least 1 nameservers on dnsConfig" -}}
  {{- end -}}
  {{- if or $dnsConfig.nameservers $dnsConfig.searches $dnsConfig.options -}}
    {{- with $dnsConfig.nameservers -}}
      {{- if gt (len .) 3 -}}
        {{- fail "There can be at most 3 nameservers specified in dnsConfig" -}}
      {{- end -}}
nameservers:
      {{- range . }}
  - {{ tpl . $root }}
      {{- end }}
    {{- end -}}
    {{- with $dnsConfig.searches -}}
      {{- if gt (len .) 6 -}}
        {{- fail "There can be at most 6 search domains specified in dnsConfig" -}}
      {{- end }}
searches:
      {{- range . }}
  - {{  tpl . $root }}
      {{- end }}
    {{- end -}}
    {{- with $dnsConfig.options }}
options:
      {{- range . }}
  - name: {{ tpl .name $root }}
        {{- with .value }}
    value: {{ tpl (toString .) $root | quote }}
        {{- end }}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
