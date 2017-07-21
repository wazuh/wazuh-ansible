## Install Ansible

```
Debian
sudo apt-get install ansible

CentOS
sudo yum install ansible (EPEL)
```

## Generate keys

If you do not already have an SSH key pair that you would like to use for Ansible administration, we can create one now on your Ansible, locate in Wazuh Manager host and run:

```
$ ssh-keygen
```

Choose ~/.ssh/id_rsa_ansible as output.

Enable ssh-agent and register de key:

```
$ eval "$(ssh-agent -s)"
$ ssh-add ~/.ssh/id_rsa_ansible
```

Copy ~/.ssh/id_rsa_ansible.pub content into the .ssh/authorized_keys host where you want to deploy Wazuh Agents in.


## Configuring Ansible Hosts

Open the file with root privileges:

```
$ sudo nano /etc/ansible/hosts
```

Add destination hosts:

```
[wazuh-manager]
10.0.0.51

[wazuh-agent]
10.0.0.123
10.0.0.122
10.0.0.121

[elastic-stack]
10.0.0.124
```

## Install roles/playbooks

```
cd ~
git clone https://github.com/wazuh/wazuh-ansible/
cp -pr wazuh-playbook/* /etc/ansible/roles/
```


## Run the playbook

Create in your home o preferred folder the file agent.yml with the content:

```
- hosts: all:!wazuh-manager
  roles:
     - { role: ansible-wazuh-agent, wazuh_manager_ip: 10.0.0.51 }
```

and other file with wazuh-manager.yml with the content:

```
- hosts: wazuh-manager
  roles:
    - role: ansible-wazuh-server
    - role: ansible-role-filebeat
```

Run the playbook for a manager

```
$ ansible-playbook wazuh-manager.yml -e"@vars.yml"
```

Run the playbook for an agent:


```
$ ansible-playbook wazuh-agent.yml -e"@vars.yml"
```


## Example Playbook

```
    - hosts: wazuh-agents
      roles:
        - ansible-wazuh-agent
    - hots: wazuh-manager
        - ansible-wazuh-manager
        - ansible-role-filebeat
    - hosts: elasticsearch
        - ansible-role-elasticsearch

```

### Based on previous work from dj-wasabi

https://github.com/dj-wasabi/ansible-ossec-server

### Modified by Wazuh

The playbooks have been modified by Wazuh, including some specific requirements, templates and configuration to improve integration with Wazuh ecosystem.
