# wazuh-ansible

## Example Playbooks

This directory contains usage example for different deployment scenarios of the Wazuh stack.

### Requirements

To execute these playbooks you require a target host and a [controller] machine to deploy the playbooks. For demo purposes these can be on the same machine by using virtual machines o docker containers.

Repository ships with a [poetry] project file which can be used to quickly provide a python virtual environment with the required ansible dependencies to run these playbooks. You can execute `poetry install` and `poetry shell` to kickstart a virtual environment.

There's also an example playbook called `wazuh-docker-lab.yml` which shows how to create a docker network and multiple containers used with the example playbooks and the docker [connection plugin] for ansible.

Create containers: `ansible-playbook -v wazuh-docker-lab.yml`

Deploy distributed Elastic example: `ansible-playbook -c docker -i 'es-node01,es-node02,es-node03,es-kib01,wz-mgr01' wazuh-elastic_stack-distributed.yml`

### Elastic stack

For all software components in a single host:
 - `wazuh-elastic-single.yml`
 - `wazuh-manager-single.yml`
 - `wazuh-kibana-single.yml`

or simply `wazuh-all-in-one.yml` will run all these at once.

The distributed example using x-pack is little more involved, as it requires the following resolvable hosts:

  - es-node01
  - es-node02
  - es-node03
  - es-kib01
  - wz-mgr01

this example can be found at `wazuh-elastic_stack-distributed.yml`.

### OpenDistro

Similarly, for all software components in a single host:
 - `wazuh-elastic-single.yml`
 - `wazuh-manager-single.yml`
 - `wazuh-kibana-single.yml`

or use the `wazuh-odfe-all-in-one.yml` playbook.

Please note that OpenDistro role is more demanding regarding certificate chain, host and domain name, so it's advised to take a look everything is correctly setup or just use the distributed docker lab.



[controller]: https://docs.ansible.com/ansible/latest/network/getting_started/basic_concepts.html
[poetry]: (https://python-poetry.org/)
[connection plugin]: (https://docs.ansible.com/ansible/2.8/plugins/connection/docker.html)
