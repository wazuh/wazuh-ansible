Role Name
=========

This role will install the Wazuh server on a host.

Requirements
------------

This role will work on:
 * Red Hat
 * Debian


Role Variables
--------------

This role has some variables which you can or need to override.
```
ossec_server_config: []
ossec_agent_configs: []
api_user: []
```
Vault variables
----------------

### vars/agentless.yml
This file has the agenless c.
```
---
agentless_passlist:
  - host: wazuh@wazuh.com
    passwd: testpasswd
  - host: wazuh2@wazuh.com
    passwd: test2passwd
```

### templates/agentless.j2

In this template we create the file with the format .passlist that ossec needs.

```
{% for agentless in agentless_passlist %}
{{ agentless.host }}|{{ agentless.passwd }}
{% endfor %}
```

### tasks/main

In the main we import the variables included in the vault file agentless.yml, then we move to a temporal file the folder /var/ossec/agentless/.passlist_tmp and then encode to base64.

```
- name: Import agentless secret variable file
  include_vars: "agentless.yml"
  no_log: true

- name: Agentless Credentials
  template:
    src: agentless.j2
    dest: "/var/ossec/agentless/.passlist_tmp"
    owner: root
    group: root
    mode: 0644
  no_log: true
  when: agentless_passlist is defined

- name: Encode the secret
  shell: /usr/bin/base64 /var/ossec/agentless/.passlist_tmp > /var/ossec/agentless/.passlist && rm /var/ossec/agentless/.passlist_tmp
  when: agentless_passlist is defined
```

### vars/api_user.yml
This file has user and password created in httpasswd format.
```
---
user:
  - "wazuh:$apr1$XSwG938n$tDxKvaCBx5C/kdU2xXP3K."
  - "wazuh2:$apr1$XSwG938n$tDxKvaCBx5C/kdU2xXP3K."
```


### Example setup

Edit the vars file for the host which runs the ossec-server:
### host_vars/ossec-server
```
ossec_server_config:
  mail_to:
    - me@example.com
  mail_smtp_server: localhost
  mail_from: ossec@example.com
  frequency_check: 43200
  syscheck_scan_on_start: 'yes'
  ignore_files:
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
    - check_all: 'yes'
      dirs: /etc,/usr/bin,/usr/sbin
    - check_all: 'yes'
      dirs: /bin,/sbin
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
      protocol: 'udp'
  log_level: 1
  email_level: 12
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

ossec_agent_configs:
  - type: os
    type_value: linux
    frequency_check: 79200
    ignore_files:
      - /etc/mtab
      - /etc/mnttab
      - /etc/hosts.deny
      - /etc/mail/statistics
      - /etc/svc/volatile
    directories:
      - check_all: yes
        dirs: /etc,/usr/bin,/usr/sbin
      - check_all: yes
        dirs: /bin,/sbin
    localfiles:
      - format: 'syslog'
        location: '/var/log/messages'
      - format: 'syslog'
        location: '/var/log/secure'
      - format: 'syslog'
        location: '/var/log/maillog'
      - format: 'apache'
        location: '/var/log/httpd/error_log'
      - format: 'apache'
        location: '/var/log/httpd/access_log'
      - format: 'apache'
        location: '/var/ossec/logs/active-responses.log'
```

####ossec_server_config:
At first, there is the server configuration. Change it for your needs, as this default setup won't do any good for you. (You don't have access to use the mail.example.com mailhost. :-))


####ossec_agent_configs:
http://ossec-docs.readthedocs.org/en/latest/manual/agent/agent-configuration.html

There are 3 "types":
  * os
  * name
  * profile

In the above setup, the type is os. And this configuration is for the "linux" os. You can have several types configured in the host_vars file, so you can create all kind of different configs.

You can find here some more information about the ossec shared agent configuration: http://ossec-docs.readthedocs.org/en/latest/manual/syscheck/

#### <_role_>/vars/main.yml
nil

Dependencies
------------

No dependencies.

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: ossec-server.example.com
      roles:
         - { role: ansible-wazuh-manager }

License
-------

GPLv3

Author Information
------------------

Please send suggestion or pull requests to make this role better.

Github: https://github.com/dj-wasabi/ansible-ossec-server

mail: ikben [ at ] werner-dijkerman . nl

Modificated by **Wazuh**
