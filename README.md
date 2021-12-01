# wazuh-ansible

Install Ansible, link is
`https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html`

Once Ansible is installed, 

`$ cd /etc/ansible/roles`

`$ git clone git@github.com:auasad/wazuh-ansible.git`

`$ cd /etc/ansible/roles/wazuh-ansible/playbooks`

`$ ansible-playbook wazuh-elastic_stack-single.yml -b -K`

It will prompt for the root password of your machine, provide that,
then will prompt for the IP Address of the node for the Wazuh SOC installation, when the installation is finished, type in your browser;

http://ip_address:5601/
