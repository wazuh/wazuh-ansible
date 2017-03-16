## Install Ansible (server)

```
Debian
sudo apt-get install ansible

CentOS
sudo yum install ansible (EPEL)
```

## Generate keys

If you do not already have an SSH key pair that you would like to use for Ansible administration, we can create one now on your Ansible, locate in OSSEC Manager host and run:

```
$ ssh-keygen
```

Choose ~/.ssh/id_rsa_ansible as output.

Enable ssh-agent and register de key:

```
$ eval "$(ssh-agent -s)"
$ ssh-add ~/.ssh/id_rsa_ansible
```

Copy ~/.ssh/id_rsa_ansible.pub content into the .ssh/authorized_keys host where you want to deploy OSSEC Agents in.


## Configuring Ansible Hosts

Open the file with root privileges:

```
$ sudo nano /etc/ansible/hosts
```

Add ossec hosts:

```
[wazuh-manager]
10.0.0.51

[wazuh-agent]
10.0.0.123
10.0.0.122
10.0.0.121

[elk]
10.0.0.124
```

## Install roles/playbooks

```
cd ~
git clone https://github.com/wazuh/ossec-playbook/
cp -pr ossec-playbook/* /etc/ansible/roles/
```


## Run the playbook

Create in your home o preferred folder the file agent.yml with the content:

```
- hosts: all:!ossec-manager
  roles:
     - { role: ansible-wazuh-agent, ossec_server_ip: 10.0.0.51 }
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

Run the playbbok for an agent:


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
    - hosts: elk
        - ansible-role-elk

```

### Created by

Github: https://github.com/dj-wasabi/ansible-ossec-server

mail: ikben [ at ] werner-dijkerman . nl

Modificated by Wazuh
