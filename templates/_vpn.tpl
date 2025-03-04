{{/*
VPN sidecar
Usage:
{{ include "common.vpn.volumes" . }}
*/}}
{{- define "common.vpn.sidecar" }}
- name: wireguard
  image: lscr.io/linuxserver/wireguard:latest
  imagePullPolicy: IfNotPresent
  restartPolicy: Always  # this makes it a native sidecar
  securityContext:
    seLinuxOptions: {}
    privileged: false
    allowPrivilegeEscalation: false
    runAsNonRoot: false
    readOnlyRootFilesystem: false
    seccompProfile:
      type: "RuntimeDefault"
    capabilities:
      add: 
        - "NET_ADMIN"
        {{- if .Values.vpn.sysModule }}
        - "SYS_MODULE"
        {{- end }}
  resources: {{- include "common.resources.preset" (dict "type" "2xnano") | nindent 4 }}
  env:
    - name: PUID
      value: {{ required "A valid UID required!" .Values.host.uid | quote }}
    - name: PGID
      value: {{ required "A valid GID required!" .Values.host.gid | quote }}
    - name: TZ
      value: {{ required "A valid timezone required!" .Values.host.tz | quote }}
  volumeMounts:
    - name: wireguard-conf
      mountPath: /config/wg_confs/wg0.conf
      subPath: {{ .Values.vpn.secretKey }}
      readOnly: true
    {{- if .Values.vpn.sysModule }}
    - name: lib-modules
      mountPath: /lib/modules
    {{- end }}
{{- end }}

{{- define "common.vpn.volumes" }}
- name: wireguard-conf
  secret:
    secretName: {{ .Values.vpn.secretRef }}
    optional: false
{{- if .Values.vpn.sysModule }}
- name: lib-modules
  hostPath:
    path: /lib/modules
    type: Directory
{{- end }}
{{- end }}

{{- define "common.vpn.securityContext.sysctls" }}
- name: net.ipv4.conf.all.src_valid_mark
  value: "1"
{{- end }}
