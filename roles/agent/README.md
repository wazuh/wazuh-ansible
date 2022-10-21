Ansible Playbook - Wazuh agent
==============================

Installing, deploying and configuring Wazuh Agent.

## Table of content

- [Ansible Playbook - Wazuh agent](#ansible-playbook---wazuh-agent)
  - [Table of content](#table-of-content)
  - [OS Requirements](#os-requirements)
  - [Playbook example](#playbook-example)
  - [Default Variables](#default-variables)
    - [api\_pass](#api_pass)
      - [Default value](#default-value)
    - [authd\_pass](#authd_pass)
      - [Default value](#default-value-1)
    - [wazuh\_agent\_active\_response](#wazuh_agent_active_response)
      - [Default value](#default-value-2)
    - [wazuh\_agent\_address](#wazuh_agent_address)
      - [Default value](#default-value-3)
    - [wazuh\_agent\_api\_validate](#wazuh_agent_api_validate)
      - [Default value](#default-value-4)
    - [wazuh\_agent\_authd](#wazuh_agent_authd)
      - [Default value](#default-value-5)
    - [wazuh\_agent\_cis\_cat](#wazuh_agent_cis_cat)
      - [Default value](#default-value-6)
    - [wazuh\_agent\_client\_buffer](#wazuh_agent_client_buffer)
      - [Default value](#default-value-7)
    - [wazuh\_agent\_config\_defaults](#wazuh_agent_config_defaults)
      - [Default value](#default-value-8)
    - [wazuh\_agent\_config\_overlay](#wazuh_agent_config_overlay)
      - [Default value](#default-value-9)
    - [wazuh\_agent\_enrollment](#wazuh_agent_enrollment)
      - [Default value](#default-value-10)
    - [wazuh\_agent\_labels](#wazuh_agent_labels)
      - [Default value](#default-value-11)
    - [wazuh\_agent\_localfiles](#wazuh_agent_localfiles)
      - [Default value](#default-value-12)
    - [wazuh\_agent\_log\_format](#wazuh_agent_log_format)
      - [Default value](#default-value-13)
    - [wazuh\_agent\_nat](#wazuh_agent_nat)
      - [Default value](#default-value-14)
    - [wazuh\_agent\_nolog\_sensible](#wazuh_agent_nolog_sensible)
      - [Default value](#default-value-15)
    - [wazuh\_agent\_openscap](#wazuh_agent_openscap)
      - [Default value](#default-value-16)
    - [wazuh\_agent\_osquery](#wazuh_agent_osquery)
      - [Default value](#default-value-17)
    - [wazuh\_agent\_rootcheck](#wazuh_agent_rootcheck)
      - [Default value](#default-value-18)
    - [wazuh\_agent\_sca](#wazuh_agent_sca)
      - [Default value](#default-value-19)
    - [wazuh\_agent\_sources\_installation](#wazuh_agent_sources_installation)
      - [Default value](#default-value-20)
    - [wazuh\_agent\_syscheck](#wazuh_agent_syscheck)
      - [Default value](#default-value-21)
    - [wazuh\_agent\_syscollector](#wazuh_agent_syscollector)
      - [Default value](#default-value-22)
    - [wazuh\_agent\_version](#wazuh_agent_version)
      - [Default value](#default-value-23)
    - [wazuh\_agent\_yum\_lock\_timeout](#wazuh_agent_yum_lock_timeout)
      - [Default value](#default-value-24)
    - [wazuh\_api\_reachable\_from\_agent](#wazuh_api_reachable_from_agent)
      - [Default value](#default-value-25)
    - [wazuh\_auto\_restart](#wazuh_auto_restart)
      - [Default value](#default-value-26)
    - [wazuh\_crypto\_method](#wazuh_crypto_method)
      - [Default value](#default-value-27)
    - [wazuh\_custom\_packages\_installation\_agent\_deb\_url](#wazuh_custom_packages_installation_agent_deb_url)
      - [Default value](#default-value-28)
    - [wazuh\_custom\_packages\_installation\_agent\_enabled](#wazuh_custom_packages_installation_agent_enabled)
      - [Default value](#default-value-29)
    - [wazuh\_custom\_packages\_installation\_agent\_rpm\_url](#wazuh_custom_packages_installation_agent_rpm_url)
      - [Default value](#default-value-30)
    - [wazuh\_dir](#wazuh_dir)
      - [Default value](#default-value-31)
    - [wazuh\_managers](#wazuh_managers)
      - [Default value](#default-value-32)
    - [wazuh\_notify\_time](#wazuh_notify_time)
      - [Default value](#default-value-33)
    - [wazuh\_profile\_centos](#wazuh_profile_centos)
      - [Default value](#default-value-34)
    - [wazuh\_profile\_ubuntu](#wazuh_profile_ubuntu)
      - [Default value](#default-value-35)
    - [wazuh\_time\_reconnect](#wazuh_time_reconnect)
      - [Default value](#default-value-36)
    - [wazuh\_winagent\_config](#wazuh_winagent_config)
      - [Default value](#default-value-37)
  - [Discovered Tags](#discovered-tags)
  - [Dependencies](#dependencies)
  - [License and copyright](#license-and-copyright)
    - [Based on previous work from dj-wasabi](#based-on-previous-work-from-dj-wasabi)
    - [Modified by Wazuh](#modified-by-wazuh)

---

OS Requirements
----------------

This role is compatible with:
 * Red Hat
 * CentOS
 * Fedora
 * Debian
 * Ubuntu

Playbook example
----------------

The following is an example of how this role can be used:

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

## Default Variables

### api_pass

#### Default value

```YAML
api_pass: wazuh
```

### authd_pass

#### Default value

```YAML
authd_pass: ''
```

### wazuh_agent_active_response

#### Default value

```YAML
wazuh_agent_active_response:
  ar_disabled: no
  ca_store: '{{ wazuh_dir }}/etc/wpk_root.pem'
  ca_store_win: wpk_root.pem
  ca_verification: yes
```

### wazuh_agent_address

#### Default value

```YAML
wazuh_agent_address: '{{ "any" if wazuh_agent_nat else ansible_default_ipv4.address
  }}'
```

### wazuh_agent_api_validate

#### Default value

```YAML
wazuh_agent_api_validate: true
```

### wazuh_agent_authd
Collection with the settings to register an agent using authd.

#### Default value

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

#### Default value

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

#### Default value

```YAML
wazuh_agent_client_buffer:
  disable: no
  queue_size: '5000'
  events_per_sec: '500'
```

### wazuh_agent_config_defaults

#### Default value

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

#### Default value

```YAML
wazuh_agent_config_overlay: true
```

### wazuh_agent_enrollment

#### Default value

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

#### Default value

```YAML
wazuh_agent_labels:
  enable: false
  list:
    - key: Env
      value: Production
```

### wazuh_agent_localfiles

#### Default value

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

#### Default value

```YAML
wazuh_agent_log_format: plain
```

### wazuh_agent_nat

#### Default value

```YAML
wazuh_agent_nat: false
```

### wazuh_agent_nolog_sensible

#### Default value

```YAML
wazuh_agent_nolog_sensible: true
```

### wazuh_agent_openscap

#### Default value

```YAML
wazuh_agent_openscap:
  disable: yes
  timeout: 1800
  interval: 1d
  scan_on_start: yes
```

### wazuh_agent_osquery

#### Default value

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

#### Default value

```YAML
wazuh_agent_rootcheck:
  frequency: 43200
```

### wazuh_agent_sca

#### Default value

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

#### Default value

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

#### Default value

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

#### Default value

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

#### Default value

```YAML
wazuh_agent_version: 4.3.9
```

### wazuh_agent_yum_lock_timeout

#### Default value

```YAML
wazuh_agent_yum_lock_timeout: 30
```

### wazuh_api_reachable_from_agent

#### Default value

```YAML
wazuh_api_reachable_from_agent: true
```

### wazuh_auto_restart

#### Default value

```YAML
wazuh_auto_restart: yes
```

### wazuh_crypto_method

#### Default value

```YAML
wazuh_crypto_method: aes
```

### wazuh_custom_packages_installation_agent_deb_url

#### Default value

```YAML
wazuh_custom_packages_installation_agent_deb_url: ''
```

### wazuh_custom_packages_installation_agent_enabled

#### Default value

```YAML
wazuh_custom_packages_installation_agent_enabled: false
```

### wazuh_custom_packages_installation_agent_rpm_url

#### Default value

```YAML
wazuh_custom_packages_installation_agent_rpm_url: ''
```

### wazuh_dir

#### Default value

```YAML
wazuh_dir: /var/ossec
```

### wazuh_managers
Collection of Wazuh Managers' IP address, port, and protocol used by the agent

#### Default value

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

#### Default value

```YAML
wazuh_notify_time: '10'
```

### wazuh_profile_centos

#### Default value

```YAML
wazuh_profile_centos: centos, centos7, centos7.6
```

### wazuh_profile_ubuntu

#### Default value

```YAML
wazuh_profile_ubuntu: ubuntu, ubuntu18, ubuntu18.04
```

### wazuh_time_reconnect

#### Default value

```YAML
wazuh_time_reconnect: '60'
```

### wazuh_winagent_config

#### Default value

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

## License and copyright

WAZUH Copyright (C) 2016, Wazuh Inc. (License GPLv3)

### Based on previous work from dj-wasabi

  - https://github.com/dj-wasabi/ansible-ossec-server

### Modified by Wazuh

The playbooks have been modified by Wazuh, including some specific requirements, templates and configuration to improve integration with Wazuh ecosystem.
