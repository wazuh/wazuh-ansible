# Ansible Playbook - Wazuh agent

Installing, deploying and configuring Wazuh Agent.

## Table of content

- [Default Variables](#default-variables)
  - [api_pass](#api_pass)
  - [authd_pass](#authd_pass)
  - [wazuh_agent_active_response](#wazuh_agent_active_response)
  - [wazuh_agent_address](#wazuh_agent_address)
  - [wazuh_agent_api_validate](#wazuh_agent_api_validate)
  - [wazuh_agent_authd](#wazuh_agent_authd)
  - [wazuh_agent_cis_cat](#wazuh_agent_cis_cat)
  - [wazuh_agent_client_buffer](#wazuh_agent_client_buffer)
  - [wazuh_agent_config_defaults](#wazuh_agent_config_defaults)
  - [wazuh_agent_config_overlay](#wazuh_agent_config_overlay)
  - [wazuh_agent_enrollment](#wazuh_agent_enrollment)
  - [wazuh_agent_labels](#wazuh_agent_labels)
  - [wazuh_agent_localfiles](#wazuh_agent_localfiles)
  - [wazuh_agent_log_format](#wazuh_agent_log_format)
  - [wazuh_agent_nat](#wazuh_agent_nat)
  - [wazuh_agent_nolog_sensible](#wazuh_agent_nolog_sensible)
  - [wazuh_agent_openscap](#wazuh_agent_openscap)
  - [wazuh_agent_osquery](#wazuh_agent_osquery)
  - [wazuh_agent_rootcheck](#wazuh_agent_rootcheck)
  - [wazuh_agent_sca](#wazuh_agent_sca)
  - [wazuh_agent_sources_installation](#wazuh_agent_sources_installation)
  - [wazuh_agent_syscheck](#wazuh_agent_syscheck)
  - [wazuh_agent_syscollector](#wazuh_agent_syscollector)
  - [wazuh_agent_version](#wazuh_agent_version)
  - [wazuh_agent_yum_lock_timeout](#wazuh_agent_yum_lock_timeout)
  - [wazuh_api_reachable_from_agent](#wazuh_api_reachable_from_agent)
  - [wazuh_auto_restart](#wazuh_auto_restart)
  - [wazuh_crypto_method](#wazuh_crypto_method)
  - [wazuh_custom_packages_installation_agent_deb_url](#wazuh_custom_packages_installation_agent_deb_url)
  - [wazuh_custom_packages_installation_agent_enabled](#wazuh_custom_packages_installation_agent_enabled)
  - [wazuh_custom_packages_installation_agent_rpm_url](#wazuh_custom_packages_installation_agent_rpm_url)
  - [wazuh_dir](#wazuh_dir)
  - [wazuh_managers](#wazuh_managers)
  - [wazuh_notify_time](#wazuh_notify_time)
  - [wazuh_profile_centos](#wazuh_profile_centos)
  - [wazuh_profile_ubuntu](#wazuh_profile_ubuntu)
  - [wazuh_time_reconnect](#wazuh_time_reconnect)
  - [wazuh_winagent_config](#wazuh_winagent_config)
- [Discovered Tags](#discovered-tags)
- [Dependencies](#dependencies)
- [License](#license)
- [Author](#author)

---

## OS Requirements

This role is compatible with:

* Red Hat

* CentOS

* Fedora

* Debian

* Ubuntu


## Playbook example

The following is an example of how this role can be used:

```yaml

- hosts: all:!wazuh-manager

roles:

- ansible-wazuh-agent

vars:

wazuh_managers:

- address: 127.0.0.1

port: 1514

protocol: tcp

api_port: 55000

api_proto: 'http'

api_user: 'ansible'

wazuh_agent_authd:

registration_address: 127.0.0.1

enable: true

port: 1515

ssl_agent_ca: null

ssl_auto_negotiate: 'no'

```


## Default Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):


### api_pass

#### Default Value

```YAML
api_pass: wazuh
```

### authd_pass

#### Default Value

```YAML
authd_pass: ''
```

### wazuh_agent_active_response

#### Default Value

```YAML
wazuh_agent_active_response:
  ar_disabled: no
  ca_store: '{{ wazuh_dir }}/etc/wpk_root.pem'
  ca_store_win: wpk_root.pem
  ca_verification: yes
```

### wazuh_agent_address

#### Default Value

```YAML
wazuh_agent_address: '{{ "any" if wazuh_agent_nat else ansible_default_ipv4.address
  }}'
```

### wazuh_agent_api_validate

#### Default Value

```YAML
wazuh_agent_api_validate: true
```

### wazuh_agent_authd

Collection with the settings to register an agent using authd.

#### Default Value

```YAML
wazuh_agent_authd:
  registration_address: 127.0.0.1
  enable: false
  port: 1515
  agent_name:
  groups: []
  ssl_agent_ca:
  ssl_agent_cert:
  ssl_agent_key:
  ssl_auto_negotiate: no
```

### wazuh_agent_cis_cat

#### Default Value

```YAML
wazuh_agent_cis_cat:
  disable: yes
  install_java: no
  timeout: 1800
  interval: 1d
  scan_on_start: yes
  java_path: wodles/java
  java_path_win: \\server\jre\bin\java.exe
  ciscat_path: wodles/ciscat
  ciscat_path_win: C:\cis-cat
```

### wazuh_agent_client_buffer

#### Default Value

```YAML
wazuh_agent_client_buffer:
  disable: no
  queue_size: '5000'
  events_per_sec: '500'
```

### wazuh_agent_config_defaults

#### Default Value

```YAML
wazuh_agent_config_defaults:
  repo: '{{ wazuh_repo }}'
  active_response: '{{ wazuh_agent_active_response }}'
  log_format: '{{ wazuh_agent_log_format }}'
  client_buffer: '{{ wazuh_agent_client_buffer }}'
  syscheck: '{{ wazuh_agent_syscheck }}'
  rootcheck: '{{ wazuh_agent_rootcheck }}'
  openscap: '{{ wazuh_agent_openscap }}'
  osquery: '{{ wazuh_agent_osquery }}'
  syscollector: '{{ wazuh_agent_syscollector }}'
  sca: '{{ wazuh_agent_sca }}'
  cis_cat: '{{ wazuh_agent_cis_cat }}'
  localfiles: '{{ wazuh_agent_localfiles }}'
  labels: '{{ wazuh_agent_labels }}'
  enrollment: '{{ wazuh_agent_enrollment }}'
```

### wazuh_agent_config_overlay

#### Default Value

```YAML
wazuh_agent_config_overlay: true
```

### wazuh_agent_enrollment

#### Default Value

```YAML
wazuh_agent_enrollment:
  enabled: yes
  manager_address: ''
  port: 1515
  agent_name: ''
  groups: ''
  agent_address: ''
  ssl_ciphers: HIGH:!ADH:!EXP:!MD5:!RC4:!3DES:!CAMELLIA:@STRENGTH
  server_ca_path: ''
  agent_certificate_path: ''
  agent_key_path: ''
  authorization_pass_path: '{{ wazuh_dir }}/etc/authd.pass'
  auto_method: no
  delay_after_enrollment: 20
  use_source_ip: no
```

### wazuh_agent_labels

#### Default Value

```YAML
wazuh_agent_labels:
  enable: false
  list:
    - key: Env
      value: Production
```

### wazuh_agent_localfiles

#### Default Value

```YAML
wazuh_agent_localfiles:
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
  linux:
    - format: syslog
      location: '{{ wazuh_dir }}/logs/active-responses.log'
    - format: full_command
      command: last -n 20
      frequency: '360'
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
  windows:
    - format: eventlog
      location: Application
    - format: eventchannel
      location: Security
      query: >
        "Event/System[EventID != 5145 and EventID != 5156 and EventID != 5447 and
        EventID != 4656 and EventID != 4658 and EventID != 4663 and
        EventID != 4660 and EventID != 4670 and EventID != 4690 and EventID != 4703
        and EventID != 4907]"
    - format: eventlog
      location: System
    - format: syslog
      location: active-response\active-responses.log
```

### wazuh_agent_log_format

#### Default Value

```YAML
wazuh_agent_log_format: plain
```

### wazuh_agent_nat

#### Default Value

```YAML
wazuh_agent_nat: false
```

### wazuh_agent_nolog_sensible

#### Default Value

```YAML
wazuh_agent_nolog_sensible: true
```

### wazuh_agent_openscap

#### Default Value

```YAML
wazuh_agent_openscap:
  disable: yes
  timeout: 1800
  interval: 1d
  scan_on_start: yes
```

### wazuh_agent_osquery

#### Default Value

```YAML
wazuh_agent_osquery:
  disable: yes
  run_daemon: yes
  bin_path_win: C:\Program Files\osquery\osqueryd
  log_path: /var/log/osquery/osqueryd.results.log
  log_path_win: C:\Program Files\osquery\log\osqueryd.results.log
  config_path: /etc/osquery/osquery.conf
  config_path_win: C:\Program Files\osquery\osquery.conf
  add_labels: yes
```

### wazuh_agent_rootcheck

#### Default Value

```YAML
wazuh_agent_rootcheck:
  frequency: 43200
```

### wazuh_agent_sca

#### Default Value

```YAML
wazuh_agent_sca:
  enabled: yes
  scan_on_start: yes
  interval: 12h
  skip_nfs: yes
  day: ''
  wday: ''
  time: ''
```

### wazuh_agent_sources_installation

#### Default Value

```YAML
wazuh_agent_sources_installation:
  enabled: false
  branch: v4.3.9
  user_language: y
  user_no_stop: y
  user_install_type: agent
  user_dir: /var/ossec
  user_delete_dir: y
  user_enable_active_response: y
  user_enable_syscheck: y
  user_enable_rootcheck: y
  user_enable_openscap: n
  user_enable_sca: y
  user_enable_authd: y
  user_generate_authd_cert: n
  user_update: y
  user_binaryinstall:
  user_agent_server_ip: YOUR_MANAGER_IP
  user_agent_server_name:
  user_agent_config_profile:
  user_ca_store: '{{ wazuh_dir }}/wpk_root.pem'
```

### wazuh_agent_syscheck

#### Default Value

```YAML
wazuh_agent_syscheck:
  frequency: 43200
  scan_on_start: yes
  auto_ignore: no
  win_audit_interval: 60
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
  ignore_win:
    - .log$|.htm$|.jpg$|.png$|.chm$|.pnf$|.evtx$
  no_diff:
    - /etc/ssl/private.key
  directories:
    - dirs: /etc,/usr/bin,/usr/sbin
      checks: ''
    - dirs: /bin,/sbin,/boot
      checks: ''
  win_directories:
    - dirs: '%WINDIR%'
      checks: recursion_level="0" restrict="regedit.exe$|system.ini$|win.ini$"
    - dirs: '%WINDIR%\SysNative'
      checks: >-
        recursion_level="0" restrict="at.exe$|attrib.exe$|cacls.exe$|cmd.exe$|eventcreate.exe$|ftp.exe$|lsass.exe$|
        net.exe$|net1.exe$|netsh.exe$|reg.exe$|regedt32.exe|regsvr32.exe|runas.exe|sc.exe|schtasks.exe|sethc.exe|subst.exe$"
    - dirs: '%WINDIR%\SysNative\drivers\etc%'
      checks: recursion_level="0"
    - dirs: '%WINDIR%\SysNative\wbem'
      checks: recursion_level="0" restrict="WMIC.exe$"
    - dirs: '%WINDIR%\SysNative\WindowsPowerShell\v1.0'
      checks: recursion_level="0" restrict="powershell.exe$"
    - dirs: '%WINDIR%\SysNative'
      checks: recursion_level="0" restrict="winrm.vbs$"
    - dirs: '%WINDIR%\System32'
      checks: >-
        recursion_level="0" restrict="at.exe$|attrib.exe$|cacls.exe$|cmd.exe$|eventcreate.exe$|ftp.exe$|lsass.exe$|net.exe$|net1.exe$|
        netsh.exe$|reg.exe$|regedit.exe$|regedt32.exe$|regsvr32.exe$|runas.exe$|sc.exe$|schtasks.exe$|sethc.exe$|subst.exe$"
    - dirs: '%WINDIR%\System32\drivers\etc'
      checks: recursion_level="0"
    - dirs: '%WINDIR%\System32\wbem'
      checks: recursion_level="0" restrict="WMIC.exe$"
    - dirs: '%WINDIR%\System32\WindowsPowerShell\v1.0'
      checks: recursion_level="0" restrict="powershell.exe$"
    - dirs: '%WINDIR%\System32'
      checks: recursion_level="0" restrict="winrm.vbs$"
    - dirs: '%PROGRAMDATA%\Microsoft\Windows\Start Menu\Programs\Startup'
      checks: realtime="yes"
  windows_registry:
    - key: HKEY_LOCAL_MACHINE\Software\Classes\batfile
    - key: HKEY_LOCAL_MACHINE\Software\Classes\cmdfile
    - key: HKEY_LOCAL_MACHINE\Software\Classes\comfile
    - key: HKEY_LOCAL_MACHINE\Software\Classes\exefile
    - key: HKEY_LOCAL_MACHINE\Software\Classes\piffile
    - key: HKEY_LOCAL_MACHINE\Software\Classes\AllFilesystemObjects
    - key: HKEY_LOCAL_MACHINE\Software\Classes\Directory
    - key: HKEY_LOCAL_MACHINE\Software\Classes\Folder
    - key: HKEY_LOCAL_MACHINE\Software\Classes\Protocols
      arch: both
    - key: HKEY_LOCAL_MACHINE\Software\Policies
      arch: both
    - key: HKEY_LOCAL_MACHINE\Security
    - key: HKEY_LOCAL_MACHINE\Software\Microsoft\Internet Explorer
      arch: both
    - key: HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services
    - key: HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\KnownDLLs
    - key: HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\SecurePipeServers\winreg
    - key: HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Run
      arch: both
    - key: HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\RunOnce
      arch: both
    - key: HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\RunOnceEx
    - key: HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\URL
      arch: both
    - key: HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies
      arch: both
    - key: HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\Windows
      arch: both
    - key: HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\Winlogon
      arch: both
    - key: HKEY_LOCAL_MACHINE\Software\Microsoft\Active Setup\Installed Components
      arch: both
  windows_registry_ignore:
    - key: HKEY_LOCAL_MACHINE\Security\Policy\Secrets
    - key: HKEY_LOCAL_MACHINE\Security\SAM\Domains\Account\Users
    - key: \Enum$
      type: sregex
```

### wazuh_agent_syscollector

#### Default Value

```YAML
wazuh_agent_syscollector:
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

### wazuh_agent_version

#### Default Value

```YAML
wazuh_agent_version: 4.3.9
```

### wazuh_agent_yum_lock_timeout

#### Default Value

```YAML
wazuh_agent_yum_lock_timeout: 30
```

### wazuh_api_reachable_from_agent

#### Default Value

```YAML
wazuh_api_reachable_from_agent: true
```

### wazuh_auto_restart

#### Default Value

```YAML
wazuh_auto_restart: yes
```

### wazuh_crypto_method

#### Default Value

```YAML
wazuh_crypto_method: aes
```

### wazuh_custom_packages_installation_agent_deb_url

#### Default Value

```YAML
wazuh_custom_packages_installation_agent_deb_url: ''
```

### wazuh_custom_packages_installation_agent_enabled

#### Default Value

```YAML
wazuh_custom_packages_installation_agent_enabled: false
```

### wazuh_custom_packages_installation_agent_rpm_url

#### Default Value

```YAML
wazuh_custom_packages_installation_agent_rpm_url: ''
```

### wazuh_dir

#### Default Value

```YAML
wazuh_dir: /var/ossec
```

### wazuh_managers

Collection of Wazuh Managers' IP address, port, and protocol used by the agent

#### Default Value

```YAML
wazuh_managers:
  - address: 127.0.0.1
    port: 1514
    protocol: tcp
    api_port: 55000
    api_proto: https
    api_user: wazuh
    max_retries: 5
    retry_interval: 5
    register: true
```

### wazuh_notify_time

#### Default Value

```YAML
wazuh_notify_time: '10'
```

### wazuh_profile_centos

#### Default Value

```YAML
wazuh_profile_centos: centos, centos7, centos7.6
```

### wazuh_profile_ubuntu

#### Default Value

```YAML
wazuh_profile_ubuntu: ubuntu, ubuntu18, ubuntu18.04
```

### wazuh_time_reconnect

#### Default Value

```YAML
wazuh_time_reconnect: '60'
```

### wazuh_winagent_config

#### Default Value

```YAML
wazuh_winagent_config:
  download_dir: C:\
  install_dir: C:\Program Files\ossec-agent\
  install_dir_x86: C:\Program Files (x86)\ossec-agent\
  auth_path: C:\Program Files\ossec-agent\agent-auth.exe
  auth_path_x86: C:\'Program Files (x86)'\ossec-agent\agent-auth.exe
  check_md5: true
  md5: eee54087d25a42ceb27ecf8ad562143f
```

## Discovered Tags

**_api_**

**_authd_**

**_config_**

**_init_**


## Dependencies

None.

## License

license (GPLv3)

# Copyright

WAZUH Copyright (C) 2016, Wazuh Inc.

## Author

Wazuh


### Based on previous work from dj-wasabi

- https://github.com/dj-wasabi/ansible-ossec-server

### Modified by Wazuh

The playbooks have been modified by Wazuh, including some specific requirements, templates and configuration to improve integration with Wazuh ecosystem.
