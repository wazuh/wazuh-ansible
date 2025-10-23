# Setting Up the Development Environment

Follow these steps to configure the development environment for Wazuh-Ansible.

Refer to the [Requirements](../ref/getting-started/requirements.md) section in the reference manual for detailed information on the installation and configuration prerequisites for Wazuh-Ansible.

## Toolchain for Deploying Wazuh with Ansible

- Ansible:
    Ensure Ansible 2.9 or newer is installed.

- Python:
    Python 3.6 or newer is recommended.

- Additional Required Tools:
  - Git: Required for cloning the repository and managing version control.
  - SSH: Needed for connecting to remote servers.

- Clone the [wazuh-ansible](https://github.com/wazuh/wazuh-ansible) repository and navigate to its directory.

  ```bash
    git clone --branch v6.0.0 https://github.com/wazuh/wazuh-ansible.git
  ```

- Install Ansible collections: use the `ansible-galaxy` command to install the required Ansible collections specified in the `requirements.yml` file.

  ```bash
    cd wazuh-ansible
    ansible-galaxy install -r requirements.yml
  ```

## Deployment

Do not forget to set up the inventory file (`inventory.ini`) to define your target hosts. This file should include the IP addresses or hostnames of the machines where you want to deploy Wazuh components. Check the [Configuration files](../ref/configuration/configuration-files.md) section for more details on how to configure the inventory file.

Ensure that the target nodes are accessible via SSH and have Python installed. You can verify connectivity by using the `ping` module for Linux/MacOS hosts or the `win_ping` module for Windows hosts.

Once these requirements are met, you can proceed to deploy Wazuh using Ansible. Please refer to the [Deployment](../ref/deployment.md) of the Reference manual for detailed instructions on how to deploy Wazuh using Ansible.

Example command to deploy Wazuh agents on target hosts:

```bash
  ansible-playbook -i inventory.ini wazuh-agent.yml
```
