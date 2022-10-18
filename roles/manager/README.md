# Ansible Playbook - Wazuh manager

This role will install the Wazuh manager on a host.

## Table of content

- [Ansible Playbook - Wazuh manager](#ansible-playbook---wazuh-manager)
  - [Table of content](#table-of-content)
  - [Requirements](#requirements)
  - [Example Playbook](#example-playbook)
  - [Default config](#default-config)
    - [defaults/main.yml](#defaultsmainyml)
    - [wazuh\_custom\_packages\_installation\_manager\_deb\_url](#wazuh_custom_packages_installation_manager_deb_url)
      - [Default value](#default-value)
    - [wazuh\_custom\_packages\_installation\_manager\_enabled](#wazuh_custom_packages_installation_manager_enabled)
      - [Default value](#default-value-1)
    - [wazuh\_custom\_packages\_installation\_manager\_rpm\_url](#wazuh_custom_packages_installation_manager_rpm_url)
      - [Default value](#default-value-2)
    - [wazuh\_dir](#wazuh_dir)
      - [Default value](#default-value-3)
    - [wazuh\_manager\_agent\_disconnection\_time](#wazuh_manager_agent_disconnection_time)
      - [Default value](#default-value-4)
    - [wazuh\_manager\_agents\_disconnection\_alert\_time](#wazuh_manager_agents_disconnection_alert_time)
      - [Default value](#default-value-5)
    - [wazuh\_manager\_alerts\_log](#wazuh_manager_alerts_log)
      - [Default value](#default-value-6)
    - [wazuh\_manager\_api](#wazuh_manager_api)
      - [Default value](#default-value-7)
    - [wazuh\_manager\_authd](#wazuh_manager_authd)
      - [Default value](#default-value-8)
    - [wazuh\_manager\_ciscat](#wazuh_manager_ciscat)
      - [Default value](#default-value-9)
    - [wazuh\_manager\_cluster](#wazuh_manager_cluster)
      - [Default value](#default-value-10)
    - [wazuh\_manager\_commands](#wazuh_manager_commands)
      - [Default value](#default-value-11)
    - [wazuh\_manager\_config\_defaults](#wazuh_manager_config_defaults)
      - [Default value](#default-value-12)
    - [wazuh\_manager\_config\_overlay](#wazuh_manager_config_overlay)
      - [Default value](#default-value-13)
    - [wazuh\_manager\_connection](#wazuh_manager_connection)
      - [Default value](#default-value-14)
    - [wazuh\_manager\_email\_from](#wazuh_manager_email_from)
      - [Default value](#default-value-15)
    - [wazuh\_manager\_email\_level](#wazuh_manager_email_level)
      - [Default value](#default-value-16)
    - [wazuh\_manager\_email\_log\_source](#wazuh_manager_email_log_source)
      - [Default value](#default-value-17)
    - [wazuh\_manager\_email\_maxperhour](#wazuh_manager_email_maxperhour)
      - [Default value](#default-value-18)
    - [wazuh\_manager\_email\_notification](#wazuh_manager_email_notification)
      - [Default value](#default-value-19)
    - [wazuh\_manager\_email\_queue\_size](#wazuh_manager_email_queue_size)
      - [Default value](#default-value-20)
    - [wazuh\_manager\_email\_smtp\_server](#wazuh_manager_email_smtp_server)
      - [Default value](#default-value-21)
    - [wazuh\_manager\_extra\_emails](#wazuh_manager_extra_emails)
      - [Default value](#default-value-22)
    - [wazuh\_manager\_fqdn](#wazuh_manager_fqdn)
      - [Default value](#default-value-23)
    - [wazuh\_manager\_globals](#wazuh_manager_globals)
      - [Default value](#default-value-24)
    - [wazuh\_manager\_integrations](#wazuh_manager_integrations)
      - [Default value](#default-value-25)
    - [wazuh\_manager\_json\_output](#wazuh_manager_json_output)
      - [Default value](#default-value-26)
    - [wazuh\_manager\_labels](#wazuh_manager_labels)
      - [Default value](#default-value-27)
    - [wazuh\_manager\_localfiles](#wazuh_manager_localfiles)
      - [Default value](#default-value-28)
    - [wazuh\_manager\_log\_format](#wazuh_manager_log_format)
      - [Default value](#default-value-29)
    - [wazuh\_manager\_log\_level](#wazuh_manager_log_level)
      - [Default value](#default-value-30)
    - [wazuh\_manager\_logall](#wazuh_manager_logall)
      - [Default value](#default-value-31)
    - [wazuh\_manager\_logall\_json](#wazuh_manager_logall_json)
      - [Default value](#default-value-32)
    - [wazuh\_manager\_mailto](#wazuh_manager_mailto)
      - [Default value](#default-value-33)
    - [wazuh\_manager\_monitor\_aws](#wazuh_manager_monitor_aws)
      - [Default value](#default-value-34)
    - [wazuh\_manager\_openscap](#wazuh_manager_openscap)
      - [Default value](#default-value-35)
    - [wazuh\_manager\_osquery](#wazuh_manager_osquery)
      - [Default value](#default-value-36)
    - [wazuh\_manager\_package\_state](#wazuh_manager_package_state)
      - [Default value](#default-value-37)
    - [wazuh\_manager\_reports](#wazuh_manager_reports)
      - [Default value](#default-value-38)
    - [wazuh\_manager\_rootcheck](#wazuh_manager_rootcheck)
      - [Default value](#default-value-39)
    - [wazuh\_manager\_rule\_exclude](#wazuh_manager_rule_exclude)
      - [Default value](#default-value-40)
    - [wazuh\_manager\_ruleset](#wazuh_manager_ruleset)
      - [Default value](#default-value-41)
    - [wazuh\_manager\_sca](#wazuh_manager_sca)
      - [Default value](#default-value-42)
    - [wazuh\_manager\_sources\_installation](#wazuh_manager_sources_installation)
      - [Default value](#default-value-43)
    - [wazuh\_manager\_syscheck](#wazuh_manager_syscheck)
      - [Default value](#default-value-44)
    - [wazuh\_manager\_syscollector](#wazuh_manager_syscollector)
      - [Default value](#default-value-45)
    - [wazuh\_manager\_syslog\_outputs](#wazuh_manager_syslog_outputs)
      - [Default value](#default-value-46)
    - [wazuh\_manager\_version](#wazuh_manager_version)
      - [Default value](#default-value-47)
    - [wazuh\_manager\_vulnerability\_detector](#wazuh_manager_vulnerability_detector)
      - [Default value](#default-value-48)
  - [Vault variables](#vault-variables)
    - [vars/agentless\_creds.yml](#varsagentless_credsyml)
    - [vars/wazuh\_api\_creds.yml](#varswazuh_api_credsyml)
    - [vars/authd\_pass.yml](#varsauthd_passyml)
  - [\`\`\`](#)
  - [Discovered Tags](#discovered-tags)
  - [Dependencies](#dependencies)
  - [License and copyright](#license-and-copyright)
    - [Based on previous work from dj-wasabi](#based-on-previous-work-from-dj-wasabi)
    - [Modified by Wazuh](#modified-by-wazuh)

---

Requirements
------------

This role will work on:
 * Red Hat
 * CentOS
 * Fedora
 * Debian
 * Ubuntu

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: wazuh-server.example.com
      roles:
         - { role: ansible-wazuh-server }

Default config
--------------

### defaults/main.yml
```
---
wazuh_manager_fqdn: "wazuh-server"

wazuh_manager_config:
  json_output: 'yes'
  alerts_log: 'yes'
  logall: 'no'
  authd:
    enable: false
  email_notification: no
  mail_to:
    - admin@example.net
  mail_smtp_server: localhost
  mail_from: wazuh-server@example.com
  syscheck:
    frequency: 43200
    scan_on_start: 'yes'
    ignore:
      - /etc/mtab
      - /etc/mnttab
      - /etc/hosts.deny
      - /etc/mail/statistics
      - /etc/random-seed
      - /etc/random.seed
      - /etc/adjtime
      - /etc/httpd/logs
      - /etc/utmpx
      - /etc/wtmpx
      - /etc/cups/certs
      - /etc/dumpdates
      - /etc/svc/volatile
    no_diff:
      - /etc/ssl/private.key
    directories:
      - dirs: /etc,/usr/bin,/usr/sbin
        checks: 'check_all="yes"'
      - dirs: /bin,/sbin
        checks: 'check_all="yes"'
  rootcheck:
    frequency: 43200
  openscap:
    timeout: 1800
    interval: '1d'
    scan_on_start: 'yes'
  log_level: 1
  email_level: 12
  localfiles:
    - format: 'syslog'
      location: '/var/log/messages'
    - format: 'syslog'
      location: '/var/log/secure'
    - format: 'command'
      command: 'df -P'
      frequency: '360'
    - format: 'full_command'
      command: 'netstat -tln | grep -v 127.0.0.1 | sort'
      frequency: '360'
    - format: 'full_command'
      command: 'last -n 20'
      frequency: '360'
  globals:
    - '127.0.0.1'
    - '192.168.2.1'
  connection:
    - type: 'secure'
      port: '1514'
      protocol: 'tcp'
  commands:
    - name: 'disable-account'
      executable: 'disable-account.sh'
      expect: 'user'
      timeout_allowed: 'yes'
    - name: 'restart-ossec'
      executable: 'restart-ossec.sh'
      expect: ''
      timeout_allowed: 'no'
    - name: 'firewall-drop'
      executable: 'firewall-drop.sh'
      expect: 'srcip'
      timeout_allowed: 'yes'
    - name: 'host-deny'
      executable: 'host-deny.sh'
      expect: 'srcip'
      timeout_allowed: 'yes'
    - name: 'route-null'
      executable: 'route-null.sh'
      expect: 'srcip'
      timeout_allowed: 'yes'
    - name: 'win_route-null'
      executable: 'route-null.cmd'
      expect: 'srcip'
      timeout_allowed: 'yes'
  active_responses:
    - command: 'host-deny'
      location: 'local'
      level: 6
      timeout: 600

#### Custom variables:
You can create a YAML file and change the default variables for this role, to later using it with `-e` option in `ansible-playbooks`, for example:

```
---
wazuh_manager_fqdn: "wazuh-server"

wazuh_manager_config:
  email_notification: yes
  mail_to:
    - myadmin@mydomain.com
  mail_smtp_server: mysmtp.mydomain.com
```

## Default Variables

This role has some variables which you can or need to override.

### agent_groups

#### Default value

```YAML
agent_groups: []
```

### wazuh_custom_packages_installation_manager_deb_url

#### Default value

```YAML
wazuh_custom_packages_installation_manager_deb_url: https://s3-us-west-1.amazonaws.com/packages-dev.wazuh.com/
```

### wazuh_custom_packages_installation_manager_enabled

#### Default value

```YAML
wazuh_custom_packages_installation_manager_enabled: false
```

### wazuh_custom_packages_installation_manager_rpm_url

#### Default value

```YAML
wazuh_custom_packages_installation_manager_rpm_url: https://s3-us-west-1.amazonaws.com/packages-dev.wazuh.com/
```

### wazuh_dir

#### Default value

```YAML
wazuh_dir: /var/ossec
```

### wazuh_manager_agent_disconnection_time

#### Default value

```YAML
wazuh_manager_agent_disconnection_time: 20s
```

### wazuh_manager_agents_disconnection_alert_time

#### Default value

```YAML
wazuh_manager_agents_disconnection_alert_time: 100s
```

### wazuh_manager_alerts_log

#### Default value

```YAML
wazuh_manager_alerts_log: yes
```

### wazuh_manager_api

#### Default value

```YAML
wazuh_manager_api:
  bind_addr: 0.0.0.0
  port: 55000
  behind_proxy_server: false
  https: true
  https_key: api/configuration/ssl/server.key
  https_cert: api/configuration/ssl/server.crt
  https_use_ca: false
  https_ca: api/configuration/ssl/ca.crt
  logging_level: info
  logging_path: logs/api.log
  cors: false
  cors_source_route: '*'
  cors_expose_headers: '*'
  cors_allow_headers: '*'
  cors_allow_credentials: false
  cache: true
  cache_time: 0.750
  access_max_login_attempts: 5
  access_block_time: 300
  access_max_request_per_minute: 300
  drop_privileges: true
  experimental_features: false
  remote_commands_localfile: true
  remote_commands_localfile_exceptions: []
  remote_commands_wodle: true
  remote_commands_wodle_exceptions: []
```

### wazuh_manager_authd

#### Default value

```YAML
wazuh_manager_authd:
  enable: true
  port: 1515
  use_source_ip: no
  force:
    enabled: yes
    key_mismatch: yes
    disconnected_time: 1h
    after_registration_time: 1h
  purge: yes
  use_password: no
  ciphers: HIGH:!ADH:!EXP:!MD5:!RC4:!3DES:!CAMELLIA:@STRENGTH
  ssl_agent_ca:
  ssl_verify_host: no
  ssl_manager_cert: sslmanager.cert
  ssl_manager_key: sslmanager.key
  ssl_auto_negotiate: no
```

### wazuh_manager_ciscat

#### Default value

```YAML
wazuh_manager_ciscat:
  disable: yes
  install_java: yes
  timeout: 1800
  interval: 1d
  scan_on_start: yes
  java_path: /usr/lib/jvm/java-1.8.0-openjdk-amd64/jre/bin
  ciscat_path: wodles/ciscat
```

### wazuh_manager_cluster

#### Default value

```YAML
wazuh_manager_cluster:
  disable: yes
  name: wazuh
  node_name: manager_01
  node_type: master
  key: ugdtAnd7Pi9myP7CVts4qZaZQEQcRYZa
  port: '1516'
  bind_addr: 0.0.0.0
  nodes:
    - manager
  hidden: no
```

### wazuh_manager_commands

#### Default value

```YAML
wazuh_manager_commands:
  - name: disable-account
    executable: disable-account
    timeout_allowed: yes
  - name: restart-wazuh
    executable: restart-wazuh
  - name: firewall-drop
    executable: firewall-drop
    expect: srcip
    timeout_allowed: yes
  - name: host-deny
    executable: host-deny
    timeout_allowed: yes
  - name: route-null
    executable: route-null
    timeout_allowed: yes
  - name: win_route-null
    executable: route-null.exe
    timeout_allowed: yes
  - name: netsh
    executable: netsh.exe
    timeout_allowed: yes
```

### wazuh_manager_config_defaults

#### Default value

```YAML
wazuh_manager_config_defaults:
  repo: '{{ wazuh_repo }}'
  json_output: '{{ wazuh_manager_json_output }}'
  alerts_log: '{{ wazuh_manager_alerts_log }}'
  logall: '{{ wazuh_manager_logall }}'
  logall_json: '{{ wazuh_manager_logall_json }}'
  log_format: '{{ wazuh_manager_log_format }}'
  api: '{{ wazuh_manager_api }}'
  cluster: '{{ wazuh_manager_cluster }}'
  connection: '{{ wazuh_manager_connection }}'
  authd: '{{ wazuh_manager_authd }}'
  email_notification: '{{ wazuh_manager_email_notification }}'
  mail_to: '{{ wazuh_manager_mailto }}'
  mail_smtp_server: '{{ wazuh_manager_email_smtp_server }}'
  mail_from: '{{ wazuh_manager_email_from }}'
  mail_maxperhour: '{{ wazuh_manager_email_maxperhour }}'
  mail_queue_size: '{{ wazuh_manager_email_queue_size }}'
  email_log_source: '{{ wazuh_manager_email_log_source }}'
  extra_emails: '{{ wazuh_manager_extra_emails }}'
  reports: '{{ wazuh_manager_reports}}'
  syscheck: '{{ wazuh_manager_syscheck }}'
  rootcheck: '{{ wazuh_manager_rootcheck }}'
  openscap: '{{ wazuh_manager_openscap }}'
  cis_cat: '{{ wazuh_manager_ciscat }}'
  osquery: '{{ wazuh_manager_osquery }}'
  syscollector: '{{ wazuh_manager_syscollector }}'
  sca: '{{ wazuh_manager_sca }}'
  vulnerability_detector: '{{ wazuh_manager_vulnerability_detector }}'
  log_level: '{{ wazuh_manager_log_level }}'
  email_level: '{{ wazuh_manager_email_level }}'
  localfiles: '{{ wazuh_manager_localfiles }}'
  globals: '{{ wazuh_manager_globals }}'
  commands: '{{ wazuh_manager_commands }}'
  ruleset: '{{ wazuh_manager_ruleset }}'
  rule_exclude: '{{ wazuh_manager_rule_exclude }}'
  syslog_outputs: '{{ wazuh_manager_syslog_outputs }}'
  integrations: '{{ wazuh_manager_integrations }}'
  monitor_aws: '{{ wazuh_manager_monitor_aws }}'
  labels: '{{ wazuh_manager_labels }}'
  agents_disconnection_time: '{{ wazuh_manager_agent_disconnection_time }}'
  agents_disconnection_alert_time: '{{ wazuh_manager_agents_disconnection_alert_time
    }}'
```

### wazuh_manager_config_overlay

#### Default value

```YAML
wazuh_manager_config_overlay: true
```

### wazuh_manager_connection

#### Default value

```YAML
wazuh_manager_connection:
  - type: secure
    port: '1514'
    protocol: tcp
    queue_size: 131072
```

### wazuh_manager_email_from

#### Default value

```YAML
wazuh_manager_email_from: wazuh@example.wazuh.com
```

### wazuh_manager_email_level

#### Default value

```YAML
wazuh_manager_email_level: 12
```

### wazuh_manager_email_log_source

#### Default value

```YAML
wazuh_manager_email_log_source: alerts.log
```

### wazuh_manager_email_maxperhour

#### Default value

```YAML
wazuh_manager_email_maxperhour: 12
```

### wazuh_manager_email_notification

#### Default value

```YAML
wazuh_manager_email_notification: no
```

### wazuh_manager_email_queue_size

#### Default value

```YAML
wazuh_manager_email_queue_size: 131072
```

### wazuh_manager_email_smtp_server

#### Default value

```YAML
wazuh_manager_email_smtp_server: smtp.example.wazuh.com
```

### wazuh_manager_extra_emails

#### Default value

```YAML
wazuh_manager_extra_emails:
  - enable: false
    mail_to: recipient@example.wazuh.com
    format: full
    level: 7
    event_location:
    group:
    do_not_delay: false
    do_not_group: false
    rule_id:
```

### wazuh_manager_fqdn

#### Default value

```YAML
wazuh_manager_fqdn: wazuh-server
```

### wazuh_manager_globals

#### Default value

```YAML
wazuh_manager_globals:
  - 127.0.0.1
  - ^localhost.localdomain$
  - 127.0.0.53
```

### wazuh_manager_integrations

#### Default value

```YAML
wazuh_manager_integrations:
  - name:
    hook_url: <hook_url>
    alert_level: 10
    alert_format: json
    rule_id:
  - name:
    api_key: <api_key>
    alert_level: 12
```

### wazuh_manager_json_output

#### Default value

```YAML
wazuh_manager_json_output: yes
```

### wazuh_manager_labels

#### Default value

```YAML
wazuh_manager_labels:
  enable: false
  list:
    - key: Env
      value: Production
```

### wazuh_manager_localfiles

#### Default value

```YAML
wazuh_manager_localfiles:
  common:
    - format: command
      command: df -P
      frequency: '360'
    - format: full_command
      command: >
        netstat -tulpn | sed 's/\([[:alnum:]]\+\)\ \+[[:digit:]]\+\ \+[[:digit:]]\+\
        \+\(.*\):\([[:digit:]]*\)\ \+\([0-9\.\:\*]\+\).\+\
        \([[:digit:]]*\/[[:alnum:]\-]*\).*/\1 \2 == \3 == \4 \5/' | sort -k 4 -g |
        sed 's/ == \(.*\) ==/:\1/' | sed 1,2d
      alias: netstat listening ports
      frequency: '360'
    - format: full_command
      command: last -n 20
      frequency: '360'
    - format: syslog
      location: '{{ wazuh_dir }}/logs/active-responses.log'
  debian:
    - format: syslog
      location: /var/log/auth.log
    - format: syslog
      location: /var/log/syslog
    - format: syslog
      location: /var/log/dpkg.log
    - format: syslog
      location: /var/log/kern.log
  centos:
    - format: syslog
      location: /var/log/messages
    - format: syslog
      location: /var/log/secure
    - format: syslog
      location: /var/log/maillog
    - format: audit
      location: /var/log/audit/audit.log
```

### wazuh_manager_log_format

#### Default value

```YAML
wazuh_manager_log_format: plain
```

### wazuh_manager_log_level

#### Default value

```YAML
wazuh_manager_log_level: 3
```

### wazuh_manager_logall

#### Default value

```YAML
wazuh_manager_logall: no
```

### wazuh_manager_logall_json

#### Default value

```YAML
wazuh_manager_logall_json: no
```

### wazuh_manager_mailto

#### Default value

```YAML
wazuh_manager_mailto:
  - admin@example.net
```

### wazuh_manager_monitor_aws

#### Default value

```YAML
wazuh_manager_monitor_aws:
  disabled: yes
  interval: 10m
  run_on_start: yes
  skip_on_error: yes
  s3:
    - name:
      bucket_type:
      path:
      only_logs_after:
      access_key:
      secret_key:
```

### wazuh_manager_openscap

#### Default value

```YAML
wazuh_manager_openscap:
  disable: yes
  timeout: 1800
  interval: 1d
  scan_on_start: yes
```

### wazuh_manager_osquery

#### Default value

```YAML
wazuh_manager_osquery:
  disable: yes
  run_daemon: yes
  log_path: /var/log/osquery/osqueryd.results.log
  config_path: /etc/osquery/osquery.conf
  ad_labels: yes
```

### wazuh_manager_package_state

#### Default value

```YAML
wazuh_manager_package_state: present
```

### wazuh_manager_reports

#### Default value

```YAML
wazuh_manager_reports:
  - enable: false
    category: syscheck
    title: 'Daily report: File changes'
    email_to: recipient@example.wazuh.com
    location:
    group:
    rule:
    level:
    srcip:
    user:
    showlogs:
```

### wazuh_manager_rootcheck

#### Default value

```YAML
wazuh_manager_rootcheck:
  frequency: 43200
```

### wazuh_manager_rule_exclude

#### Default value

```YAML
wazuh_manager_rule_exclude:
  - 0215-policy_rules.xml
```

### wazuh_manager_ruleset

#### Default value

```YAML
wazuh_manager_ruleset:
  rules_path: custom_ruleset/rules/
  decoders_path: custom_ruleset/decoders/
  cdb_lists:
    - audit-keys
    - security-eventchannel
    - amazon/aws-eventnames
```

### wazuh_manager_sca

#### Default value

```YAML
wazuh_manager_sca:
  enabled: yes
  scan_on_start: yes
  interval: 12h
  skip_nfs: yes
  day: ''
  wday: ''
  time: ''
```

### wazuh_manager_sources_installation

#### Default value

```YAML
wazuh_manager_sources_installation:
  enabled: false
  branch: v4.3.9
  user_language: en
  user_no_stop: y
  user_install_type: server
  user_dir: /var/ossec
  user_delete_dir:
  user_enable_active_response:
  user_enable_syscheck: y
  user_enable_rootcheck: y
  user_enable_openscap: n
  user_enable_authd: y
  user_generate_authd_cert:
  user_update: y
  user_binaryinstall:
  user_enable_email: n
  user_auto_start: y
  user_email_address:
  user_email_smpt:
  user_enable_syslog: n
  user_white_list: n
  user_ca_store:
  threads: '2'
```

### wazuh_manager_syscheck

#### Default value

```YAML
wazuh_manager_syscheck:
  disable: no
  frequency: 43200
  scan_on_start: yes
  auto_ignore: no
  ignore:
    - /etc/mtab
    - /etc/hosts.deny
    - /etc/mail/statistics
    - /etc/random-seed
    - /etc/random.seed
    - /etc/adjtime
    - /etc/httpd/logs
    - /etc/utmpx
    - /etc/wtmpx
    - /etc/cups/certs
    - /etc/dumpdates
    - /etc/svc/volatile
  ignore_linux_type:
    - .log$|.swp$
  no_diff:
    - /etc/ssl/private.key
  directories:
    - dirs: /etc,/usr/bin,/usr/sbin
      checks: ''
    - dirs: /bin,/sbin,/boot
      checks: ''
  auto_ignore_frequency:
    frequency: frequency="10"
    timeframe: timeframe="3600"
    value: no
  skip_nfs: yes
  skip_dev: yes
  skip_proc: yes
  skip_sys: yes
  process_priority: 10
  max_eps: 100
  sync_enabled: yes
  sync_interval: 5m
  sync_max_interval: 1h
  sync_max_eps: 10
```

### wazuh_manager_syscollector

#### Default value

```YAML
wazuh_manager_syscollector:
  disable: no
  interval: 1h
  scan_on_start: yes
  hardware: yes
  os: yes
  network: yes
  packages: yes
  ports_no: yes
  processes: yes
```

### wazuh_manager_syslog_outputs

#### Default value

```YAML
wazuh_manager_syslog_outputs:
  - server:
    port:
    format:
```

### wazuh_manager_version

#### Default value

```YAML
wazuh_manager_version: 4.3.9
```

### wazuh_manager_vulnerability_detector

#### Default value

```YAML
wazuh_manager_vulnerability_detector:
  enabled: no
  interval: 5m
  run_on_start: yes
  providers:
    - enabled: no
      os:
        - trusty
        - xenial
        - bionic
      update_interval: 1h
      name: '"canonical"'
    - enabled: no
      os:
        - wheezy
        - stretch
        - jessie
        - buster
      update_interval: 1h
      name: '"debian"'
    - enabled: no
      update_from_year: '2010'
      update_interval: 1h
      name: '"redhat"'
    - enabled: no
      update_from_year: '2010'
      update_interval: 1h
      name: '"nvd"'
```

Vault variables
----------------

### vars/agentless_creds.yml
This file has the agenless credentials.
```
---
 agentless_creds:
 - type: ssh_integrity_check_linux
   frequency: 3600
   host: root@example.net
   state: periodic
   arguments: '/bin /etc/ /sbin'
   passwd: qwerty
```

### vars/wazuh_api_creds.yml
This file has user and password created in httpasswd format.
```
---
wazuh_api_user:
  - "foo:$apr1$/axqZYWQ$Xo/nz/IG3PdwV82EnfYKh/"
```

### vars/authd_pass.yml
This file has the password to be used for the authd daemon.
```
---
authd_pass: foobar

## Discovered Tags

**_config_**

**_config_api_users_**

**_init_**

**_manager_**

**_molecule-idempotence-notest_**

**_rules_**


## Dependencies

None.

## License and copyright

WAZUH Copyright (C) 2016, Wazuh Inc. (License GPLv3)

### Based on previous work from dj-wasabi

 - https://github.com/dj-wasabi/ansible-ossec-server

### Modified by Wazuh

The playbooks have been modified by Wazuh, including some specific requirements, templates and configuration to improve integration with Wazuh ecosystem.
