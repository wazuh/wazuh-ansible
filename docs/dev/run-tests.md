# How to run the tests

The Wazuh Ansible project has been developed to adhere to code quality and testing standards using the [Ansible Lint](https://ansible-lint.readthedocs.io/en/latest/) tool.

## Prerequisites

Before running the tests, ensure you have Ansible and Ansible Lint installed. You can install Ansible Lint via pip using the following command: `pip install ansible-lint`.

Additionally, you need to download the required Ansible collections specified in the `requirements.yml` file of the project. To install these collections, run: `ansible-galaxy collection install -r requirements.yml`.

## Running the Tests

To perform linting tests, execute the following command:

```bash
ansible-lint wazuh-agent.yml wazuh-aio.yml wazuh-distributed.yml .github/playbooks/gather_agent_logs.yml .github/playbooks/gather_central_logs.yml .
```

Example Output:

```bash
  $ ansible-lint wazuh-agent.yml wazuh-aio.yml wazuh-distributed.yml .github/playbooks/gather_agent_logs.yml .github/playbooks/gather_central_logs.yml .

  `WARNING Skipped installing collection dependencies due to running in offline mode.
  Passed: 0 failure(s), 0 warning(s) on 26 files. Profile 'production' was required, but only 'production' profile passed.`

  This command will run Ansible Lint on the specified playbook files, ensuring that the playbooks and roles follow best practices, patterns, and conventions recommended by the Ansible community.
```
